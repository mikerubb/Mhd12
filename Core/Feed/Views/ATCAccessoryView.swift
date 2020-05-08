//
//  ATCAccessoryView.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 10/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

protocol ATCAccessoryViewButtonDelegate: class {
    func didTapPhotoButton()
    func didTapLocationButton()
}

class ATCAccessoryView : UIView {
    //MARK: - Properties
    var delegate: ATCAccessoryViewButtonDelegate?
    var imageComposerVC: ATCComposerPhotoGalleryViewController?

    var headingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Add to your Post"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    lazy var photoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "camera-filled-icon"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleAddPhotoButton), for: .touchUpInside)
        return button
    }()

    lazy var locationButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "pinpoint-icon"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(handleAddLocationButton), for: .touchUpInside)
        return button
    }()

    var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.backgroundColor = .green
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = UIColor.darkModeColor(hexString: "#f5f5f5")
        isUserInteractionEnabled = true
        addViews()
        configureViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addViews() {
        addSubview(headingLabel)
        addSubview(buttonStackView)
    }
    
    func configureViews() {
        buttonStackView.addArrangedSubview(photoButton)
        buttonStackView.addArrangedSubview(locationButton)
        
        buttonStackView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        buttonStackView.widthAnchor.constraint(equalToConstant: 130).isActive = true
        buttonStackView.topAnchor.constraint(equalTo: topAnchor, constant: 25).isActive = true
        buttonStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
        
        headingLabel.topAnchor.constraint(equalTo: topAnchor, constant: 25).isActive = true
        headingLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
        headingLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        headingLabel.widthAnchor.constraint(equalToConstant: 190).isActive = true
        
    }
    
    // MARK: - Handler
    @objc func handleAddPhotoButton() {
        delegate?.didTapPhotoButton()
    }
    
    @objc func handleAddLocationButton() {
        delegate?.didTapLocationButton()
    }
 
}
