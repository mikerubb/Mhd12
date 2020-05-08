//
//  ATCSocialNetworkProfileViewController.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 24/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class UserStatus {
    enum Status {
        case friend
        case nonfriend
        case loggedInUser
    }
    var profileAuthor: ATCUser? = nil
    var status: Status = .loggedInUser
    var friendCount: Int = 0
}

class ATCSocialNetworkProfileViewController : ATCGenericCollectionViewController {
    var uiConfig: ATCUIGenericConfigurationProtocol
    var userspostsVC: ATCSocialNetworkProfilePostsViewController?
    var profileImageVC: ATCSocialNetworkProfileDetailsVC?

    let userStatus = UserStatus()
    var loggedInUser: ATCUser?

    private var buttonArray: [ATCGenericBaseModel] = []
    private var itemsArray: [ATCGenericBaseModel] = []

    //User is other person -> When the feed cell avatar is tapped.
    //The user could be self / friend / non friend therefore we checkUserStatus
    var user: ATCUser? {
        didSet {
            checkUserStatus()
        }
    }

    var profileImageNameVC: ATCGenericCollectionViewController?
    let loginManager = ATCFirebaseLoginManager()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfileInfo),name: kATCLoggedInUserDataDidChangeNotification, object: nil)
    }

    // To be called from Host View Controller only. Assigns the loggedInUser to 'User' and 'Self.LoggedInUser' variable
    func setupLoggedInUser(loggedInUser: ATCUser) {
        self.loggedInUser = loggedInUser
        self.user = loggedInUser
    }

    init(uiConfig: ATCUIGenericConfigurationProtocol) {
        self.uiConfig = uiConfig
    
        let layout = ATCCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 20

    let collectionVCConfiguration = ATCGenericCollectionViewControllerConfiguration(
            pullToRefreshEnabled: false,
            pullToRefreshTintColor: UIColor.darkModeColor(hexString: "#f5f5f5"),
            collectionViewBackgroundColor: UIColor.darkModeColor(hexString: "#f5f5f5"),
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
        self.title = "Profile"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func checkUserStatus(){
        let socialManager = ATCFirebaseSocialGraphManager()
        guard let loggedInUser = loggedInUser else { return }
        guard let user = user else { return }

        guard let userUID = user.uid else { return }
        guard let loggedInUserUID = loggedInUser.uid else { return }

        //Fetching Friends
        socialManager.fetchFriends(viewer: user) { (friends) in
            self.userStatus.friendCount = friends.count
          
            //Self Profile
            if loggedInUserUID == userUID {
                self.userStatus.profileAuthor = loggedInUser
                self.userStatus.status = .loggedInUser
                self.update()
                return
            }

            // Checking if the user is friend
            socialManager.fetchFriends(viewer: loggedInUser) { (friends) in
                for friend in friends {
                    guard let friendUID = friend.uid else { return }
                    if userUID == friendUID {
                        self.userStatus.profileAuthor = user
                        self.userStatus.status = .friend
                        self.update()
                        return
                    }
                }
                
                // Not a friend
                self.userStatus.profileAuthor = user
                self.userStatus.status = .nonfriend
                self.update()
                return
            }
        }
    }

    private func configureNotificationButton() {
        let notificationBarButton = UIBarButtonItem(image: UIImage(named: "bell-glyph-icon"),
                                                    style: .done,
                                                    target: self,
                                                    action: #selector(handleNotificationBarButton))
        self.navigationItem.rightBarButtonItem = notificationBarButton
    }

    private func configureAllFriendsButton(uiConfig: ATCUIGenericConfigurationProtocol, datasource: ATCGenericCollectionViewControllerDataSource) -> ATCGenericCollectionViewController {
        let layout = ATCCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let configuration = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
                                                                            pullToRefreshTintColor: UIColor.darkModeColor(hexString: "#f5f5f5"),
                                                                            collectionViewBackgroundColor: UIColor.darkModeColor(hexString: "#f5f5f5"),
                                                                            collectionViewLayout: layout,
                                                                            collectionPagingEnabled: false,
                                                                            hideScrollIndicators: true,
                                                                            hidesNavigationBar: false,
                                                                            headerNibName: nil,
                                                                            scrollEnabled: false,
                                                                            uiConfig: uiConfig,
                                                                            emptyViewModel: nil)
        let vc = ATCGenericCollectionViewController(configuration: configuration)
        vc.genericDataSource = datasource
        vc.use(adapter: ATCProfileButtonItemRowAdapter(uiConfig: uiConfig), for: "ATCProfileButtonItem")
        vc.selectionBlock = self.seeAllFriendsSelectionBlock()
        return vc
    }

    private func seeAllFriendsSelectionBlock() -> ATCollectionViewSelectionBlock? {
        return {[weak self] (navController, object, indexPath) in
            if let modelButton = object as? ATCProfileButtonItem {
                guard let strongSelf = self else { return}
                guard let user = strongSelf.user else { return }
                guard let loggedInUser = strongSelf.loggedInUser else { return }
                if modelButton.title == "See All Friends" {
                    let allFriendsVC = ATCSocialNetworkAllFriendsViewController(uiConfig: strongSelf.uiConfig, loggedInUser: loggedInUser)
                    allFriendsVC.update(viewer: user)
                    strongSelf.navigationController?.pushViewController(allFriendsVC, animated: true)
                }
            }
        }
    }

    private func update() {
        guard let profileAuthor = userStatus.profileAuthor else { return }
        let friendCount = userStatus.friendCount
        guard let loggedInUser = loggedInUser else { return }
        
        switch(userStatus.status) {
        case .friend:
            configureProfileDetails(buttonText: "Send Message", profileAuthor: profileAuthor)
            break
        case .nonfriend:
            configureProfileDetails(buttonText: "Add Friend", profileAuthor: profileAuthor)
            break
        case .loggedInUser:
            configureProfileDetails(buttonText: "Profile Settings", profileAuthor: profileAuthor)
            configureNotificationButton()
            break
        }

        var carouselHeight: CGFloat = 0
        var buttonCarouselHeight: CGFloat = 0
        
        if friendCount < 4 {
            carouselHeight = 188
            buttonCarouselHeight = 0
        }else if friendCount >= 4 && friendCount <= 6 {
            carouselHeight = 370
            buttonCarouselHeight = 0
        } else {
            carouselHeight = 370
            buttonCarouselHeight = 70
        }
    
        switch(userStatus.status) {
        case .friend:
            configureControllers(profileAuthor: profileAuthor, loggedInUser: loggedInUser,friendCarouselHeight: carouselHeight, allFriendsButtonHeight: buttonCarouselHeight)
            break
            
        case .nonfriend:
            configureControllers(profileAuthor: profileAuthor, loggedInUser: loggedInUser,friendCarouselHeight: carouselHeight, allFriendsButtonHeight: buttonCarouselHeight)
            break
            
        case .loggedInUser:
            configureControllers(profileAuthor: profileAuthor, loggedInUser: loggedInUser, friendCarouselHeight: carouselHeight, allFriendsButtonHeight: buttonCarouselHeight)
            break
        }
    }

    fileprivate func configureProfileDetails(buttonText: String, profileAuthor: ATCUser) {
        itemsArray.removeAll()
        itemsArray.append(ATCImage(profileAuthor.profilePictureURL, placeholderImage: UIImage.localImage("empty-avatar")))
        itemsArray.append(ATCText(text: profileAuthor.fullName()))
        itemsArray.append(ATCProfileButtonItem(title: buttonText,
                                               color: UIColor.darkModeColor(hexString: "#e8f0fd"),
                                               textColor: UIColor.darkModeColor(hexString: "#3876e7")))
        itemsArray.append(ATCHeaderText(headerText: "Friends"))
    }

    fileprivate func configureControllers(profileAuthor: ATCUser, loggedInUser: ATCUser, friendCarouselHeight: CGFloat, allFriendsButtonHeight: CGFloat) {
        buttonArray.append(ATCProfileButtonItem(title: "See All Friends",
                                                color: UIColor.darkModeColor(hexString: "#EAECF0"),
                                                textColor: UIColor.darkModeColor(hexString: "#000000")))
        let buttonDatasource = ATCGenericLocalHeteroDataSource(items: buttonArray)
        let buttonVC = configureAllFriendsButton(uiConfig: uiConfig, datasource: buttonDatasource)
        let buttonCarousel = ATCCarouselViewModel(title: nil,
                                                  viewController: buttonVC,
                                                  cellHeight: allFriendsButtonHeight)
        buttonCarousel.parentViewController = self

        let friendsVC = ATCSocialNetworkProfileFriendsListVC(uiConfig: uiConfig, user: profileAuthor, loggedInUser: loggedInUser)
        let friendsCarousel = ATCViewControllerContainerViewModel(viewController: friendsVC, cellHeight: friendCarouselHeight, subcellHeight: nil)
        friendsCarousel.parentViewController = self

        let postsDatasource = ATCSocialNetworkSelfUserPostsDatasource(user: profileAuthor, loggedInUser: loggedInUser)
        userspostsVC = ATCSocialNetworkProfilePostsViewController(uiConfig: uiConfig, datasource: postsDatasource, viewer: profileAuthor, loggedInUser: loggedInUser)
        guard let usersPostsVC = userspostsVC else { return }
        let containerViewModel = ATCViewControllerContainerViewModel(viewController: usersPostsVC, cellHeight: nil, subcellHeight: nil)
        containerViewModel.parentViewController = self

        //Profile Image Name Carousel
        let profileInfoDataSource = ATCGenericLocalHeteroDataSource(items: itemsArray)
        profileImageVC = ATCSocialNetworkProfileDetailsVC(uiConfig: uiConfig, datasource: profileInfoDataSource, loggedInUser: loggedInUser, user: profileAuthor)
        guard let profileImageVC = profileImageVC else { return }
        let profileImageNameCarousel = ATCViewControllerContainerViewModel(viewController: profileImageVC, cellHeight: 318, subcellHeight: nil)
        profileImageNameCarousel.parentViewController = self

        // Configure parent collection VC here
        self.use(adapter: ATCViewControllerContainerRowAdapter(), for: "ATCViewControllerContainerViewModel")
        self.registerReuseIdentifiers()
        self.genericDataSource = ATCGenericLocalHeteroDataSource(items: [profileImageNameCarousel, friendsCarousel, buttonCarousel, containerViewModel])
        self.genericDataSource?.loadFirst()
    }

    @objc private func updateProfileInfo() {
        print("UPDATE PROFILE")
        if let loggedInUser = self.loggedInUser {
            loginManager.resyncPersistentUser(user: loggedInUser) { (newUser) in
                guard let newUser = newUser else { return }
                self.setupLoggedInUser(loggedInUser: newUser)
            }
        }
    }

    @objc private func handleNotificationBarButton() {
        guard let loggedInUser = self.loggedInUser else { return }
        let vc = ATCSocialNetworkNotificationVC(uiConfig: uiConfig)
        vc.update(viewer: loggedInUser)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
