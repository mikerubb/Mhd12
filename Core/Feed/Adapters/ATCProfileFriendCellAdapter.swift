//
//  ATCProfileFriendCellAdapter.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 24/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit
class ATCProfileFriendCellAdapter: ATCGenericCollectionRowAdapter {
    let uiConfig: ATCUIGenericConfigurationProtocol
    
    init(uiConfig: ATCUIGenericConfigurationProtocol) {
        self.uiConfig = uiConfig
    }
    
    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        if let user = object as? ATCUser, let cell = cell as? ATCProfileFriendCell {
            let profileImageURL = user.profilePictureURL
            if let imageURL = profileImageURL {
                cell.profileImageView.kf.setImage(with: URL(string: imageURL))
            }
            cell.friendName.text = user.fullName()
            cell.friendName.backgroundColor = uiConfig.mainThemeBackgroundColor
    
            cell.setNeedsLayout()
        }
    }
    
    
    func cellClass() -> UICollectionViewCell.Type {
        return ATCProfileFriendCell.self
    }
    
    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        guard let viewModel = object as? ATCUser else { return .zero }
        let cellHeight: CGFloat = 170 
        let cellWidth = ((containerBounds.width - 56) / 3)
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
}

