//
//  ATCDetailPostViewController.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 11/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

protocol ATCUpdateNewsFeedDelegate: class {
    func refreshNewsFeed()
}

class ATCDetailPostViewController : ATCGenericCollectionViewController {
    
    //MARK: - Properties
    var uiConfig: ATCUIGenericConfigurationProtocol
    var post: ATCPost? = nil
    var loggedInUser: ATCUser? = nil
    var storiesViewController: ATCGenericCollectionViewController? = nil
    var moreOptions: ATCSocialNetworkMoreOptions!
    var postUser: ATCUser? = nil
    var delegate: ATCUpdateNewsFeedDelegate? = nil
    var postCommentsCount: Int = 0
    
    var textViewBottomAnchor: NSLayoutConstraint?
    var textHeightConstraint: NSLayoutConstraint?
    var containerHeightConstraint: NSLayoutConstraint?
    
    let textViewContainerViewHeight: CGFloat = 38
    let textViewHeight: CGFloat = 30
    var keyboardHeight: CGFloat = 0
    
    let placeholderText = "Add Comment to this Post"
    
    var textViewContainerView: UIView = {
        let textview = UIView()
        textview.translatesAutoresizingMaskIntoConstraints = false
        textview.backgroundColor = UIColor.darkModeColor(hexString: "#f6f6f6")
        return textview
    }()

    lazy var addNewCommentTextView: UITextView = {
        let textview = UITextView()
        textview.translatesAutoresizingMaskIntoConstraints = false
        textview.delegate = self
        textview.text = placeholderText
        textview.textColor = self.uiConfig.mainTextColor
        textview.backgroundColor = self.uiConfig.mainThemeBackgroundColor
        textview.isScrollEnabled = false
        textview.font = UIFont.systemFont(ofSize: 14)
        textview.tintColor = self.uiConfig.mainTextColor
        textview.contentInset = UIEdgeInsets(top: 4, left: 4, bottom: 0, right: 4)
        return textview
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "share-icon")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = self.uiConfig.colorGray0
        button.addTarget(self, action: #selector(handlePostCommentButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var transparentBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var detailedPostVC: ATCPostViewController? = nil
    var commentsVC: ATCCommentsViewController? = nil
    
    //MARK: - Init
    init(uiConfig: ATCUIGenericConfigurationProtocol, post: ATCPost, loggedInUser: ATCUser) {
        self.uiConfig = uiConfig
        self.post = post
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
        self.title = "Detail Post"
        fetchPostUser()
        configureControllers()
        addViews()
        setupViews()
        adjustTextViewHeight()
        configureDismissKeyboardOnTap()
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeKeyboardWillShow()
        observeKeyboardWillHide()
        addNewCommentTextView.selectedTextRange = addNewCommentTextView.textRange(from: addNewCommentTextView.beginningOfDocument, to: addNewCommentTextView.beginningOfDocument)
       // fetchPostUser()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    

    
    //MARK: - Configurations
    func configureControllers() {
        guard let post = post else { return }
        guard let loggedInUser = loggedInUser else {
            print("Viewer Not found")
            return
            
        }
        let commentdatasource = ATCSocialNetworkCommentsDataSource(user: loggedInUser, post: post)
        let postDatasource = ATCSocialNetworkDetailPostDatasource(viewer: loggedInUser,post: post)
    
        commentsVC = ATCCommentsViewController(uiConfig: uiConfig, datasource: commentdatasource)
        detailedPostVC = ATCPostViewController(uiConfig: uiConfig, datasource: postDatasource, loggedInUser: loggedInUser)
        
        guard let detailedPostVC = detailedPostVC else { return }
        guard let commentsVC = commentsVC else { return }
        
        let commentsViewModel = ATCViewControllerContainerViewModel(viewController: commentsVC, cellHeight: nil, subcellHeight: nil)
        let detailPostViewModel = ATCCarouselViewModel(title: nil, viewController: detailedPostVC, cellHeight: calculateCellHeight())
        
        self.use(adapter: ATCViewControllerContainerRowAdapter(), for: "ATCViewControllerContainerViewModel")
        
        commentsViewModel.parentViewController = self
        detailPostViewModel.parentViewController = self
    
        detailedPostVC.adapter?.delegate = self
        self.registerReuseIdentifiers()
        
  
        self.genericDataSource = ATCGenericLocalHeteroDataSource(items: [detailPostViewModel,commentsViewModel])
        
        
        self.genericDataSource?.loadFirst()
    }

    
    //Calculating the detailed post height
    func calculateCellHeight() -> CGFloat {
        var knownHeight : CGFloat = 0
        var cellHeight: CGFloat = 0
        if let post = post {
            let width = self.view.frame.width - 54
            let text = post.postText
            
            if post.postMedia.isEmpty {
                knownHeight =  122 + 28
            }else if (post.postText.isEmpty) && !(post.postMedia.isEmpty) {
                knownHeight = 200 + 120
            }else {
                knownHeight = 322 + 28
            }
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 2
            let rect = NSString(string: text).boundingRect(with: CGSize(width: width, height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.paragraphStyle: style], context: nil)
             cellHeight = rect.height + knownHeight
        }
        return cellHeight
    }
    
    fileprivate func addViews() {
        view.addSubview(transparentBackgroundView)
        view.addSubview(textViewContainerView)
        textViewContainerView.addSubview(addNewCommentTextView)
        textViewContainerView.addSubview(sendButton)
    }
    
    fileprivate func setupViews() {
        transparentBackgroundView.bottomAnchor.constraint(equalTo: textViewContainerView.topAnchor).isActive = true
        transparentBackgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        transparentBackgroundView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        transparentBackgroundView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        
        textViewBottomAnchor = textViewContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        textViewBottomAnchor?.isActive = true
        
        textViewContainerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        textViewContainerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        containerHeightConstraint = textViewContainerView.heightAnchor.constraint(equalToConstant: textViewContainerViewHeight)
        containerHeightConstraint?.isActive = true
        
        addNewCommentTextView.bottomAnchor.constraint(equalTo: textViewContainerView.bottomAnchor, constant: -4).isActive = true
        addNewCommentTextView.leftAnchor.constraint(equalTo: textViewContainerView.leftAnchor, constant: 8).isActive = true
        addNewCommentTextView.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: -8).isActive = true
        textHeightConstraint = addNewCommentTextView.heightAnchor.constraint(equalToConstant: textViewHeight)
        textHeightConstraint?.isActive = true
        
        sendButton.bottomAnchor.constraint(equalTo: textViewContainerView.bottomAnchor, constant: -4).isActive = true
        sendButton.rightAnchor.constraint(equalTo: textViewContainerView.rightAnchor, constant: -8).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    fileprivate func fetchPostUser() {
        let userManager = ATCSocialFirebaseUserManager()
        guard let post = post else { return }
        guard let postAuthorID = post.authorID else { return }
        userManager.fetchUser(userID: postAuthorID) { (user) in
            self.postUser = user
        }
    }
    
    // Comment Text View Height Adjustment
    fileprivate func adjustTextViewHeight() {
        let fixedWidth = addNewCommentTextView.frame.size.width
        let newSize = addNewCommentTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        self.textHeightConstraint?.constant = newSize.height
        
        let heightDifference = newSize.height - textViewHeight
        let newParentContainerHeight = textViewContainerViewHeight + heightDifference
        
        self.containerHeightConstraint?.constant = newParentContainerHeight
        self.view.layoutIfNeeded()
    }
    
    fileprivate func observeKeyboardWillShow() {
        NotificationCenter.default.addObserver(self, selector: #selector(commentKeyboardWillShow),name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    fileprivate func observeKeyboardWillHide() {
          NotificationCenter.default.addObserver(self, selector: #selector(commentKeyboardWillHide),name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func commentKeyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            transparentBackgroundView.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                let tabBarHeight : CGFloat = self.tabBarController?.tabBar.frame.height ?? 0
                self.textViewBottomAnchor?.constant = -(self.keyboardHeight - tabBarHeight)
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func commentKeyboardWillHide(_ notification: Notification) {
        transparentBackgroundView.isHidden = true
        UIView.animate(withDuration: 0.3, animations: {
            let tabBarHeight : CGFloat = self.tabBarController?.tabBar.frame.height ?? 0
            self.textViewBottomAnchor?.constant = 0 //(-tabBarHeight)
            self.view.layoutIfNeeded()
        })
    }
    
    fileprivate func configureDismissKeyboardOnTap() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDismissKeyboardTap))
        self.transparentBackgroundView.addGestureRecognizer(tapRecognizer)
    }
    
    //MARK: - Handlers
    @objc func handleDismissKeyboardTap() {
        addNewCommentTextView.resignFirstResponder()
        UIView.animate(withDuration: 0.3, animations: {
            self.textViewBottomAnchor?.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func handlePostCommentButton() {
        // Handle Post Button To Firebase here
        guard let post = post, let loggedInUser = loggedInUser else { return }
        guard let loggedInUserUID = loggedInUser.uid else { return }
        guard let postAuthorID = post.authorID else { return }
        let socialNetworkManager = ATCSocialNetworkFirebaseAPIManager()
        let commentComposer = ATCCommentComposerState()
    
        commentComposer.postID = post.id
        commentComposer.commentAuthorID = loggedInUser.uid
        commentComposer.date = Date()
        
        if addNewCommentTextView.text != placeholderText && !(addNewCommentTextView.text.isEmpty) {
            commentComposer.commentText = addNewCommentTextView.text
        }else{
            print("No comment to post")
            return
        }
       let notificationComposer = ATCNotificationComposerState(post: post, notificationAuthorID: loggedInUserUID, reacted: false, commented: true, isInteracted: false, createdAt: Date())
        
        if postAuthorID != loggedInUserUID {
            socialNetworkManager.postNotification(composer: notificationComposer) {
                print("Notification Posted")
            }
        }
        
        socialNetworkManager.saveNewComment(loggedInUser: loggedInUser, commentComposer: commentComposer, post: post) {
            guard let commentsVC = self.commentsVC else { return }
            self.addNewCommentTextView.text = nil
            self.adjustTextViewHeight()
            self.addNewCommentTextView.resignFirstResponder()
            commentsVC.genericDataSource?.loadFirst()
            self.detailedPostVC?.genericDataSource?.loadFirst()
        }
        
    }
    
}

// Handling Text View Delegate 
extension ATCDetailPostViewController : UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.adjustTextViewHeight()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        if updatedText.isEmpty {
            textView.text = placeholderText
            textView.textColor = UIColor.lightGray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
        else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.textColor = UIColor.black
            textView.text = text
        }
        else {
            return true
        }
        
        return false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let currentText = textView.text
        
        if currentText == ""  {
            textView.text = placeholderText
            textView.textColor = UIColor.lightGray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
 
}

extension ATCDetailPostViewController : ATCFeedPostCellAdapterDelegate {
   
    func moreButtonDidTap(_ userAdapter: ATCFeedPostCellAdapter, cell: ATCPostCell, on post: ATCPost) {
        guard let navController = self.navigationController else { return }
        guard let loggedInUser = loggedInUser else { return }
        moreOptions = ATCSocialNetworkMoreOptions(viewer: loggedInUser, navController: navController)
        moreOptions.delegate = self
        moreOptions.showPostActionSheet(on: post, cell: cell)
    }
    
    func didTapComment(_ userAdapter: ATCFeedPostCellAdapter, on post: ATCPost) {}
    
    func updateReaction(_ userAdapter: ATCFeedPostCellAdapter, on post: ATCPost, reaction: String) {
        guard let loggedInUser = loggedInUser else {
            return
        }
        let socialNetworkManager = ATCSocialNetworkFirebaseAPIManager()
        socialNetworkManager.updatePostReactions(loggedInUser: loggedInUser, post: post, reaction: reaction) {
            self.detailedPostVC?.genericDataSource?.loadFirst()
        }
    }
    
    func showCommentTextView(_ userAdapter: ATCFeedPostCellAdapter, on post: ATCPost) {
        addNewCommentTextView.becomeFirstResponder()
    }
    
    func profileImageDidTap(_ userAdapter: ATCFeedPostCellAdapter, on post: ATCPost) {
        
        let userManager = ATCSocialFirebaseUserManager()
        guard let loggedInUser = loggedInUser else { return}
        
        let profileViewController = ATCSocialNetworkProfileViewController(uiConfig: uiConfig)
        guard let postAuthorID = post.authorID else { return }
        userManager.fetchUser(userID: postAuthorID) { (user) in
            guard let user = user else { return }
            profileViewController.loggedInUser = loggedInUser
            profileViewController.user = user
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


extension ATCDetailPostViewController : ATCPostDidGetDeletedDelegate {
    func postDeletedOnNewsFeed() {}
    func postDeletedOnProfilePage() {}
    
    func postDeletedOnDetailPage() {
        self.detailedPostVC?.genericDataSource?.loadFirst()
        self.navigationController?.popViewController(animated: true)
        self.delegate?.refreshNewsFeed()
    }
}
