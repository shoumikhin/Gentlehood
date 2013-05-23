//
//  GHVocabularyViewController.m
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-15-05.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import "GHVocabularyViewController.h"

//==============================================================================
@interface GHVocabularyViewController ()

@end
//==============================================================================
@implementation GHVocabularyViewController
//------------------------------------------------------------------------------
- (void)awakeFromNib
{
    [super awakeFromNib];

    self.updateAddress = [NSString stringWithFormat:@"%@/%@/?id=%i", GH_API, GH_API_GET_CATEGORY, GHPostVocabulary];
}
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.titleView = [UIImageView.alloc initWithImage:[UIImage imageNamed:@"vocabulary_title"]];
}
//------------------------------------------------------------------------------
@end
//==============================================================================