//
//  ATCPostViewController.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 12/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit


class ATCPostViewController : ATCGenericCollectionViewController {
    
    //MARK: - Properties
    var uiConfig: ATCUIGenericConfigurationProtocol
    var datasource: ATCGenericCollectionViewControllerDataSource
    let cellId = "ATCPost"
    var storiesViewController: ATCGenericCollectionViewController? = nil
    var loggedInUser: ATCUser? = nil
    var adapter: ATCFeedPostCellAdapter? = nil
    
    //MARK: - Init
    init(uiConfig: ATCUIGenericConfigurationProtocol, datasource: ATCGenericCollectionViewControllerDataSource, loggedInUser: ATCUser) {
        self.uiConfig = uiConfig
        self.datasource = datasource
        self.loggedInUser = loggedInUser

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
        adapter = ATCFeedPostCellAdapter(uiConfig: uiConfig)
        guard let adapter = adapter else { return }
        self.use(adapter: adapter, for: "ATCPost")
       
        setupDatasource()
    }

    
    private func setupDatasource() {
        self.genericDataSource = datasource
        self.genericDataSource?.loadFirst()
    }
    
    override func registerReuseIdentifiers() {
        collectionView.register(ATCPostCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


