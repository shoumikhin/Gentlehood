//
//  VocabularyViewController.m
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-15-05.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import "VocabularyViewController.h"

//==============================================================================
@interface VocabularyViewController ()

@end
//==============================================================================
@implementation VocabularyViewController
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.titleView = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"vocabulary_title"]];
    self.tableView.backgroundView = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"background"]];
    self.tableView.separatorColor = [UIColor colorWithRed:20.0/256 green:49.0/256 blue:97.0/256 alpha:0.25];
}
//------------------------------------------------------------------------------
@end
//==============================================================================