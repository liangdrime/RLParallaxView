//
//  RLParallaxView.h
//  RLParallaxView
//
//  Created by roylee on 2017/11/3.
//  Copyright © 2017年 Roylee-ML. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RLParallaxView : UIView

/// An image view at the background.
@property (nonatomic, readonly) UIImageView *backgroundImageView;

/// A content view for add subviews, if you need a background translucent effect, the view
/// new created must be added to the `contentView`.
@property (nonatomic, readonly) UIView *contentView;

/// A weak refrence of a scroll view, if need parallax effect the `scrollView` must not be nil.
@property (nonatomic, weak) UIScrollView *scrollView;

/// Set the background image of background image view.
@property (nonatomic, strong) UIImage *backgroundImage;

/// Minumheight that limit the height of the background view.
/// Note, the parallax effect is used the method that change height of the background image view.
@property (nonatomic, assign) CGFloat backgroundMinumHeight;

/// Default is NO, if Yes, the background image will always show through the content view,
/// that means all the content in `contentView` will be hollow out, and the background image will
/// be see at the same time.
@property (nonatomic, assign) BOOL backgroundTranslucent;

/// A height which indicate the rectangular area to be translucented, and the width is equal to
/// the view, default height is 0.
@property (nonatomic, assign) CGFloat translucentHeight;

/// A property indicate whether the background image should parallax when move up, default is Yes.
@property (nonatomic, assign) BOOL parallaxEnabled;

/// The background image will be blur when move up if Yes, default is NO.
@property (nonatomic, assign) BOOL blurBackgroundImageEnabled;

/// If NO, the contentInsets of scroll view changed, the original top insets will be changed.
/// Default is NO.
@property (nonatomic, assign) BOOL ignoreContentInsetChanged;

/// If YES, the contentInsets of scroll view will be ignored, the top always from zero point.
/// Default is NO.
@property (nonatomic, assign) BOOL ignoreContentInset;

/// Overide by subclass.
- (void)parallaxHeaderView:(RLParallaxView *)hederView scrollViewDidScroll:(UIScrollView *)scrollView;

/// Set the background image, like property `backgroundImage`. If animted is YES,
/// will add a fade animation during set the image.
- (void)setBackgroundImage:(UIImage *)backgroundImage animated:(BOOL)animated;

@end
