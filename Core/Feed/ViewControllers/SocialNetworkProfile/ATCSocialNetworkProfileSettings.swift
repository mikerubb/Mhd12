//
//  ATCSocialNetworkProfileSettings.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 10/07/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCSocialNetworkProfileSettings : QuickTableViewController {
    
    let viewer: ATCUser
    private var accountDetails: TapActionRow<TapActionCell>!
    private var settings: TapActionRow<TapActionCell>!
    private var logout: TapActionRow<TapActionCell>!
    
    init(viewer: ATCUser) {
        self.viewer = viewer
        super.init(nibName: nil, bundle: nil)
        title = "Profile Settings"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        accountDetails = TapActionRow(text: "Account Details", action: buttonPressed())
        settings = TapActionRow(text: "Settings", action: buttonPressed())
        logout = TapActionRow(text: "Log Out", action: buttonPressed())
        
        tableContents = [
        Section(title: "General", rows: [accountDetails, settings, logout])
        ]
    }
    
    // MARK: - Actions
    private func buttonPressed() -> (Row) -> Void {
        return { [unowned self] in
            switch $0 {
            case let row as TapActionRow<TapActionCell> where row == self.accountDetails:
                self.handleAccountDetailsButton()
            case let row as TapActionRow<TapActionCell> where row == self.settings:
                self.handleSettingsButton()
            case let row as TapActionRow<TapActionCell> where row == self.logout:
                self.navigationController?.popViewController(animated: true)
                NotificationCenter.default.post(name: kLogoutNotificationName, object: nil)
            default:
                break
            }
        }
    }
    
    private func handleAccountDetailsButton() {
        let manager = ATCFirebaseProfileManager()
        let accountDetailsVC = ATCChatAccountDetailsViewController(user: viewer, manager: manager, cancelEnabled: true)
        self.navigationController?.pushViewController(accountDetailsVC, animated: true)
    }
    
    private func handleSettingsButton() {
        let settingsVC = ATCSettingsViewController()
        settingsVC.user = self.viewer
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    private func didToggleSelection() -> (Row) -> Void {
        return { [weak self] row in
            // ...
        }
    }
}
