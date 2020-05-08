//
//  ATCTestDatasourceProtocol.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 25/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit
import FirebaseFirestore

// This is just for practicing and clearing my concept.
// This is only for posts for now. Will implement for stories later.
//
//class ATCSocialNetworkAPIManager: ATCSocialNetworkAPIProtocol {
//    
//    func saveNewPost(user: ATCUser?, post: ATCPost, completion: @escaping () -> Void) {
//        if let user = user {
//            post.profileImage = user.profilePictureURL!
//            post.postUserName = user.fullName()
//            post.authorID = user.uid
//        }
//        
//        let dictionary: [String: Any] = [
//        
//            "postText"      : post.postText,
//            "postMedia"     : post.postMedia, // Post Media will be bunch of URLs first uploaded to firestore storage. We have a class for that
//            "location"      : post.location ?? "San Francisco",
//            "createdAt"     : post.createdAt ?? "",
//            "author"        : post.postUserName ?? "",
//            "profilePicURL" : post.profileImage ,
//            "authorID"      : post.authorID ?? ""
//            
//        ]
//        
//        let newDocument =  Firestore.firestore().collection("SocialNetwork_Posts").document()
//        newDocument.setData(dictionary)
//        completion()
//        
//    }
//    
//    func fetchNewsFeed(loggedInUser: ATCUser, completion: @escaping ([ATCPost]) -> Void) {
//        let socialManager = ATCFirebaseSocialGraphManager()
//        var friendPosts: [ATCPost] = []
//        var friends: [ATCUser] = []
//        
//        socialManager.fetchFriends(viewer: loggedInUser) { (fetchedFriends) in
//            friends = fetchedFriends
//        }
//        
//        let db = Firestore.firestore()
//        let ref = db.collection("SocialNetwork_Post")
//        
//        for friend in friends {
//            guard let friendUID = friend.uid else { return }
//            let friendRef = ref.whereField("authorID", isEqualTo: friendUID)
//            
//            friendRef.getDocuments { (snapshot, err) in
//                if let _ = err {
//                    return
//                }else {
//                    let documents = snapshot?.documents
//                    if let docs = documents {
//                        for doc in docs {
//                            let documentData = doc.data()
//                            let newPost = ATCPost(jsonDict: documentData)
//                            friendPosts.append(newPost)
//                        }
//                    }
//                }
//            }
//            
//        }
//        completion(friendPosts)
//    }
//
//}
//
//
//// NEW FILE
//
//class ATCFirebasePostsDataSource: ATCGenericCollectionViewControllerDataSource {
//    var user: ATCUser
//    var socialNetworkAPIManager: ATCSocialNetworkAPIProtocol
//    var delegate: ATCGenericCollectionViewControllerDataSourceDelegate?
//    var friendsPosts: [ATCPost] = []
//    
//    init(user: ATCUser) {
//        self.user = user
//        self.socialNetworkAPIManager = ATCSocialNetworkAPIManager()
//    }
//    
//    func object(at index: Int) -> ATCGenericBaseModel? {
//        if index < friendsPosts.count {
//            return friendsPosts[index]
//        }
//        return nil
//    }
//    
//    func numberOfObjects() -> Int {
//       return friendsPosts.count
//    }
//    
//    func loadFirst() {
//        socialNetworkAPIManager.fetchFriendPosts(loggedInUser: user) { (fetchedPosts) in
//            self.friendsPosts = fetchedPosts
//            self.delegate?.genericCollectionViewControllerDataSource(self, didLoadFirst: fetchedPosts)
//        }
//    }
//    
//    func loadBottom() {}
//    
//    func loadTop() {}
//    
//
//    
//    
//}
