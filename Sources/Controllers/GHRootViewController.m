//
//  GHRootViewController.m
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-16-05.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import "GHRootViewController.h"

#import "GHPostViewController.h"
#import "GHVocabularyViewController.h"
#import "GHVocabularyDefinitionViewController.h"

//==============================================================================
static NSUInteger const kThoughtsIndex = 2;
static NSTimeInterval const kIntervalToHideTabBar = 3.0;
//==============================================================================
@interface GHRootViewController () <UITabBarControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) UISwipeGestureRecognizer *swipeRightRecognizer;
@property (nonatomic) UISwipeGestureRecognizer *swipeLeftRecognizer;
@property (nonatomic) UITapGestureRecognizer *singleTapRecognizer;
@property (nonatomic) UITapGestureRecognizer *doubleTapRecognizer;
@property (nonatomic) UILongPressGestureRecognizer *longPressRecognizer;
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
    self.singleTapRecognizer.delaysTouchesBegan = YES;
    self.singleTapRecognizer.delaysTouchesEnded = YES;
    self.singleTapRecognizer.delegate = self;

    self.doubleTapRecognizer = [UITapGestureRecognizer.alloc initWithTarget:self action:@selector(onDoubleTap:)];
    self.doubleTapRecognizer.numberOfTapsRequired = 2;
    self.doubleTapRecognizer.delaysTouchesEnded = YES;
    self.doubleTapRecognizer.delegate = self;

    [self.singleTapRecognizer requireGestureRecognizerToFail:self.doubleTapRecognizer];

    self.longPressRecognizer = [UILongPressGestureRecognizer.alloc initWithTarget:self action:@selector(onLongPress:)];
    self.longPressRecognizer.delegate = self;

    [self.longPressRecognizer requireGestureRecognizerToFail:self.singleTapRecognizer];
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
    [self.view addGestureRecognizer:self.longPressRecognizer];

    self.barsHidden = NO;
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
    if ([gestureRecognizer isKindOfClass:UISwipeGestureRecognizer.class] &&
        [otherGestureRecognizer isKindOfClass:UISwipeGestureRecognizer.class])
        return NO;

    if ([gestureRecognizer isKindOfClass:UITapGestureRecognizer.class] &&
        [otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")])
        return NO;

    return YES;
}
//------------------------------------------------------------------------------
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view superviewOfClass:UITabBar.class] ||
        [touch.view superviewOfClass:UINavigationBar.class] ||
        [touch.view isKindOfClass:UINavigationBar.class])
        return NO;

    if ([gestureRecognizer isKindOfClass:UITapGestureRecognizer.class] &&
        [touch.view.viewController isKindOfClass:GHVocabularyViewController.class] &&
        [touch.view isKindOfClass:NSClassFromString(@"UITableViewCellContentView")])
        return NO;

    if ([gestureRecognizer isKindOfClass:UITapGestureRecognizer.class] &&
        UIMenuController.sharedMenuController.menuVisible)
    {
        [UIMenuController.sharedMenuController setMenuVisible:NO animated:YES];

        return NO;
    }

    return YES;
}
//------------------------------------------------------------------------------
- (void)onSwipeRight:(UIGestureRecognizer *)gestureRecognizer
{
    NSUInteger index = self.selectedIndex - 1;
    
    if (index < self.viewControllers.count - 1)
        [self swipeToIndex:index];
    else
        if ([self.selectedViewController isKindOfClass:UINavigationController.class] &&
            [((UINavigationController *)self.selectedViewController).topViewController isKindOfClass:GHVocabularyDefinitionViewController.class])
            [(UINavigationController *)self.selectedViewController popViewControllerAnimated:YES];
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
        [((UINavigationController *)self.selectedViewController).topViewController isKindOfClass:GHPostViewController.class])
        [(GHPostViewController *)((UINavigationController *)self.selectedViewController).topViewController bookmarkContentAtPoint:[gestureRecognizer locationInView:gestureRecognizer.view]];
}
//------------------------------------------------------------------------------
- (void)onLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (UIGestureRecognizerStateBegan != gestureRecognizer.state)
        return;

    if ([self.selectedViewController isKindOfClass:UINavigationController.class] &&
        [((UINavigationController *)self.selectedViewController).topViewController isKindOfClass:GHPostViewController.class])
        [(GHPostViewController *)((UINavigationController *)self.selectedViewController).topViewController showMenuAtPoint:[gestureRecognizer locationInView:gestureRecognizer.view]];
}
//------------------------------------------------------------------------------
- (void)setBarsHidden:(BOOL)hidden
{
    if (hidden && ![[NSUserDefaults.standardUserDefaults valueForKey:kGHOptionAutoHidePanels] boolValue])
        return;

    _barsHidden = hidden;
    [self.barsTimer invalidate];

    [self setTabBarHidden:_barsHidden animated:YES];

    [UIApplication.sharedApplication setStatusBarHidden:_barsHidden withAnimation:UIStatusBarAnimationFade];

    for (UIViewController *controller in self.viewControllers)
        if ([controller isKindOfClass:UINavigationController.class])
            [((UINavigationController *)controller) setNavigationBarHidden:_barsHidden animated:YES];
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