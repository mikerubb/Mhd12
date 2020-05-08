//
//  ATCSocialNetworkNotificationVC.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 29/07/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCSocialNetworkNotificationVC : ATCGenericCollectionViewController {

    let uiConfig : ATCUIGenericConfigurationProtocol
    var viewer: ATCUser? = nil

    init(uiConfig: ATCUIGenericConfigurationProtocol) {
        self.uiConfig = uiConfig
        let collectionVCConfiguration = ATCGenericCollectionViewControllerConfiguration(
            pullToRefreshEnabled: false,
            pullToRefreshTintColor: uiConfig.mainThemeBackgroundColor,
            collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
            collectionViewLayout: ATCLiquidCollectionViewLayout(),
            collectionPagingEnabled: false,
            hideScrollIndicators: false,
            hidesNavigationBar: false,
            headerNibName: nil,
            scrollEnabled: true,
            uiConfig: uiConfig,
            emptyViewModel: nil
        )
        super.init(configuration: collectionVCConfiguration)
        self.title = "Notifications"
    }

    func update(viewer: ATCUser) {
        self.viewer = viewer
        guard let viewer = self.viewer else { return }
        
        // Setting up datasource and collectionView
        let datasource = ATCSocialNetworkNotificationsDataSource(loggedInUser: viewer)
        let vc = ATCSocialNetworkNotificationsChildVC(uiConfig: uiConfig,
                                                      datasource: datasource,
                                                      loggedInUser: viewer)
        
        let discoverPostViewModel = ATCViewControllerContainerViewModel(viewController: vc, cellHeight: nil, subcellHeight: 90)
        discoverPostViewModel.parentViewController = self

        self.use(adapter: ATCViewControllerContainerRowAdapter(), for: "ATCViewControllerContainerViewModel")
        self.genericDataSource = ATCGenericLocalHeteroDataSource(items: [discoverPostViewModel])
        self.registerReuseIdentifiers()
        self.genericDataSource?.loadFirst()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
