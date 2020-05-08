//
//  ATCHeaderTextCellAdapter.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 26/07/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCHeaderTextCellAdapter: ATCGenericCollectionRowAdapter {
    
    var font: UIFont
    var textColor: UIColor
    var staticHeight: CGFloat?
    var bgColor: UIColor?
    var alignment: NSTextAlignment
    
    init(font: UIFont,
         textColor: UIColor,
         staticHeight: CGFloat? = nil,
         bgColor: UIColor? = nil,
         alignment: NSTextAlignment = .left) {
        self.font = font
        self.textColor = textColor
        self.staticHeight = staticHeight
        self.bgColor = bgColor
        self.alignment = alignment
    }
    
    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        guard let viewModel = object as? ATCHeaderText, let cell = cell as? ATCTextCollectionViewCell else { return }
        cell.label.font = font
        cell.label.textColor = textColor
        cell.label.text = viewModel.headerText
        cell.label.textAlignment = alignment
        
        cell.accessoryLabel.isHidden = true
        if let bgColor = bgColor {
            cell.backgroundColor = bgColor
        } else {
            cell.backgroundColor = .clear
        }
        cell.label.setNeedsLayout()
        cell.setNeedsLayout()
    }
    
    func cellClass() -> UICollectionViewCell.Type {
        return ATCTextCollectionViewCell.self
    }
    
    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        guard let viewModel = object as? ATCHeaderText else { return .zero }
        let width = containerBounds.width
        if let staticHeight = staticHeight {
            return CGSize(width: width, height: staticHeight)
        }
        let height = viewModel.headerText.height(withConstrainedWidth: width, font: self.font)
        return CGSize(width: width, height: height + font.lineHeight)
    }
}
