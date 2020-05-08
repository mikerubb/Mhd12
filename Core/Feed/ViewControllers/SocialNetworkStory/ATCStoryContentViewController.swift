//
//  ATCStoryContentViewController.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 17/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

protocol ATCNextUserStoryDelegate: class {
    func nextUserStory(at newUserIndex: Int)
}
class ATCStoryContentViewController: UIViewController {
    
    var storiesDataSource : [[ATCStory]] = []
    var currentIndex: Int = 0
    
    lazy var pageViewController: UIPageViewController = {
        let pVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pVC.view.backgroundColor = .black
        pVC.delegate = self
        pVC.dataSource = self
        return pVC
    }()
    
    var dismissButton : ATCDismissButton = {
        let button = ATCDismissButton()
        return button
    }()
    
    init(datasource: [[ATCStory]]) {
        self.storiesDataSource = datasource
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        let initialViewController: ATCStoryPreviewController = setupViewControllers(at: currentIndex)!
        let viewControllers = [initialViewController]
        
        pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true)
        pageViewController.view.frame = self.view.frame
        
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        view.addSubview(pageViewController.view)
        view.bringSubviewToFront(dismissButton)
        
        configureDismissButton()
    }
    
    func setupViewControllers(at index: Int) -> ATCStoryPreviewController? {
        if (storiesDataSource.count == 0 || index >= storiesDataSource.count ) {
            return nil
        }
        let vc = ATCStoryPreviewController()
        vc.friendStory = storiesDataSource[index]
        vc.delegate = self
        vc.pageIndex = index
        currentIndex = index
        
        vc.view.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
        return vc
    }
    
    func configureDismissButton() {
        view.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.addTarget(self, action: #selector(handleDismissButton), for: .touchUpInside)
        
        dismissButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 72).isActive = true
        dismissButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
    }
    
    
    // MARK: - Handler
    @objc func handleDismissButton() {
        dismiss(animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func navigateToNextUserStory(fowardTo index: Int) {
        if (index > (storiesDataSource.count - 1)) {
            dismiss(animated: true)
            return
        }
        let startingViewController: ATCStoryPreviewController = setupViewControllers(at: index)!
        let viewControllers = [startingViewController]
        pageViewController.setViewControllers(viewControllers , direction: .forward, animated: true, completion: nil)
    }
}

extension ATCStoryContentViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as! ATCStoryPreviewController).pageIndex
        if (index == 0) || (index >= storiesDataSource.count) {
            return nil
        }
        index -= 1
        return setupViewControllers(at: index)
    }
    
    //2
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! ATCStoryPreviewController).pageIndex
        if index == NSNotFound {
            return nil
        }
        index += 1
        if (index == storiesDataSource.count) {
            return nil
        }
        return setupViewControllers(at: index)
    }
}

extension ATCStoryContentViewController : ATCNextUserStoryDelegate {
    func nextUserStory(at newUserIndex: Int) {
        self.navigateToNextUserStory(fowardTo: newUserIndex)
    }
}


