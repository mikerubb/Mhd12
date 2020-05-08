//
//  ATCNewPostViewController.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 10/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//
import CoreLocation
import UIKit

protocol ATCDidCreateNewPostDelegate: class {
    func didCreateNewPost()
}

class ATCNewPostViewController : UIViewController {
    
    //MARK: - Properties
    var viewer: ATCUser?
    var keyboardHeight: CGFloat = 0
    var photoButtonSelected: Bool = false
    var postComposer = ATCPostComposerState()
    var latitude: Double? = 0.0
    var longitude: Double? = 0.0
    
    var accessoryViewBottomConstraint: NSLayoutConstraint?
    var addNewPhotoHeight: NSLayoutConstraint?
   
    var imageComposerVC: ATCComposerPhotoGalleryViewController!
    var uiConfig: ATCUIGenericConfigurationProtocol
    
    var profileImage: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = UIColor.darkModeColor(hexString: "#f5f5f5")
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 50 / 2
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let userName: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "location not available "
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var postTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    lazy var accessoryView: ATCAccessoryView = {
        let view = ATCAccessoryView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.photoButton.tintColor = self.uiConfig.colorGray0
        view.locationButton.tintColor = self.uiConfig.colorGray0
        return view
    }()

    var addNewPhotoView: UIView = {
        let addNewPhoto = UIView()
        addNewPhoto.translatesAutoresizingMaskIntoConstraints = false
        addNewPhoto.backgroundColor = UIColor.darkModeColor(hexString: "#f5f5f5")
        return addNewPhoto
    }()

    var delegate: ATCDidCreateNewPostDelegate?

    // MARK: - INIT
    init(viewer: ATCUser, uiConfig: ATCUIGenericConfigurationProtocol) {
        self.uiConfig = uiConfig
        self.viewer = viewer
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = uiConfig.mainThemeBackgroundColor
        self.title = "Create Post"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(handlePostButton))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(handleCancelButton))
        addViews()
        configureLayout()
        configureAddNewPhotoView()
        configureViewerProfileData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        postTextView.becomeFirstResponder()
        observeKeyboardWillShow()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    //MARK: - Configurations
    func addViews() {
        view.addSubview(profileImage)
        view.addSubview(userName)
        view.addSubview(locationLabel)
        view.addSubview(postTextView)
        view.addSubview(accessoryView)
        view.addSubview(addNewPhotoView)
    }
    
    private func configureViewerProfileData() {
        guard let viewer = viewer else { return }
        let profileImageURL = viewer.profilePictureURL
        if let profileImageURL = profileImageURL {
            profileImage.kf.setImage(with: URL(string: profileImageURL))
        }
        userName.text = viewer.fullName()
    }
    
    private func configureAddNewPhotoView() {
        imageComposerVC = ATCComposerPhotoGalleryViewController(uiConfig: uiConfig)
        addChild(imageComposerVC)
        
        guard let imageComposerView = imageComposerVC.view else { return }
        imageComposerVC.collectionView.backgroundColor = UIColor.darkModeColor(hexString: "#f5f5f5")
        
        imageComposerView.translatesAutoresizingMaskIntoConstraints = false
        addNewPhotoView.addSubview(imageComposerView)
        imageComposerVC.didMove(toParent: self)
        
        imageComposerView.topAnchor.constraint(equalTo: addNewPhotoView.topAnchor, constant: 0).isActive = true
        imageComposerView.leftAnchor.constraint(equalTo: addNewPhotoView.leftAnchor, constant: 0).isActive = true
        imageComposerView.rightAnchor.constraint(equalTo: addNewPhotoView.rightAnchor, constant: 0).isActive = true
        imageComposerView.bottomAnchor.constraint(equalTo: addNewPhotoView.bottomAnchor).isActive = true
    }
    
    func configureLayout() {
        let safeArea = self.view.safeAreaLayoutGuide
        
        profileImage.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 12).isActive = true
        profileImage.leftAnchor.constraint(equalTo: safeArea.leftAnchor, constant: 8).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 50).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        userName.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16).isActive = true
        userName.leftAnchor.constraint(equalTo: profileImage.rightAnchor, constant: 12).isActive = true
        userName.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 8).isActive = true
        userName.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        locationLabel.topAnchor.constraint(equalTo: userName.bottomAnchor).isActive = true
        locationLabel.leftAnchor.constraint(equalTo: profileImage.rightAnchor, constant: 12).isActive = true
        locationLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        locationLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        postTextView.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 12).isActive = true
        postTextView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        postTextView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        postTextView.bottomAnchor.constraint(equalTo: addNewPhotoView.topAnchor).isActive = true
        
        addNewPhotoView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        addNewPhotoView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        addNewPhotoView.bottomAnchor.constraint(equalTo: accessoryView.topAnchor).isActive = true
        addNewPhotoHeight = addNewPhotoView.heightAnchor.constraint(equalToConstant: 1)
        addNewPhotoHeight?.isActive = true
        
        accessoryViewBottomConstraint = accessoryView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        accessoryViewBottomConstraint?.isActive = true
        accessoryView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        accessoryView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        accessoryView.heightAnchor.constraint(equalToConstant: 70).isActive = true
    }
    
    private func observeKeyboardWillShow() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    // MARK : - Handlers
    @objc func handlePostButton() {
        let socialNetworkManager = ATCSocialNetworkFirebaseAPIManager()
        guard let viewer = viewer else { return }
        
        var postText = String()
        var postMediaArray : [UIImage] = []
        
        if locationLabel.text == "location not available" {
            postComposer.location = ""
        }
            
        
        //Get images in the post
        if let dataSource = imageComposerVC.genericDataSource as? ATCGenericLocalDataSource<ATCFormImageViewModel> {
            let items = dataSource.items
            postMediaArray = items.compactMap({ $0.image })
        }
        
        if (postTextView.text.isEmpty) && (postMediaArray.isEmpty) {
                print("Can't be posted")
                return
            } else {
                 postText = postTextView.text
                 postComposer.postMedia = postMediaArray
            }
        
        //Post Composer created
        postComposer.postText = postText
       // postComposer.postMedia = postMediaArray
        postComposer.date = Date()
        
        //Send this Post Composer object, with viewer to protocol
        let uiBusy = UIActivityIndicatorView(style: .medium)
        uiBusy.hidesWhenStopped = true
        uiBusy.startAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: uiBusy)
        
        socialNetworkManager.saveNewPost(user: viewer, postComposer: postComposer) {
            self.dismiss(animated: true)
            self.delegate?.didCreateNewPost()
        }
    }
    
    @objc func handleCancelButton() {
        postTextView.resignFirstResponder()
        dismiss(animated: true)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            print("new post \(keyboardHeight)")
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
                self.accessoryViewBottomConstraint?.constant = -(self.keyboardHeight)
            })
        }
    }
}

extension ATCNewPostViewController : ATCAccessoryViewButtonDelegate {
    func didTapPhotoButton() {
        let bottom = NSMakeRange(postTextView.text.count - 1, 1)
        postTextView.scrollRangeToVisible(bottom)
 
        photoButtonSelected = !photoButtonSelected
        UIView.animate(withDuration: 0.3, animations: {
            if (self.photoButtonSelected) {
                self.addNewPhotoHeight?.constant = 100
                self.accessoryView.headingLabel.text = "Add photo to your post"
                self.accessoryView.photoButton.tintColor = self.view.tintColor
            } else {
                self.addNewPhotoHeight?.constant = 1
                self.accessoryView.headingLabel.text = "Add to your post"
                self.accessoryView.photoButton.tintColor = self.uiConfig.colorGray0
            }
            self.view.layoutIfNeeded()
        })
    }

    func didTapLocationButton() {
        let vc = LocationPicker()
        vc.addBarButtons()
        vc.pickCompletion = {[weak self] (pickedLocationItem) in
            guard let `self` = self else { return }
            
            self.postComposer.latitude = pickedLocationItem.coordinate?.latitude
            self.postComposer.longitude = pickedLocationItem.coordinate?.longitude
            self.postComposer.location = pickedLocationItem.name
            self.locationLabel.text = "\(pickedLocationItem.name)"
        }
        self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
}



