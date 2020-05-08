//
//  ATCSocialNetworkProfileFriendsListCV.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 24/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCSocialNetworkProfileFriendsListVC : ATCGenericCollectionViewController {
    var uiConfig : ATCUIGenericConfigurationProtocol
    var cellId = "ATCUser"
    var user: ATCUser? = nil
    var loggedInUser: ATCUser? = nil

    init(uiConfig: ATCUIGenericConfigurationProtocol, user: ATCUser, loggedInUser: ATCUser) {
        self.uiConfig = uiConfig
        self.user = user
        self.loggedInUser = loggedInUser

        let layout = ATCCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12

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
        self.use(adapter: ATCProfileFriendCellAdapter(uiConfig: uiConfig), for: "ATCUser")
        let friendsDatasource = ATCSocialNetworkProfileFriendsDataSource(user: user)
        self.genericDataSource = friendsDatasource
        self.selectionBlock = self.friendsListSelectionBlock()
    }

    private func friendsListSelectionBlock() -> ATCollectionViewSelectionBlock? {
        return {[weak self] (navController, object, indexPath) in
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

    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 16, bottom: 0, right: 16)
    }

    override func registerReuseIdentifiers() {
        collectionView.register(ATCProfileFriendCell.self, forCellWithReuseIdentifier: cellId)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
