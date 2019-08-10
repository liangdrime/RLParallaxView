//
//  RLParallaxView.m
//  RLParallaxView
//
//  Created by roylee on 2017/11/3.
//  Copyright © 2017年 Roylee-ML. All rights reserved.
//

#import "RLParallaxView.h"
#import "RLBlurView.h"
#import <objc/runtime.h>

static void * kContentOffsetContext = &kContentOffsetContext;
static void * kContentInsetContext  = &kContentInsetContext;

@interface RLParallaxViewObserver : NSObject

@property (nonatomic, unsafe_unretained) id unsafeTarget;
@property (nonatomic, copy) void (^observeBlock)(NSString *path, id object, NSDictionary<NSString *,id> *change, void *context);

@end

@implementation RLParallaxViewObserver

- (void)dealloc {
    NSObject *target = nil;
    @synchronized (self) {
        _observeBlock = nil;
        
        // The target should still exist at this point, because we still need to
        // tear down its KVO observation. Therefore, we can use the unsafe
        // reference (and need to, because the weak one will have been zeroed by
        // now).
        target = self.unsafeTarget;
        
        _unsafeTarget = nil;
    }
    
    [target removeObserver:self forKeyPath:@"contentInset"];
    [target removeObserver:self forKeyPath:@"contentOffset"];
}

- (instancetype)initWithScrollView:(UIScrollView *)scrollView {
    self = [super init];
    if (self) {
        _unsafeTarget = scrollView;
        [self addObservers];
    }
    return self;
}

- (void)addObservers {
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [_unsafeTarget addObserver:self forKeyPath:@"contentInset" options:options context:kContentInsetContext];
    [_unsafeTarget addObserver:self forKeyPath:@"contentOffset" options:options context:kContentOffsetContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (_observeBlock) {
        _observeBlock(keyPath, object, change, context);
    }
}
@end




static void * RLParallaxViewObserverKey  = &RLParallaxViewObserverKey;
@interface RLParallaxView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) RLBlurView *blurView;
@property (nonatomic, assign) CGFloat originContentInsetTop;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, assign) CGFloat lastOffsetY;

@end

@implementation RLParallaxView

- (instancetype)initWithFrame:(CGRect)frame {
    NSAssert(frame.size.width > 0, @"The size of frame should not be zero.");
    self = [super initWithFrame:frame];
    if (self) {
        [self _commonInit];
        [self _setupViews];
    }
    return self;
}

- (void)_commonInit {
    _parallaxEnabled = YES;
    _backgroundTranslucent = NO;
    _backgroundMinumHeight = 0;
    _blurBackgroundImageEnabled = NO;
}

- (void)_setupViews {
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _backgroundImageView.backgroundColor = [UIColor clearColor];
    _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    _backgroundImageView.layer.masksToBounds = YES;
    
    self.contentView = [[UIView alloc] initWithFrame:self.bounds];
    _contentView.backgroundColor = self.backgroundColor;
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self addSubview:_backgroundImageView];
    [self addSubview:_contentView];
}

- (void)setScrollView:(UIScrollView *)scrollView {
    if (_scrollView == scrollView) {
        return;
    }
    
    // Delete old `RLParallaxViewObserver` to remove the observer.
    objc_setAssociatedObject(_scrollView, RLParallaxViewObserverKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    _scrollView = scrollView;
    _originContentInsetTop = scrollView.contentInset.top;
    
    // Create observer.
    RLParallaxViewObserver *observer = [[RLParallaxViewObserver alloc] initWithScrollView:scrollView];
    observer.observeBlock = ^(NSString *path, id object, NSDictionary<NSString *,id> *change, void *context) {
        [self observeValueForKeyPath:path ofObject:object change:change context:context];
    };
    
    // Add new observer to the scrollview.
    objc_setAssociatedObject(_scrollView, RLParallaxViewObserverKey, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    _backgroundImageView.image = backgroundImage;
}

- (void)setBackgroundTranslucent:(BOOL)backgroundTranslucent {
    if (backgroundTranslucent) {
        if (!_maskLayer) {
            self.maskLayer = [CAShapeLayer new];
            _maskLayer.frame = _contentView.bounds;
            _maskLayer.backgroundColor = [UIColor whiteColor].CGColor;
            _maskLayer.fillRule = kCAFillRuleEvenOdd;
            
            _contentView.layer.mask = _maskLayer;
        }
    }else {
        _contentView.layer.mask = nil;
        self.maskLayer = nil;
    }
    _backgroundTranslucent = backgroundTranslucent;
}

- (void)setBlurBackgroundImageEnabled:(BOOL)blurBackgroundImageEnabled {
    if (blurBackgroundImageEnabled) {
        if (!_blurView) {
            _blurView = [[RLBlurView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
            _blurView.frame = self.backgroundImageView.bounds;
            _blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _blurView.backgroundColor = [UIColor clearColor];
            [self.backgroundImageView addSubview:_blurView];
        }
    }else {
        [_blurView removeFromSuperview];
        [self setBlurView:nil];
    }
    _blurBackgroundImageEnabled = blurBackgroundImageEnabled;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage animated:(BOOL)animated {
    self.backgroundImage = backgroundImage;
    
    if (animated) {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.45f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        [self.backgroundImageView.layer addAnimation:transition forKey:@"back_image_fade"];
    }
}

- (void)parallaxHeaderView:(RLParallaxView *)hederView scrollViewDidScroll:(UIScrollView *)scrollView {}

#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == kContentInsetContext) {
        
        if (!_ignoreContentInsetChanged && !_ignoreContentInset) {
            UIEdgeInsets inset = [change[NSKeyValueChangeNewKey] UIEdgeInsetsValue];
            _originContentInsetTop = inset.top;
        }
        
    }else if (context == kContentOffsetContext) {
    
        CGFloat originContentInsetTop = _ignoreContentInset ? 0 : _originContentInsetTop;
        CGPoint newOffset = [change[NSKeyValueChangeNewKey] CGPointValue];
        newOffset.y = newOffset.y + originContentInsetTop;
        CGFloat originBgImageVHeight = CGRectGetHeight(self.frame);
        CGFloat distance = originBgImageVHeight - _backgroundMinumHeight;
        
        // Scale and parallax
        if (newOffset.y >= distance) {
            if (_parallaxEnabled) {
                self.backgroundImageView.frame = ({
                    CGRect frame = self.backgroundImageView.frame;
                    frame.size.height = _backgroundMinumHeight;
                    frame.origin.y = originBgImageVHeight - CGRectGetHeight(frame); // bottom
                    frame;
                });
            }else {
                self.backgroundImageView.frame = self.bounds;
            }
        }
        else {
            self.backgroundImageView.frame = ({
                CGRect frame = self.backgroundImageView.frame;
                frame.size.height = originBgImageVHeight - newOffset.y;
                frame.origin.y = originBgImageVHeight - CGRectGetHeight(frame); // bottom
                frame;
            });
        }
        
        // Background translucent
        if (_backgroundTranslucent) {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            CGRect frame = _maskLayer.frame;
            frame.size.height = CGRectGetHeight(_contentView.frame) - (newOffset.y + _translucentHeight);
            frame.origin.y = CGRectGetHeight(_contentView.frame) - CGRectGetHeight(frame);
            _maskLayer.frame = frame;
            [CATransaction commit];
        }
        
        // Blur backgorundimage
        [self blurBackgroundImageWithOffset:newOffset.y];
        
        // Call subclass method.
        [self parallaxHeaderView:self scrollViewDidScroll:_scrollView];
    }
}

- (void)blurBackgroundImageWithOffset:(CGFloat)offset {
    if (!_blurBackgroundImageEnabled) {
        return;
    }
    CGFloat distance = CGRectGetHeight(self.frame) - _backgroundMinumHeight;
    CGFloat blurRadius = 20;
    
    if (offset > distance) {
        if (![objc_getAssociatedObject(self.backgroundImageView, "set_blure_max") boolValue]) {
            self.blurView.blurRadius = blurRadius;
            objc_setAssociatedObject(self.backgroundImageView, "set_blure_max", @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    else if (offset < 0) {
        if (![objc_getAssociatedObject(self.backgroundImageView, "set_blure_min") boolValue]) {
            self.blurView.blurRadius = 0;
            objc_setAssociatedObject(self.backgroundImageView, "set_blure_min", @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    else {
        self.blurView.blurRadius = blurRadius *offset / distance;
        objc_setAssociatedObject(self.backgroundImageView, "set_blure_min", @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self.backgroundImageView, "set_blure_max", @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

/*
- (void)blurBackgroundImageWithOffset:(CGFloat)offset {
    if (!_blurBackgroundImageEnabled) {
        return;
    }
    CGFloat distance = self.height - _backgroundMinumHeight;
    CGFloat blurInterval = 2, blurRadius = 20;
    
    if (offset >= distance) {
        if (![objc_getAssociatedObject(self.backgroundImageView, "set_blure_max") boolValue]) {
            objc_setAssociatedObject(self.backgroundImageView, "set_blure_max", @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            [self asyncBlurBackgroundImageWithRadius:blurRadius resetBackgroundImage:^BOOL{
                CGFloat newOffsetY = self.scrollView.contentOffset.y + _originContentInsetTop;
                return newOffsetY >= distance;
            }];
        }
    }
    else if (offset <= 0) {
        self.backgroundImageView.image = _backgroundImage;
        objc_setAssociatedObject(self.backgroundImageView, "set_blure_max", @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    else {
        if (offset > _lastOffsetY + blurInterval) {
            _lastOffsetY = offset + blurInterval;
            
            [self asyncBlurBackgroundImageWithRadius:blurRadius *offset/distance resetBackgroundImage:^BOOL{
                CGFloat newOffsetY = self.scrollView.contentOffset.y + _originContentInsetTop;
                return newOffsetY > 0 && newOffsetY < distance;
            }];
        }else if (offset < _lastOffsetY - blurInterval) {
            _lastOffsetY = offset - blurInterval;
            
            [self asyncBlurBackgroundImageWithRadius:blurRadius *offset/distance resetBackgroundImage:^BOOL{
                CGFloat newOffsetY = self.scrollView.contentOffset.y + _originContentInsetTop;
                return newOffsetY > 0 && newOffsetY < distance;
            }];
        }
        objc_setAssociatedObject(self.backgroundImageView, "set_blure_max", @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)asyncBlurBackgroundImageWithRadius:(CGFloat)radius resetBackgroundImage:(BOOL(^)())completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *backgroundImage = [self.backgroundImage applyBlurWithRadius:radius tintColor:nil saturationDeltaFactor:1 maskImage:nil];
        if ((completion && completion()) || !completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.backgroundImageView.image = backgroundImage;
            });
        }
    });
}
 */

@end

