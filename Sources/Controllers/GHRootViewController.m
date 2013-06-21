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
@property (nonatomic) NSTimer *tabBarTimer;

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
    self.swipeLeftRecognizer = [UISwipeGestureRecognizer.alloc initWithTarget:self action:@selector(onSwipeLeft:)];
    self.swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;

    self.singleTapRecognizer = [UITapGestureRecognizer.alloc initWithTarget:self action:@selector(onSingleTap:)];
    self.singleTapRecognizer.numberOfTapsRequired = 1;
    self.singleTapRecognizer.delegate = self;
    self.singleTapRecognizer.delaysTouchesBegan = YES;

    self.doubleTapRecognizer = [UITapGestureRecognizer.alloc initWithTarget:self action:@selector(onDoubleTap:)];
    self.doubleTapRecognizer.numberOfTapsRequired = 2;
    self.doubleTapRecognizer.delegate = self;

    [self.singleTapRecognizer requireGestureRecognizerToFail:self.doubleTapRecognizer];
}
//------------------------------------------------------------------------------
- (void)dealloc
{
    [self.tabBarTimer invalidate];
}
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor.alloc initWithPatternImage:[UIImage imageNamed:@"background"]];

    self.selectedIndex = kThoughtsIndex;
    [self.view addGestureRecognizer:self.swipeRightRecognizer];
    [self.view addGestureRecognizer:self.swipeLeftRecognizer];
    [self.view addGestureRecognizer:self.singleTapRecognizer];
    [self.view addGestureRecognizer:self.doubleTapRecognizer];
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

    [self autoHideTabBar];
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
    [self autoHideTabBar];
}
//------------------------------------------------------------------------------
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer isKindOfClass:UITapGestureRecognizer.class] && 1 == ((UITapGestureRecognizer *)otherGestureRecognizer).numberOfTapsRequired)
        [otherGestureRecognizer.view removeGestureRecognizer:otherGestureRecognizer];

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
    for (UIViewController *controller in self.viewControllers)
        if ([controller isKindOfClass:UINavigationController.class])
            [((UINavigationController *)controller) setNavigationBarHidden:!((UINavigationController *)controller).isNavigationBarHidden animated:YES];

    [self setTabBarHidden:!self.isTabBarHidden animated:YES];
    [self autoHideTabBar];
}
//------------------------------------------------------------------------------
- (void)onDoubleTap:(UIGestureRecognizer *)gestureRecognizer
{
    if ([self.selectedViewController isKindOfClass:UINavigationController.class] &&
        [((UINavigationController *)self.selectedViewController).topViewController isKindOfClass:GHContentViewController.class])
        [(GHContentViewController *)((UINavigationController *)self.selectedViewController).topViewController bookmarkContentAtPoint:[gestureRecognizer locationInView:gestureRecognizer.view]];
}
//------------------------------------------------------------------------------
- (void)autoHideTabBar
{
    [self.tabBarTimer invalidate];

    if (!self.isTabBarHidden)
        self.tabBarTimer = [NSTimer scheduledTimerWithTimeInterval:kIntervalToHideTabBar target:self selector:@selector(hideTabBar) userInfo:nil repeats:NO];
}
//------------------------------------------------------------------------------
- (void)hideTabBar
{
    [self.tabBarTimer invalidate];

    if (!self.isTabBarHidden)
    {
        for (UIViewController *controller in self.viewControllers)
            if ([controller isKindOfClass:UINavigationController.class])
                [((UINavigationController *)controller) setNavigationBarHidden:YES animated:YES];
        
        [self setTabBarHidden:YES animated:YES];
    }
}
//------------------------------------------------------------------------------
@end
//==============================================================================