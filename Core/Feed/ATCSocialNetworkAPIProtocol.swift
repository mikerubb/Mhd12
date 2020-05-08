//
//  ATCSocialNetworkAPIProtocol.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 26/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

protocol ATCSocialNetworkAPIProtocol: class {
    func fetchNewsFeed(loggedInUser: ATCUser, completion: @escaping([ATCPost]) -> Void)
    func updatePostReactions(loggedInUser: ATCUser, post: ATCPost?, reaction: String, completion: @escaping() -> Void)
    func saveNewComment(loggedInUser: ATCUser, commentComposer: ATCCommentComposerState, post: ATCPost, completion: @escaping() -> Void)
    func fetchPostComments(post: ATCPost, completion: @escaping([ATCComment]) -> Void)
    func fetchUserPosts(user: ATCUser, loggedInUser: ATCUser, completion: @escaping ([ATCPost]) -> Void)
    func fetchPost(post: ATCPost, loggedInUser: ATCUser, completion: @escaping([ATCPost]) -> Void)
    func fetchPostUsingID(postID: String, loggedInUser: ATCUser, completion: @escaping(ATCPost) -> Void)
    func updatePost(post: ATCPost, completion: @escaping () -> Void)
    func fetchDiscoverPosts(loggedInUser: ATCUser, completion: @escaping([ATCPost]) -> Void)
    func deletePost(post: ATCPost, completion: @escaping() -> Void)
    func fetchProfileFriends(User: ATCUser, completion: @escaping (_ friends: [ATCUser]) -> Void)
    func postNotification(composer: ATCNotificationComposerState, completion: @escaping() -> Void)
    func fetchNotifications(loggedInUser: ATCUser, completion: @escaping([ATCSocialNetworkNotification]) -> Void)
    func updateNotification(loggedInUser: ATCUser, notificationID: String, completion: @escaping() -> Void)
}

