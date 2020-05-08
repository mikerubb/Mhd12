//
//  ATChatMessage.swift
//  ChatApp
//
//  Created by Florian Marcu on 8/20/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import Firebase
import FirebaseFirestore

class ATCMediaItem: MediaItem {
    var url: URL? = nil
    var image: UIImage? = nil
    var placeholderImage: UIImage
    var size: CGSize
    init(url: URL?, image: UIImage? = nil) {
        self.url = url
        self.image = image
        self.placeholderImage = UIImage.localImage("camera-icon")
        self.size = CGSize(width: 500, height: 500)
    }
}

class ATChatMessage: ATCGenericBaseModel, MessageType {
    var id: String?

    var sentDate: Date

    var kind: MessageKind

    lazy var sender: SenderType = Sender(senderId: atcSender.uid ?? "No Id", displayName: atcSender.uid ?? "No Name")

    var atcSender: ATCUser
    var recipient: ATCUser
    var seenByRecipient: Bool

    var messageId: String {
        return id ?? UUID().uuidString
    }

    var image: UIImage? = nil {
        didSet {
            self.kind = .photo(ATCMediaItem(url: downloadURL, image: self.image))
        }
    }
    var downloadURL: URL? = nil
    let content: String

    init(messageId: String, messageKind: MessageKind, createdAt: Date, atcSender: ATCUser, recipient: ATCUser, seenByRecipient: Bool) {
        self.id = messageId
        self.kind = messageKind
        self.sentDate = createdAt
        self.atcSender = atcSender
        self.recipient = recipient
        self.seenByRecipient = seenByRecipient

        switch messageKind {
        case .text(let text):
            self.content = text
        default:
            self.content = ""
        }
    }

    init(user: ATCUser, image: UIImage, url: URL) {
        self.image = image
        content = ""
        sentDate = Date()
        id = nil
        let mediaItem = ATCMediaItem(url: url, image: nil)
        self.kind = MessageKind.photo(mediaItem)
        self.atcSender = user
        self.recipient = user
        self.seenByRecipient = true
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let sentDate = data["created"] as? Timestamp else {
            return nil
        }
        guard let senderID = data["senderID"] as? String else {
            return nil
        }
        guard let senderFirstName = data["senderFirstName"] as? String else {
            return nil
        }
        guard let senderLastName = data["senderLastName"] as? String else {
            return nil
        }
        guard let senderProfilePictureURL = data["senderProfilePictureURL"] as? String else {
            return nil
        }
        guard let recipientID = data["recipientID"] as? String else {
            return nil
        }
        guard let recipientFirstName = data["recipientFirstName"] as? String else {
            return nil
        }
        guard let recipientLastName = data["recipientLastName"] as? String else {
            return nil
        }
        guard let recipientProfilePictureURL = data["recipientProfilePictureURL"] as? String else {
            return nil
        }

        id = document.documentID

        self.sentDate = sentDate.dateValue()
        self.atcSender = ATCUser(uid: senderID, firstName: senderFirstName, lastName: senderLastName, avatarURL: senderProfilePictureURL)
        self.recipient = ATCUser(uid: recipientID, firstName: recipientFirstName, lastName: recipientLastName, avatarURL: recipientProfilePictureURL)

        if let content = data["content"] as? String {
            self.content = content
            downloadURL = nil
            self.kind = MessageKind.text(content)
        } else if let urlString = data["url"] as? String, let url = URL(string: urlString) {
            downloadURL = url
            self.content = ""
            let mediaItem = ATCMediaItem(url: url, image: nil)
            self.kind = MessageKind.photo(mediaItem)
        } else {
            return nil
        }
        self.seenByRecipient = true
    }

    required init(jsonDict: [String: Any]) {
        fatalError()
    }

    var description: String {
        return self.messageText
    }

    var messageText: String {
        switch kind {
        case .text(let text):
            return text
        default:
            return ""
        }
    }
    
    var channelId: String {
        let id1 = (recipient.uid ?? "")
        let id2 = (atcSender.uid ?? "")
        return id1 < id2 ? id1 + id2 : id2 + id1
    }
}

extension ATChatMessage: DatabaseRepresentation {

    var representation: [String : Any] {
        var rep: [String : Any] = [
            "created": sentDate,
            "senderID": atcSender.uid ?? "",
            "senderFirstName": atcSender.firstName ?? "",
            "senderLastName": atcSender.lastName ?? "",
            "senderProfilePictureURL": atcSender.profilePictureURL ?? "",
            "recipientID": recipient.uid ?? "",
            "recipientFirstName": recipient.firstName ?? "",
            "recipientLastName": recipient.lastName ?? "",
            "recipientProfilePictureURL": atcSender.profilePictureURL ?? "",
        ]

        if let url = downloadURL {
            rep["url"] = url.absoluteString
        } else {
            rep["content"] = content
        }

        return rep
    }

}

extension ATChatMessage: Comparable {

    static func == (lhs: ATChatMessage, rhs: ATChatMessage) -> Bool {
        return lhs.id == rhs.id
    }

    static func < (lhs: ATChatMessage, rhs: ATChatMessage) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
}

import Foundation

protocol DatabaseRepresentation {
    var representation: [String: Any] { get }
}
