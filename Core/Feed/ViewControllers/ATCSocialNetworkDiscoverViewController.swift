//
//  ATCSocialNetworkDiscoverViewController.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 10/07/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit


class ATCSocialNetworkDiscoverViewController : ATCGenericCollectionViewController {
    
    let uiConfig : ATCUIGenericConfigurationProtocol
    var viewer: ATCUser? = nil
    
    init(uiConfig: ATCUIGenericConfigurationProtocol) {
        self.uiConfig = uiConfig
        let emptyViewModel = CPKEmptyViewModel(image: nil,
                                               title: "No Posts",
                                               description: "Popular posts will show up here.",
                                               callToAction: nil)
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
            emptyViewModel: emptyViewModel
        )
        super.init(configuration: collectionVCConfiguration)
        self.title = "Discover"
     
        
    }
    
    func update(viewer: ATCUser) {
        self.viewer = viewer
        guard let viewer = self.viewer else { return }
        
        
        // Setting up datasource and collectionView
        let datasource = ATCSocialNetworkDiscoverDatasource(viewer: viewer)
        let vc = ATCFeedPostsCollectionViewController(uiConfig: uiConfig, datasource: datasource, viewer: viewer)
    
        let discoverPostViewModel = ATCViewControllerContainerViewModel(viewController: vc, cellHeight: nil, subcellHeight: nil)
        discoverPostViewModel.parentViewController = self
        
        
        self.use(adapter: ATCViewControllerContainerRowAdapter(), for: "ATCViewControllerContainerViewModel")
        self.genericDataSource = ATCGenericLocalHeteroDataSource(items: [discoverPostViewModel])
        self.genericDataSource?.loadFirst()
        self.registerReuseIdentifiers()
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
