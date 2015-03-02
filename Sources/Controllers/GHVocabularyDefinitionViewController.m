//
//  GHVocabularyViewController.m
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-15-05.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import "GHVocabularyDefinitionViewController.h"

//==============================================================================
@implementation GHVocabularyDefinitionViewController
//------------------------------------------------------------------------------
- (void)awakeFromNib
{
    [super awakeFromNib];

    self.category = GHPostVocabulary;
}
//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.view.alpha = 1.0;
}
//------------------------------------------------------------------------------
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    self.view.alpha = 0.0;
}
//------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
{
    //let's override this to avoid inherited call
    TRACK(@"APPEAR", ((GHPost *)self.fetchedResultsController.fetchedObjects.lastObject).title);
}
//------------------------------------------------------------------------------
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //let's override this to avoid inherited call
}
//------------------------------------------------------------------------------
@end
//==============================================================================