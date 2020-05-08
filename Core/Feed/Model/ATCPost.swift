//
//  ATCFeed.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 07/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit


class ATCPost : ATCGenericBaseModel {
    
    var postUserName: String?
    var postText: String
    var postLikes: Int
    var postComment: Int
    var postMedia: [String]
    var postReactions: [String: Int] = [:]
    var profileImage: String
    var authorID: String?
    var createdAt: Date?
    var location: String?
    var id: String
    var latitude: Double? = nil
    var longitude: Double? = nil
    var selectedReaction: String? = nil
    
    var description: String {
        return "ATCUser post"
    }
    // Creating an ATCPost in new post VC using this initializer
    init(postUserName: String, postText: String, postLikes: Int, postComment: Int, postMedia: [String], profileImage: String, createdAt: Date?, authorID: String, location: String, id: String, latitude: Double, longitude: Double, postReactions: [String: Int], selectedReaction: String) {
        self.postUserName = postUserName
        self.postText = postText
        self.postLikes = postLikes
        self.postComment = postComment
        self.postMedia = postMedia
        self.profileImage = profileImage
        self.createdAt = createdAt
        self.authorID = authorID
        self.location = location
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.postReactions = postReactions
        self.selectedReaction = selectedReaction
    }
    
    // When creating a post from data fetched from firebase
    required init(jsonDict: [String: Any]) {
        self.authorID = jsonDict["authorID"] as? String ?? ""
        self.postMedia = jsonDict["postMedia"] as? [String] ?? []
        self.postText = jsonDict["postText"] as? String ?? ""
        self.createdAt = jsonDict["createdAt"] as? Date ?? Date()
        self.postLikes = (jsonDict["postLikes"] as? Int) ?? 0
        self.postUserName = (jsonDict["postUserName"] as? String) ?? ""
        self.postComment = (jsonDict["postComment"] as? Int) ?? 0
        self.profileImage = (jsonDict["profileImage"] as? String) ?? ""
        self.location = (jsonDict["location"] as? String) ?? "San Francisco"
        self.id = (jsonDict["id"] as? String) ?? ""
        self.longitude = (jsonDict["longitude"] as? Double) ?? 0.0
        self.latitude = (jsonDict["latitude"] as? Double) ?? 0.0
        self.postReactions = (jsonDict["reactions"] as? [String: Int]) ?? [:]
        self.selectedReaction = (jsonDict["selectedReaction"] as? String) ?? ""
    }
}
