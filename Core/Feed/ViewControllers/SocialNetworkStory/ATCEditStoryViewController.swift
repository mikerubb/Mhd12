//
//  ATCEditStoryViewController.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 06/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit
import AVFoundation

protocol ATCDidCreateNewStoryDelegate: class {
    func didCreateNewStory()
}

protocol ATStoryUpdateComposeViewControllerDelegate {
    func storyDidGetUpdated()
}

class ATCEditStoryViewController : UIViewController {
    
    var mediaType = String()
    var imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .black 
        return imageView
    }()
    var imageCaptured : UIImage! {
        didSet {
            mediaType = "image"
            print("Image Set")
            imageView.isHidden = false
            videoPreview.isHidden = true
        }
    }
    
    var videoURL: URL? {
        didSet {
            mediaType = "video"
            print("Video Set")
            resetVideoPlayer()
            imageView.isHidden = true
            videoPreview.isHidden = false
            self.previewVideo(url: videoURL)
        }
    }
    var cancelButton = ATCDismissButton()
    var viewer: ATCUser? = nil
    var delegate: ATStoryUpdateComposeViewControllerDelegate?
    var player: AVPlayer?
    
    var videoPreview: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    var postButton : UIButton = {
        let button = UIButton()
        button.setTitle("Post", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = UIColor(hexString: "#f5f5f5")
        button.addTarget(self, action: #selector(handlePostButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = imageCaptured
        configureImageView()
        configurePostButton()
        configureCancelButton()
        configureVideoPlayer()
    }
    
    func configureImageView() {
        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    func configureCancelButton() {
        view.addSubview(cancelButton)
        cancelButton.contentMode = .scaleAspectFill
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(handleCancelButton), for: .touchUpInside)
        
        cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 32).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    func configurePostButton() {
        view.addSubview(postButton)
        postButton.contentMode = .scaleAspectFill
        postButton.translatesAutoresizingMaskIntoConstraints = false
        postButton.layer.cornerRadius = 20
        postButton.clipsToBounds = true
        
        postButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12).isActive = true
        postButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12).isActive = true
        postButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        postButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    private func configureVideoPlayer() {
        view.addSubview(videoPreview)
        
        videoPreview.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        videoPreview.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        videoPreview.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        videoPreview.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
    }
    
    fileprivate func resetVideoPlayer() {
        if player != nil {
            player?.pause()
            player?.replaceCurrentItem(with: nil)
            player = nil
        }
    }
    
    func previewVideo(url: URL?) {
        let videoURL = url
        guard let vidURL = videoURL else { return }
        player = AVPlayer(url: vidURL)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.videoPreview.bounds
        self.videoPreview.layer.addSublayer(playerLayer)
        guard let player = player else { return }
        player.play()
    }
    
    @objc func handleCancelButton() {
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc func handlePostButton() {
        //Logic to upload the photo to firebase
        guard let viewer = viewer else {
            print("Viewer not found")
            return
            
        }
        let storyManager = ATCSocialNetworkStoryFirebaseManager()
        let composerState = ATCStoryComposerState()
        
        composerState.mediaType = mediaType   // Will figure out how to check for videos and photos here
        if mediaType == "image" {
            composerState.photoMedia = imageCaptured
        }else if mediaType == "video" {
            composerState.videoMedia = videoURL
        }
        
        storyManager.saveStories(loggedInUser: viewer, storyComposer: composerState) {
            print("Story Uploaded")
            self.dismiss(animated: true, completion: {
                self.delegate?.storyDidGetUpdated()
            })
        }
        
    }
}


