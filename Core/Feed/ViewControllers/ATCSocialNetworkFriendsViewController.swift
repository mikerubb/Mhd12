//
//  ATCSocialNetworkFriendsViewController.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 09/07/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCSocialNetworkFriendsViewController: ATCGenericCollectionViewController, ATCSearchBarAdapterDelegate {
    
    var viewer: ATCUser? = nil
    let uiConfig: ATCUIGenericConfigurationProtocol
    let reportingManager: ATCUserReportingProtocol?
    let socialManager: ATCFirebaseSocialGraphManager
    let userSearchDataSource: ATCGenericSearchViewControllerDataSource
    var friendsCollectionViewController: ATCGenericCollectionViewController?
    
    init(uiConfig: ATCUIGenericConfigurationProtocol, reportingManager: ATCUserReportingProtocol?, userSearchDataSource: ATCGenericSearchViewControllerDataSource) {
        self.uiConfig = uiConfig
        self.userSearchDataSource = userSearchDataSource
        self.reportingManager = reportingManager
        self.socialManager = ATCFirebaseSocialGraphManager()

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
      
        self.title = "Friends"
        
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateSocialGraph), name: kSocialGraphDidUpdateNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateSocialGraph), name: kUserReportingDidUpdateNotificationName, object: nil)
    }
    
    
    func friendSelectionBlock(viewer: ATCUser)  -> ATCollectionViewSelectionBlock? {
        return {[weak self] (navController, object, indexPath) in
            guard let `self` = self else { return }
            let uiConfig = ATCChatUIConfiguration(uiConfig: self.uiConfig)
            if let friendship = object as? ATCChatFriendship {
                let user = friendship.otherUser
                let id1 = (user.uid ?? "")
                let id2 = (viewer.uid ?? "")
                let channelId = id1 < id2 ? id1 + id2 : id2 + id1
                var channel = ATCChatChannel(id: channelId, name: user.fullName())
                channel.participants = [user, viewer]
                let vc = ATCChatThreadViewController(user: viewer, channel: channel, uiConfig: uiConfig, reportingManager: self.reportingManager, recipients: [user])
                navController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func update(user: ATCUser) {
        self.viewer = user
        guard let viewer = viewer else { fatalError() }

        // Configure Friends VC
        let emptyViewModel = CPKEmptyViewModel(image: nil,
                                               title: "No Friends",
                                               description: "Your friends will show up here. Add some friends to see their posts, stories and messages.", callToAction: nil)
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

        friendsCollectionViewController = ATCGenericCollectionViewController(configuration: collectionVCConfiguration)
        guard let friendsCollectionViewController = friendsCollectionViewController else { return }
        let adapter = ATCFriendshipRowAdapter(uiConfig: uiConfig)
        adapter.delegate = self
        friendsCollectionViewController.use(adapter: adapter, for: "ATCChatFriendship")
        
        friendsCollectionViewController.selectionBlock = self.friendSelectionBlock(viewer: viewer)
        friendsCollectionViewController.genericDataSource = ATCChatFirebaseFriendshipsDataSource(user: viewer)
        friendsCollectionViewController.genericDataSource?.loadFirst()

        let friendsViewModel = ATCViewControllerContainerViewModel(viewController: friendsCollectionViewController,
                                                                   cellHeight: nil,
                                                                   subcellHeight: 60,
                                                                   minTotalHeight: 200)
        friendsViewModel.parentViewController = self

        // Setup SearchBar
        let searchBar = ATCSearchBar(placeholder: "Search")
        let searchAdapter = ATCSearchBarAdapter(uiConfig: uiConfig)
        searchAdapter.delegate = self
        self.use(adapter: searchAdapter, for: "ATCSearchBar")
        
        self.use(adapter: ATCViewControllerContainerRowAdapter(), for: "ATCViewControllerContainerViewModel")
        self.registerReuseIdentifiers()
        self.genericDataSource = ATCGenericLocalHeteroDataSource(items: [searchBar, friendsViewModel])
        self.genericDataSource?.loadFirst()
    }
    
    private func sendPushNotification(to user: ATCUser) {
        guard let viewer = viewer else { return }
        let message = "\(viewer.fullName()) accepted your friend request"
        
        let notificationSender = ATCPushNotificationSender()
        if let token = user.pushToken, user.uid != viewer.uid {
            notificationSender.sendPushNotification(to: token, title: "SocialNetwork", body: message)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func didUpdateSocialGraph() {
        self.genericDataSource?.loadFirst()
    }

    // MARK: - ATCSearchBarAdapterDelegate
    func searchAdapterDidFocus(_ adapter: ATCSearchBarAdapter) {
        guard let viewer = viewer else { return }
        let searchVC = ATCChatUserSearchViewController.searchVC(uiConfig: uiConfig,
                                                                searchDataSource: userSearchDataSource,
                                                                viewer: viewer,
                                                                reportingManager: reportingManager)
        let navController = ATCNavigationController(rootViewController: searchVC, topNavigationLeftViews: nil, topNavigationRightViews: nil, topNavigationLeftImage: nil, topNavigationTintColor: nil)
        searchVC.cancelBlock = {() -> Void in
            searchVC.navigationController?.dismiss(animated: true, completion: nil)
            self.friendsCollectionViewController?.genericDataSource?.loadFirst()
        }
        self.present(navController, animated: true, completion: nil)
    }
}

extension ATCSocialNetworkFriendsViewController: ATCFriendshipRowAdapterDelegate {
    func friendshipAdapter(_ adapter: ATCFriendshipRowAdapter, didTakeActionOn friendship: ATCChatFriendship) {
        switch friendship.type {
        case .inbound:
            // Accept friendship
            self.socialManager.acceptFriendRequest(viewer: friendship.currentUser,
                                                   from: friendship.otherUser) {[weak self] in
                                                    guard let self = self else { return }
                                                    self.friendsCollectionViewController?.genericDataSource?.loadFirst()
            }
            sendPushNotification(to: friendship.otherUser)
            break
        case .outbound:
            // Cancel friend request
            self.socialManager.cancelFriendRequest(viewer: friendship.currentUser,
                                                   to: friendship.otherUser, completion: {
                                                    self.friendsCollectionViewController?.genericDataSource?.loadFirst()
            })
        default: break
        }
    }
}
