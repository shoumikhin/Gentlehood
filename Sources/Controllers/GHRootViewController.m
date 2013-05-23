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
    NSUInteger index = self.selectedIndex - 1;
    
    if (index < self.viewControllers.count - 2)  //do not switch to "Settings" tab
        [self swipeToIndex:index];
}
//------------------------------------------------------------------------------
- (void)onSwipeLeft:(UIGestureRecognizer *)gestureRecognizer
{
    NSUInteger index = self.selectedIndex + 1;

    if (index < self.viewControllers.count - 1)  //do not switch to "Settings" tab
        [self swipeToIndex:index];
}
//------------------------------------------------------------------------------
@end
//==============================================================================