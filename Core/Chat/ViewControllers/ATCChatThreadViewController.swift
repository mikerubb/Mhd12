//
//  ATCChatThreadViewController.swift
//  ChatApp
//
//  Created by Florian Marcu on 8/26/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit
import Photos
import Firebase
import FirebaseFirestore
import FirebaseStorage

protocol ATCChatUIConfigurationProtocol {
    var primaryColor: UIColor {get}
    var backgroundColor: UIColor {get}
    var inputTextViewBgColor: UIColor {get}
    var inputTextViewTextColor: UIColor {get}
    var inputPlaceholderTextColor: UIColor {get}
    init(uiConfig: ATCUIGenericConfigurationProtocol)
}

class ATCChatUIConfiguration: ATCChatUIConfigurationProtocol {
    let primaryColor: UIColor = UIColor(hexString: "#0084ff")
    let backgroundColor: UIColor
    let inputTextViewBgColor: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                switch traitCollection.userInterfaceStyle {
                    case
                    .unspecified,
                    .light: return UIColor(hexString: "#f4f4f6")
                    case .dark: return UIColor(hexString: "#0b0b09")
                    @unknown default:
                        return .white
                }
            }
        } else {
            return UIColor(hexString: "#f4f4f6")
        }
    }()

    let inputTextViewTextColor: UIColor
    let inputPlaceholderTextColor: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                switch traitCollection.userInterfaceStyle {
                    case
                    .unspecified,
                    .light: return UIColor(hexString: "#979797")
                    case .dark: return UIColor(hexString: "#686868")
                    @unknown default:
                        return .white
                }
            }
        } else {
            return UIColor(hexString: "#979797")
        }
    }()

    required init(uiConfig: ATCUIGenericConfigurationProtocol) {
        backgroundColor = uiConfig.mainThemeBackgroundColor
        inputTextViewTextColor = uiConfig.colorGray0
    }
}

class ATCChatThreadViewController: MessagesViewController, MessagesDataSource {

    var user: ATCUser
    var recipients: [ATCUser]
    private var messages: [ATChatMessage] = []
    private var messageListener: ListenerRegistration?

    private let db = Firestore.firestore()
    private var reference: CollectionReference?
    private let storage = Storage.storage().reference()

    let reportingManager: ATCUserReportingProtocol?

    private var isSendingPhoto = false {
        didSet {
            DispatchQueue.main.async {
                self.messageInputBar.leftStackViewItems.forEach { item in
                    item.inputBarAccessoryView?.sendButton.isEnabled = !self.isSendingPhoto
                }
            }
        }
    }

    var channel: ATCChatChannel
    var uiConfig: ATCChatUIConfigurationProtocol

    init(user: ATCUser,
         channel: ATCChatChannel,
         uiConfig: ATCChatUIConfigurationProtocol,
         reportingManager: ATCUserReportingProtocol?,
         recipients: [ATCUser] = []) {
        self.user = user
        self.channel = channel
        self.uiConfig = uiConfig
        self.recipients = recipients
        self.reportingManager = reportingManager

        super.init(nibName: nil, bundle: nil)
        self.title = channel.name
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        messageListener?.remove()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        reference = db.collection(["channels", channel.id, "thread"].joined(separator: "/"))

        messageListener = reference?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }

            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
        }

        navigationItem.largeTitleDisplayMode = .never

        maintainPositionOnKeyboardFrameChanged = true

        let inputTextView = messageInputBar.inputTextView
        inputTextView.tintColor = uiConfig.primaryColor
        inputTextView.textColor = uiConfig.inputTextViewTextColor
        inputTextView.backgroundColor = uiConfig.inputTextViewBgColor
        inputTextView.layer.cornerRadius = 14.0
        inputTextView.layer.borderWidth = 0.0
        inputTextView.font = UIFont.systemFont(ofSize: 16.0)
        inputTextView.placeholderLabel.textColor = uiConfig.inputPlaceholderTextColor
        inputTextView.placeholderLabel.text = "Start typing..."
        inputTextView.textContainerInset = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 6, left: 15, bottom: 6, right: 15)

        let sendButton = messageInputBar.sendButton
        sendButton.setTitleColor(uiConfig.primaryColor, for: .normal)
        sendButton.setImage(UIImage.localImage("share-icon", template: true), for: .normal)
        sendButton.title = ""
        sendButton.setSize(CGSize(width: 30, height: 30), animated: false)
        sendButton.tintColor = uiConfig.primaryColor

        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self

        let cameraItem = InputBarButtonItem(type: .system)
        cameraItem.tintColor = uiConfig.primaryColor
        cameraItem.image = UIImage.localImage("camera-filled-icon", template: true)
        cameraItem.addTarget(
            self,
            action: #selector(cameraButtonPressed),
            for: .primaryActionTriggered
        )
        cameraItem.setSize(CGSize(width: 30, height: 30), animated: false)

        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        messageInputBar.setRightStackViewWidthConstant(to: 35, animated: false)
        messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false)
        messageInputBar.backgroundColor = uiConfig.backgroundColor
        messageInputBar.backgroundView.backgroundColor = uiConfig.backgroundColor
        messageInputBar.separatorLine.isHidden = true

        self.updateNavigationBar()
        messagesCollectionView.backgroundColor = uiConfig.backgroundColor
        view.backgroundColor = uiConfig.backgroundColor
    }

    // MARK: - Actions

    @objc private func cameraButtonPressed() {
        let picker = UIImagePickerController()
        picker.delegate = self

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }

        present(picker, animated: true, completion: nil)
    }

    // MARK: - Helpers

    private func save(_ message: ATChatMessage) {
        reference?.addDocument(data: message.representation) {[weak self] error in
            if let e = error {
                print("Error sending message: \(e.localizedDescription)")
                return
            }
            guard let `self` = self else { return }

            let channelRef = Firestore.firestore().collection("channels").document(self.channel.id)
            var lastMessage = ""
            switch message.kind {
            case let .text(text):
                lastMessage = text
            case .photo(_):
                lastMessage = "Someone sent a photo."
            default:
                break
            }
            let newData: [String: Any] = [
                "lastMessageDate": Date(),
                "lastMessage": lastMessage
            ]
            channelRef.setData(newData, merge: true)
            ATCChatFirebaseManager.updateChannelParticipationIfNeeded(channel: self.channel)
            self.sendOutPushNotificationsIfNeeded(message: message)

            self.messagesCollectionView.scrollToBottom()
        }
    }

    private func sendOutPushNotificationsIfNeeded(message: ATChatMessage) {
        var lastMessage = ""
        switch message.kind {
        case let .text(text):
//            if let firstName = user.firstName {
//                lastMessage = firstName + ": " + text
//            } else {
                lastMessage = text
//            }
        case .photo(_):
            lastMessage = "Someone sent a photo."
        default:
            break
        }

        let notificationSender = ATCPushNotificationSender()
        recipients.forEach { (recipient) in
            if let token = recipient.pushToken, recipient.uid != user.uid {
                notificationSender.sendPushNotification(to: token, title: user.firstName ?? "Social Network", body: lastMessage)
            }
        }
    }

    private func insertNewMessage(_ message: ATChatMessage) {
        guard !messages.contains(message) else {
            return
        }

        messages.append(message)
        messages.sort()

        let isLatestMessage = messages.firstIndex(of: message) == (messages.count - 1)
        let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage

        messagesCollectionView.reloadData()

        if shouldScrollToBottom {
            DispatchQueue.main.async {
                self.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }

    private func handleDocumentChange(_ change: DocumentChange) {
        guard let message = ATChatMessage(document: change.document) else {
            return
        }
        switch change.type {
        case .added:
            if let url = message.downloadURL {
                downloadImage(at: url) { [weak self] image in
                    guard let `self` = self else {
                        return
                    }
                    guard let image = image else {
                        return
                    }

                    message.image = image
                    self.insertNewMessage(message)
                }
            } else {
                insertNewMessage(message)
            }
        default:
            break
        }
    }

    private func uploadImage(_ image: UIImage, to channel: ATCChatChannel, completion: @escaping (URL?) -> Void) {

        guard let scaledImage = image.scaledToSafeUploadSize, let data = scaledImage.jpegData(compressionQuality: 0.4) else {
            completion(nil)
            return
        }
        let hud = CPKProgressHUD.progressHUD(style: .loading(text: "Sending"))
        hud.show(in: view)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
        storage.child(channel.id).child(imageName).putData(data, metadata: metadata) { meta, error in
            hud.dismiss()
            if let name = meta?.path, let bucket = meta?.bucket {
                let path = "gs://" + bucket + "/" + name
                completion(URL(string: path))
            } else {
                completion(nil)
            }
        }
    }

    private func sendPhoto(_ image: UIImage) {
        isSendingPhoto = true
        uploadImage(image, to: channel) { [weak self] url in
            guard let `self` = self else {
                return
            }
            self.isSendingPhoto = false

            guard let url = url else {
                return
            }
            let message = ATChatMessage(user: self.user, image: image, url: url)
            message.downloadURL = url

            self.save(message)
            self.messagesCollectionView.scrollToBottom()
        }
    }

    private func downloadImage(at url: URL, completion: @escaping (UIImage?) -> Void) {
        let ref = Storage.storage().reference(forURL: url.absoluteString)
        let megaByte = Int64(1 * 1024 * 1024)

        ref.getData(maxSize: megaByte) { data, error in
            guard let imageData = data else {
                completion(nil)
                return
            }

            completion(UIImage(data: imageData))
        }
    }

    private func updateNavigationBar() {
        if self.channel.participants.count > 2 {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(actionsButtonTapped))
        } else {
            // 1-1 conversations
            if reportingManager != nil {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(repotingButtonTapped))
            }
        }
    }

    fileprivate func otherUser() -> ATCUser? {
        for recipient in recipients {
            if recipient.uid != user.uid {
                return recipient
            }
        }
        return nil
    }

    @objc private func repotingButtonTapped() {
        self.showCaretMenu()
    }

    @objc private func actionsButtonTapped() {
        let alert = UIAlertController(title: "Group Settings", message: "", preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: "Rename Group", style: .default, handler: {[weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.didTapRenameButton()
        }))
        alert.addAction(UIAlertAction(title: "Leave Group", style: .destructive, handler: {[weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.didTapLeaveGroupButton()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = self.view.bounds
        }
        self.present(alert, animated: true)
    }

    private func didTapRenameButton() {
        let alert = UIAlertController(title: "Change Name", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Enter Group Name"
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {[weak self] (action) in
            guard let strongSelf = self else { return }
            guard let name = alert.textFields?.first?.text else {
                return
            }
            if name.count == 0 {
                strongSelf.didTapRenameButton()
                return
            }
            ATCChatFirebaseManager.renameGroup(channel: strongSelf.channel, name: name)
            strongSelf.title = name
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }

    private func didTapLeaveGroupButton() {
        let alert = UIAlertController(title: "Are you sure?", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {[weak self] (action) in
            guard let strongSelf = self else { return }
            ATCChatFirebaseManager.leaveGroup(channel: strongSelf.channel, user: strongSelf.user)
            strongSelf.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }

    // MARK: - MessagesDataSource

    func currentSender() -> SenderType {
        return Sender(senderId: user.uid ?? "noid", displayName: "You")
    }

    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func messageForItem(at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> MessageType {
        if indexPath.section < messages.count {
            return messages[indexPath.section]
        }
        fatalError()
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func cellTopLabelAttributedText(for message: MessageType,
                                    at indexPath: IndexPath) -> NSAttributedString? {

        let name = message.sender.displayName
        return NSAttributedString(
            string: name,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .caption1),
                .foregroundColor: UIColor(white: 0.3, alpha: 1)
            ]
        )
    }
}

// MARK: - MessagesLayoutDelegate

extension ATCChatThreadViewController: MessagesLayoutDelegate {

    func avatarSize(for message: MessageType, at indexPath: IndexPath,
                    in messagesCollectionView: MessagesCollectionView) -> CGSize {

        return .zero
    }

    func footerViewSize(for message: MessageType, at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> CGSize {

        return CGSize(width: 0, height: 8)
    }

    func heightForLocation(message: MessageType, at indexPath: IndexPath,
                           with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {

        return 0
    }
}

// MAR: - MessageInputBarDelegate

extension ATCChatThreadViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
        let message = ATChatMessage(messageId: UUID().uuidString,
                                    messageKind: MessageKind.text(text),
                                    createdAt: Date(),
                                    atcSender: user,
                                    recipient: user,
                                    seenByRecipient: false)
        save(message)
        inputBar.inputTextView.text = ""
    }

    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {}
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {}
    func inputBar(_ inputBar: InputBarAccessoryView, didSwipeTextViewWith gesture: UISwipeGestureRecognizer) {}
}

// MARK: - MessagesDisplayDelegate

extension ATCChatThreadViewController: MessagesDisplayDelegate {

    func backgroundColor(for message: MessageType, at indexPath: IndexPath,
                         in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? uiConfig.primaryColor : UIColor(hexString: "#f0f0f0")
    }

    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath,
                             in messagesCollectionView: MessagesCollectionView) -> Bool {
        return false
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {

        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if let message = message as? ATChatMessage {
            avatarView.initials = message.atcSender.initials
            if let urlString = message.atcSender.profilePictureURL {
                avatarView.kf.setImage(with: URL(string: urlString))
            }
        }
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url]
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        if (detector == .url) {
            return [ NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue ]
        }
            return [NSAttributedString.Key.foregroundColor : UIColor.white]
    }
}

extension ATCChatThreadViewController : MessageCellDelegate, MessageLabelDelegate {
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        let indexPath = messagesCollectionView.indexPath(for: cell)
        guard let tappedCellIndexPath = indexPath else { return }
        let tappedMessage = messageForItem(at: tappedCellIndexPath, in: messagesCollectionView)
        if let message = tappedMessage as? ATChatMessage {
            if let downloadURL = message.downloadURL {
                let imageViewerVC = ATCChatImageViewer()
                imageViewerVC.downloadURL = downloadURL
                present(imageViewerVC, animated: true)
            } else {
                print("Message does not contain image")
            }
        }
    }
    
    func didSelectURL(_ url: URL) {
        var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        comps.scheme = "https"
        let https = comps.url
        guard let httpsURL = https else { return }
        let webViewController = ATCWebViewController(url: httpsURL, title: "Web")
        navigationController?.pushViewController(webViewController, animated: true)
    }
}
// MARK: - UIImagePickerControllerDelegate

extension ATCChatThreadViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset {
            let size = CGSize(width: 500, height: 500)
            PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: nil) { result, info in
                guard let image = result else {
                    return
                }

                self.sendPhoto(image)
            }
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            sendPhoto(image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}

extension ATCChatThreadViewController {
    fileprivate func showCaretMenu() {
        guard let reportingManager = reportingManager, let profile = self.otherUser() else { return }
        let alert = UIAlertController(title: "Actions on " + (profile.firstName ?? ""),
                                      message: "",
                                      preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: "Block user", style: .destructive, handler: {(action) in
            reportingManager.block(sourceUser: self.user, destUser: profile, completion: {[weak self]  (success) in
                guard let `self` = self else { return }
                self.showBlockMessage(success: success)
            })
        }))
        alert.addAction(UIAlertAction(title: "Report user", style: .default, handler: {(action) in
            self.showReportMenu()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = self.navigationController?.navigationBar
            if let frame = self.navigationController?.navigationBar.frame {
                popoverPresentationController.sourceRect = frame
            }
        }
        self.present(alert, animated: true, completion: nil)
    }

    fileprivate func showReportMenu() {
        let alert = UIAlertController(title: "Why are you reporting this account?", message: "", preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: "Spam", style: .default, handler: {(action) in
            self.reportUser(reason: .spam)
        }))
        alert.addAction(UIAlertAction(title: "Sensitive photos", style: .default, handler: {(action) in
            self.reportUser(reason: .sensitiveImages)
        }))
        alert.addAction(UIAlertAction(title: "Abusive content", style: .default, handler: {(action) in
            self.reportUser(reason: .abusive)
        }))
        alert.addAction(UIAlertAction(title: "Harmful information", style: .default, handler: {(action) in
            self.reportUser(reason: .harmful)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = self.view.bounds
        }
        self.present(alert, animated: true, completion: nil)
    }

    fileprivate func showBlockMessage(success: Bool) {
        let message = (success) ? "This user has been blocked successfully." : "An error has occured. Please try again."
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    fileprivate func reportUser(reason: ATCReportingReason) {
        guard let reportingManager = reportingManager, let profile = self.otherUser() else { return }
        reportingManager.report(sourceUser: user,
                                destUser: profile,
                                reason: reason) {[weak self] (success) in
                                    guard let `self` = self else { return }
                                    self.showReportMessage(success: success)
        }
    }

    fileprivate func showReportMessage(success: Bool) {
        let message = (success) ? "This user has been reported successfully." : "An error has occured. Please try again."
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
