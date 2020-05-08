//
//  ATCSocialNetworkSelfUserPostsDatasource.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 04/07/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCSocialNetworkSelfUserPostsDatasource : ATCGenericCollectionViewControllerDataSource {
    var delegate: ATCGenericCollectionViewControllerDataSourceDelegate?
    var userPosts: [ATCPost] = []
    var user: ATCUser
    var loggedInUser: ATCUser
    var socialNetworkAPIManager: ATCSocialNetworkFirebaseAPIManager
    
    init(user: ATCUser, loggedInUser: ATCUser) {
        self.user = user
        self.loggedInUser = loggedInUser
        self.socialNetworkAPIManager = ATCSocialNetworkFirebaseAPIManager()
    }
    
    func object(at index: Int) -> ATCGenericBaseModel? {
        if index < userPosts.count {
            return userPosts[index]
        }
        return nil
    }
    
    func numberOfObjects() -> Int {
        return userPosts.count
    }
    
    func loadFirst() {
        socialNetworkAPIManager.fetchUserPosts(user: user, loggedInUser: loggedInUser) { (posts) in
            self.userPosts = posts
            self.delegate?.genericCollectionViewControllerDataSource(self, didLoadFirst: posts)
        }
    }

    func loadBottom() {
    }

    func loadTop() {
    }
}
