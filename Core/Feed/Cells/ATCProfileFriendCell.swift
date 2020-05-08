//
//  ATCProfileFriendCell.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 24/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCProfileFriendCell: UICollectionViewCell {
    
    var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var friendName: UITextView = {
        let friendName = UITextView()
        friendName.isEditable = false
        friendName.isScrollEnabled = false
        friendName.font = UIFont.systemFont(ofSize: 14)
        friendName.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 0, right: 0)
        friendName.layer.cornerRadius = 10
        friendName.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        friendName.translatesAutoresizingMaskIntoConstraints = false
        friendName.clipsToBounds = true
        return friendName
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.darkModeColor(hexString: "f5f5f5")
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
        setupViews()
    }
    
    private func setupViews() {
        addSubview(profileImageView)
        addSubview(friendName)

        NSLayoutConstraint.activate(
            [

                friendName.bottomAnchor.constraint(equalTo: bottomAnchor),
                friendName.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
                friendName.rightAnchor.constraint(equalTo: rightAnchor),
                friendName.heightAnchor.constraint(equalToConstant: 40),
                
                profileImageView.topAnchor.constraint(equalTo: topAnchor),
                profileImageView.leftAnchor.constraint(equalTo: leftAnchor),
                profileImageView.rightAnchor.constraint(equalTo: rightAnchor),
                profileImageView.bottomAnchor.constraint(equalTo: friendName.topAnchor)
            ]
        
        )
        
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
