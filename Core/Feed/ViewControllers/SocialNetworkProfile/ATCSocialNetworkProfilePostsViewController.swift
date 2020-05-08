//
//  ATCSocialNetworkProfilePostsViewController.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 11/07/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCSocialNetworkProfilePostsViewController : ATCGenericCollectionViewController {
    var uiConfig: ATCUIGenericConfigurationProtocol
    var datasource: ATCGenericCollectionViewControllerDataSource
    let cellId = "ATCPost"
    let viewer: ATCUser?
    let loggedInUser: ATCUser?
    var moreOptions: ATCSocialNetworkMoreOptions!
    
    init(uiConfig: ATCUIGenericConfigurationProtocol, datasource: ATCGenericCollectionViewControllerDataSource, viewer: ATCUser, loggedInUser: ATCUser) {
        self.uiConfig = uiConfig
        self.datasource = datasource
        self.viewer = viewer
        self.loggedInUser = loggedInUser
        
        
        let layout = ATCCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 8
        let configuration = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
                                                                            pullToRefreshTintColor: UIColor.darkModeColor(hexString: "f5f5f5"),
                                                                            collectionViewBackgroundColor: UIColor.darkModeColor(hexString: "f5f5f5"),
                                                                            collectionViewLayout: layout,
                                                                            collectionPagingEnabled: false,
                                                                            hideScrollIndicators: true,
                                                                            hidesNavigationBar: false,
                                                                            headerNibName: nil,
                                                                            scrollEnabled: true,
                                                                            uiConfig: uiConfig,
                                                                            emptyViewModel: nil)
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
                guard let loggedInUser = self.loggedInUser else { return }
                let detailPostVC = ATCDetailPostViewController(uiConfig: self.uiConfig, post: selectedPost, loggedInUser: loggedInUser)
                navController?.pushViewController(detailPostVC, animated: true)
            }
        }
    }
}

extension ATCSocialNetworkProfilePostsViewController : ATCFeedPostCellAdapterDelegate {

    func showCommentTextView(_ userAdapter: ATCFeedPostCellAdapter, on post: ATCPost) {}
    func profileImageDidTap(_ userAdapter: ATCFeedPostCellAdapter, on post: ATCPost) {}
    
    func moreButtonDidTap(_ userAdapter: ATCFeedPostCellAdapter, cell: ATCPostCell, on post: ATCPost) {
        guard let navigationController = self.navigationController else { return }
        guard let loggedInUser = self.loggedInUser else { return }
        moreOptions = ATCSocialNetworkMoreOptions(viewer: loggedInUser, navController: navigationController)
        moreOptions.delegate = self
        moreOptions.showPostActionSheet(on: post, cell: cell)
    }
    
    
    func updateReaction(_ userAdapter: ATCFeedPostCellAdapter, on post: ATCPost, reaction: String) {
        guard let loggedInUser = loggedInUser else { return }
        let socialNetworkManager = ATCSocialNetworkFirebaseAPIManager()
        socialNetworkManager.updatePostReactions(loggedInUser: loggedInUser, post: post, reaction: reaction) {
            self.genericDataSource?.loadFirst()
        }
    }
    
    func didTapComment(_ userAdapter: ATCFeedPostCellAdapter, on post: ATCPost) {
        guard let viewer = viewer else { return }
        let detailPostVC = ATCDetailPostViewController(uiConfig: self.uiConfig, post: post, loggedInUser: viewer)
        detailPostVC.addNewCommentTextView.becomeFirstResponder()
        self.navigationController?.pushViewController(detailPostVC, animated: true)
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

extension ATCSocialNetworkProfilePostsViewController : ATCPostDidGetDeletedDelegate {
    func postDeletedOnNewsFeed() {}
    func postDeletedOnDetailPage() {}

    func postDeletedOnProfilePage() {
        self.genericDataSource?.loadFirst()
    }
}
