//
//  ATCCommentsViewController.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 12/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCCommentsViewController : ATCGenericCollectionViewController {
    var uiConfig : ATCUIGenericConfigurationProtocol
    let cellId = "ATCComment"
    var datasource: ATCGenericCollectionViewControllerDataSource
    init(uiConfig: ATCUIGenericConfigurationProtocol, datasource: ATCGenericCollectionViewControllerDataSource) {
        self.uiConfig = uiConfig
        self.datasource = datasource
        
        let layout = ATCCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
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
        self.use(adapter: ATCCommentCellAdapter(uiConfig: uiConfig), for: "ATCComment")
        self.selectionBlock = self.detailCommentSelectionBlock()
        self.genericDataSource = datasource
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 4, left: 8, bottom: 50, right: 8)
    }
    
    private func detailCommentSelectionBlock()  -> ATCollectionViewSelectionBlock? {
            return { (navController, object, indexPath) in
               print("Tapped")
            }
        }

    override func registerReuseIdentifiers() {
        collectionView.register(ATCCommentsCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


