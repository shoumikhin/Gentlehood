//
//  GHThoughtsViewController.m
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-15-05.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import "GHThoughtsViewController.h"

//==============================================================================
@implementation GHThoughtsViewController
//------------------------------------------------------------------------------
- (void)awakeFromNib
{
    [super awakeFromNib];

    self.category = GHPostThought;
    self.predicate = [NSPredicate predicateWithFormat:@"ANY categories.identifier == %i", self.category];
}
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage *image = [UIImage imageNamed:NSLocalizedString(@"THOSUGHTS_TITLE", nil)];

    if (image)
        self.navigationItem.titleView = [UIImageView.alloc initWithImage:image];
}
//------------------------------------------------------------------------------
@end
//==============================================================================