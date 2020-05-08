//
//  ATCSocialNetworkStoryFirebaseManager.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 02/07/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage


class ATCSocialNetworkStoryFirebaseManager : ATCSocialNetworkStoryAPIProtocol {

    
    func saveStories(loggedInUser: ATCUser, storyComposer: ATCStoryComposerState, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let storiesReference = db.collection("socialnetwork_stories")
        let timestamp = FieldValue.serverTimestamp()
        
        var storyDictionary: [String: Any] = [
            "storyType"     :   storyComposer.mediaType ?? "",
            "storyAuthorID" :   loggedInUser.uid ?? "",
            "createdAt"     :   timestamp
        ]

        //Upload Media URL
        if let photo = storyComposer.photoMedia {
            self.uploadImage(photo) { (url) in
                guard let uploadPhotoURL = url else { return }
                let uploadPhotoURLString = uploadPhotoURL.absoluteString
                let newStoryDocument = storiesReference.document()
                storyDictionary["storyMediaURL"] =  uploadPhotoURLString
                storyDictionary["storyID"]  =   newStoryDocument.documentID
                newStoryDocument.setData(storyDictionary)
                completion()
            }
            return
        } else {
            print("No Photo to Upload")
        }
        
        if let videoURL = storyComposer.videoMedia {
            self.uploadVideo(videoURL) { (url) in
                guard let videoURL = url else { return }
                let videoURLStrng = videoURL.absoluteString
                let newStoryDocument = storiesReference.document()
                storyDictionary["storyMediaURL"] =  videoURLStrng
                storyDictionary["storyID"]  =   newStoryDocument.documentID
                newStoryDocument.setData(storyDictionary)
                completion()
            }
            return
        }else {
            print("No Video to Upload")
        }
        
    }
    
    func fetchStories(loggedInUser: ATCUser, completion: @escaping (ATCStoriesUserState) -> Void) {
        // fetch stories here
        // 1. Fetch friends and for each friend check for stories
        let db = Firestore.firestore()
        let storiesReference = db.collection("socialnetwork_stories")
        let socialManager = ATCFirebaseSocialGraphManager()
        let storiesUserState = ATCStoriesUserState()
    
        var friendsStories  : [[ATCStory]] = []
        var friendsStoryRetrieved: [ATCUser] = []
        
        var selfStories: [ATCStory] = []
        var friendUsers: [ATCUser] = []
        
        let currentTime = Date()
        
        guard let loggedInUserUID = loggedInUser.uid else { return }
        let storyRef = storiesReference.whereField("storyAuthorID", isEqualTo: loggedInUserUID)
        let userManager = ATCSocialFirebaseUserManager()
        
        var selfStoriesFiltered = 0
        

        print("Self Story Check Point 1")
        storyRef.getDocuments { (snapshot, error) in
            if let _ = error {
                print("Something went wrong")
                return
            }
            
            guard let querySnapshot = snapshot else { return }
            
            let documents = querySnapshot.documents
            if documents.count == 0 {
                selfStories = []
                storiesUserState.selfStory = false
            }else {
                for doc in documents {
                    let data = doc.data()
                    let storyCreationDate = doc["createdAt"] as! Timestamp
                    let storyDate = storyCreationDate.dateValue()
                    let difference = Calendar.current.dateComponents([.hour, .minute], from: storyDate, to: currentTime)
                    let hours = difference.hour
                   
    
                    guard let differencehour = hours else {
                        print("Couldn't retrieve hours")
                        return
                        
                    }
                    if differencehour >= 24 {
                            selfStoriesFiltered = selfStoriesFiltered + 1
                            // Those stories greater than 24 hour difference to be removed from server
                    } else {
                            let story = ATCStory(jsonDict: data)
                            selfStories.append(story)
                        }
                    
                   
                    if selfStories.count == (documents.count - selfStoriesFiltered) && selfStories.count > 0 {
                        storiesUserState.selfStory = true
                        friendsStories.append(selfStories)
                        userManager.fetchUser(userID: loggedInUserUID, completion: { (user) in
                            guard let user = user else { return }
                            friendUsers.append(user)
                        })
                    }
                }
  
            }
            
        
        
        print("Self Story Check Point 2")
        
        socialManager.fetchFriends(viewer: loggedInUser) { (fetchedFriends) in
            let friends = fetchedFriends
            
            
            if friends.count == 0 && selfStories.count == 0{
                storiesUserState.stories = []
                storiesUserState.users = []
                storiesUserState.selfStory = false
                completion(storiesUserState)
                return 
            }else if friends.count == 0 && selfStories.count > 0 {
                storiesUserState.stories = friendsStories
                storiesUserState.users = friendUsers
                storiesUserState.selfStory = true
                completion(storiesUserState)
                return
            }
            
            var friendsStoriesFiltered = 0
        
            for friend in friends {
                var singleUserStory : [ATCStory] = []
                guard let friendUID = friend.uid else { return }
                let storyRef = storiesReference.whereField("storyAuthorID", isEqualTo: friendUID)
            
                storyRef.getDocuments(completion: { (querySnapshot, error) in
                    if let _ = error {
                        storiesUserState.stories = []
                        storiesUserState.users = []
                        completion(storiesUserState)
                        return
                    }
                    
                    guard let snapshot = querySnapshot else {
                        storiesUserState.stories = []
                        storiesUserState.users = []
                        completion(storiesUserState)
                        return
                    }
                    
                    let documents = snapshot.documents
                    
                    
                    if documents.count == 0 && selfStories.count == 0 {
                        storiesUserState.stories = []
                        storiesUserState.users = []
                        storiesUserState.selfStory = false
                        completion(storiesUserState)
                        
                    }else if documents.count == 0 && selfStories.count > 0 {
                        storiesUserState.stories = friendsStories
                        storiesUserState.users = friendUsers
                        storiesUserState.selfStory = true
                        completion(storiesUserState)
                    }else if documents.count > 0 && selfStories.count > 0 {
                        storiesUserState.selfStory = true
                    }
                    
                    for doc in documents {
                        let storyCreationDate = doc["createdAt"] as! Timestamp
                        let storyDate = storyCreationDate.dateValue()
                        let difference = Calendar.current.dateComponents([.hour, .minute], from: storyDate, to: currentTime)
                        let hours = difference.hour
                        
                        
                        guard let differencehour = hours else {
                            print("Couldn't retrieve hours")
                            return
                            
                        }
                        if differencehour >= 24 {
                            // Those stories greater than 24 hour difference to be removed from server
                        } else {
                            let data = doc.data()
                            let newStory = ATCStory(jsonDict: data)
                            singleUserStory.append(newStory)
                        }
                    }
                    
                    // If there exist even one story for a friend, only then append it to friendStoryRetrieved
                    if singleUserStory.count > 0 {
                        friendsStories.append(singleUserStory)
                        friendsStoryRetrieved.append(friend)
                        friendUsers.append(friend)
                    } else {
                        friendsStoriesFiltered = friendsStoriesFiltered + 1
                    }
                    
                    print("Stories fetch check point 3")
                    if friendsStoryRetrieved.count == (fetchedFriends.count - friendsStoriesFiltered) {
                        storiesUserState.stories = friendsStories
                        storiesUserState.users = friendUsers
                        completion(storiesUserState)
                    }
                })
            }
          }
        }
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
    
    private func uploadVideo(_ videoURL: URL, completion: @escaping (URL?) -> Void) {
        let storage = Storage.storage().reference()
        
        let metadata = StorageMetadata()
        metadata.contentType = "video/mp4"
        
        let videoName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
        let ref = storage.child("SocialNetwork_Posts").child(videoName)
        
        ref.putFile(from: videoURL, metadata: metadata) { meta, error in
            ref.downloadURL(completion: { (url, error) in
                print("Video URL is: \(url)")
                completion(url)
            })
        }
    }
}
