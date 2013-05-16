//
//  AphorismsViewController.m
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-15-05.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import "AphorismsViewController.h"

//==============================================================================
@interface AphorismsViewController ()

@end
//==============================================================================
@implementation AphorismsViewController
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.titleView = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"aphorisms_title"]];
    self.view.backgroundColor = [UIColor.alloc initWithPatternImage:[UIImage imageNamed:@"background"]];
}
//------------------------------------------------------------------------------
@end
//==============================================================================