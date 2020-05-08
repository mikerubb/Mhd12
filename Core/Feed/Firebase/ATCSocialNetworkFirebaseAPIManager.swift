//
//  ATCSocialNetworkFirebaseAPIManager.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 26/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class ATCSocialNetworkFirebaseAPIManager : ATCSocialNetworkAPIProtocol {

    func saveNewPost(user: ATCUser?, postComposer: ATCPostComposerState, completion: @escaping () -> Void) {
        let photos = postComposer.postMedia ?? []
        let newDocumentRef =  Firestore.firestore().collection("SocialNetwork_Posts").document()

        var photoURLs: [String] = []
        var uploadedPhotos = 0
        
        let reactionsDictionary: [String: Int] = [
             "like"            : 0,
             "angry"           : 0,
             "sad"             : 0,
             "surprised"       : 0,
             "laugh"           : 0,
             "cry"             : 0,
             "love"            : 0
        ]
        
        var dictionary: [String: Any] = [
            
            "postText"      : postComposer.postText ?? "" ,
            "location"      : postComposer.location ?? "",
            "createdAt"     : postComposer.date ?? Date(),
            "latitude"      : postComposer.latitude ?? 0,
            "longitude"     : postComposer.longitude ?? 0,
            "reactions"     : reactionsDictionary,
            "postComment"   : 0,
            "postLikes"     : 0
        ]
        
        if let user = user {
            dictionary["authorID"] = user.uid
        }
        
        
        if photos.count == 0 {
            dictionary["id"] = newDocumentRef.documentID
            newDocumentRef.setData(dictionary)
            completion()
            return
        }
        
        photos.forEach { (image) in
            self.uploadImage(image, completion: { (url) in
                if let urlString = url?.absoluteString {
                    print(urlString)
                    photoURLs.append(urlString)
                    
                }
                uploadedPhotos += 1
                if (uploadedPhotos == photos.count) {
                    dictionary["id"] = newDocumentRef.documentID
                    dictionary["postMedia"] = photoURLs
                    newDocumentRef.setData(dictionary)
                    completion()
                }
            })
        }
    }
    
    private func fetchReactions(user: ATCUser, completion: @escaping ([ATCPostReactionStatus]) -> Void) {
        let db = Firestore.firestore()
        let reactionRef = db.collection("socialnetwork_reactions")
        guard let loggedInUseruid = user.uid else { return }
        
        let reactionDoc = reactionRef.whereField("reactionAuthorID", isEqualTo: loggedInUseruid)
        var postreactionstatus: [ATCPostReactionStatus] = []
        
        reactionDoc.getDocuments { (snapshot, error) in
            if let _ = error {
                print("Some error")
                return
            }

            guard let querySnapshot = snapshot else { return }
            let documents = querySnapshot.documents
            if (documents.count == 0) {
                completion([])
            }
            for doc in documents {
                let data = doc.data()
                let newPostReactionStatus = ATCPostReactionStatus(jsonDict: data)
                postreactionstatus.append(newPostReactionStatus)

                if postreactionstatus.count == documents.count {
                    completion(postreactionstatus)
                }
            }
        }
    }

    func fetchNewsFeed(loggedInUser: ATCUser, completion: @escaping ([ATCPost]) -> Void) {
        let serialQueue = DispatchQueue(label: "com.iosAppTemplate.Queue")

        let db = Firestore.firestore()
        let ref = db.collection("SocialNetwork_Posts")

        guard let loggedInUseruid = loggedInUser.uid else { return }
        var loggedInUserPost: [ATCPost] = []
        var allSelfPosts: [ATCPost] = []

        let selfReference = ref.whereField("authorID", isEqualTo: loggedInUseruid).order(by: "createdAt", descending: true)
        var postReactionStatus : [ATCPostReactionStatus] = []

        self.fetchReactions(user: loggedInUser) { (postReactions) in
        postReactionStatus = postReactions
            print("Reaction count = \(postReactions.count)")

         // Fetching Self Posts
            selfReference.getDocuments { (snapshot, error) in
                if let _ = error {
                    return
                }
                print("Newsfeed reaction 2")
                guard let querySnapshot = snapshot else { return }
                    let docs = querySnapshot.documents
                
                    for doc in docs {
                        let data = doc.data()
                        let timeStamp = doc["createdAt"] as! Timestamp
                        let date = timeStamp.dateValue()
                        let newPost = ATCPost(jsonDict: data)

                        let id = newPost.id

                        postReactionStatus.contains(where: { (status) -> Bool in
                            if (status.postID == id) {
                                newPost.selectedReaction = status.reaction
                                return true
                            } else {
                                return false
                            }
                        })

                        newPost.createdAt = date
                        newPost.profileImage = loggedInUser.profilePictureURL ?? ""
                        newPost.postUserName = loggedInUser.fullName()
                        let reactions = newPost.postReactions
                        let reactionValues = Array(reactions.values)
                        let totalReactionCount = reactionValues.reduce(0, +)
                        newPost.postLikes = totalReactionCount
                        serialQueue.sync {
                            loggedInUserPost.append(newPost)
                        }
                        
                        if loggedInUserPost.count == docs.count {
                            allSelfPosts = loggedInUserPost
                        }
                    }

            // Fetching Friend's Posts
            let socialManager = ATCFirebaseSocialGraphManager()
            var friendPosts: [ATCPost] = []
            var friendsPostRetrieved: [ATCUser] = []

            //Fetching friends here
            print("Newsfeed reaction 3")
            socialManager.fetchFriends(viewer: loggedInUser) { (fetchedFriends) in

                let allfriends = fetchedFriends
                if (allfriends.count == 0) {
                    completion([])
                    return
                }
                for friend in allfriends {
                    guard let friendUID = friend.uid else { return }
                    let postsRef = ref.whereField("authorID", isEqualTo: friendUID).order(by: "createdAt", descending: true)
                    
                    postsRef.getDocuments(completion: { (querySnapshot, error) in
                        if let error = error {
                            print(error)
                            completion([])
                            return
                        }

                        guard let snapshot = querySnapshot else {
                            completion([])
                            return
                        }

                        let documents = snapshot.documents
                        for doc in documents {
                            let data = doc.data()
                            let timeStamp = doc["createdAt"] as! Timestamp
                            let date = timeStamp.dateValue()
                            let newPost = ATCPost(jsonDict: data)
                            
                            
                            let id = newPost.id
                            
                            postReactionStatus.contains(where: { (status) -> Bool in
                                if (status.postID == id) {
                                    newPost.selectedReaction = status.reaction
                                    return true
                                } else {
                                    return false
                                }
                            })
                            
                            newPost.createdAt = date
                            newPost.profileImage = friend.profilePictureURL ?? ""
                            newPost.postUserName = friend.fullName()
                            serialQueue.sync {
                                friendPosts.append(newPost)
                            }
                        }
                        friendsPostRetrieved.append(friend)
                        print("newsfeed 4")
                        if friendsPostRetrieved.count == fetchedFriends.count {
                            let allposts = friendPosts + allSelfPosts
                            let sortedPosts = allposts.sorted(by: { $0.createdAt! > $1.createdAt! })
                        
                            completion(sortedPosts)
                        }
                    })
                }
            }
        }
    }
}
    
    func updatePostReactions(loggedInUser: ATCUser, post: ATCPost?, reaction: String, completion: @escaping () -> Void) {
        // add reactions logic here
        guard let post = post else { return }
        guard let loggedInUserUID = loggedInUser.uid else { return }

        //1. Get the post using post.id
        //2. Fetch the reactions dictionary
        let db = Firestore.firestore()
        let ref = db.collection("SocialNetwork_Posts").document("\(post.id)")
        let reactionRef = db.collection("socialnetwork_reactions")
        
        ref.getDocument { (snapshot, error) in
            if let _ = error {
                print("Error")
                completion()
                return
            }
            guard let querySnapshot = snapshot else { return }
            guard let data = querySnapshot.data() else { return }
            
            let reactionsDictionary = data["reactions"] as? [String : Int]
            
            guard var dictionary = reactionsDictionary  else { return }
        
            
            //3. Check which reaction is sent through function
            //4. Increment that reaction
            switch(reaction) {
            case "like":
                guard let likereaction = dictionary["like"]  else { return }
                dictionary["like"] = likereaction + 1
                break
            case "surprised":
                guard let surprisedreaction = dictionary["surprised"]  else { return }
                dictionary["surprised"] = surprisedreaction + 1
                break
            case "sad":
                guard let sadreaction = dictionary["sad"] else { return }
                dictionary["sad"] = sadreaction + 1
                break
            case "angry":
                guard let angryReaction = dictionary["angry"] else { return }
                dictionary["angry"] = angryReaction + 1
                break
            case "laugh":
                guard let laughReaction = dictionary["laugh"] else { return }
                dictionary["laugh"] = laughReaction + 1
                break
            case "love":
                guard let loveReaction = dictionary["love"] else { return }
                dictionary["love"] = loveReaction + 1
                break
            default:
                break
            }

            let reactionDoc = reactionRef.whereField("reactionAuthorID", isEqualTo: loggedInUserUID)

            reactionDoc.getDocuments(completion: { (querySnapshot, error) in
                if let _ = error {
                    return
                }
                guard let snapshot = querySnapshot else { return }
                let documents = snapshot.documents
                for doc in documents {
                    let data = doc.data()
                    let postID = data["postID"] as? String
                    guard let postid = postID else { return }
                    if postid == post.id {
                        let prevReaction = data["reaction"] as? String
                        guard let previousReaction = prevReaction else {
                            return
                        }
                        guard let previousReactionCount = dictionary["\(previousReaction)"] else { return }
                        dictionary["\(previousReaction)"] = previousReactionCount - 1
                        let reactionValues = Array(dictionary.values)
                        let totalReactionCount = reactionValues.reduce(0, +)
                        ref.setData(["reactions" : dictionary], merge: true)
                        ref.setData(["postLikes" : totalReactionCount], merge: true)
                        
                        if reaction == "no_reaction" {
                            doc.reference.delete()
                            completion()
                            return
                        }
                        doc.reference.setData(["reaction" : reaction], merge: true)
                        completion()
                        return
                    }
                }
                
                 let newReactionDocRef = reactionRef.document()
                
                // Add the new reaction to the post
                let reactionDic : [String: String] = [
                    "postID" : "\(post.id)",
                    "reactionAuthorID" : "\(loggedInUserUID)",
                    "reaction"  : reaction
                    
                ]
                 newReactionDocRef.setData(reactionDic)

                let reactionValues = Array(dictionary.values)
                let totalReactionCount = reactionValues.reduce(0, +)
                
                ref.setData(["reactions" : dictionary], merge: true)
                ref.setData(["postLikes" : totalReactionCount], merge: true)
                completion()
            })
        }
    }
 
    func saveNewComment(loggedInUser: ATCUser, commentComposer: ATCCommentComposerState, post: ATCPost, completion: @escaping () -> Void) {
        
        // Save comments to firebase here
        let db = Firestore.firestore()
        let commentsCollectionRef = db.collection("socialnetwork_comments")
        
        
        var newCommentDictionary: [String: Any] = [
            "postID"            :   commentComposer.postID ?? "",
            "commentauthorID"   :   commentComposer.commentAuthorID ?? "",
            "commentText"       :   commentComposer.commentText ?? "",
            "createdAt"         :   commentComposer.date ?? Date()
        ]
        
        let document = commentsCollectionRef.document()
        newCommentDictionary["commentID"]   =   document.documentID
        
        document.setData(newCommentDictionary)
        self.updatePost(post: post) {
            completion()
        }
    }
    
    func fetchPost(post: ATCPost, loggedInUser: ATCUser,completion: @escaping ([ATCPost]) -> Void) {
        guard let loggedInUseruid = loggedInUser.uid else { return }
        let ref = Firestore.firestore().collection("SocialNetwork_Posts")
        let reactionRef = Firestore.firestore().collection("socialnetwork_reactions")
        var fetchedPost: [ATCPost] = []
        let postID = post.id
        
        var postreactionstatus: [ATCPostReactionStatus] = []

        let reactionDoc = reactionRef.whereField("reactionAuthorID", isEqualTo: loggedInUseruid)
        reactionDoc.getDocuments { (snapshot, error) in
            if let _ = error {
                print("Some error")
                return
            }
            
            guard let querySnapshot = snapshot else { return }
            let documents = querySnapshot.documents
            for doc in documents {
                let data = doc.data()
                let newPostReactionStatus = ATCPostReactionStatus(jsonDict: data)
                postreactionstatus.append(newPostReactionStatus)
            }
        
        
        
        let postRef = ref.document("\(postID)")
        postRef.getDocument { (snapshot, error) in
            if let _ = error {
                print("No Post Found")
                return
            }
            
            guard let querySnapshot = snapshot else { return }
            guard let data = querySnapshot.data() else { return }
            let timeStamp = data["createdAt"] as! Timestamp
            let date = timeStamp.dateValue()
            let newPost = ATCPost(jsonDict: data)
            newPost.createdAt = date
            
            let id = newPost.id
            postreactionstatus.contains(where: { (status) -> Bool in
                if (status.postID == id) {
                    newPost.selectedReaction = status.reaction
                    return true
                } else {
                    return false
                }
            })
            
            let userManager = ATCSocialFirebaseUserManager()
            guard let authorID = newPost.authorID else { return }
            
            userManager.fetchUser(userID: authorID, completion: { (user) in
                if let user = user {
                    newPost.profileImage = user.profilePictureURL ?? ""
                    newPost.postUserName = user.fullName()
                    fetchedPost.append(newPost)
                    completion(fetchedPost)
                }
            })
            
        }
      }
    }
    
    func fetchPostUsingID(postID: String, loggedInUser: ATCUser, completion: @escaping(ATCPost) -> Void) {
        guard let loggedInUseruid = loggedInUser.uid else { return }
        let ref = Firestore.firestore().collection("SocialNetwork_Posts")
        let reactionRef = Firestore.firestore().collection("socialnetwork_reactions")
        
        var postreactionstatus: [ATCPostReactionStatus] = []
        
        let reactionDoc = reactionRef.whereField("reactionAuthorID", isEqualTo: loggedInUseruid)
        reactionDoc.getDocuments { (snapshot, error) in
            if let _ = error {
                print("Some error")
                return
            }
            
            guard let querySnapshot = snapshot else { return }
            let documents = querySnapshot.documents
            for doc in documents {
                let data = doc.data()
                let newPostReactionStatus = ATCPostReactionStatus(jsonDict: data)
                postreactionstatus.append(newPostReactionStatus)
            }
            
        
            let postRef = ref.document("\(postID)")
            postRef.getDocument { (snapshot, error) in
                if let _ = error {
                    print("No Post Found")
                    return
                }
                
                guard let querySnapshot = snapshot else { return }
                guard let data = querySnapshot.data() else { return }
                let timeStamp = data["createdAt"] as! Timestamp
                let date = timeStamp.dateValue()
                let newPost = ATCPost(jsonDict: data)
                newPost.createdAt = date
            
                let id = newPost.id
                postreactionstatus.contains(where: { (status) -> Bool in
                    if (status.postID == id) {
                        newPost.selectedReaction = status.reaction
                        return true
                    } else {
                        return false
                    }
                })
                
                let userManager = ATCSocialFirebaseUserManager()
                guard let authorID = newPost.authorID else { return }
                

                userManager.fetchUser(userID: authorID, completion: { (user) in
                    if let user = user {
                        newPost.profileImage = user.profilePictureURL ?? ""
                        newPost.postUserName = user.fullName()
                        completion(newPost)
                    }
                })
                
            }
        }
    }
    
    
    // updating a post once a comment has been made
    func updatePost(post: ATCPost, completion: @escaping () -> Void) {
        let ref = Firestore.firestore().collection("SocialNetwork_Posts")
        let postID = post.id
        
        let postRef = ref.document("\(postID)")
        postRef.getDocument { (snapshot, error) in
            if let _ = error {
                print("No doc found")
                return
            }
            
            guard let querySnapshot = snapshot else { return }
            guard let data = querySnapshot.data() else { return }
    
            guard let commentCount = data["postComment"] as? Int else { return }
        
            let newCommentCount = commentCount + 1
            postRef.setData(["postComment" : newCommentCount], merge: true)
            completion()
        }
    }
    
    
    func fetchPostComments(post: ATCPost, completion: @escaping ([ATCComment]) -> Void) {
        let db = Firestore.firestore()
        let commentsRef = db.collection("socialnetwork_comments")
        var postCommentsArray : [ATCComment] = []
        
        let userManager = ATCSocialFirebaseUserManager()
        
        let postComments = commentsRef.whereField("postID", isEqualTo: post.id) //.order(by: "createdAt", descending: true)
        postComments.getDocuments { (querySnapshot, error) in
            if let _  = error {
                print("Comments couldn't be fetched")
                completion([])
                return
            }
            
            guard let snapshot = querySnapshot else { return }
            let documents = snapshot.documents
            for doc in documents {
                let data = doc.data()
                let timeStamp = data["createdAt"] as? Timestamp
                let date = timeStamp?.dateValue()
                let authorID = data["commentauthorID"] as? String ?? ""
                userManager.fetchUser(userID: authorID, completion: { (user) in
                    guard let user = user else { return }
                    let newComment = ATCComment(jsonDict: data)
                    newComment.createdAt = date
                    newComment.commentAuthorProfilePicture = user.profilePictureURL
                    newComment.commentAuthorUsername = user.fullName()
                    postCommentsArray.append(newComment)
                    
                    if documents.count == postCommentsArray.count {
                        completion(postCommentsArray)
                    }
                })
            }
        }
    }

    func fetchUserPosts(user: ATCUser, loggedInUser: ATCUser, completion: @escaping ([ATCPost]) -> Void) {
        let db = Firestore.firestore()
        let ref = db.collection("SocialNetwork_Posts")
        guard let userUID = user.uid else { return }
        let selfUserRef = ref.whereField("authorID", isEqualTo: userUID).order(by: "createdAt", descending: true)
        var profileUserPosts: [ATCPost] = []
        var postreactionstatus: [ATCPostReactionStatus] = []

        self.fetchReactions(user: loggedInUser) { (reactions) in
            postreactionstatus = reactions
            selfUserRef.getDocuments { (querySnapshot, error) in
                if let _ = error {
                    print("Some error occured")
                    return
                }

                guard let snapshot = querySnapshot else { return }
                let documents = snapshot.documents
                for doc in documents {
                    let data = doc.data()
                    let timeStamp = doc["createdAt"] as! Timestamp
                    let date = timeStamp.dateValue()
                    let newPost = ATCPost(jsonDict: data)
                    let id = newPost.id
                    
                    postreactionstatus.contains(where: { (status) -> Bool in
                        if (status.postID == id) {
                            newPost.selectedReaction = status.reaction
                            return true
                        } else {
                            return false
                        }
                    })

                    newPost.createdAt = date
                    newPost.profileImage = user.profilePictureURL ?? ""
                    newPost.postUserName = user.fullName()
                    profileUserPosts.append(newPost)
                }
                
                if profileUserPosts.count == documents.count {
                    completion(profileUserPosts)
                }
            }
        }
    }

    func fetchDiscoverPosts(loggedInUser: ATCUser, completion: @escaping ([ATCPost]) -> Void) {
        var loggedInUserFriends: [String: Bool] = [:]
        let db = Firestore.firestore()
        let postRef = db.collection("SocialNetwork_Posts")
        guard let userUID = loggedInUser.uid else { return }
        let reactionRef = Firestore.firestore().collection("socialnetwork_reactions")
        var fetchedPosts: [ATCPost] = []
        var postreactionstatus: [ATCPostReactionStatus] = []
        let userManager = ATCSocialFirebaseUserManager()

        guard let loggedInUserUID = loggedInUser.uid else { return }
        loggedInUserFriends = [loggedInUserUID : true]

        let socialManager = ATCFirebaseSocialGraphManager()

        let reactionDoc = reactionRef.whereField("reactionAuthorID", isEqualTo: userUID)
        reactionDoc.getDocuments { (snapshot, error) in
            if let _ = error {
                print("Some error")
                return
            }

            guard let querySnapshot = snapshot else { return }
            let documents = querySnapshot.documents
            for doc in documents {
                let data = doc.data()
                let newPostReactionStatus = ATCPostReactionStatus(jsonDict: data)
                postreactionstatus.append(newPostReactionStatus)
            }
        }

        socialManager.fetchFriends(viewer: loggedInUser) { (friends) in
            if friends.count > 0 {
                for friend in friends {
                    guard let friendUID = friend.uid else { return }
                    loggedInUserFriends[friendUID] = true
                }
            }
            postRef.getDocuments(completion: { (querySnapshot, error) in
                if let _ = error {
                    return
                }

                guard let snapshot = querySnapshot else { return }
                let documents = snapshot.documents
                var docCount = 0
                
                for doc in documents {
                    let timeStamp = doc["createdAt"] as! Timestamp
                    let date = timeStamp.dateValue()
                    let data = doc.data()
                    let newPost = ATCPost(jsonDict: data)
                    
                    let postAuthorID = newPost.authorID
                    guard let authorID = postAuthorID else { return }
                    let id = newPost.id

                    postreactionstatus.contains(where: { (status) -> Bool in
                        if (status.postID == id) {
                            newPost.selectedReaction = status.reaction
                            return true
                        } else {
                            return false
                        }
                    })

                    if (loggedInUserFriends[authorID] == nil) {
                        userManager.fetchUser(userID: authorID, completion: { (user) in
                            guard let user = user else { return }
                            newPost.createdAt = date
                            newPost.profileImage = user.profilePictureURL ?? " "
                            newPost.postUserName = user.fullName()
                            fetchedPosts.append(newPost)
                            if fetchedPosts.count == (documents.count - docCount) {
                                let sortedPosts = fetchedPosts.sorted(by: { $0.createdAt! > $1.createdAt! })
                                completion(sortedPosts)
                            }
                        })
                    } else {
                        docCount = docCount + 1
                        if fetchedPosts.count == (documents.count - docCount) {
                            let sortedPosts = fetchedPosts.sorted(by: { $0.createdAt! > $1.createdAt! })
                            completion(sortedPosts)
                        }
                    }
                }
            })
        }
    }

    func deletePost(post: ATCPost, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let postID = post.id

        let postRef = db.collection("SocialNetwork_Posts").whereField("id", isEqualTo: postID)
        let commentRef = db.collection("socialnetwork_comments").whereField("postID", isEqualTo: postID)

        postRef.getDocuments { (query, error) in
            if let _ = error {
                return
            }
            guard let querySnapshot = query else { return }
            let documents = querySnapshot.documents
            
            for doc in documents {
                doc.reference.delete()
            }
            
            commentRef.getDocuments(completion: { (query, error) in
                if let _ = error {
                    return
                }
                
                guard let querySnapshot = query else { return }
                let comments = querySnapshot.documents
                
                for comment in comments {
                    comment.reference.delete()
                }
                completion()
            })
        }
    }

    func fetchProfileFriends(User: ATCUser, completion: @escaping (_ friends: [ATCUser]) -> Void) {
        let socialManager = ATCFirebaseSocialGraphManager()
        socialManager.fetchFriendships(viewer: User) { (friendships) in
            let friendsArray = friendships.compactMap({$0.type == .mutual ? $0.otherUser : nil})
            let selectedFriends = Array(friendsArray.prefix(6))
            completion(selectedFriends)
        }
    }

    func postNotification(composer: ATCNotificationComposerState, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let ref = db.collection("socialnetwork_notifications").document()

        let post = composer.post
        let postID = post.id
        guard let postAuthorID = post.authorID else { return }
        
        let notificationDictionary: [String: Any] = [
                "postID"                :   postID,
                "postAuthorID"          :   postAuthorID,
                "notificationAuthorID"  :   composer.notificationAuthorID,
                "reacted"               :   composer.reacted,
                "commented"             :   composer.commented,
                "isInteracted"          :   composer.isInteracted,
                "createdAt"             :   composer.createdAt ?? Date(),
                "id"                    :   ref.documentID
        ]
        ref.setData(notificationDictionary, merge: true)
        completion()
    }

    func fetchNotifications(loggedInUser: ATCUser, completion: @escaping ([ATCSocialNetworkNotification]) -> Void) {
        let db = Firestore.firestore()
        let ref = db.collection("socialnetwork_notifications")
        let userManager = ATCSocialFirebaseUserManager()

        var notificationsArray: [ATCSocialNetworkNotification] = []
        guard let loggedInUserUID = loggedInUser.uid else { return }
        let notificationRef = ref.whereField("postAuthorID", isEqualTo: loggedInUserUID) //.order(by: "createdAt", descending: true)
        notificationRef.getDocuments { (querySnapshot, error) in
            if let _ = error {
                return
            }

            guard let snapshot = querySnapshot else { return }

            let documents = snapshot.documents

            for doc in documents {
                let data = doc.data()
                let timeStamp = doc["createdAt"] as! Timestamp
                let date = timeStamp.dateValue()
                let notificationAuthorID = data["notificationAuthorID"] as? String ?? ""
                userManager.fetchUser(userID: notificationAuthorID, completion: { (user) in
                    guard let user = user else { return }
                    let newNotification = ATCSocialNetworkNotification(jsonDict: data)
                    newNotification.createdAt = date
                    newNotification.notificationAuthorProfileImage = user.profilePictureURL ?? ""
                    newNotification.notificationAuthorUsername = user.fullName()
                    notificationsArray.append(newNotification)
                    
                    if notificationsArray.count == documents.count {
                        completion(notificationsArray)
                    }
                })
            }
        }
    }

    func updateNotification(loggedInUser: ATCUser, notificationID: String, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let ref = db.collection("socialnetwork_notifications")
        
        let documentRef = ref.document("\(notificationID)")
        documentRef.setData(["isInteracted" : true], merge: true)
        completion()
    }

    private func uploadImage(_ image: UIImage, completion: @escaping (URL?) -> Void) {
        let storage = Storage.storage().reference()
        
        guard let scaledImage = image.scaledToSafeUploadSize, let data = scaledImage.jpegData(compressionQuality: 0.4) else {
            completion(nil)
            return
        }

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
        let ref = storage.child("SocialNetwork_Posts").child(imageName)
        ref.putData(data, metadata: metadata) { meta, error in
            ref.downloadURL { (url, error) in
                print("Picture URL is : \(url)")
                completion(url)
            }
        }
    }
}
