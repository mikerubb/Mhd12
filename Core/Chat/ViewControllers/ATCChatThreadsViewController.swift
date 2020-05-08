//
//  ATCChatThreadsViewController.swift
//  ChatApp
//
//  Created by Florian Marcu on 8/20/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class ATCChatThreadsViewController: ATCGenericCollectionViewController {

    let chatConfig: ATCChatUIConfiguration

    init(configuration: ATCGenericCollectionViewControllerConfiguration,
         selectionBlock: ATCollectionViewSelectionBlock?,
         viewer: ATCUser,
         chatConfig: ATCChatUIConfiguration) {
        self.chatConfig = chatConfig
        super.init(configuration: configuration, selectionBlock: selectionBlock)
        self.use(adapter: ATCChatThreadAdapter(uiConfig: configuration.uiConfig, viewer: viewer), for: "ATCChatChannel")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func firebaseThreadsVC(uiConfig: ATCUIGenericConfigurationProtocol,
                                  dataSource: ATCGenericCollectionViewControllerDataSource,
                                  viewer: ATCUser,
                                  reportingManager: ATCUserReportingProtocol?,
                                  chatConfig: ATCChatUIConfiguration,
                                  emptyViewModel: CPKEmptyViewModel?) -> ATCChatThreadsViewController {
        let collectionVCConfiguration = ATCGenericCollectionViewControllerConfiguration(
            pullToRefreshEnabled: false,
            pullToRefreshTintColor: uiConfig.mainThemeBackgroundColor,
            collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
            collectionViewLayout: ATCLiquidCollectionViewLayout(),
            collectionPagingEnabled: false,
            hideScrollIndicators: false,
            hidesNavigationBar: false,
            headerNibName: nil,
            scrollEnabled: false,
            uiConfig: uiConfig,
            emptyViewModel: emptyViewModel
        )

        let vc = ATCChatThreadsViewController(configuration: collectionVCConfiguration,
                                              selectionBlock: ATCChatThreadsViewController.selectionBlock(viewer: viewer, chatConfig: chatConfig, reportingManager: reportingManager),
                                              viewer: viewer,
                                              chatConfig: chatConfig)
        vc.genericDataSource = dataSource
        return vc
    }

    static func selectionBlock(viewer: ATCUser, chatConfig: ATCChatUIConfiguration, reportingManager: ATCUserReportingProtocol?) -> ATCollectionViewSelectionBlock? {
        return {(navController, object, indexPath) in
            if let channel = object as? ATCChatChannel {
                let vc = ATCChatThreadViewController(user: viewer,
                                                     channel: channel,
                                                     uiConfig: chatConfig,
                                                     reportingManager: reportingManager,
                                                     recipients: channel.participants)
                if channel.participants.count == 2 {
                    let otherUser = (viewer.uid == channel.participants.first?.uid) ? channel.participants[1] : channel.participants[0]
                    vc.title = otherUser.fullName()
                }
                navController?.pushViewController(vc, animated: true)
            }
        }
    }
}
