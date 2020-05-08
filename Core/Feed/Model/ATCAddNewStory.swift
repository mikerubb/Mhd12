//
//  ATCAddNewStory.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 23/07/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCAddNewStory: ATCGenericBaseModel {
    var addImageURL: String?

    init(addImageURL: String?) {
        self.addImageURL = addImageURL
    }

    required init(jsonDict: [String : Any]) {
        fatalError()
    }

    var description: String {
        return "New Story"
    }
}
