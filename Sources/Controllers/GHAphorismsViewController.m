//
//  GHAphorismsViewController.m
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-15-05.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import "GHAphorismsViewController.h"

//==============================================================================
@interface GHAphorismsViewController ()

@end
//==============================================================================
@implementation GHAphorismsViewController
//------------------------------------------------------------------------------
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.updateAddress = [NSString stringWithFormat:@"%@/%@/?id=%i", GH_API, GH_API_GET_CATEGORY, GHPostAphorism];
}
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.titleView = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"aphorisms_title"]];
}
//------------------------------------------------------------------------------
@end
//==============================================================================