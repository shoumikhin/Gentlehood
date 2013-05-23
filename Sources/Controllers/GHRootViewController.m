//
//  GHRootViewController.m
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-16-05.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import "GHRootViewController.h"

//==============================================================================
@interface GHRootViewController ()

@property (nonatomic) UISwipeGestureRecognizer *swipeRightRecognizer;
@property (nonatomic) UISwipeGestureRecognizer *swipeLeftRecognizer;

@end
//==============================================================================
@implementation GHRootViewController
//------------------------------------------------------------------------------
- (void)awakeFromNib
{
    [super awakeFromNib];

    self.swipeRightRecognizer = [UISwipeGestureRecognizer.alloc initWithTarget:self action:@selector(onSwipeRight:)];
    self.swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    self.swipeLeftRecognizer = [UISwipeGestureRecognizer.alloc initWithTarget:self action:@selector(onSwipeLeft:)];
    self.swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
}
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.selectedIndex = 2;  //switch to "Thoughts" tab
    [self.view addGestureRecognizer:self.swipeRightRecognizer];
    [self.view addGestureRecognizer:self.swipeLeftRecognizer];
}
//------------------------------------------------------------------------------
- (void)viewDidUnload
{
    [super viewDidUnload];

    [self.view removeGestureRecognizer:self.swipeRightRecognizer];
    [self.view removeGestureRecognizer:self.swipeLeftRecognizer];
}
//------------------------------------------------------------------------------
- (void)onSwipeRight:(UIGestureRecognizer *)gestureRecognizer
{
    [self swipeTo:self.selectedIndex - 1];
}
//------------------------------------------------------------------------------
- (void)onSwipeLeft:(UIGestureRecognizer *)gestureRecognizer
{
    [self swipeTo:self.selectedIndex + 1];
}
//------------------------------------------------------------------------------
- (void)swipeTo:(NSUInteger)to
{
    if (self.selectedIndex == to || to > self.viewControllers.count - 2)  //do not switch to "Settings" tab
        return;

    UIView *fromView = self.selectedViewController.view;
    UIView *toView = [self.viewControllers[to] view];
    CGRect viewSize = fromView.frame;
    CGFloat screenWidth = UIApplication.frame.size.width;

    [fromView.superview addSubview:toView];
    toView.frame = CGRectMake(to > self.selectedIndex ? screenWidth : - screenWidth, viewSize.origin.y, screenWidth, viewSize.size.height);

    [UIView animateWithDuration:0.33 animations:^
    {
        fromView.frame = CGRectMake(to > self.selectedIndex ? - screenWidth : screenWidth, viewSize.origin.y, screenWidth, viewSize.size.height);
        toView.frame = CGRectMake(0.0, viewSize.origin.y, screenWidth, viewSize.size.height);
    }
    completion:^(BOOL finished)
    {
        [fromView removeFromSuperview];
        self.selectedIndex = to;
    }];
}
//------------------------------------------------------------------------------
@end
//==============================================================================