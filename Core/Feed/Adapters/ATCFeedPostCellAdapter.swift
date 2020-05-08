//
//  ATCFeedPostCellAdapter.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 07/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

protocol ATCFeedPostCellAdapterDelegate: class {
    func didTapComment(_ userAdapter: ATCFeedPostCellAdapter, on post: ATCPost)
    func showCommentTextView(_ userAdapter: ATCFeedPostCellAdapter, on post: ATCPost)
    func profileImageDidTap(_ userAdapter: ATCFeedPostCellAdapter, on post: ATCPost)
    func updateReaction(_ userAdapter: ATCFeedPostCellAdapter, on post: ATCPost, reaction: String)
    func moreButtonDidTap(_ userAdapter: ATCFeedPostCellAdapter, cell: ATCPostCell,  on post: ATCPost)
    func imageDidTap(_ userAdapter: ATCFeedPostCellAdapter, on post: ATCPost, at indexPath: IndexPath)
}

class ATCFeedPostCellAdapter: ATCGenericCollectionRowAdapter {
    let uiConfig: ATCUIGenericConfigurationProtocol
    var textViewSize = CGSize(width: 0, height: 0)
    var delegate: ATCFeedPostCellAdapterDelegate?
    
    init(uiConfig: ATCUIGenericConfigurationProtocol) {
        self.uiConfig = uiConfig
    }
    
    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        if let post = object as? ATCPost, let cell = cell as? ATCPostCell {
            let profileImageURL = post.profileImage
            
            cell.profileImage.kf.setImage(with: URL(string: profileImageURL))
            
            if post.postMedia.isEmpty {
                cell.heightConstraint?.constant = 1
            }else {
                cell.heightConstraint?.constant = 200        
            }
      
            cell.profileImage.layer.cornerRadius = 60 / 2
            cell.profileImage.layer.masksToBounds = true

            cell.userName.text = post.postUserName
            
            //Formatting Date
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "d MMM yyyy HH:mm"
            if let date = post.createdAt {
                let stringDate = TimeFormatHelper.timeAgoString(date: date)
                cell.createdAtDate.text = stringDate
            }
            
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 2
            let atributes : [NSAttributedString.Key : Any] = [NSAttributedString.Key.paragraphStyle: style,
                                                              NSAttributedString.Key.backgroundColor: uiConfig.mainThemeBackgroundColor,
                                                              NSAttributedString.Key.foregroundColor: uiConfig.mainTextColor,
                                                              NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]
            cell.postText.attributedText = NSAttributedString(string: post.postText, attributes: atributes)
            cell.postText.backgroundColor = uiConfig.mainThemeBackgroundColor

            let parentVC = ATCImageCarouselViewController(uiConfig: uiConfig)

            let layout = ATCCollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            let imagesVCConfig = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
                                                                                 pullToRefreshTintColor: uiConfig.mainThemeBackgroundColor,
                                                                                 collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
                                                                                 collectionViewLayout: layout,
                                                                                 collectionPagingEnabled: true,
                                                                                 hideScrollIndicators: true,
                                                                                 hidesNavigationBar: true,
                                                                                 headerNibName: nil,
                                                                                 scrollEnabled: true,
                                                                                 uiConfig: uiConfig,
                                                                                 emptyViewModel: nil)
            
            let imagesVC = ATCGenericCollectionViewController(configuration: imagesVCConfig)
            imagesVC.selectionBlock =  {[weak self] (navigationController, object, indexPath) in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.imageDidTap(strongSelf, on: post, at: indexPath)
            }

            // Data source of the collection view cell within each post cell
            var imagesURL = [String]()
            imagesURL = post.postMedia

            let images = imagesURL.map { ATCImage($0) }
            imagesVC.genericDataSource = ATCGenericLocalHeteroDataSource(items: images)
            imagesVC.use(adapter: ATCImageRowAdapter(), for: "ATCImage")

            var items: [ATCGenericBaseModel] = []
            let carousel: ATCCarouselViewModel!
            if images.count > 1 {
                carousel = ATCCarouselViewModel(title: nil,
                                                    viewController: imagesVC,
                                                    cellHeight: 200,
                                                    pageControlEnabled: true)
            } else {
                carousel = ATCCarouselViewModel(title: nil,
                                                viewController: imagesVC,
                                                cellHeight: 200,
                                                pageControlEnabled: false)
            }
            items.append(carousel)
            parentVC.use(adapter: ATCViewControllerContainerRowAdapter(), for: "ATCViewControllerContainerViewModel")
            parentVC.genericDataSource = ATCGenericLocalHeteroDataSource(items: items)
            cell.imageCarouselCV = parentVC
            
            let commentsCount = post.postComment
            let likesCount = post.postLikes
            cell.likesCountLabel.text = likesCount > 0 ? "\(likesCount)" : nil
            cell.likesCountLabel.textColor = uiConfig.mainTextColor
            cell.commentsCountLabel.text = commentsCount > 0 ? "\(commentsCount)" : nil

            let reaction = post.selectedReaction
            if let reaction = reaction {
                print(reaction)
                cell.showReactions(reaction: reaction)
            }

            cell.locationLabel.text = post.location ?? ""
            cell.reactionsContainerView.backgroundColor = uiConfig.mainThemeBackgroundColor
            cell.likeButton.backgroundColor = uiConfig.mainThemeBackgroundColor
            cell.likeButton.tintColor = UIColor.darkModeColor(hexString: "#000000")
            cell.commentButton.backgroundColor = uiConfig.mainThemeBackgroundColor
            cell.commentButton.tintColor = UIColor.darkModeColor(hexString: "#000000")

            cell.delegate = self
            cell.post = post
            cell.backgroundColor = uiConfig.mainThemeBackgroundColor
            cell.setNeedsLayout()
        }
    }

    func cellClass() -> UICollectionViewCell.Type {
        return ATCPostCell.self
    }
    
    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        guard let viewModel = object as? ATCPost else { return .zero }

        var knownHeight : CGFloat = 0
        let width = containerBounds.width - 40

        if viewModel.postMedia.isEmpty {
            knownHeight =  122 + 28//60 + 40 + 30 + 45
        } else if (viewModel.postText.isEmpty) && !(viewModel.postMedia.isEmpty) {
            knownHeight = 200 + 120
        } else {
            knownHeight = 322 + 28
           // knownHeight = 200 + 110 + 60
        }

        let text = viewModel.postText
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 2
        
        let rect = NSString(string: text).boundingRect(with: CGSize(width: width, height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.paragraphStyle: style], context: nil)
        let cellHeight = rect.height + knownHeight
        return CGSize(width: containerBounds.width - 16, height: cellHeight)
    }
    
}

extension ATCFeedPostCellAdapter : ATCPostCellDelegate {
    
    func commentButtonDidTap(on cell: ATCPostCell, on post: ATCPost) {
        delegate?.didTapComment(self, on: post)
        delegate?.showCommentTextView(self, on: post)
    }
    
    func profileImageDidTap(on cell: ATCPostCell, on post: ATCPost) {
        delegate?.profileImageDidTap(self, on: post)
    }
    
    func updateReaction(on post: ATCPost, reaction: String) {
        delegate?.updateReaction(self, on: post, reaction: reaction)
    }
    
    func moreButtonDidTap(on cell: ATCPostCell, on post: ATCPost) {
        delegate?.moreButtonDidTap(self, cell: cell, on: post)
    }
}
