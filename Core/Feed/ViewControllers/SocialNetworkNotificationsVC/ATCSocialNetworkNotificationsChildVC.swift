//
//  ATCSocialNetworkNotificationsChildVC.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 29/07/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCSocialNetworkNotificationsChildVC : ATCGenericCollectionViewController {
    
    let uiConfig : ATCUIGenericConfigurationProtocol
    let datasource: ATCGenericCollectionViewControllerDataSource
    var loggedInUser: ATCUser? = nil
    
    init(uiConfig: ATCUIGenericConfigurationProtocol, datasource: ATCGenericCollectionViewControllerDataSource, loggedInUser: ATCUser) {
        self.uiConfig = uiConfig
        self.datasource = datasource
        self.loggedInUser = loggedInUser
        
        let layout = ATCCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let collectionVCConfiguration = ATCGenericCollectionViewControllerConfiguration(
            pullToRefreshEnabled: false,
            pullToRefreshTintColor: uiConfig.mainThemeBackgroundColor,
            collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
            collectionViewLayout: layout,
            collectionPagingEnabled: false,
            hideScrollIndicators: false,
            hidesNavigationBar: false,
            headerNibName: nil,
            scrollEnabled: true,
            uiConfig: uiConfig,
            emptyViewModel: nil
        )
        super.init(configuration: collectionVCConfiguration)
        self.use(adapter: ATCSocialNetworkNotificationCellAdapter(uiConfig: uiConfig),
                 for: "ATCSocialNetworkNotification")
        self.genericDataSource = datasource
        self.selectionBlock = self.notificationsSelectionBlock()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.genericDataSource?.loadFirst()
    }
    
    func notificationsSelectionBlock()  -> ATCollectionViewSelectionBlock? {
        return { (navController, object, indexPath) in
            if let object = object as? ATCSocialNetworkNotification {
                guard let loggedInUser = self.loggedInUser else { return }
                let postID = object.postID
                let notificationID = object.id
                let socialManager = ATCSocialNetworkFirebaseAPIManager()
                socialManager.updateNotification(loggedInUser: loggedInUser, notificationID: notificationID, completion: {
                    print("Notification Interacted")
                })
                socialManager.fetchPostUsingID(postID: postID, loggedInUser: loggedInUser, completion: { (post) in
                    let detailPostVC = ATCDetailPostViewController(uiConfig: self.uiConfig, post: post, loggedInUser: loggedInUser)
                    navController?.pushViewController(detailPostVC, animated: true)
                })
            }
        }
    }
    
    override func registerReuseIdentifiers() {
        self.collectionView.register(ATCNotificationCell.self, forCellWithReuseIdentifier: "ATCSocialNetworkNotification")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
