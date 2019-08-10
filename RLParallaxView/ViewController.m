//
//  ViewController.m
//  RLParallaxView
//
//  Created by roylee on 2019/8/10.
//  Copyright © 2019 roylee. All rights reserved.
//

#import "ViewController.h"
#import "RLParallaxView.h"

@interface ViewController ()

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) RLParallaxView *headerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupViews];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    if (@available(iOS 11, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)setupViews {
    // Scroll view.
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height * 2);
    [self.view addSubview:_scrollView];
    
    // Parallax header view.
    _headerView = [[RLParallaxView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
    _headerView.backgroundColor = [UIColor lightGrayColor];
    _headerView.backgroundMinumHeight = _headerView.frame.size.height;
    _headerView.ignoreContentInset = YES;
    _headerView.backgroundImage = [UIImage imageNamed:@"header.jpeg"];
    _headerView.scrollView = _scrollView;
    _headerView.blurBackgroundImageEnabled = YES;
    _headerView.translucentHeight = 64;
    _headerView.backgroundTranslucent = YES;
    [self.scrollView addSubview:_headerView];
    
    // Content view.
    [self setupContentView];
}

- (void)setupContentView {
    UIView *avatarView = [UIView new];
    avatarView.frame = CGRectMake(15, 64 + 10, 100, 100);
    avatarView.backgroundColor = [UIColor lightGrayColor];
    
    UILabel *titleLabel = [UILabel new];
    CGRect frame = CGRectMake(CGRectGetMaxX(avatarView.frame) + 15, CGRectGetMinY(avatarView.frame) + 8, 0, 80);
    frame.size.width = self.view.bounds.size.width - 15 - frame.origin.x;
    titleLabel.frame = frame;
    titleLabel.text = @"《航海王》是日本漫画家尾田荣一郎作画的少年漫画作品，在《周刊少年Jump》1997年第34号开始连载，电子版由漫番漫画连载";
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.numberOfLines = 3;
    titleLabel.textColor = [UIColor grayColor];
    
    // Must add subviews to the `contentView`.
    [_headerView.contentView addSubview:avatarView];
    [_headerView.contentView addSubview:titleLabel];
}

@end
