//
//  GHContentViewController.m
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-16-05.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import "GHContentViewController.h"

//==============================================================================
@interface GHContentViewController ()

@property (nonatomic) NSMutableArray *posts;

@end
//==============================================================================
@implementation GHContentViewController
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor.alloc initWithPatternImage:[UIImage imageNamed:@"background"]];
    self.tableView.separatorColor = [UIColor colorWithRed:20.0/256 green:49.0/256 blue:97.0/256 alpha:0.25];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:GH_WEB_CELL_ID];
    self.refreshControl = UIRefreshControl.new;
    self.refreshControl.tintColor = [UIColor colorWithRed:20.0/256 green:49.0/256 blue:97.0/256 alpha:0.75];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];

    [self refresh];
}
//------------------------------------------------------------------------------
- (void)refresh
{
    [self.refreshControl beginRefreshing];
    
    GHContentViewController __block __weak *this = self;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:this.updateAddress]];
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
        {
            this.posts = NSMutableArray.new;

            for (NSDictionary *post in JSON[@"posts"])
                [this.posts addObject:post[@"content"]];

            dispatch_async(dispatch_get_main_queue(), ^
            {
                [this.tableView reloadData];
                [this.refreshControl endRefreshing];
            });
        }
        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                SHOW_ALERT(nil, NSLocalizedString(@"UPDATE_FAILURE", nil), nil, NSLocalizedString(@"OK", nil), nil);
                [this.refreshControl endRefreshing];
            });
        }];

        [operation start];
    });
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GH_WEB_CELL_ID forIndexPath:indexPath];

    //[webView loadHTMLString:self.posts[indexPath.row] baseURL:nil];

    return cell;
}
//------------------------------------------------------------------------------
@end
//==============================================================================