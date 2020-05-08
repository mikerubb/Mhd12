//
//  ATCSocialNetworkNewsFeedDataSource .swift
//  SocialNetwork
//
//  Created by Osama Naeem on 27/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit


class ATCSocialNetworkNewsFeedDataSource: ATCGenericCollectionViewControllerDataSource {
    
    var user: ATCUser
    var socialNetworkAPIManager: ATCSocialNetworkAPIProtocol
    var delegate: ATCGenericCollectionViewControllerDataSourceDelegate?
    var friendsPosts: [ATCPost] = []
    
    init(user: ATCUser) {
        self.user = user
        self.socialNetworkAPIManager = ATCSocialNetworkFirebaseAPIManager()
    }
    
    func object(at index: Int) -> ATCGenericBaseModel? {
        if index < friendsPosts.count {
            return friendsPosts[index]
        }
        return nil
    }
    
    func numberOfObjects() -> Int {
        return friendsPosts.count
    }
    
    func loadFirst() {
        socialNetworkAPIManager.fetchNewsFeed(loggedInUser: user) { (fetchedPosts) in
            self.friendsPosts = fetchedPosts
            self.delegate?.genericCollectionViewControllerDataSource(self, didLoadFirst: fetchedPosts)
        }
    }
    
    func loadBottom() {
        
    }
    
    func loadTop() {}
    
    
    
}
