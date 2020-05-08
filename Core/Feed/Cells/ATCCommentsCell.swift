//
//  ATCCommentsCell.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 12/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCCommentsCell : UICollectionViewCell {
    
    //MARK: - Properties
    var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkModeColor(hexString: "#f5f5f5")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    var profileImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    var commentAuthorUsername: UILabel = {
        let commentLabel = UILabel()
        commentLabel.font = UIFont.boldSystemFont(ofSize: 14)
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        return commentLabel
    }()
    
    var commentTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = UIColor.darkModeColor(hexString: "#f5f5f5")
        textView.text = "This is just a comment"
        textView.font = UIFont.systemFont(ofSize: 12)
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.isSelectable = false
        textView.isUserInteractionEnabled = false
        return textView
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addViews()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Configurations
    private func addViews() {
        addSubview(containerView)
        addSubview(profileImage)
        containerView.addSubview(commentAuthorUsername)
        containerView.addSubview(commentTextView)
    }
    
    private func setupLayout() {
        profileImage.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        profileImage.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 40).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        containerView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        containerView.leftAnchor.constraint(equalTo: profileImage.rightAnchor, constant: 12).isActive = true
        containerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        
        commentAuthorUsername.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8).isActive = true
        commentAuthorUsername.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10).isActive = true
        commentAuthorUsername.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -4).isActive = true
        commentAuthorUsername.heightAnchor.constraint(equalToConstant: 14).isActive = true
        
        commentTextView.topAnchor.constraint(equalTo: commentAuthorUsername.bottomAnchor, constant: 0).isActive = true
        commentTextView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        commentTextView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -4).isActive = true
        commentTextView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0).isActive = true
        
    }
}
