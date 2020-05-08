//
//  ATCChatHomeViewController.swift
//  ChatApp
//
//  Created by Florian Marcu on 8/21/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class ATCChatHomeViewController: ATCGenericCollectionViewController, ATCSearchBarAdapterDelegate {
    let userSearchDataSource: ATCGenericSearchViewControllerDataSource
    let threadsDataSource: ATCGenericCollectionViewControllerDataSource
    var viewer: ATCUser? = nil
    let uiConfig: ATCUIGenericConfigurationProtocol
    let reportingManager: ATCUserReportingProtocol?
    let loginManager = ATCFirebaseLoginManager()

    init(configuration: ATCGenericCollectionViewControllerConfiguration,
         uiConfig: ATCUIGenericConfigurationProtocol,
         selectionBlock: ATCollectionViewSelectionBlock?,
         threadsDataSource: ATCGenericCollectionViewControllerDataSource,
         userSearchDataSource: ATCGenericSearchViewControllerDataSource,
         reportingManager: ATCUserReportingProtocol?) {
        self.userSearchDataSource = userSearchDataSource
        self.threadsDataSource = threadsDataSource
        self.uiConfig = uiConfig
        self.reportingManager = reportingManager
        super.init(configuration: configuration, selectionBlock: selectionBlock)

        self.title = "Chat"
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateSocialGraph), name: kSocialGraphDidUpdateNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateSocialGraph), name: kUserReportingDidUpdateNotificationName, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(updateProfileInfo),name: kATCLoggedInUserDataDidChangeNotification, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func homeVC(uiConfig: ATCUIGenericConfigurationProtocol,
                       threadsDataSource: ATCGenericCollectionViewControllerDataSource,
                       userSearchDataSource: ATCGenericSearchViewControllerDataSource,
                       reportingManager: ATCUserReportingProtocol?) -> ATCChatHomeViewController {
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

        let homeVC = ATCChatHomeViewController(configuration: collectionVCConfiguration, uiConfig: uiConfig, selectionBlock: { (navController, object, indexPath) in

        }, threadsDataSource: threadsDataSource, userSearchDataSource: userSearchDataSource, reportingManager: reportingManager)
        return homeVC
    }


    func storiesViewController(uiConfig: ATCUIGenericConfigurationProtocol,
                               dataSource: ATCGenericCollectionViewControllerDataSource,
                               viewer: ATCUser) -> ATCGenericCollectionViewController {
        let layout = ATCCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        let configuration = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
                                                                            pullToRefreshTintColor: uiConfig.mainThemeBackgroundColor,
                                                                            collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
                                                                            collectionViewLayout: layout,
                                                                            collectionPagingEnabled: false,
                                                                            hideScrollIndicators: true,
                                                                            hidesNavigationBar: false,
                                                                            headerNibName: nil,
                                                                            scrollEnabled: true,
                                                                            uiConfig: uiConfig,
                                                                            emptyViewModel: nil)
        let vc = ATCGenericCollectionViewController(configuration: configuration,
                                                    selectionBlock: self.storySelectionBlock(viewer: viewer,
                                                                                             uiConfig: uiConfig))
        vc.genericDataSource = dataSource
        vc.use(adapter: ATCChatUserStoryAdapter(uiConfig: uiConfig, loggedInUser: viewer), for: "ATCUser")
        return vc
    }

    func storySelectionBlock(viewer: ATCUser, uiConfig: ATCUIGenericConfigurationProtocol) -> ATCollectionViewSelectionBlock? {
        return {[weak self] (navController, object, indexPath) in
            guard let `self` = self else { return }
            let uiConfig = ATCChatUIConfiguration(uiConfig: uiConfig)
            if let user = object as? ATCUser {
                let id1 = (user.uid ?? "")
                let id2 = (viewer.uid ?? "")
                let channelId = id1 < id2 ? id1 + id2 : id2 + id1
                var channel = ATCChatChannel(id: channelId, name: user.fullName())
                channel.participants = [user, viewer]
                let vc = ATCChatThreadViewController(user: viewer,
                                                     channel: channel,
                                                     uiConfig: uiConfig,
                                                     reportingManager: self.reportingManager,
                                                     recipients: [user])
                navController?.pushViewController(vc, animated: true)
            }
        }
    }

    func update(user: ATCUser) {
        self.viewer = user
        guard let viewer = viewer else { fatalError() }

        // Update user search data source
        userSearchDataSource.viewer = viewer

        // Configure search bar
        let searchBar = ATCSearchBar(placeholder: "Search for friends")
        let searchAdapter = ATCSearchBarAdapter(uiConfig: uiConfig)
        searchAdapter.delegate = self
        self.use(adapter: searchAdapter, for: "ATCSearchBar")

        // Configure Stories carousel
        let friendsDataSource = ATCChatFirebaseFriendsDataSource(user: viewer)
        let storiesVC = self.storiesViewController(uiConfig: uiConfig,
                                                   dataSource: friendsDataSource,
                                                   viewer: viewer)
        let storiesCarousel = ATCCarouselViewModel(title: nil,
                                                   viewController: storiesVC,
                                                   cellHeight: 105)
        storiesCarousel.parentViewController = self

        // Configure list of message threads
        let chatConfig = ATCChatUIConfiguration(uiConfig: uiConfig)

        let emptyViewModel = CPKEmptyViewModel(image: nil,
                                               title: "No Conversations",
                                               description: "Add friends and start conversations with them. Your conversations will show up here.",
                                               callToAction: "Add Friends")
        let threadsVC = ATCChatThreadsViewController.firebaseThreadsVC(uiConfig: uiConfig,
                                                                       dataSource: threadsDataSource,
                                                                       viewer: viewer,
                                                                       reportingManager: reportingManager,
                                                                       chatConfig: chatConfig,
                                                                       emptyViewModel: emptyViewModel)
        
        let threadsViewModel = ATCViewControllerContainerViewModel(viewController: threadsVC,
                                                                   cellHeight: nil,
                                                                   subcellHeight: 85,
                                                                   minTotalHeight: 200)
        threadsViewModel.parentViewController = self
        self.use(adapter: ATCViewControllerContainerRowAdapter(), for: "ATCViewControllerContainerViewModel")

        self.registerReuseIdentifiers()

        if let threadsDataSource = threadsDataSource as? ATCChatFirebaseChannelDataSource {
            threadsDataSource.user = user
        }
        self.genericDataSource = ATCGenericLocalHeteroDataSource(items: [searchBar, storiesCarousel, threadsViewModel])
        self.genericDataSource?.loadFirst()
    }

    // MARK: - ATCSearchBarAdapterDelegate
    func searchAdapterDidFocus(_ adapter: ATCSearchBarAdapter) {
        guard let viewer = viewer else { return }
        let searchVC = ATCChatUserSearchViewController.searchVC(uiConfig: self.configuration.uiConfig,
                                                                searchDataSource: userSearchDataSource,
                                                                viewer:viewer,
                                                                reportingManager: reportingManager)
        let navController = ATCNavigationController(rootViewController: searchVC, topNavigationLeftViews: nil, topNavigationRightViews: nil, topNavigationLeftImage: nil, topNavigationTintColor: nil)
        searchVC.cancelBlock = {() -> Void in
            searchVC.navigationController?.dismiss(animated: true, completion: nil)
        }
        self.present(navController, animated: true, completion: nil)
    }

    // MAR: - Private
    @objc
    private func didUpdateSocialGraph() {
        guard let viewer = viewer else { return }
        // This will update the home screen
        self.update(user: viewer)
    }
    
    @objc private func updateProfileInfo() {
        if let viewer = self.viewer {
            loginManager.resyncPersistentUser(user: viewer) { (newUser) in
                guard let newUser = newUser else { return }
                self.update(user: newUser)
            }
        }
    }
}
