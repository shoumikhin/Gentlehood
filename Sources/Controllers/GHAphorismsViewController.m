//
//  GHAphorismsViewController.m
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-15-05.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import "GHAphorismsViewController.h"

//==============================================================================
@implementation GHAphorismsViewController
//------------------------------------------------------------------------------
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.category = GHPostAphorism;
    self.predicate = [NSPredicate predicateWithFormat:@"ANY categories.identifier == %i", self.category];
}
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", [UIDevice systemVersionIsAtLeast:@"7.0"] ? @"" : @"6_", NSLocalizedString(@"APHORISMS_TITLE", nil)]];

    if (image)
        self.navigationItem.titleView = [UIImageView.alloc initWithImage:image];}
//------------------------------------------------------------------------------
@end
//==============================================================================