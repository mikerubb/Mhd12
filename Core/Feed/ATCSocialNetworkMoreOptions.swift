//
//  ATCSocialNetworkMoreOptions.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 18/07/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

protocol ATCPostDidGetDeletedDelegate: class {
    func postDeletedOnNewsFeed()
    func postDeletedOnDetailPage()
    func postDeletedOnProfilePage()
}

class ATCSocialNetworkMoreOptions : NSObject {
    var viewer: ATCUser?
    var navcontroller: UINavigationController? = nil
    var delegate: ATCPostDidGetDeletedDelegate? = nil
    
    init(viewer: ATCUser, navController: UINavigationController) {
        self.viewer = viewer
        self.navcontroller = navController
    }

    private func report(_ post: ATCPost, reason: ATCReportingReason) {
        let reporter = ATCFirebaseUserReporter()
        let userManager = ATCSocialFirebaseUserManager()
        guard let sourceUser = viewer else { return }
        guard let postAuthorUID = post.authorID else { return }
        
        userManager.fetchUser(userID: postAuthorUID) { (destUser) in
            guard let destUser = destUser else { return }
            reporter.report(sourceUser: sourceUser, destUser: destUser, reason: reason, completion: { (reported) in
                let alert = UIAlertController(title: "Reported!", message: "The post has been reported.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil))

                self.delegate?.postDeletedOnNewsFeed() //Same method called to refresh the newsfeed
                self.delegate?.postDeletedOnDetailPage()
                
                self.navcontroller?.present(alert, animated: true, completion: nil)
            })
        }
    }

    private func block(_ post: ATCPost) {
        let reporter = ATCFirebaseUserReporter()
        let userManager = ATCSocialFirebaseUserManager()
        guard let sourceUser = viewer else { return }
        guard let postAuthorUID = post.authorID else { return }
        
        userManager.fetchUser(userID: postAuthorUID) { (user) in
            guard let destUser = user else { return }
            reporter.block(sourceUser: sourceUser, destUser: destUser, completion: { (blocked) in
                let alert = UIAlertController(title: "Blocked!", message: "The user has been blocked.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil))
                
                self.delegate?.postDeletedOnNewsFeed()
                self.delegate?.postDeletedOnDetailPage()
                self.navcontroller?.present(alert, animated: true, completion: nil)
            })
        }
    }

     func showReportActionSheet(on post: ATCPost) {
        
        let actionSheet = UIAlertController(title: "Report", message: "Select the reason of reporting: ", preferredStyle: .actionSheet)
        
        let sensitiveImagesAction = UIAlertAction(title: "Sensitive Images", style: .default) { [weak self]  (remove) in
            guard let strongSelf = self else { return }
            let sensitiveImages: ATCReportingReason = .sensitiveImages
            strongSelf.report(post, reason: sensitiveImages)
        }
        let spamAction = UIAlertAction(title: "Spam", style: .default) { [weak self]  (remove) in
            
            guard let strongSelf = self else { return }
            let spam: ATCReportingReason = .spam
            strongSelf.report(post, reason: spam)
        }
        let abusiveAction = UIAlertAction(title: "Abusive", style: .default) { [weak self]  (remove) in
          
            guard let strongSelf = self else { return }
            let abusive: ATCReportingReason = .abusive
            strongSelf.report(post, reason: abusive)
        }
        let harmfulAction = UIAlertAction(title: "Harmful", style: .default) { [weak self]  (remove) in
            
            guard let strongSelf = self else { return }
            let harmful: ATCReportingReason = .harmful
            strongSelf.report(post, reason: harmful)
            
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(sensitiveImagesAction)
        actionSheet.addAction(spamAction)
        actionSheet.addAction(abusiveAction)
        actionSheet.addAction(harmfulAction)
        actionSheet.addAction(cancelAction)

       navcontroller?.present(actionSheet, animated: true, completion: nil)
    }

    func showPostActionSheet(on post: ATCPost, cell: ATCPostCell) {
        guard let viewerUID = viewer?.uid else { return }
        guard let postAuthorID = post.authorID else { return }

        let actionSheet = UIAlertController(title: "More", message: "", preferredStyle: .actionSheet)
        let blockUserAction = UIAlertAction(title: "Block User", style: .default) { [weak self] (block) in
            //Block User
            guard let strongSelf = self else { return }
            strongSelf.block(post)
        }
        
        let reportUserAction = UIAlertAction(title: "Report Post", style: .default) { [weak self]  (report) in
            // Report User
            guard let strongSelf = self else { return }
            strongSelf.showReportActionSheet(on: post)
        }
        
        let shareAction = UIAlertAction(title: "Share Post", style: .default) { [weak self] (share) in
            guard let strongSelf = self else { return }
            strongSelf.didTapShareButton(post: post, cell: cell)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete Post", style: .destructive) { [weak self] (remove) in
            guard let strongSelf = self else { return }
            print("Delete the selected Post")
            // Connect this with firebase and delete this post!
            let socialManager = ATCSocialNetworkFirebaseAPIManager()
            socialManager.deletePost(post: post, completion: {
                strongSelf.delegate?.postDeletedOnNewsFeed()
                strongSelf.delegate?.postDeletedOnProfilePage()
                strongSelf.delegate?.postDeletedOnDetailPage()
            })
        }
        
        actionSheet.addAction(blockUserAction)
        actionSheet.addAction(reportUserAction)
        actionSheet.addAction(shareAction)
        actionSheet.addAction(cancelAction)
        
        if postAuthorID == viewerUID {
            actionSheet.addAction(deleteAction)
        }
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = cell.contentView
            popoverController.sourceRect = CGRect(x: cell.contentView.frame.width - 16, y: 8, width: 0, height: 0)
         }

        navcontroller?.present(actionSheet, animated: true, completion: nil)
    }
    
    func didTapShareButton(post: ATCPost, cell: ATCPostCell) {
        print("Shared")
        let firstActivityItem = post.postText
        let items: [Any] = [firstActivityItem]
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: items, applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { (type, success, array, error) in
            if error == nil {
                
            }
        }
        
        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            .postToWeibo,
            .postToTencentWeibo,
            .print,
            .postToFlickr,
            .postToVimeo
        ]
        
        if let popoverController = activityViewController.popoverPresentationController {
           popoverController.sourceView = cell.contentView
           popoverController.sourceRect = CGRect(x: cell.contentView.frame.width - 16, y: 8, width: 0, height: 0)
        }
        
        navcontroller?.present(activityViewController, animated: true, completion: nil)
    }
}
