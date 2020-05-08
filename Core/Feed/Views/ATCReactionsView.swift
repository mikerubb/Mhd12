//
//  ATCReactionsView.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 14/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCReactionsView : UIView {
    
    let padding: CGFloat = 6
    let iconHeight: CGFloat = 40
    var arrangedSubviews: [ATCImageView] = []

    override init(frame: CGRect) {
        super.init(frame: .zero)
            self.layer.shadowColor = UIColor(white: 0.4, alpha: 0.8).cgColor
            self.layer.shadowRadius = 8
            self.layer.shadowOpacity = 0.5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureicons() {
        let iconStackView = UIStackView(arrangedSubviews: arrangedSubviews)
        iconStackView.frame = self.frame
        iconStackView.distribution = .fillEqually
        iconStackView.axis = .horizontal
        iconStackView.spacing = padding
        iconStackView.layoutMargins = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        iconStackView.isLayoutMarginsRelativeArrangement = true
        addSubview(iconStackView)
    }
    
    fileprivate func setupIcons() {
        let images = ["blue_like", "red_heart", "cry_laugh", "surprised", "cry", "angry"]
        
        arrangedSubviews = images.map { (imageName) -> ATCImageView in
            let view = ATCImageView()
            view.image = UIImage(named: imageName)
            view.imageIdentifier = imageName
            view.layer.cornerRadius = iconHeight / 2
            view.isUserInteractionEnabled = true
            return view
        }
    }
    
    func fetchWidthOfStackView() -> CGFloat {
        //First set up icons before calculating the width
        setupIcons()
        
        //Calculating width of the container view
        let iconNum = CGFloat(arrangedSubviews.count)
        let width = iconHeight * iconNum + (iconNum + 1) * padding
        return width
    }
}
