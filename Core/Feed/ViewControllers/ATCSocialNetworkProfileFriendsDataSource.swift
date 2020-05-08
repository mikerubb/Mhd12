//
//  ATCSocialNetworkProfileFriendsDataSource.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 26/07/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCSocialNetworkProfileFriendsDataSource : ATCGenericCollectionViewControllerDataSource {
    
  var delegate: ATCGenericCollectionViewControllerDataSourceDelegate?
    let user : ATCUser
    let socialManager : ATCSocialNetworkAPIProtocol
    var friends: [ATCUser] = []
    
    init(user: ATCUser) {
        self.user = user
        self.socialManager = ATCSocialNetworkFirebaseAPIManager()
    }
    
    func object(at index: Int) -> ATCGenericBaseModel? {
        if index < friends.count {
            return friends[index]
        }
        return nil
    }
    
    func numberOfObjects() -> Int {
        return friends.count
    }
    
    func loadFirst() {
        socialManager.fetchProfileFriends(User: user) { (friends) in
            self.friends = friends
            self.delegate?.genericCollectionViewControllerDataSource(self, didLoadFirst: friends)
        }
    }
    
    func loadBottom() {
    }
    
    func loadTop() {
    }
    
    
}
