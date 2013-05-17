//
//  GHContentViewController.m
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-16-05.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import "GHContentViewController.h"

#import "GHWebCell.h"

//==============================================================================
@interface GHContentViewController () <GHWebCellDelegate>

@property (nonatomic) NSMutableDictionary *heights;

@end
//==============================================================================
@implementation GHContentViewController
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor.alloc initWithPatternImage:[UIImage imageNamed:@"background"]];
    self.refreshControl = UIRefreshControl.new;
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];

    [self refresh];
}
//------------------------------------------------------------------------------
- (void)refresh
{
    self.heights = NSMutableDictionary.new;
    [self.refreshControl beginRefreshing];

    GHContentViewController __block __weak *this = self;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:this.updateAddress]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        this.posts = NSMutableArray.new;

        for (NSDictionary *post in JSON[@"posts"])
            [this.posts addObject:[NSString stringWithFormat:@"<html><head><style type=\"text/css\">body {font-family: \"%@\"; font-size: %i; text-align:center;}</style></head><body>%@</body></html>", @"Georgia", 20, post[@"content"]]];

        [this.tableView reloadData];
        [this.refreshControl endRefreshing];
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        SHOW_ALERT(nil, NSLocalizedString(@"UPDATE_FAILURE", nil), nil, NSLocalizedString(@"OK", nil), nil);
        [this.refreshControl endRefreshing];
    }];

    [operation start];
}
//------------------------------------------------------------------------------
- (void)updateCell:(GHWebCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    self.heights[@(indexPath.row)] = @(cell.webView.scrollView.contentSize.height);
    [self.tableView reloadData];
}
//------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.posts.count;
}
//------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.heights[@(indexPath.row)])
        return [self.heights[@(indexPath.row)] floatValue];

    return 44.0;
}
//------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GHWebCell *cell = [tableView dequeueReusableCellWithIdentifier:GH_WEB_CELL_ID forIndexPath:indexPath];

    cell.delegate = self;
    cell.indexPath = indexPath;

    if (!self.heights[@(indexPath.row)])
        [cell.webView loadHTMLString:self.posts[indexPath.row] baseURL:nil];

    return cell;
}
//------------------------------------------------------------------------------
@end
//==============================================================================