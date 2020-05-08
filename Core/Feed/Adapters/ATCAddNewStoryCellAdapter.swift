//
//  ATCAddNewStoryCellAdapter.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 23/07/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit
class ATCAddNewStoryCellAdapter: ATCGenericCollectionRowAdapter {
    let uiConfig: ATCUIGenericConfigurationProtocol

    init(uiConfig: ATCUIGenericConfigurationProtocol) {
        self.uiConfig = uiConfig
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        if let object = object as? ATCAddNewStory,
            let addImageURL = object.addImageURL,
            let cell = cell as? ATCUserStoryCollectionViewCell {
            cell.storyImageView.contentMode = .scaleAspectFill
            cell.storyImageView.clipsToBounds = true
            cell.storyImageView.layer.cornerRadius = 50.0/2.0
            cell.storyImageView.kf.setImage(with: URL(string: addImageURL))

            cell.imageContainerView.backgroundColor = uiConfig.mainThemeBackgroundColor
            cell.whiteBorderView.layer.cornerRadius = 55.0/2.0

            cell.storyTitleLabel.text = "Add Story"
            cell.storyTitleLabel.font = uiConfig.regularFont(size: 11)
            cell.storyTitleLabel.textColor = uiConfig.mainSubtextColor

            cell.onlineStatusView.isHidden = true
            cell.onlineStatusView.layer.cornerRadius = 15.0/2.0
            cell.onlineStatusView.layer.borderColor = UIColor.white.cgColor
            cell.onlineStatusView.layer.borderWidth = 3
            cell.onlineStatusView.backgroundColor = UIColor(hexString: "#4acd1d")
            cell.containerView.backgroundColor = .clear
            cell.imageContainerView.backgroundColor = .clear

            cell.setNeedsLayout()
        }
    }

    func cellClass() -> UICollectionViewCell.Type {
        return ATCUserStoryCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        guard let viewModel = object as? ATCAddNewStory else { return .zero }
       return CGSize(width: 75, height: 90)
    }
}
