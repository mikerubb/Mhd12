//
//  ATCHeaderText.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 26/07/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCHeaderText : ATCGenericBaseModel {
    
    var headerText: String
    
    init(headerText: String) {
        self.headerText = headerText
    }
    required init(jsonDict: [String : Any]) {
        fatalError()
    }
    
    var description: String {
        return headerText
    }
    
    
}
