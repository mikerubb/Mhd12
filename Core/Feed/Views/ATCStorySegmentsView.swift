//
//  ATCStorySegmentsView.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 18/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit
import AVKit

protocol ATCSegmentDataSource: class {
    func numberOfSegmentsToShow() -> Int
}
protocol ATCSegmentAnimationDelegate: class {
    func animationDidEnd(at index: Int)
    func restartAnimation(at index: Int)
}

class ATCStorySegmentsView : UIView {
    
    let stackView: UIStackView = {
        let v = UIStackView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.axis = .horizontal
        v.alignment = .fill
        v.distribution = .fillEqually
        v.spacing = 4
        return v
    }()
    
    var animationIndex = 0
     var duration: TimeInterval = 2
    var dataSource: ATCSegmentDataSource? {
        didSet {
           addSegments()
        }
    }
    var delegate: ATCSegmentAnimationDelegate?
    private var segmentsArray = [Segment]()
    var storyData = [ATCStory]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configurestackView()

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configurestackView() {
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            
            // constrain stack view to all 4 sides
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            ])
    }
    
    func startAnimation() {
        animate()
    }

     func animate(at index: Int = 0) {
        let currentSegment = segmentsArray[index]
        let storyType = storyData[index].storyType
        let mediaURL = storyData[index].storyMediaURL
        animationIndex = index
        
        if storyType == "image" {
            duration = 5
        }else {
            duration = calculateVideoDuration(mediaURL)
        }
        
        currentSegment.showTopSegment()
        UIView.animate(withDuration: duration, delay: 0, options: .curveLinear, animations: {
           self.layoutIfNeeded()
        }) { (finished) in
            if (finished) {
                self.delegate?.animationDidEnd(at: index)
                self.next()
            } else {
                return
            }
        }
    }
    
    private func calculateVideoDuration(_ url: String) -> Double {
        let videoURL = URL(string: url)
        guard let vidURL = videoURL else { return 0.0 }
        let asset = AVAsset(url: vidURL)
            
        let duration = asset.duration
        let durationTime = CMTimeGetSeconds(duration)
        
        return Double(durationTime)
    }

     private func next() {
        let newIndex = animationIndex + 1
        if newIndex < segmentsArray.count {
            animationIndex = newIndex
            animate(at: newIndex)
        } else {
            print("All Stories Finished")
        }
    }
    
    
    private func calculatePrevIndex(currentIndex: Int) -> Int {
        if currentIndex == 0 {
            return currentIndex
        }
        let previousIndex = currentIndex - 1
        return previousIndex
    }
    
    private func addSegments() {
        let numberOfSegment = dataSource?.numberOfSegmentsToShow()
        guard let segmentQuantity = numberOfSegment else { return }
        
        for _ in 0..<segmentQuantity {
            let seg = Segment()
            seg.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(seg)
            segmentsArray.append(seg)
        }      
    }
    
    func nextStory() {
        let ongoingSegmentIndex = animationIndex
        let ongoingSegment = segmentsArray[ongoingSegmentIndex]
        ongoingSegment.showTopSegment()
        ongoingSegment.topSegment.layer.removeAllAnimations()
        self.delegate?.animationDidEnd(at: ongoingSegmentIndex)
        self.next()
    }
    
    func previousStory() {
        let ongoingSegmentIndex = animationIndex
        let ongoingSegment = segmentsArray[ongoingSegmentIndex]
        ongoingSegment.topSegment.layer.removeAllAnimations()
        ongoingSegment.hideTopSegment()
    
        let previousSegment = segmentsArray[calculateIndexForPreviousSegment(presentIndex: ongoingSegmentIndex)]
        previousSegment.hideTopSegment()
        
        if ongoingSegmentIndex == 0 {
            self.delegate?.animationDidEnd(at: ongoingSegmentIndex - 1)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.animate(at: ongoingSegmentIndex)
            }
        } else {
            self.delegate?.animationDidEnd(at: ongoingSegmentIndex - 2)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.animate(at: ongoingSegmentIndex - 1)
            }
        }
        print("prev story")
        }
    
    func calculateIndexForPreviousSegment(presentIndex: Int) -> Int {
        if (presentIndex == 0) {
            return 0
        }
        let previousIndex = presentIndex - 1
        return previousIndex
    }
    
    func cancelAllAnimations() {
        for segment in segmentsArray {
            segment.topSegment.layer.removeAllAnimations()
            segment.bottomSegment.layer.removeAllAnimations()
        }
    }
}


