//
//  ATCCommentCellAdapter.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 12/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCCommentCellAdapter: ATCGenericCollectionRowAdapter {
    let uiConfig: ATCUIGenericConfigurationProtocol
    
    init(uiConfig: ATCUIGenericConfigurationProtocol) {
        self.uiConfig = uiConfig
    }
    
    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        if let comment = object as? ATCComment, let cell = cell as? ATCCommentsCell {
            
            let profileImageURL = comment.commentAuthorProfilePicture
            if let profileImageURL = profileImageURL {
                cell.profileImage.kf.setImage(with: URL(string: profileImageURL))
                cell.profileImage.layer.cornerRadius = 40 / 2
                cell.profileImage.layer.masksToBounds = true
            }
            if let commentUsername = comment.commentAuthorUsername {
                cell.commentAuthorUsername.text = commentUsername
            }
            
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 2
            let atributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.paragraphStyle: style,
                                                              NSAttributedString.Key.foregroundColor: uiConfig.mainTextColor,
                                                              NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]
            guard let commentText = comment.commentText else { return }
            cell.commentTextView.attributedText = NSAttributedString(string: commentText, attributes: atributes)
            cell.backgroundColor = uiConfig.mainThemeBackgroundColor
            cell.setNeedsLayout()
        }
    }
    
    func cellClass() -> UICollectionViewCell.Type {
        return ATCCommentsCell.self
    }
    
    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        guard let viewModel = object as? ATCComment else { return .zero }
        let approximateWidth = containerBounds.width - 40 - 44 - 30
        let knownHeight : CGFloat = 56 + 8
        
        let text = viewModel.commentText
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 2
        
        guard let commentText = text else { return .zero }
        let rect = NSString(string: commentText).boundingRect(with: CGSize(width: approximateWidth, height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12), NSAttributedString.Key.paragraphStyle: style], context: nil)
        let cellHeight = rect.height + knownHeight

        return CGSize(width: containerBounds.width - 32, height: cellHeight)
    }
    
}


