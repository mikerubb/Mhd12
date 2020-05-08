//
//  ATCNotificationCell.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 29/07/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCNotificationCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    var profileImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 21
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    var timeAgoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "2 hours ago"
        label.font = UIFont.systemFont(ofSize: 12)
        label.contentMode = .scaleAspectFill
        return label
    }()
    
    var notificationTextView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 3
        label.text = "This is just a notification"
        label.font = UIFont.systemFont(ofSize: 14)
        label.isUserInteractionEnabled = false
        return label
    }()
    
    var dividerLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.darkModeColor(hexString: "#f5f5f5")
        return view
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addViews()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Configurations
    private func addViews() {
        addSubview(profileImage)
        addSubview(notificationTextView)
        addSubview(timeAgoLabel)
        addSubview(dividerLine)
    }
    
    private func setupLayout() {
        profileImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 19).isActive = true
        profileImage.leftAnchor.constraint(equalTo:contentView.leftAnchor, constant: 20).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 42).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 42).isActive = true
        
        notificationTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12).isActive = true
        notificationTextView.leftAnchor.constraint(equalTo: profileImage.rightAnchor, constant: 10).isActive = true
        notificationTextView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
        notificationTextView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        timeAgoLabel.topAnchor.constraint(equalTo: notificationTextView.bottomAnchor, constant: 2).isActive = true
        timeAgoLabel.leftAnchor.constraint(equalTo: notificationTextView.leftAnchor, constant: 0).isActive = true
        timeAgoLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeAgoLabel.heightAnchor.constraint(equalToConstant: 13).isActive = true
        
        dividerLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        dividerLine.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
        dividerLine.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
        dividerLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
}
