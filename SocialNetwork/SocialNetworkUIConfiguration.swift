//
//  ChatUIConfiguration.swift
//  ChatApp
//
//  Created by Florian Marcu on 8/18/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class SocialNetworkUIConfiguration: ATCUIGenericConfigurationProtocol {
    let colorGray0: UIColor = UIColor.darkModeColor(hexString: "#000000")
    let colorGray3: UIColor = UIColor.darkModeColor(hexString: "#333333")
    let colorGray9: UIColor = UIColor.darkModeColor(hexString: "#f4f4f4")

    let mainThemeBackgroundColor: UIColor = UIColor.modedColor(light: "#ffffff", dark: "#121212")
    let mainThemeForegroundColor: UIColor = UIColor(hexString: "#3875e8") //#3068CC")
    let mainTextColor: UIColor = UIColor.darkModeColor(hexString: "#151723")
    let mainSubtextColor: UIColor = UIColor.darkModeColor(hexString: "#7e7e7e")
    let statusBarStyle: UIStatusBarStyle = .default
    let hairlineColor: UIColor = UIColor.darkModeColor(hexString: "#d6d6d6")

    let regularSmallFont = UIFont.systemFont(ofSize: 14)
    let regularMediumFont = UIFont.systemFont(ofSize: 17)
    let regularLargeFont = UIFont.systemFont(ofSize: 23)
    let mediumBoldFont = UIFont.boldSystemFont(ofSize: 17)
    let boldLargeFont = UIFont.boldSystemFont(ofSize: 23)
    let boldSmallFont = UIFont.boldSystemFont(ofSize: 14)
    let boldSuperSmallFont = UIFont.boldSystemFont(ofSize: 11)
    let boldSuperLargeFont = UIFont.boldSystemFont(ofSize: 29)

    let italicMediumFont = UIFont.italicSystemFont(ofSize: 17)

    func regularFont(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size)
    }

    func boldFont(size: CGFloat) -> UIFont {
        return UIFont.boldSystemFont(ofSize: size)
    }

    func configureUI() {
        UITabBar.appearance().barTintColor = self.mainThemeBackgroundColor
        UITabBar.appearance().tintColor = self.mainThemeForegroundColor
        UITabBar.appearance().unselectedItemTintColor = UIColor.darkModeColor(hexString: "#606771")
        UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor : UIColor(hexString: "#606771"),
                                                          .font: self.boldSuperSmallFont],
                                                         for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor : self.mainThemeForegroundColor,
                                                          .font: self.boldSuperSmallFont],
                                                         for: .selected)

        UITabBar.appearance().backgroundImage = UIImage.colorForNavBar(self.mainThemeBackgroundColor)
        UITabBar.appearance().shadowImage = UIImage.colorForNavBar(self.hairlineColor)

        UINavigationBar.appearance().barTintColor = self.mainThemeBackgroundColor
        UINavigationBar.appearance().tintColor = self.mainThemeForegroundColor
        //
        //        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: ATCUIConfiguration.shared.navigationBarTitleColor]
        //        UINavigationBar.appearance().isTranslucent = false
        //
        //        UITabBar.appearance().tintColor = ATCUIConfiguration.shared.mainThemeColor
        //        UITabBar.appearance().barTintColor = ATCUIConfiguration.shared.tabBarBarTintColor
        //        if #available(iOS 10.0, *) {
        //            UITabBar.appearance().unselectedItemTintColor = ATCUIConfiguration.shared.mainThemeColor
        //        }
    }
}
