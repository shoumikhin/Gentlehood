//
//  RootViewController.m
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-16-05.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import "RootViewController.h"

//==============================================================================
@interface RootViewController ()

@property (nonatomic) UISwipeGestureRecognizer *swipeRightRecognizer;
@property (nonatomic) UISwipeGestureRecognizer *swipeLeftRecognizer;

@end
//==============================================================================
@implementation RootViewController
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

    [UIView transitionFromView:self.selectedViewController.view toView:[self.viewControllers[to] view] duration:0.33 options:to > self.selectedIndex ? UIViewAnimationOptionTransitionFlipFromRight : UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished)
     {
         self.selectedIndex = to;
     }];
}
//------------------------------------------------------------------------------
@end
//==============================================================================