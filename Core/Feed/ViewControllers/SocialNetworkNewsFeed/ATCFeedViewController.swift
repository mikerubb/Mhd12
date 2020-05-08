//
//  ATCFeedViewController.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 05/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCFeedViewController: ATCGenericCollectionViewController {
    var uiConfig: ATCUIGenericConfigurationProtocol
    var viewer: ATCUser? = nil
    var storiesViewController: ATCGenericCollectionViewController? = nil
    var postsVC: ATCFeedPostsCollectionViewController?

    var storiesState: ATCStoriesUserState? = nil
    var storiesDatasource : [[ATCStory]] = []
    let loginManager = ATCFirebaseLoginManager()

    init(uiConfig: ATCUIGenericConfigurationProtocol, collectionVCConfiguration: ATCGenericCollectionViewControllerConfiguration) {
        self.uiConfig = uiConfig
        super.init(configuration: collectionVCConfiguration)

        self.title = "Feed"
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfileInfo),name: kATCLoggedInUserDataDidChangeNotification, object: nil)
    }

    static func feedVC(uiConfig: ATCUIGenericConfigurationProtocol) -> ATCFeedViewController {
        let collectionVCConfiguration = ATCGenericCollectionViewControllerConfiguration(
            pullToRefreshEnabled: false,
            pullToRefreshTintColor: uiConfig.mainThemeBackgroundColor,
            collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
            collectionViewLayout: ATCLiquidCollectionViewLayout(),
            collectionPagingEnabled: false,
            hideScrollIndicators: true,
            hidesNavigationBar: false,
            headerNibName: nil,
            scrollEnabled: true,
            uiConfig: uiConfig,
            emptyViewModel: nil
        )

        let feedVC = ATCFeedViewController(uiConfig: uiConfig, collectionVCConfiguration: collectionVCConfiguration)
        return feedVC
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
                                                    selectionBlock: self.storySelectionBlock(viewer: viewer))

        vc.use(adapter: ATCAddNewStoryCellAdapter(uiConfig: uiConfig), for: "ATCAddNewStory")
        vc.use(adapter: ATCChatUserStoryAdapter(uiConfig: uiConfig, loggedInUser: viewer), for: "ATCUser")
        vc.genericDataSource = dataSource
        storiesViewController = vc
        return vc
    }
    
    func storySelectionBlock(viewer: ATCUser) -> ATCollectionViewSelectionBlock? {
        return { (navController, object, indexPath) in
            if object is ATCUser {
                let storyViewController = ATCStoryContentViewController(datasource: self.storiesDatasource)
                guard let storiesState = self.storiesState else { return }
                if storiesState.selfStory {
                    storyViewController.currentIndex = indexPath.row
                } else {
                    storyViewController.currentIndex = indexPath.row - 1
                }
                self.present(storyViewController, animated: true)
                
            } else {
                let rootVC = ATCComposeNewStoryViewController(viewer: viewer)
                rootVC.delegate = self
                let vc = UINavigationController(rootViewController: rootVC)
                vc.isNavigationBarHidden = true
                self.present(vc, animated: true)
            }
        }
    }

    func update(user: ATCUser) {
        self.viewer = user
        guard let viewer = viewer else { return }

        // Configure Posts View Controller
        let socialNetworkFeedPostDataSource = ATCSocialNetworkNewsFeedDataSource(user: viewer)
        self.postsVC = ATCFeedPostsCollectionViewController(uiConfig: self.uiConfig, datasource: socialNetworkFeedPostDataSource, viewer: viewer)
        guard let postVC = self.postsVC else { return }

        let postsViewModel = ATCViewControllerContainerViewModel(viewController: postVC,
                                                                 cellHeight: nil,
                                                                 subcellHeight: nil,
                                                                 minTotalHeight: 400)
        postsViewModel.parentViewController = self
        self.use(adapter: ATCViewControllerContainerRowAdapter(), for: "ATCViewControllerContainerViewModel")
        
      // Configure Stories View Controller
        let storiesdatasource = ATCSocialNetworkStoriesDatasource(user: viewer)
        storiesdatasource.datasource = self
        let storiesVC = self.storiesViewController(uiConfig: self.uiConfig,
                                                   dataSource: storiesdatasource,
                                                   viewer: viewer)

        let storiesCarousel = ATCCarouselViewModel(title: nil,
                                                   viewController: storiesVC,
                                                   cellHeight: 100)
        storiesCarousel.parentViewController = self

        self.genericDataSource = ATCGenericLocalHeteroDataSource(items: [storiesCarousel, postsViewModel])
        self.genericDataSource?.loadFirst()
        self.registerReuseIdentifiers()
     
    }

    @objc private func updateProfileInfo() {
      
        if let viewer = self.viewer {
            loginManager.resyncPersistentUser(user: viewer) { (newUser) in
                guard let newUser = newUser else { return }
                self.update(user: newUser)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ATCFeedViewController: ATCDidCreateNewPostDelegate, ATCDidCreateNewStoryDelegate {
    func didCreateNewPost() {
        guard let postVC = postsVC else { return }
        DispatchQueue.main.async {
            postVC.genericDataSource?.loadFirst()
        }
    }
    
    func didCreateNewStory() {
        guard let storiesViewController = storiesViewController else { return }
        DispatchQueue.main.async {
            storiesViewController.genericDataSource?.loadFirst()
        }
    }
}


extension ATCFeedViewController: ATCFetchCompleted {
    func fetchCompleted(state: ATCStoriesUserState) {
        self.storiesState = state
        self.storiesDatasource = state.stories
    }
}

