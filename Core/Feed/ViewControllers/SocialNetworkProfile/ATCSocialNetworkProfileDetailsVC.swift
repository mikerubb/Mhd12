//
//  ATCSocialNetworkProfileDetailsVC.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 26/07/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCSocialNetworkProfileDetailsVC : ATCGenericCollectionViewController {
    var uiConfig : ATCUIGenericConfigurationProtocol
    var cellId = "ATCUser"
    var datasource: ATCGenericCollectionViewControllerDataSource? = nil
    var loggedInUser: ATCUser? = nil
    var user: ATCUser? = nil
    
    init(uiConfig: ATCUIGenericConfigurationProtocol, datasource: ATCGenericCollectionViewControllerDataSource, loggedInUser: ATCUser, user: ATCUser) {
        self.uiConfig = uiConfig
        self.datasource = datasource
        self.loggedInUser = loggedInUser
        self.user = user
        
        let layout = ATCCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let collectionVCConfiguration = ATCGenericCollectionViewControllerConfiguration(
            pullToRefreshEnabled: false,
            pullToRefreshTintColor: .white,
            collectionViewBackgroundColor: UIColor.darkModeColor(hexString: "#f5f5f5"),
            collectionViewLayout: layout,
            collectionPagingEnabled: true,
            hideScrollIndicators: true,
            hidesNavigationBar: false,
            headerNibName: nil,
            scrollEnabled: false,
            uiConfig: uiConfig,
            emptyViewModel: nil
        )
        
        super.init(configuration: collectionVCConfiguration)
        self.use(adapter: ATCTextRowAdapter(font: uiConfig.boldFont(size: 18),
                                            textColor: uiConfig.mainTextColor,
                                            alignment: .center),
                 for: "ATCText")
        self.use(adapter:  ATCRoundImageRowAdapter(), for: "ATCImage")
        self.use(adapter: ATCProfileButtonItemRowAdapter(uiConfig: uiConfig), for: "ATCProfileButtonItem")
        self.use(adapter: ATCHeaderTextCellAdapter(font: uiConfig.boldFont(size: 24),
                                                   textColor: uiConfig.mainTextColor,
                                                   alignment: .left), for: "ATCHeaderText")
        self.genericDataSource = datasource
        self.selectionBlock = self.accountDetailsSelectionBlock()
    }

    private func accountDetailsSelectionBlock() -> ATCollectionViewSelectionBlock? {
        return {[weak self] (navController, object, indexPath) in
            if let modelButton = object as? ATCProfileButtonItem {
                guard let strongSelf = self else { return}
                if modelButton.title == "Profile Settings" {
                    guard let loggedInUser = strongSelf.loggedInUser else { return }
                    let profileSettingsVC = ATCSocialNetworkProfileSettings(viewer: loggedInUser)
                    strongSelf.navigationController?.pushViewController(profileSettingsVC, animated: true)
                }else if modelButton.title == "Send Message" {
                    // Takes user to message thread
                    
                    let uiConfig = ATCChatUIConfiguration(uiConfig: strongSelf.uiConfig)
                    
                    guard let otherUser = strongSelf.user else {
                        return
                    }
                    guard let viewer = strongSelf.loggedInUser else {
                        return
                        
                    }
                    let id1 = (otherUser.uid ?? "")
                    let id2 = (viewer.uid ?? "")
                    let channelId = id1 < id2 ? id1 + id2 : id2 + id1
                    var channel = ATCChatChannel(id: channelId, name: otherUser.fullName())
                    channel.participants = [otherUser, viewer]
                    let vc = ATCChatThreadViewController(user: viewer,
                                                         channel: channel,
                                                         uiConfig: uiConfig,
                                                         reportingManager: ATCFirebaseUserReporter(),
                                                         recipients: [otherUser])
                    navController?.pushViewController(vc, animated: true)
                    
                } else {
                    let socialManager = ATCFirebaseSocialGraphManager()
                    guard let loggedInUser = strongSelf.loggedInUser else { return }
                    guard let user = strongSelf.user else { return }
                    socialManager.sendFriendRequest(viewer: loggedInUser, to: user, completion: {
                    })
                }
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
