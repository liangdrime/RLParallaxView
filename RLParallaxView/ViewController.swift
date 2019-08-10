//
//  ViewController.swift
//  RLParallaxView
//
//  Created by roylee on 2019/8/10.
//  Copyright © 2019 roylee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private lazy var headerView = {
        return RLParallaxView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 300))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        // Disable scroll view auto adjust inset.
        edgesForExtendedLayout = []
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    private func setupViews() {
        // Config scrollview.
        scrollView.frame = view.bounds
        scrollView.contentSize = CGSize(width: view.bounds.width, height: view.bounds.height * 2)
        view.addSubview(scrollView)
        
        // Parallax header view.
        headerView.backgroundColor = UIColor.lightGray
        headerView.backgroundMinumHeight = headerView.frame.height
        headerView.ignoreContentInset = true
        headerView.backgroundImage = UIImage(named: "header.jpeg")
        headerView.scrollView = scrollView
        headerView.blurBackgroundImageEnabled = true
        headerView.translucentHeight = 64
        headerView.backgroundTranslucent = true
        scrollView.addSubview(headerView)
        
        // Content view.
        setupContent()
    }
    
    private func setupContent() {
        let avatarView = UIView()
        avatarView.frame = CGRect(x: 15, y: 64 + 10, width: 100, height: 100)
        avatarView.backgroundColor = UIColor.lightGray
        
        let titleLabel = UILabel()
        var frame = CGRect(x: avatarView.frame.minX + 15, y: avatarView.frame.minY + 8, width: 0, height: 80)
        frame.size.width = view.bounds.width - 15 - frame.minX
        titleLabel.frame = frame
        titleLabel.text = "《航海王》是日本漫画家尾田荣一郎作画的少年漫画作品，在《周刊少年Jump》1997年第34号开始连载，电子版由漫番漫画连载"
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        titleLabel.numberOfLines = 3
        titleLabel.textColor = UIColor.gray
        
        // Must add subviews to the `contentView`.
        headerView.contentView.addSubview(avatarView)
        headerView.contentView.addSubview(titleLabel)
    }
}
