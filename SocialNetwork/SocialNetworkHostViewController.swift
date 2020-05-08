//
//  ChatHostViewController.swift
//  ChatApp
//
//  Created by Florian Marcu on 8/18/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class SocialNetworkHostViewController: UIViewController, UITabBarControllerDelegate {

    let homeVC: ATCChatHomeViewController
    let profileVC : ATCSocialNetworkProfileViewController
    let contactVC : ATCSocialNetworkFriendsViewController
    let feedVC: ATCFeedViewController
    let discoverVC: ATCSocialNetworkDiscoverViewController
    let uiConfig: ATCUIGenericConfigurationProtocol
    let serverConfig: SocialNetworkServerConfiguration
    let reportingManager: ATCUserReportingProtocol?
    var viewer: ATCUser? = nil

    init(uiConfig: ATCUIGenericConfigurationProtocol,
         serverConfig: SocialNetworkServerConfiguration,
         threadsDataSource: ATCGenericCollectionViewControllerDataSource,
         userSearchDataSource: ATCGenericSearchViewControllerDataSource,
         reportingManager: ATCUserReportingProtocol?) {
        self.uiConfig = uiConfig
        self.serverConfig = serverConfig
        self.homeVC = ATCChatHomeViewController.homeVC(uiConfig: uiConfig,
                                                       threadsDataSource: threadsDataSource,
                                                       userSearchDataSource: userSearchDataSource,
                                                       reportingManager: reportingManager)
        self.contactVC = ATCSocialNetworkFriendsViewController(uiConfig: uiConfig, reportingManager: nil, userSearchDataSource: userSearchDataSource)
        self.profileVC = ATCSocialNetworkProfileViewController(uiConfig: uiConfig)
        self.feedVC = ATCFeedViewController.feedVC(uiConfig: uiConfig)
        self.discoverVC = ATCSocialNetworkDiscoverViewController(uiConfig: uiConfig)
        self.reportingManager = reportingManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var hostController: ATCHostViewController = { [unowned self] in
        let menuItems: [ATCNavigationItem] = [
            ATCNavigationItem(title: nil,
                              viewController: feedVC,
                              image: UIImage.localImage("social-home-unselected-icon", template: true),
                              selectedImage: UIImage.localImage("home-glyph-icon", template: true),
                              type: .viewController,
                              leftTopViews: [self.composeNewStory()],
                              rightTopViews: [self.composeNewPost()]),
            ATCNavigationItem(title: nil,
                              viewController: discoverVC,
                              image: UIImage.localImage("social-search-icon", template: true),
                              selectedImage: UIImage.localImage("search-glyph-icon", template: true),
                              type: .viewController,
                              leftTopViews: nil,
                              rightTopViews: nil),
            ATCNavigationItem(title: nil,
                              viewController: homeVC,
                              image: UIImage.localImage("social-chat-icon", template: true),
                              selectedImage: UIImage.localImage("bubble-chat-glyph-large-icon", template: true),
                              type: .viewController,
                              leftTopViews: nil,
                              rightTopViews: [self.newMessageButton()]),
            ATCNavigationItem(title: nil,
                              viewController: contactVC,
                              image: UIImage.localImage("social-friends-tab-icon", template: true),
                              selectedImage: UIImage.localImage("friends-glyph-icon-large", template: true),
                              type: .viewController,
                              leftTopViews: nil,
                              rightTopViews: nil),
            ATCNavigationItem(title: nil,
                              viewController: profileVC,
                              image: UIImage.localImage("social-profile-icon", template: true),
                              selectedImage: UIImage.localImage("profile-glyph-large-icon", template: true),
                              type: .viewController,
                              leftTopViews: nil,
                              rightTopViews: nil)
         
        ]
        let menuConfiguration = ATCMenuConfiguration(user: nil,
                                                     cellClass: ATCCircledIconMenuCollectionViewCell.self,
                                                     headerHeight: 0,
                                                     items: menuItems,
                                                     uiConfig: ATCMenuUIConfiguration(itemFont: uiConfig.regularMediumFont,
                                                                                      tintColor: uiConfig.mainTextColor,
                                                                                      itemHeight: 45.0,
                                                                                      backgroundColor: uiConfig.mainThemeBackgroundColor))

        let config = ATCHostConfiguration(menuConfiguration: menuConfiguration,
                                          style: .tabBar,
                                          topNavigationRightViews: nil,
                                          titleView: nil,
                                          topNavigationLeftImage: UIImage.localImage("three-equal-lines-icon", template: true),
                                          topNavigationTintColor: uiConfig.mainThemeForegroundColor,
                                          statusBarStyle: uiConfig.statusBarStyle,
                                          uiConfig: uiConfig,
                                          pushNotificationsEnabled: true,
                                          locationUpdatesEnabled: false)
        let onboardingCoordinator = self.onboardingCoordinator(uiConfig: uiConfig)
        let walkthroughVC = self.walkthroughVC(uiConfig: uiConfig)
        return ATCHostViewController(configuration: config, onboardingCoordinator: onboardingCoordinator, walkthroughVC: walkthroughVC, profilePresenter: nil)
        }()

    override func viewDidLoad() {
        super.viewDidLoad()
        hostController.delegate = self
        self.addChildViewControllerWithView(hostController)
        hostController.view.backgroundColor = uiConfig.mainThemeBackgroundColor
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return uiConfig.statusBarStyle
    }

    fileprivate func onboardingCoordinator(uiConfig: ATCUIGenericConfigurationProtocol) -> ATCOnboardingCoordinatorProtocol {
        let landingViewModel = ATCLandingScreenViewModel(imageIcon: "logo-icon",
                                                         title: "Welcome to Compatriot",
                                                         subtitle: "Network with compatriots around you.",
                                                         loginString: "Log In",
                                                         signUpString: "Sign Up")
        let loginViewModel = ATCLoginScreenViewModel(contactPointField: "E-mail or phone number",
                                                     passwordField: "Password",
                                                     title: "Sign In",
                                                     loginString: "Log In",
                                                     facebookString: "Facebook Login",
                                                     separatorString: "OR")

        let signUpViewModel = ATCSignUpScreenViewModel(nameField: "Full Name",
                                                       phoneField: "Phone Number",
                                                       emailField: "E-mail Address",
                                                       passwordField: "Password",
                                                       title: "Create new account",
                                                       signUpString: "Sign Up")
        
        let userManager: ATCSocialUserManagerProtocol? = serverConfig.isFirebaseAuthEnabled ? ATCSocialFirebaseUserManager() : nil
        return ATCClassicOnboardingCoordinator(landingViewModel: landingViewModel,
                                               loginViewModel: loginViewModel,
                                               signUpViewModel: signUpViewModel,
                                               uiConfig: SocialNetworkOnboardingUIConfig(config: uiConfig),
                                               serverConfig: serverConfig, userManager: userManager)
    }

    fileprivate func walkthroughVC(uiConfig: ATCUIGenericConfigurationProtocol) -> ATCWalkthroughViewController {
        let viewControllers = ATCChatMockStore.walkthroughs.map { ATCClassicWalkthroughViewController(model: $0, uiConfig: uiConfig, nibName: "ATCClassicWalkthroughViewController", bundle: nil) }
        return ATCWalkthroughViewController(nibName: "ATCWalkthroughViewController",
                                            bundle: nil,
                                            viewControllers: viewControllers,
                                            uiConfig: uiConfig)
    }

    fileprivate func newMessageButton() -> UIButton {
        let newMessageButton = UIButton()
        newMessageButton.configure(icon: UIImage.localImage("inscription-icon", template: true), color: self.uiConfig.mainTextColor)
        newMessageButton.snp.makeConstraints({ (maker) in
            maker.width.equalTo(40.0)
            maker.height.equalTo(40.0)
        })
//        newMessageButton.backgroundColor = UIColor(hexString: "#f5f5f5")
//        newMessageButton.layer.cornerRadius = 40.0/2
//        newMessageButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10);
        newMessageButton.addTarget(self, action: #selector(didTapNewMessageButton), for: .touchUpInside)
        return newMessageButton
    }

    fileprivate func composeNewStory() -> UIButton {
        let newStoryButton = UIButton()
        newStoryButton.configure(icon: UIImage.localImage("camera-icon", template: true), color: self.uiConfig.mainTextColor)
        newStoryButton.snp.makeConstraints({ (maker) in
            maker.width.equalTo(40.0)
            maker.height.equalTo(40.0)
        })
//        newStoryButton.backgroundColor = UIColor(hexString: "#f5f5f5")
//        newStoryButton.layer.cornerRadius = 40.0/2
//        newStoryButton.imageEdgeInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10);
        newStoryButton.addTarget(self, action: #selector(didTapNewStoryButton), for: .touchUpInside)
        return newStoryButton
    }

    fileprivate func composeNewPost() -> UIButton {
        let newPostButton = UIButton()
        newPostButton.configure(icon: UIImage.localImage("inscription-icon", template: true), color: self.uiConfig.mainTextColor)
        newPostButton.snp.makeConstraints({ (maker) in
            maker.width.equalTo(40.0)
            maker.height.equalTo(40.0)
        })
//        newPostButton.backgroundColor = UIColor(hexString: "#f5f5f5")
//        newPostButton.layer.cornerRadius = 40.0/2
//        newPostButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10);
        newPostButton.addTarget(self, action: #selector(didTapComposePostButton), for: .touchUpInside)
        return newPostButton
    }

    @objc fileprivate func didTapNewMessageButton() {
        guard let viewer = viewer else { return }
        let vc = ATCChatGroupCreationViewController(uiConfig: uiConfig,
                                                    selectionBlock: nil,
                                                    viewer: viewer,
                                                    reportingManager: reportingManager)
        vc.title = "Choose People"
        homeVC.navigationController?.pushViewController(vc, animated: true)
    }

    @objc fileprivate func didTapNewStoryButton() {
        guard let viewer = viewer else { return }
        let rootVC = ATCComposeNewStoryViewController(viewer: viewer)
        rootVC.delegate = feedVC
        let vc = UINavigationController(rootViewController: rootVC)
        vc.isNavigationBarHidden = true
        feedVC.present(vc, animated: true)
    }

    @objc fileprivate func didTapComposePostButton() {
        guard let viewer = viewer else { return }
        let rootVC = ATCNewPostViewController(viewer: viewer, uiConfig: uiConfig)
        rootVC.delegate = feedVC
        let vc = UINavigationController(rootViewController: rootVC)
        feedVC.present(vc, animated: true)
    }
}

extension SocialNetworkHostViewController: ATCHostViewControllerDelegate {
    func hostViewController(_ hostViewController: ATCHostViewController, didLogin user: ATCUser) {
        print("Initial Log In")
        self.viewer = user
        self.homeVC.update(user: user)
        self.contactVC.update(user: user)
        self.profileVC.setupLoggedInUser(loggedInUser: user)
        self.feedVC.update(user: user)
        self.discoverVC.update(viewer: user)
    }

    func hostViewController(_ hostViewController: ATCHostViewController, didSync user: ATCUser) {
        print("LoggedIn" )
        self.viewer = user
        self.homeVC.update(user: user)
        self.contactVC.update(user: user)
        self.profileVC.setupLoggedInUser(loggedInUser: user)
        self.feedVC.update(user: user)
        self.discoverVC.update(viewer: user)
    }
}

class SocialNetworkOnboardingUIConfig: ATCOnboardingConfigurationProtocol {
    var backgroundColor: UIColor
    var titleColor: UIColor
    var titleFont: UIFont
    var logoTintColor: UIColor?

    var subtitleColor: UIColor
    var subtitleFont: UIFont

    var loginButtonFont: UIFont
    var loginButtonBackgroundColor: UIColor
    var loginButtonTextColor: UIColor

    var signUpButtonFont: UIFont
    var signUpButtonBackgroundColor: UIColor
    var signUpButtonTextColor: UIColor
    var signUpButtonBorderColor: UIColor

    var separatorFont: UIFont
    var separatorColor: UIColor

    var textFieldColor: UIColor
    var textFieldFont: UIFont
    var textFieldBorderColor: UIColor
    var textFieldBackgroundColor: UIColor

    var signUpTextFieldFont: UIFont
    var signUpScreenButtonFont: UIFont

    init(config: ATCUIGenericConfigurationProtocol) {
        backgroundColor = config.mainThemeBackgroundColor
        titleColor = config.mainThemeForegroundColor
        titleFont = config.boldSuperLargeFont
        logoTintColor = config.mainThemeForegroundColor
        subtitleFont = config.regularLargeFont
        subtitleColor = config.mainTextColor
        loginButtonFont = config.boldLargeFont
        loginButtonBackgroundColor = config.mainThemeForegroundColor
        loginButtonTextColor = config.mainThemeBackgroundColor

        signUpButtonFont = config.boldLargeFont
        signUpButtonBackgroundColor = config.mainThemeBackgroundColor
        signUpButtonTextColor = UIColor.darkModeColor(hexString: "#414665")
        signUpButtonBorderColor = UIColor.darkModeColor(hexString: "#B0B3C6")
        separatorColor = config.mainTextColor
        separatorFont = config.mediumBoldFont

        textFieldColor = UIColor.darkModeColor(hexString: "#B0B3C6")
        textFieldFont = config.regularLargeFont
        textFieldBorderColor = UIColor.darkModeColor(hexString: "#B0B3C6")
        textFieldBackgroundColor = config.mainThemeBackgroundColor

        signUpTextFieldFont = config.regularMediumFont
        signUpScreenButtonFont = config.mediumBoldFont
    }
}
