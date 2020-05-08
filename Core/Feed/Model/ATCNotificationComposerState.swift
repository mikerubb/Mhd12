//
//  ATCNotificationComposerState.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 29/07/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCNotificationComposerState {
    var post: ATCPost
    var notificationAuthorID: String
    var reacted: Bool
    var commented: Bool
    var isInteracted: Bool = false
    var createdAt: Date?
    
    init(post: ATCPost, notificationAuthorID: String, reacted: Bool, commented: Bool, isInteracted: Bool, createdAt: Date) {
        self.post = post
        self.notificationAuthorID = notificationAuthorID
        self.reacted = reacted
        self.commented = commented
        self.isInteracted = isInteracted
        self.createdAt = createdAt
    }
}
