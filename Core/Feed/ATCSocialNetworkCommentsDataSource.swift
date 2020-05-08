//
//  ATCSocialNetworkCommentsDataSource.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 01/07/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCSocialNetworkCommentsDataSource : ATCGenericCollectionViewControllerDataSource {
    var delegate: ATCGenericCollectionViewControllerDataSourceDelegate?
    var socialNetworkAPIManager: ATCSocialNetworkAPIProtocol
    var commentsArray: [ATCGenericBaseModel] = []
    var user: ATCUser
    var post: ATCPost

    init(user: ATCUser, post: ATCPost) {
        self.user = user
        self.post = post
        self.socialNetworkAPIManager = ATCSocialNetworkFirebaseAPIManager()
    }

    func object(at index: Int) -> ATCGenericBaseModel? {
        if index < commentsArray.count {
            return commentsArray[index]
        }
        return nil
    }

    func numberOfObjects() -> Int {
         return commentsArray.count
    }

    func loadFirst() {
        socialNetworkAPIManager.fetchPostComments(post: post) { (fetchedComments) in
            self.commentsArray = fetchedComments.sorted(by: { $0.createdAt ?? Date().infiniteAgo > $1.createdAt ?? Date().infiniteAgo})
            self.delegate?.genericCollectionViewControllerDataSource(self, didLoadFirst: self.commentsArray)
        }
    }

    func loadBottom() {}

    func loadTop() {}
}
