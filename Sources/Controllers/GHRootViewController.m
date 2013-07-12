//
//  GHRootViewController.m
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-16-05.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import "GHRootViewController.h"

#import "GHContentViewController.h"

//==============================================================================
static NSUInteger const kThoughtsIndex = 2;
static NSTimeInterval const kIntervalToHideTabBar = 3.0;
//==============================================================================
@interface GHRootViewController () <UITabBarControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) UISwipeGestureRecognizer *swipeRightRecognizer;
@property (nonatomic) UISwipeGestureRecognizer *swipeLeftRecognizer;
@property (nonatomic) UITapGestureRecognizer *singleTapRecognizer;
@property (nonatomic) UITapGestureRecognizer *doubleTapRecognizer;
@property (nonatomic) NSTimer *barsTimer;
@property (nonatomic, getter = isBarsHidden) BOOL barsHidden;

@end
//==============================================================================
@implementation GHRootViewController
//------------------------------------------------------------------------------
- (void)awakeFromNib
{
    [super awakeFromNib];

    self.delegate = self;

    self.swipeRightRecognizer = [UISwipeGestureRecognizer.alloc initWithTarget:self action:@selector(onSwipeRight:)];
    self.swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    self.swipeRightRecognizer.delegate= self;
    self.swipeLeftRecognizer = [UISwipeGestureRecognizer.alloc initWithTarget:self action:@selector(onSwipeLeft:)];
    self.swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    self.swipeLeftRecognizer.delegate = self;

    self.singleTapRecognizer = [UITapGestureRecognizer.alloc initWithTarget:self action:@selector(onSingleTap:)];
    self.singleTapRecognizer.numberOfTapsRequired = 1;
    self.singleTapRecognizer.delegate = self;
    self.singleTapRecognizer.delaysTouchesBegan = YES;

    self.doubleTapRecognizer = [UITapGestureRecognizer.alloc initWithTarget:self action:@selector(onDoubleTap:)];
    self.doubleTapRecognizer.numberOfTapsRequired = 2;
    self.doubleTapRecognizer.delegate = self;
    self.doubleTapRecognizer.delaysTouchesBegan = YES;

    [self.singleTapRecognizer requireGestureRecognizerToFail:self.doubleTapRecognizer];
}
//------------------------------------------------------------------------------
- (void)dealloc
{
    [self.barsTimer invalidate];
}
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

    ((UIView *)self.view.subviews[0]).frame = UIScreen.mainScreen.bounds;

    self.view.backgroundColor = [UIColor.alloc initWithPatternImage:[UIImage imageNamed:@"background"]];

    self.selectedIndex = kThoughtsIndex;
    [self.view addGestureRecognizer:self.swipeRightRecognizer];
    [self.view addGestureRecognizer:self.swipeLeftRecognizer];
    [self.view addGestureRecognizer:self.singleTapRecognizer];
    [self.view addGestureRecognizer:self.doubleTapRecognizer];

    self.barsHidden = NO;
}
//------------------------------------------------------------------------------
- (void)viewDidUnload
{
    [super viewDidUnload];

    [self.view removeGestureRecognizer:self.swipeRightRecognizer];
    [self.view removeGestureRecognizer:self.swipeLeftRecognizer];
    [self.view removeGestureRecognizer:self.singleTapRecognizer];
    [self.view removeGestureRecognizer:self.doubleTapRecognizer];
}
//------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self autoHideBars];
}
//------------------------------------------------------------------------------
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    [self swipeToIndex:[self.viewControllers indexOfObject:viewController]];

    return YES;
}
//------------------------------------------------------------------------------
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    [self autoHideBars];
}
//------------------------------------------------------------------------------
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer isKindOfClass:UITapGestureRecognizer.class] && 1 == ((UITapGestureRecognizer *)otherGestureRecognizer).numberOfTapsRequired)
        [otherGestureRecognizer.view removeGestureRecognizer:otherGestureRecognizer];

    if ([otherGestureRecognizer isKindOfClass:UISwipeGestureRecognizer.class])
        return NO;

    return YES;
}
//------------------------------------------------------------------------------
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view.superview isKindOfClass:UITabBar.class])
        return NO;

    return YES;
}
//------------------------------------------------------------------------------
- (void)onSwipeRight:(UIGestureRecognizer *)gestureRecognizer
{
    NSUInteger index = self.selectedIndex - 1;
    
    if (index < self.viewControllers.count - 1)
        [self swipeToIndex:index];
}
//------------------------------------------------------------------------------
- (void)onSwipeLeft:(UIGestureRecognizer *)gestureRecognizer
{
    NSUInteger index = self.selectedIndex + 1;

    if (index < self.viewControllers.count)
        [self swipeToIndex:index];
}
//------------------------------------------------------------------------------
- (void)onSingleTap:(UIGestureRecognizer *)gestureRecognizer
{
    self.barsHidden = !self.barsHidden;
    [self autoHideBars];
}
//------------------------------------------------------------------------------
- (void)onDoubleTap:(UIGestureRecognizer *)gestureRecognizer
{
    if ([self.selectedViewController isKindOfClass:UINavigationController.class] &&
        [((UINavigationController *)self.selectedViewController).topViewController isKindOfClass:GHContentViewController.class])
        [(GHContentViewController *)((UINavigationController *)self.selectedViewController).topViewController bookmarkContentAtPoint:[gestureRecognizer locationInView:gestureRecognizer.view]];
}
//------------------------------------------------------------------------------
- (void)setBarsHidden:(BOOL)hidden
{
    _barsHidden = hidden;
    [self.barsTimer invalidate];

    [UIApplication.sharedApplication setStatusBarHidden:_barsHidden withAnimation:UIStatusBarAnimationFade];

    @weakify(self)

    [UIView animateWithDuration:_barsHidden ? UINavigationControllerHideShowBarDuration : 0.0 animations:
    ^{
        @strongify(self)

        if ([self.selectedViewController isKindOfClass:UINavigationController.class])
        {
            CGRect frame = ((UINavigationController *)self.selectedViewController).navigationBar.frame;

            frame.origin.y = _barsHidden ? 0.0 : UIApplication.statusBarHeight;
            ((UINavigationController *)self.selectedViewController).navigationBar.frame = frame;
        }
    }];

    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:
    ^{
        @strongify(self)

        for (UIViewController *controller in self.viewControllers)
            if ([controller isKindOfClass:UINavigationController.class])
                ((UINavigationController *)controller).navigationBar.alpha = _barsHidden ? 0.0 : kUINavigationBarTranslucentAlphaDefault;

        self.tabBar.alpha = _barsHidden ? 0.0 : kUINavigationBarTranslucentAlphaDefault;

        if (_barsHidden)
            [self.selectedViewController.view setNeedsLayout];
    }
    completion:^(BOOL finished)
    {
        if (_barsHidden)
            [self.selectedViewController.view setNeedsLayout];
    }];
}
//------------------------------------------------------------------------------
- (void)autoHideBars
{
    [self.barsTimer invalidate];

    if (!self.barsHidden)
        self.barsTimer = [NSTimer scheduledTimerWithTimeInterval:kIntervalToHideTabBar target:self selector:@selector(hideBars) userInfo:nil repeats:NO];
}
//------------------------------------------------------------------------------
- (void)hideBars
{
    if (!self.isBarsHidden)
        self.barsHidden = YES;
}
//------------------------------------------------------------------------------
@end
//==============================================================================