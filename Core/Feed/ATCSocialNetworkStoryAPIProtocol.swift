//
//  ATCSocialNetworkStoryAPIProtocol.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 02/07/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

protocol ATCSocialNetworkStoryAPIProtocol : class {
    func fetchStories(loggedInUser: ATCUser, completion: @escaping (ATCStoriesUserState) -> Void)
    func saveStories(loggedInUser: ATCUser, storyComposer: ATCStoryComposerState, completion: @escaping () -> Void)
}

