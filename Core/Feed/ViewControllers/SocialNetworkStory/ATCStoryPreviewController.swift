//
//  ATCStoryPreviewController.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 17/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit
import AVKit

class ATCStoryPreviewController: UIViewController {
    
    var pageIndex : Int = 0
    var friendStory = [ATCStory]()
    let segmentContainerView: ATCStorySegmentsView = ATCStorySegmentsView()
    var nextStoryRect = CGRect()
    var delegate: ATCNextUserStoryDelegate?
    var player: AVPlayer?
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var videoPreview: UIView = {
        let videoPreview = UIView()
        videoPreview.isUserInteractionEnabled = true
        videoPreview.translatesAutoresizingMaskIntoConstraints = false
        return videoPreview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isUserInteractionEnabled = true
        configureMediaViewsLayout()
        configureTapGestureRecognizer()
        configureSegmentContainerView()
        segmentContainerView.dataSource = self
        segmentContainerView.delegate = self
        
        nextStoryRect = CGRect(x: self.view.frame.width / 2 , y: 0, width: (self.view.frame.width - (self.view.frame.width / 2)) , height: self.view.frame.height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.6) {
            self.view.transform = .identity
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.segmentContainerView.animationIndex = 0
            self.showImage()
            self.segmentContainerView.startAnimation()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        DispatchQueue.main.async {
            self.imageView.removeFromSuperview()
            self.segmentContainerView.removeFromSuperview()
            self.segmentContainerView.animationIndex = 0
        }
    }
    
    @objc func handlePreviousStoryTap() {
        segmentContainerView.previousStory()
    }
    
    @objc func handleNextStoryTap(tap: UITapGestureRecognizer) {
        let location = tap.location(in: self.view)
        if nextStoryRect.contains(location) {
            segmentContainerView.nextStory()
        }else {
            handlePreviousStoryTap()
        }
    }
    
    fileprivate func showImage(at index: Int = 0) {
        
        let story = friendStory[index]
        let mediaURL = story.storyMediaURL
        if story.storyType == "image" {
            videoPreview.isHidden = true
            imageView.isHidden = false
            imageView.kf.setImage(with: URL(string: mediaURL))
            
        } else {
            resetVideoPlayer()
            imageView.isHidden = true
            videoPreview.isHidden = false
            configureVideofromURL(mediaURL)
        }
    }
    
    fileprivate func configureVideofromURL(_ url: String) {
        let videoURL = URL(string: url)
        guard let vidURL = videoURL else { return }
        
        let asset = AVAsset(url: vidURL)
        let keys: [String] = ["playable"]
        
        asset.loadValuesAsynchronously(forKeys: keys, completionHandler: {
            var error: NSError? = nil
            let status = asset.statusOfValue(forKey: "playable", error: &error)
            switch status {
            case .loaded:
                DispatchQueue.main.async {
                    let item = AVPlayerItem(asset: asset)
                    self.player = AVPlayer(playerItem: item)
                    let playerLayer = AVPlayerLayer(player: self.player)
                    playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    playerLayer.frame = self.videoPreview.bounds
                    self.videoPreview.layer.addSublayer(playerLayer)
                    guard let player = self.player else { return }
                    player.isMuted = true
                    player.play()
                }
                break
            case .failed:
                break
            case .cancelled:
                break
            default:
                break
            }
        })
    }
    
    fileprivate func configureSegmentContainerView() {
        view.addSubview(segmentContainerView)
        
        segmentContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            segmentContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0.0),
            segmentContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8.0),
            segmentContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8.0),
            segmentContainerView.heightAnchor.constraint(equalToConstant: 3.0),
            
            ])
       
        segmentContainerView.storyData = friendStory
    }
    
    fileprivate func configureMediaViewsLayout() {
        view.addSubview(videoPreview)
        view.addSubview(imageView)

        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 35).isActive = true
        imageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        videoPreview.topAnchor.constraint(equalTo: view.topAnchor, constant: 35).isActive = true
        videoPreview.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        videoPreview.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        videoPreview.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    fileprivate func configureTapGestureRecognizer() {
        let nextStoryTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleNextStoryTap(tap: )))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(nextStoryTapGestureRecognizer)
        
        let tapGestureVideo = UITapGestureRecognizer(target: self, action: #selector(handleNextStoryTap(tap: )))
        videoPreview.addGestureRecognizer(tapGestureVideo)
    }
    
    fileprivate func resetVideoPlayer() {
        if player != nil {
            player?.pause()
            player?.replaceCurrentItem(with: nil)
            player = nil
        }
    }
}

extension ATCStoryPreviewController : ATCSegmentDataSource {
    func numberOfSegmentsToShow() -> Int {
        let story = friendStory
        return story.count
    }
}

extension ATCStoryPreviewController : ATCSegmentAnimationDelegate {
    func animationDidEnd(at index: Int) {
        let newIndex = index + 1
        if newIndex < friendStory.count {
            showImage(at: newIndex)
        }else {
        delegate?.nextUserStory(at: pageIndex + 1)
        }
    }
    
    func restartAnimation(at index: Int) {
        showImage(at: index)
    }
}
