//
//  GHFavoritesViewController.m
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-15-05.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import "GHFavoritesViewController.h"

#import "GHPost.h"
#import "GHWebCell.h"

//==============================================================================
@implementation GHFavoritesViewController
//------------------------------------------------------------------------------
- (void)awakeFromNib
{
    [super awakeFromNib];

    self.category = GHPostAny;
    self.predicate = [NSPredicate predicateWithFormat:@"favorite == YES"];
}
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.refreshControl = nil;

    UIImage *image = [UIImage imageNamed:NSLocalizedString(@"FAVORITES_TITLE", nil)];

    if (image)
        self.navigationItem.titleView = [UIImageView.alloc initWithImage:image];
}
//------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
{
    //let's override this to avoid inherited call
}
//------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number = [super tableView:tableView numberOfRowsInSection:section];

    self.tableView.tableFooterView.hidden = number > 0;

    return number;
}
//------------------------------------------------------------------------------
@end
//==============================================================================