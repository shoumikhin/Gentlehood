//
//  GHContentViewController.m
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-16-05.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import "GHContentViewController.h"

#import "GHPost.h"
#import "GHCategory.h"
#import "GHWebCell.h"

//==============================================================================
@interface GHContentViewController () <NSFetchedResultsControllerDelegate, GHWebCellDelegate, UIScrollViewDelegate>

@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) BOOL isLoaded;
@property (nonatomic) BOOL isLoading;
@property (nonatomic) BOOL isAppendTriggered;
@property (nonatomic) NSUInteger currentPage;
@property (nonatomic) UILabel *emptyLabel;
@property (nonatomic) UIInterfaceOrientation orientation;

@end
//==============================================================================
@implementation GHContentViewController
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.isLoaded = self.isLoading = self.isAppendTriggered = NO;
    self.currentPage = 1;
    self.orientation = UIApplication.sharedApplication.statusBarOrientation;
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}
//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (UIApplication.sharedApplication.statusBarOrientation != self.orientation)
    {
        self.orientation = UIApplication.sharedApplication.statusBarOrientation;
        [self.tableView reloadData];
    }
}
//------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (!self.isLoaded && !self.isLoading && AFNetworkReachabilityStatusNotReachable != RKObjectManager.sharedManager.HTTPClient.networkReachabilityStatus)
        [self refresh];
}
//------------------------------------------------------------------------------
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    self.orientation = UIApplication.sharedApplication.statusBarOrientation;
    [self.tableView reloadData];
}
//------------------------------------------------------------------------------
- (void)refresh
{
    [self.refreshControl beginRefreshing];

    if (0.0 == self.tableView.contentOffset.y)
        [UIView animateWithDuration:UINavigationControllerHideShowBarDuration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^(void)
        {
            self.tableView.contentOffset = CGPointMake(0.0, - self.refreshControl.frame.size.height);
        }
        completion:nil];

    self.currentPage = 1;
    [self request];
}
//------------------------------------------------------------------------------
- (void)request
{
    self.isLoading = YES;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        [RKObjectManager.sharedManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:GHPost.mapping pathPattern:kGHAPIGetCategory keyPath:@"posts" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    });

    @weakify(self)

    [RKObjectManager.sharedManager getObjectsAtPath:kGHAPIGetCategory parameters:
    @{
        @"id":@(self.category),
        @"page":@(self.currentPage)
    }
    success:^
    (RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
    {
        @strongify(self)

        [NSFetchedResultsController deleteCacheWithName:kFetchCacheName];
        [self.fetchedResultsController performFetch:nil];
        [self.refreshControl endRefreshing];
        self.tableView.tableFooterView.hidden = YES;
        self.isLoaded = YES;
        self.isLoading = NO;
        self.currentPage++;
    }
    failure:^
    (RKObjectRequestOperation *operation, NSError *error)
    {
        @strongify(self)

        UIViewController *selectedController = self.tabBarController.selectedViewController;

        if (selectedController == self ||
            ([selectedController isKindOfClass:UINavigationController.class] &&
             ((UINavigationController *)selectedController).visibleViewController == self))
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"UPDATE_FAILURE", nil)];

        [self.refreshControl endRefreshing];
        self.tableView.tableFooterView.hidden = YES;
        self.isLoaded = NO;
        self.isLoading = NO;
    }];
}
//------------------------------------------------------------------------------
- (void)webCellHeight:(CGFloat)height forIndexPath:(NSIndexPath *)indexPath
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[0];

    if (indexPath.row >= sectionInfo.numberOfObjects)
        return;

    GHPost *post = [self.fetchedResultsController objectAtIndexPath:indexPath];

    if (height != post.height.floatValue)
    {
        post.height = @(height);
        [RKManagedObjectStore.defaultStore.mainQueueManagedObjectContext save:nil];
    }

    [UIView setAnimationsEnabled:NO];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView setAnimationsEnabled:YES];
}
//------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchedResultsController.sections.count;
}
//------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];

    [self.emptyLabel removeFromSuperview];
    self.emptyLabel = nil;

    if (!sectionInfo.numberOfObjects)
    {
        self.emptyLabel = [UILabel.alloc initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, kUITableViewCellHeightDefault)];
        self.emptyLabel.center = self.tableView.center;
        self.emptyLabel.backgroundColor = UIColor.clearColor;
        self.emptyLabel.textColor = [UIColor colorWithHTMLColor:kHTMLColorDefault];
        self.emptyLabel.textAlignment = NSTextAlignmentCenter;
        self.emptyLabel.font = [UIFont fontWithName:kFontFamilyItalic size:kFontSize];
        self.emptyLabel.text = NSLocalizedString(@"NO_CONTENT", nil);
        [self.tableView addSubview:self.emptyLabel];
    }

    return sectionInfo.numberOfObjects;
}
//------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GHPost *post = [self.fetchedResultsController objectAtIndexPath:indexPath];

    return post.height.floatValue;
}
//------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GHWebCell *cell = [tableView dequeueReusableCellWithIdentifier:kGHWebCellID forIndexPath:indexPath];

    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}
//------------------------------------------------------------------------------
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController)
        return _fetchedResultsController;

    NSFetchRequest *fetchRequest = NSFetchRequest.new;

    fetchRequest.entity = [NSEntityDescription entityForName:NSStringFromClass(GHPost.class) inManagedObjectContext:RKManagedObjectStore.defaultStore.mainQueueManagedObjectContext];
    fetchRequest.predicate = self.predicate;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor.alloc initWithKey:@"date" ascending:NO]];

    [NSFetchedResultsController deleteCacheWithName:kFetchCacheName];
    _fetchedResultsController = [NSFetchedResultsController.alloc initWithFetchRequest:fetchRequest managedObjectContext:RKManagedObjectStore.defaultStore.mainQueueManagedObjectContext sectionNameKeyPath:nil cacheName:kFetchCacheName];
    _fetchedResultsController.delegate = self;

	[self.fetchedResultsController performFetch:nil];

    return _fetchedResultsController;
}
//------------------------------------------------------------------------------
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}
//------------------------------------------------------------------------------
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type)
    {
        case NSFetchedResultsChangeInsert :

            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];

            break;

        case NSFetchedResultsChangeDelete :

            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

            break;

        case NSFetchedResultsChangeUpdate :

            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];

            break;

        case NSFetchedResultsChangeMove :

            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            break;
    }
}
//------------------------------------------------------------------------------
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}
//------------------------------------------------------------------------------
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    GHPost *post = [self.fetchedResultsController objectAtIndexPath:indexPath];
    GHWebCell *webCell = (GHWebCell *)cell;
    
    webCell.delegate = self;
    webCell.indexPath = indexPath;
    webCell.bookmarked = post.favoriteValue;
    [webCell loadContent:post.content];
}
//------------------------------------------------------------------------------
- (void)bookmarkContentAtPoint:(CGPoint)point
{
    if (!self.fetchedResultsController.sections.count)
        return;

    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[self.view.window convertPoint:point toView:self.tableView]];
    GHPost *post = [self.fetchedResultsController objectAtIndexPath:indexPath];
    GHWebCell *webCell = (GHWebCell *)[self.tableView cellForRowAtIndexPath:indexPath];

    post.favoriteValue = !post.favoriteValue;
    webCell.bookmarked = post.favoriteValue;
    [RKManagedObjectStore.defaultStore.mainQueueManagedObjectContext saveToPersistentStore:nil];

    [SVProgressHUD showImage:[UIImage imageNamed:@"anchor"] status:nil];
    [SVProgressHUD dismiss];
}
//------------------------------------------------------------------------------
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (-kUITableViewCellHeightDefault / 2 > scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y)
        if (!self.isLoading && !self.isAppendTriggered)
        {
            id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[0];
            GHCategory *category = [RKManagedObjectStore.defaultStore.mainQueueManagedObjectContext objectsOfEntity:NSStringFromClass(GHCategory.class) withPredicate:[NSPredicate predicateWithFormat:@"identifier == %i", self.category] sortDescriptors:nil andFetchLimit:1].lastObject;

            if (sectionInfo.numberOfObjects < category.postCount.integerValue)
            {
                self.tableView.tableFooterView.hidden = NO;
                [self request];
                self.isAppendTriggered = YES;
            }
        }
}
//------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.isAppendTriggered = NO;
}
//------------------------------------------------------------------------------
@end
//==============================================================================