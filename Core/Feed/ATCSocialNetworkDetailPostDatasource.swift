//
//  ATCSocialNetworkDetailPostDatasource.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 08/07/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCSocialNetworkDetailPostDatasource : ATCGenericCollectionViewControllerDataSource {
    var delegate: ATCGenericCollectionViewControllerDataSourceDelegate?
    var detailPost: [ATCPost] = []
    var post: ATCPost
    var viewer: ATCUser
    var socialNetworkAPIManager: ATCSocialNetworkFirebaseAPIManager
    
    init(viewer: ATCUser, post: ATCPost) {
        self.post = post
        self.viewer = viewer
        self.socialNetworkAPIManager = ATCSocialNetworkFirebaseAPIManager()
    }
    
    func object(at index: Int) -> ATCGenericBaseModel? {
        if index < detailPost.count {
            return detailPost[index]
        }
        return nil
    }
    
    func numberOfObjects() -> Int {
        return detailPost.count
    }
    
    func loadFirst() {
        socialNetworkAPIManager.fetchPost(post: post, loggedInUser: viewer) { (post) in
            self.detailPost = post
            self.delegate?.genericCollectionViewControllerDataSource(self, didLoadFirst: post)
        }
    }
    
    func loadBottom() {
    }
    
    func loadTop() {
        
    }
    
    
}
