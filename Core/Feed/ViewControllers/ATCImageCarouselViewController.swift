//
//  ATCImageCarouselViewController.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 17/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCImageCarouselViewController: ATCGenericCollectionViewController {
    var uiConfig : ATCUIGenericConfigurationProtocol
    
    init(uiConfig: ATCUIGenericConfigurationProtocol) {
        self.uiConfig = uiConfig
        let layout = ATCCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let configuration = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
                                                                            pullToRefreshTintColor: uiConfig.mainThemeBackgroundColor,
                                                                            collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
                                                                            collectionViewLayout: layout,
                                                                            collectionPagingEnabled: false,
                                                                            hideScrollIndicators: true,
                                                                            hidesNavigationBar: false,
                                                                            headerNibName: nil,
                                                                            scrollEnabled: false,
                                                                            uiConfig: uiConfig,
                                                                            emptyViewModel: nil)
        super.init(configuration: configuration)

    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
