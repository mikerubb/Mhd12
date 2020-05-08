//
//  ATCSocialNetworkDiscoverDatasource.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 10/07/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCSocialNetworkDiscoverDatasource: ATCGenericCollectionViewControllerDataSource {
    
    var delegate: ATCGenericCollectionViewControllerDataSourceDelegate?
    let viewer : ATCUser
    let socialManager : ATCSocialNetworkAPIProtocol
    var discoverPosts: [ATCPost] = []
    
    init(viewer: ATCUser) {
        self.viewer = viewer
        self.socialManager = ATCSocialNetworkFirebaseAPIManager()
    }
    
    func object(at index: Int) -> ATCGenericBaseModel? {
        if index < discoverPosts.count {
            return discoverPosts[index]
        }
        return nil
    }
    
    func numberOfObjects() -> Int {
        return discoverPosts.count
    }
    
    func loadFirst() {
        socialManager.fetchDiscoverPosts(loggedInUser: viewer) { (posts) in
            self.discoverPosts = posts
            self.delegate?.genericCollectionViewControllerDataSource(self, didLoadFirst: posts)
        }
    }
    
    func loadBottom() {
    }
    
    func loadTop() {
    }
    
    
}
