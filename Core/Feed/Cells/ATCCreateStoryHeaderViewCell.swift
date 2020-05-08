//
//  ATCCreateStoryHeaderViewCell.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 05/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCCreateStoryHeaderViewCell : UICollectionReusableView {
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var storyImageView: UIImageView!
    @IBOutlet var imageContainerView: UIView!
    
//    func configure() {
//        let tapGestureRecognzier = UITapGestureRecognizer(target: self, action: #selector(handleAddButtonTapped))
//        storyImageView.isUserInteractionEnabled = true
//        storyImageView.addGestureRecognizer(tapGestureRecognzier)
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
       // configure()
    }
    
    @objc func handleAddButtonTapped() {
        //
    }
}

