//
//  ATCSocialNetworkStoriesDatasource.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 02/07/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

protocol ATCFetchCompleted: class {
    func fetchCompleted(state: ATCStoriesUserState)
}

class ATCSocialNetworkStoriesDatasource : ATCGenericCollectionViewControllerDataSource {
    weak var delegate: ATCGenericCollectionViewControllerDataSourceDelegate?

    let socialManager: ATCSocialNetworkStoryAPIProtocol?
    var friends: [ATCGenericBaseModel] = []
    var user: ATCUser
    var datasource: ATCFetchCompleted?

    init(user: ATCUser) {
        self.user = user
        self.socialManager = ATCSocialNetworkStoryFirebaseManager()

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
        socialManager?.fetchStories(loggedInUser: user, completion: {[weak self] (state) in
            guard let `self` = self else { return }
            guard let profilePictureURL = self.user.profilePictureURL else { return }
            let addButton = ATCAddNewStory(addImageURL: profilePictureURL)

            print("Is Self User Story available:  \(state.selfStory)")
            if state.selfStory {
                self.friends = state.users
            } else {
                self.friends = [addButton] + state.users
            }
            self.delegate?.genericCollectionViewControllerDataSource(self, didLoadFirst: self.friends)
            self.datasource?.fetchCompleted(state: state)
        })
    }
}
