//
//  ATCSocialNetworkNotificationsDataSource.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 29/07/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCSocialNetworkNotificationsDataSource : ATCGenericCollectionViewControllerDataSource {

    var delegate: ATCGenericCollectionViewControllerDataSourceDelegate?
    let loggedInUser : ATCUser
    let socialManager : ATCSocialNetworkAPIProtocol
    var notifications: [ATCSocialNetworkNotification] = []

    init(loggedInUser: ATCUser) {
        self.loggedInUser = loggedInUser
        self.socialManager = ATCSocialNetworkFirebaseAPIManager()
    }

    func object(at index: Int) -> ATCGenericBaseModel? {
        if index < notifications.count {
            return notifications[index]
        }
        return nil
    }

    func numberOfObjects() -> Int {
        return notifications.count
    }

    func loadFirst() {
        socialManager.fetchNotifications(loggedInUser: loggedInUser) { (notificationsArray) in
            self.notifications = notificationsArray.sorted(by: { $0.createdAt! > $1.createdAt!})
            self.delegate?.genericCollectionViewControllerDataSource(self, didLoadFirst: self.notifications)
        }
    }

    func loadBottom() {
    }

    func loadTop() {
    }
}
