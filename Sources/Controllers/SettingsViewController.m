//
//  SettingsViewController.m
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-15-05.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import "SettingsViewController.h"

//==============================================================================
@interface SettingsViewController ()

@end
//==============================================================================
@implementation SettingsViewController
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.titleView = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"settings_title"]];
    self.view.backgroundColor = [UIColor.alloc initWithPatternImage:[UIImage imageNamed:@"background"]];
}
//------------------------------------------------------------------------------
@end
//==============================================================================