//
//  ATCPostReactionStatus.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 01/07/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCPostReactionStatus {
    var reaction: String?
    var postID: String?
    var reactionAuthorID: String?
    
    init(reaction: String, postID: String, reactionAuthorID: String) {
        self.reaction = reaction
        self.postID = postID
        self.reactionAuthorID = reactionAuthorID
    }
    
    required init(jsonDict: [String: Any]) {
        self.reaction = jsonDict["reaction"] as? String ?? ""
        self.postID = jsonDict["postID"] as? String ?? ""
        self.reactionAuthorID = jsonDict["reactionAuthorID"] as? String ?? ""
    }
}
