//
//  ATCSegment.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 20/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class Segment: UIView {
    let topSegment: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let bottomSegment : UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var startConstraint: NSLayoutConstraint = NSLayoutConstraint()
    var endConstraint: NSLayoutConstraint = NSLayoutConstraint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSegments()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSegments() {
        addSubview(bottomSegment)
        addSubview(topSegment)
        
        
        startConstraint = topSegment.widthAnchor.constraint(equalTo: bottomSegment.widthAnchor, multiplier: 0.0)
        endConstraint = topSegment.widthAnchor.constraint(equalTo: bottomSegment.widthAnchor, multiplier: 1.0)
        
        NSLayoutConstraint.activate([
            
            bottomSegment.topAnchor.constraint(equalTo: topAnchor),
            bottomSegment.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomSegment.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomSegment.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            topSegment.topAnchor.constraint(equalTo: topAnchor),
            topSegment.bottomAnchor.constraint(equalTo: bottomAnchor),
            topSegment.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            startConstraint,
            
            ])
    }
    
    func showTopSegment() {
        startConstraint.isActive = false
        endConstraint.isActive = true
    }
    
    func hideTopSegment() {
        startConstraint.isActive = true
        endConstraint.isActive = false
    }
}
