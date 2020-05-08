//
//  ChatServerConfiguration.swift
//  ChatApp
//
//  Created by Florian Marcu on 8/18/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class SocialNetworkServerConfiguration: ATCOnboardingServerConfigurationProtocol {
    var appIdentifier: String = "chat-swift-ios"

    var isFirebaseAuthEnabled: Bool = true
    var isFirebaseDatabaseEnabled: Bool = true
}
