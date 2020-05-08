//
//  ATCSocialNetworkNotificationCellAdapter.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 29/07/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCSocialNetworkNotificationCellAdapter : ATCGenericCollectionRowAdapter {
    let uiConfig: ATCUIGenericConfigurationProtocol

    init(uiConfig: ATCUIGenericConfigurationProtocol) {
        self.uiConfig = uiConfig
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        if let object = object as? ATCSocialNetworkNotification, let cell = cell as? ATCNotificationCell {
            let profileImage = object.notificationAuthorProfileImage
            let reactionText = " just reacted to your post."
            let commentedText = " commented on your post."
            
            cell.profileImage.kf.setImage(with: URL(string: profileImage))
    
            let notificationAuthorName = object.notificationAuthorUsername
            
            let boldText  = notificationAuthorName
            let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)]
            let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)
            
            
            let attribute = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]
            let normalReactionString = NSMutableAttributedString(string:reactionText, attributes: attribute)

            let normalAttribute = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]
            let normalCommentString = NSMutableAttributedString(string:commentedText, attributes: normalAttribute)

            if object.reacted {
                attributedString.append(normalReactionString)
                cell.notificationTextView.attributedText = attributedString
            }

            if object.commented {
                attributedString.append(normalCommentString)
                cell.notificationTextView.attributedText = attributedString
            }

            if !object.isInteracted {
                cell.contentView.backgroundColor = UIColor.darkModeColor(hexString: "#e3f0ff")
            } else {
                cell.contentView.backgroundColor = uiConfig.mainThemeBackgroundColor
            }
            cell.timeAgoLabel.text = TimeFormatHelper.timeAgoString(date: object.createdAt ?? Date())
            
            cell.setNeedsLayout()
        }
    }

    func cellClass() -> UICollectionViewCell.Type {
        return ATCNotificationCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        guard let viewModel = object as? ATCSocialNetworkNotification else { return .zero }
        return CGSize(width: containerBounds.width, height: 90)
    }
}
