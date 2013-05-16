//
//  StyleViewController.m
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-15-05.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import "StyleViewController.h"

//==============================================================================
@interface StyleViewController ()

@end
//==============================================================================
@implementation StyleViewController
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.titleView = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"style_title"]];
    self.view.backgroundColor = [UIColor.alloc initWithPatternImage:[UIImage imageNamed:@"background"]];
}
//------------------------------------------------------------------------------
@end
//==============================================================================