//
//  ATCChatFirebaseFriendsDataSource.swift
//  ChatApp
//
//  Created by Florian Marcu on 9/15/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class ATCChatFirebaseFriendsDataSource: ATCGenericCollectionViewControllerDataSource {
    weak var delegate: ATCGenericCollectionViewControllerDataSourceDelegate?

    let socialManager: ATCSocialGraphManagerProtocol?
    var friends: [ATCUser] = []
    var user: ATCUser

    init(user: ATCUser) {
        self.user = user
        self.socialManager = ATCFirebaseSocialGraphManager()
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
        loadIfNeeded()
    }
    
    func loadBottom() {}
    func loadTop() {}
    
    fileprivate func loadIfNeeded() {
        self.socialManager?.fetchFriends(viewer: user) { (friends) in
            self.friends = friends
            self.delegate?.genericCollectionViewControllerDataSource(self, didLoadFirst: friends)
        }
    }
}
