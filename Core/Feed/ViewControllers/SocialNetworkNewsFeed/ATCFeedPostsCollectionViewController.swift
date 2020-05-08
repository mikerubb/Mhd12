//
//  ATCFeedPostsCollectionViewController.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 07/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit


class ATCFeedPostsCollectionViewController : ATCGenericCollectionViewController {
    var uiConfig: ATCUIGenericConfigurationProtocol
    var datasource: ATCGenericCollectionViewControllerDataSource
    let cellId = "ATCPost"
    var viewer: ATCUser?
    
    var moreOptions: ATCSocialNetworkMoreOptions!
    
    init(uiConfig: ATCUIGenericConfigurationProtocol, datasource: ATCGenericCollectionViewControllerDataSource, viewer: ATCUser) {
        self.uiConfig = uiConfig
        self.datasource = datasource
        self.viewer = viewer
        
        let layout = ATCCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 8
        let emptyViewModel = CPKEmptyViewModel(image: nil,
                                               title: "No Posts",
                                               description: "Posts from your friends will show up here. Add some friends to see their posts, stories and messages.",
                                               callToAction: nil)
        let configuration = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
                                                                            pullToRefreshTintColor: UIColor.darkModeColor(hexString: "#f5f5f5"),
                                                                            collectionViewBackgroundColor: UIColor.darkModeColor(hexString: "#f5f5f5"),
                                                                            collectionViewLayout: layout,
                                                                            collectionPagingEnabled: false,
                                                                            hideScrollIndicators: true,
                                                                            hidesNavigationBar: false,
                                                                            headerNibName: nil,
                                                                            scrollEnabled: true,
                                                                            uiConfig: uiConfig,
                                                                            emptyViewModel: emptyViewModel)
        super.init(configuration: configuration)
        
        let adapter = ATCFeedPostCellAdapter(uiConfig: uiConfig)
        adapter.delegate = self
        self.use(adapter: adapter, for: "ATCPost")
        
        self.genericDataSource = datasource
        self.selectionBlock = self.feedPostsSelectionBlock()
    }

    override func registerReuseIdentifiers() {
        collectionView.register(ATCPostCell.self, forCellWithReuseIdentifier: cellId)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func feedPostsSelectionBlock()  -> ATCollectionViewSelectionBlock? {
        return { (navController, object, indexPath) in
            if let selectedPost = object as? ATCPost {
                guard let viewer = self.viewer else { return }
                let detailPostVC = ATCDetailPostViewController(uiConfig: self.uiConfig, post: selectedPost, loggedInUser: viewer)
                detailPostVC.delegate = self
                navController?.pushViewController(detailPostVC, animated: true)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 8, bottom: 0, right: 8)
    }

}

extension ATCFeedPostsCollectionViewController : ATCFeedPostCellAdapterDelegate {
    
    func showCommentTextView(_ userAdapter: ATCFeedPostCellAdapter, on post: ATCPost) {}
    
    func moreButtonDidTap(_ userAdapter: ATCFeedPostCellAdapter, cell: ATCPostCell, on post: ATCPost) {
        guard let navigationController = self.navigationController else { return  }
        guard let selectedViewer = viewer else { return }
        moreOptions = ATCSocialNetworkMoreOptions(viewer: selectedViewer, navController: navigationController)
        moreOptions.delegate = self
        moreOptions.showPostActionSheet(on: post, cell: cell)
    }

    func updateReaction(_ userAdapter: ATCFeedPostCellAdapter, on post: ATCPost, reaction: String) {
        guard let viewer = viewer else { return }
        guard let loggedInUserUID = viewer.uid else { return }
        guard let postAuthorID = post.authorID else { return }
        let socialNetworkManager = ATCSocialNetworkFirebaseAPIManager()
        
        let notificationComposer = ATCNotificationComposerState(post: post, notificationAuthorID: loggedInUserUID, reacted: true, commented: false, isInteracted: false, createdAt: Date())
        
        if postAuthorID != loggedInUserUID {
            socialNetworkManager.postNotification(composer: notificationComposer) {
                print("Notification Posted")
            }
        }

        socialNetworkManager.updatePostReactions(loggedInUser: viewer, post: post, reaction: reaction) {
             self.genericDataSource?.loadFirst()
        }
    }
    
    func didTapComment(_ userAdapter: ATCFeedPostCellAdapter, on post: ATCPost) {
        guard let viewer = viewer else { return }
        let detailPostVC = ATCDetailPostViewController(uiConfig: self.uiConfig, post: post, loggedInUser: viewer)
        detailPostVC.addNewCommentTextView.becomeFirstResponder()
        self.navigationController?.pushViewController(detailPostVC, animated: true)
    }
    
    func profileImageDidTap(_ userAdapter: ATCFeedPostCellAdapter, on post: ATCPost) {
        guard let viewer = viewer else { return }
        let postAuthorID = post.authorID
        guard let authorID = postAuthorID else { return }
        
        let userManager = ATCSocialFirebaseUserManager()
        userManager.fetchUser(userID: authorID) { (user) in
            guard let user = user else { return }
            let profileViewController = ATCSocialNetworkProfileViewController(uiConfig: self.uiConfig)
            profileViewController.loggedInUser = viewer //self is always passed to check which profile to show
            profileViewController.user = user   //Could be friend or self
            self.navigationController?.pushViewController(profileViewController, animated: true)
        }
    }
    
    func imageDidTap(_ userAdapter: ATCFeedPostCellAdapter, on post: ATCPost, at indexPath: IndexPath) {
        let imageViewerVC = ATCMediaViewerViewController(uiConfig: uiConfig)
        let imagesURL = post.postMedia
        let images = imagesURL.map { ATCImage($0) }
        imageViewerVC.datasource = images
        imageViewerVC.selectedIndexPath = indexPath
        self.navigationController?.present(imageViewerVC, animated: true, completion: nil)
    }
}


extension ATCFeedPostsCollectionViewController : ATCPostDidGetDeletedDelegate {
    func postDeletedOnDetailPage() {}
    func postDeletedOnProfilePage() {}
    
    func postDeletedOnNewsFeed() {
        DispatchQueue.main.async {
            self.genericDataSource?.loadFirst()
        }
    }
}

extension ATCFeedPostsCollectionViewController : ATCUpdateNewsFeedDelegate {
    func refreshNewsFeed() {
        DispatchQueue.main.async {
            self.genericDataSource?.loadFirst()
        }
    }
}
