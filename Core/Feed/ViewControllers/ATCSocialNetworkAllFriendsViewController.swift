//
//  ATCSocialNetworkAllFriendsViewController.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 18/07/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCSocialNetworkAllFriendsViewController: ATCGenericCollectionViewController {
    var uiConfig: ATCUIGenericConfigurationProtocol
    var viewer: ATCUser? = nil
    var loggedInUser: ATCUser? = nil
    
    init(uiConfig: ATCUIGenericConfigurationProtocol, loggedInUser: ATCUser) {
        self.uiConfig = uiConfig
        self.loggedInUser = loggedInUser
        
        let layout = ATCCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let configuration = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
                                                                            pullToRefreshTintColor:  UIColor.darkModeColor(hexString: "#f5f5f5"),
                                                                            collectionViewBackgroundColor: UIColor.darkModeColor(hexString: "#f5f5f5"),
                                                                            collectionViewLayout: layout,
                                                                            collectionPagingEnabled: false,
                                                                            hideScrollIndicators: false,
                                                                            hidesNavigationBar: false,
                                                                            headerNibName: nil,
                                                                            scrollEnabled: true,
                                                                            uiConfig: uiConfig,
                                                                            emptyViewModel: nil)
        
        super.init(configuration: configuration)
        self.title = "All Friends"
        let adapter = ATCFriendsAdapter(uiConfig: uiConfig)
        self.use(adapter: adapter, for: "ATCUser")
    }

    func update(viewer: ATCUser) {
        self.viewer = viewer
        guard let viewer = self.viewer else { return }
        
        self.selectionBlock = self.friendsSelectionBlock()
        
        self.genericDataSource = ATCChatFirebaseFriendsDataSource(user: viewer)
        self.genericDataSource?.loadFirst()
    }

    private func friendsSelectionBlock() -> ATCollectionViewSelectionBlock? {
        return {[weak self] (navController, object, indexPath) in
            print("TAPPED")
            if let friendUser = object as? ATCUser {
                guard let strongSelf = self else { return }
                guard let loggedInUser = strongSelf.loggedInUser else { return }
                let profileVC = ATCSocialNetworkProfileViewController(uiConfig: strongSelf.uiConfig)
                profileVC.loggedInUser = loggedInUser
                profileVC.user = friendUser
                strongSelf.navigationController?.pushViewController(profileVC, animated: true)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
