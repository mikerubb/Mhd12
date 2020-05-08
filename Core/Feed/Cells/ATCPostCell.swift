//
//  ATCPostCell.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 07/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

protocol ATCPostCellDelegate: class {
    func commentButtonDidTap(on cell: ATCPostCell, on post: ATCPost)
    func profileImageDidTap(on cell: ATCPostCell, on post: ATCPost)
    func updateReaction(on post: ATCPost, reaction: String)
    func moreButtonDidTap(on cell: ATCPostCell, on post: ATCPost)
}

class ATCPostCell : UICollectionViewCell {

    lazy var profileImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapOnProfileImage)))
        image.layer.masksToBounds = true
        return image
    }()

    let userName: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let createdAtDate: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 11)
        label.text = "Yesterday at 9:56 am"
        label.textColor = UIColor.darkModeColor(hexString: "#919191")
        return label
    }()

    let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "San Francisco"
        label.font = UIFont.systemFont(ofSize: 11)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.darkModeColor(hexString: "#919191")
        return label
        
    }()

    let postText: UITextView = {
        let text = UITextView()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.isScrollEnabled = false
        text.isEditable = false
        text.isUserInteractionEnabled = false
        text.font = UIFont.systemFont(ofSize: 14)
        return text
    }()

    var imageCarouselCV : ATCImageCarouselViewController? {
        didSet {
            configureCollectionView()
        }
    }

    let postMedia: UIView = {
        let media = UIView()
        media.translatesAutoresizingMaskIntoConstraints = false
        media.backgroundColor = .red
        return media
    }()

    let likesCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
        label.text = "748"
        return label
    }()

    let commentsCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
        label.text = "19"
        return label
    }()

    lazy var likeButton : UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = UIColor.darkModeColor(hexString: "#151723")
        button.setImage(UIImage(named: "thumbsup"), for: .normal)
        button.addTarget(self, action: #selector(handleLikeButton), for: .touchUpInside)
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender: )))
        lpgr.minimumPressDuration = 0.5
        button.addGestureRecognizer(lpgr)
        return button
    }()
    
    lazy var commentButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage.localImage("comments", template: true), for: .normal)
        button.addTarget(self, action: #selector(handleCommentButton), for: .touchUpInside)
        return button
    }()

    let horizontalButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = 3
        stackView.distribution = .fillEqually
        stackView.backgroundColor = .clear
        return stackView
    }()

    let dividerLine: UIView = {
        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = UIColor.darkModeColor(hexString: "f5f5f5")
        return divider
    }()

    let reactionsContainerView : ATCReactionsView = {
        let containerView = ATCReactionsView()
        containerView.frame = CGRect(x: 0, y: 0, width: containerView.fetchWidthOfStackView(), height: containerView.iconHeight + 2 * containerView.padding)
        containerView.layer.cornerRadius = containerView.frame.height / 2
        containerView.configureicons()
        return containerView
    }()

    lazy var moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor.darkModeColor(hexString: "#acacac")
        button.imageView?.contentMode = .scaleAspectFill
        button.setImage(UIImage(named: "more"), for: .normal)
        button.addTarget(self, action: #selector(handleMoreButton), for: .touchUpInside)
        return button
    }()

    var post: ATCPost? = nil
    var delegate: ATCPostCellDelegate?
    var heightConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configurations
    fileprivate func configureCollectionView() {
        guard let imageParentCV = imageCarouselCV else { return }
        
        guard let imageParentCVView = imageParentCV.view else { return }
        //imageParentCVView.collectionView.backgroundColor = UIColor(hexString: "#f5f5f5")
        
        imageParentCVView.translatesAutoresizingMaskIntoConstraints = false
        postMedia.addSubview(imageParentCVView)
       
        imageParentCVView.topAnchor.constraint(equalTo: postMedia.topAnchor, constant: 0).isActive = true
        imageParentCVView.leftAnchor.constraint(equalTo: postMedia.leftAnchor, constant: 0).isActive = true
        imageParentCVView.rightAnchor.constraint(equalTo: postMedia.rightAnchor, constant: 0).isActive = true
        imageParentCVView.bottomAnchor.constraint(equalTo: postMedia.bottomAnchor, constant: 0).isActive = true
    }
    
    // MARK : - Handlers
    @objc func handleCommentButton() {
        if let post = post {
            delegate?.commentButtonDidTap(on: self, on: post)
        }
    }

    @objc func handleMoreButton() {
        if let post = post {
            print("This post user can be reported or blocked from here")
            delegate?.moreButtonDidTap(on: self, on: post)
        }
    }

    @objc func handleLikeButton() {
        if (likeButton.currentImage == UIImage(named: "thumbsup")) {
            print("Liked")
            handleReactions(identifier: "blue_like")
        } else {
            likeButton.tintColor = UIColor.darkModeColor(hexString: "#000000")
            likeButton.setImage(UIImage(named: "thumbsup"), for: .normal)
            handleReactions(identifier: "no_reaction")
        }
    }

    @objc func handleTapOnProfileImage() {
        print("Tapped the profile Image")
        if let post = post {
            delegate?.profileImageDidTap(on: self, on: post)
        }
    }
    
    // Adding Reactions to the Post Cell
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        
        if sender.state == .began {
            handleGestureBegan(sender: sender)
        } else if sender.state == .ended {
            handleGestureEnded(sender: sender)
        } else if sender.state == .changed {
            handleGestureChanged(sender: sender)
        }
        
    }
    
    func generateHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    
    fileprivate func handleGestureEnded(sender: UILongPressGestureRecognizer) {

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            let stackView = self.reactionsContainerView.subviews.first
            stackView?.subviews.forEach({ (icon) in
                if (icon.transform != .identity) {
                    let selectedReaction = icon as! ATCImageView
                    self.handleReactions(identifier: selectedReaction.imageIdentifier)
                    self.generateHapticFeedback()
                }
                icon.transform = .identity
            })
            self.reactionsContainerView.transform.translatedBy(x: 0, y: 40)
            self.reactionsContainerView.alpha = 0
            
        }, completion: { (_) in
            
            self.reactionsContainerView.removeFromSuperview()
        })
    }

    fileprivate func handleGestureChanged(sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: self.reactionsContainerView)
        
        let stackView = self.reactionsContainerView.subviews.first
        let icons = stackView?.subviews
        guard let reactionicons = icons else  { return }
        guard let lasticon = reactionicons.last else { return }
        let lasticonposition = lasticon.frame.maxX
        
        if (location.x < 0 || location.x > lasticonposition) {
             UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    let stackView = self.reactionsContainerView.subviews.first
                    stackView?.subviews.forEach({ (icons) in
                        icons.transform = .identity
                    })
                })
        } else {
            let hitTestView = reactionsContainerView.hitTest(location, with: nil)
       
                if  hitTestView is ATCImageView {
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    
                    let stackView = self.reactionsContainerView.subviews.first
                    stackView?.subviews.forEach({ (icons) in
                        icons.transform = .identity
                    })
                    
                    hitTestView?.transform = CGAffineTransform(translationX: 0, y: -50)
                })
            }
        }
    }
    
    fileprivate func handleGestureBegan(sender: UILongPressGestureRecognizer) {
        addSubview(reactionsContainerView)
        let positionX = (self.frame.width - reactionsContainerView.frame.width ) / 2

        reactionsContainerView.alpha = 0
        reactionsContainerView.transform = CGAffineTransform(translationX: positionX, y: self.horizontalButtonStackView.frame.minY - 30)

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.reactionsContainerView.alpha = 1
            self.reactionsContainerView.transform = CGAffineTransform(translationX: positionX, y: self.horizontalButtonStackView.frame.minY - self.reactionsContainerView.frame.height - 10)
        })
    }
    
    fileprivate func handleReactions(identifier: String) {
        //Handle each case here.
        //Update firebase with reactions from here.
        guard post != nil else { return }
        switch (identifier) {
        case ("blue_like"):
            likeButton.setImage(UIImage(named: "liked"), for: .normal)
            updatePostReactions("like")
            break
        case ("surprised"):
            likeButton.setImage(UIImage(named: "wow"), for: .normal)
            updatePostReactions("surprised")
            break
        case ("cry_laugh"):
            likeButton.setImage(UIImage(named: "crylaugh"), for: .normal)
            updatePostReactions("laugh")
            break
        case ("cry"):
            likeButton.setImage(UIImage(named: "crying"), for: .normal)
            updatePostReactions("sad")
            break
        case ("angry"):
            likeButton.setImage(UIImage(named: "anger"), for: .normal)
            updatePostReactions("angry")
            break
        case ("red_heart"):
            likeButton.setImage(UIImage(named: "loved"), for: .normal)
            updatePostReactions("love")
            break
        case ("no_reaction"):
            likeButton.setImage(UIImage(named: "thumbsup"), for: .normal)
            updatePostReactions("no_reaction")
        default:
            likeButton.setImage(UIImage(named: "thumbsup"), for: .normal)
            break
        }
    }

    fileprivate func updatePostReactions(_ reaction: String) {
        guard let post = post else { return }
        delegate?.updateReaction(on: post, reaction: reaction)
    }

    func showReactions(reaction: String) {
        switch (reaction) {
        case ("like"):
          likeButton.setImage(UIImage(named: "liked"), for: .normal)
            break
        case ("surprised"):
            likeButton.setImage(UIImage(named: "wow"), for: .normal)
            break
        case ("laugh"):
            likeButton.setImage(UIImage(named: "crylaugh"), for: .normal)
            break
        case ("sad"):
            likeButton.setImage(UIImage(named: "crying"), for: .normal)
            break
        case ("angry"):
            likeButton.setImage(UIImage(named: "anger"), for: .normal)
            break
        case ("love"):
            likeButton.setImage(UIImage(named: "loved"), for: .normal)
            break
        default:
            likeButton.setImage(UIImage(named: "thumbsup"), for: .normal)
            break
        }
    }

    fileprivate func addViews() {
        addSubview(profileImage)
        addSubview(userName)
        addSubview(postText)
        addSubview(postMedia)
        configureHorizontalButtonStackView()
        addSubview(horizontalButtonStackView)
        addSubview(createdAtDate)
        addSubview(locationLabel)
        addSubview(moreButton)
        addSubview(dividerLine)
    }
    
    fileprivate func configureHorizontalButtonStackView() {
        horizontalButtonStackView.addArrangedSubview(likeButton)
        horizontalButtonStackView.addArrangedSubview(likesCountLabel)
        horizontalButtonStackView.addArrangedSubview(commentButton)
        horizontalButtonStackView.addArrangedSubview(commentsCountLabel)
        
    }
    
    fileprivate func setupLayout() {
        profileImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12).isActive = true
        profileImage.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 12).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 60).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        moreButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8).isActive = true
        moreButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6).isActive = true
        moreButton.heightAnchor.constraint(equalToConstant: 18).isActive = true
        moreButton.widthAnchor.constraint(equalToConstant: 22).isActive = true
        
        userName.leftAnchor.constraint(equalTo: profileImage.rightAnchor, constant: 12).isActive = true
        userName.rightAnchor.constraint(equalTo: moreButton.leftAnchor, constant: -8).isActive = true
        userName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).isActive = true
        userName.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        createdAtDate.leftAnchor.constraint(equalTo: profileImage.rightAnchor, constant: 12).isActive = true
        createdAtDate.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 0).isActive = true
        createdAtDate.heightAnchor.constraint(equalToConstant: 12).isActive = true
        createdAtDate.widthAnchor.constraint(equalToConstant: 90).isActive = true
        
        locationLabel.leftAnchor.constraint(equalTo: createdAtDate.rightAnchor, constant: 8).isActive = true
        locationLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8).isActive = true
        locationLabel.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 0).isActive = true
        locationLabel.heightAnchor.constraint(equalToConstant: 12).isActive = true
        
        postText.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8).isActive = true
        postText.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8).isActive = true
        postText.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8).isActive = true
        postText.bottomAnchor.constraint(equalTo: postMedia.topAnchor, constant: 0).isActive = true
        
        postMedia.bottomAnchor.constraint(equalTo: horizontalButtonStackView.topAnchor, constant: -8).isActive = true
        postMedia.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        postMedia.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        heightConstraint =  postMedia.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.isActive = true
        
//        likesCommentsLabel.bottomAnchor.constraint(equalTo: dividerLine.topAnchor, constant: -6).isActive = true
//        likesCommentsLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0).isActive = true
//        likesCommentsLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 12).isActive = true
//        likesCommentsLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
//
//        dividerLine.bottomAnchor.constraint(equalTo: horizontalButtonStackView.topAnchor, constant: -6).isActive = true
//        dividerLine.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0).isActive = true
//        dividerLine.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0).isActive = true
//        dividerLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        horizontalButtonStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
        horizontalButtonStackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8).isActive = true
       // horizontalButtonStackView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
//        let width = 120
        horizontalButtonStackView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        horizontalButtonStackView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        
    }
}
