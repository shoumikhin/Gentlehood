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
static NSString * const kFontFamily = @"Georgia";
static CGFloat const kFontSize = 20.0;
static NSUInteger const kContentWidth = 305;
//==============================================================================
@interface GHContentViewController () <GHWebCellDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) NSMutableDictionary *heights;
@property (nonatomic) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic) BOOL isLoaded;

@end
//==============================================================================
@implementation GHContentViewController
//------------------------------------------------------------------------------
- (void)awakeFromNib
{
    [super awakeFromNib];

    self.tapRecognizer = [UITapGestureRecognizer.alloc initWithTarget:self action:@selector(onTap:)];
    self.tapRecognizer.numberOfTapsRequired = 2;
    self.tapRecognizer.delegate = self;
}
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor.alloc initWithPatternImage:[UIImage imageNamed:@"background"]];
    self.refreshControl = UIRefreshControl.new;
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.view addGestureRecognizer:self.tapRecognizer];
}
//------------------------------------------------------------------------------
- (void)viewDidUnload
{
    [super viewDidUnload];

    [self.view removeGestureRecognizer:self.tapRecognizer];
}
//------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (!self.isLoaded && !self.refreshControl.refreshing)
        [self refresh];
}
//------------------------------------------------------------------------------
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer isKindOfClass:UITapGestureRecognizer.class] && 2 == ((UITapGestureRecognizer *)otherGestureRecognizer).numberOfTapsRequired)
            [otherGestureRecognizer.view removeGestureRecognizer:otherGestureRecognizer];

    return YES;
}
//------------------------------------------------------------------------------
- (void)onTap:(UIGestureRecognizer *)gestureRecognizer
{
    [self.tabBarController setTabBarHidden:!self.tabBarController.isTabBarHidden animated:YES];
}
//------------------------------------------------------------------------------
- (void)refresh
{
    self.heights = NSMutableDictionary.new;
    [self.refreshControl beginRefreshing];

    if (0.0 == self.tableView.contentOffset.y)
        [UIView animateWithDuration:UINavigationControllerHideShowBarDuration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^(void)
        {
            self.tableView.contentOffset = CGPointMake(0.0, - self.refreshControl.frame.size.height);
        }
        completion:nil];

    GHContentViewController __block __weak *this = self;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:this.updateAddress]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        this.posts = NSMutableArray.new;

        for (NSDictionary *post in JSON[@"posts"])
            [this.posts addObject:[NSString.alloc initWithFormat:@"<html><head><meta name=\"viewport\" content=\"user-scalable=no, width=device-width, initial-scale=1.0, maximum-scale=1.0\"/><meta name=\"apple-mobile-web-app-capable\" content=\"yes\" /><style type=\"text/css\">p { max-width:%upx; font-family: \"%@\"; font-size: %f; text-align:center; } img {max-width:%upx; height:auto; margin-left:auto; margin-right:auto; }</style></head><body>%@</body></html>", kContentWidth, kFontFamily, kFontSize, kContentWidth, post[@"content"]]];

        this.isLoaded = this.posts.count > 0;
        [this.tableView reloadData];
        [this.refreshControl endRefreshing];
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        [this.refreshControl endRefreshing];
        this.isLoaded = NO;

        if (this == this.tabBarController.selectedViewController)
            SHOW_ALERT(nil, NSLocalizedString(@"UPDATE_FAILURE", nil), nil, NSLocalizedString(@"OK", nil), nil);
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