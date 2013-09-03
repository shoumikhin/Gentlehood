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
static NSUInteger const kPostsPerPage = 10;
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
- (void)awakeFromNib
{
    self.navigationController.navigationBar.translucent = YES;
}
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        [RKObjectManager.sharedManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:GHPost.mapping method:RKRequestMethodGET pathPattern:kGHAPIGetCategory keyPath:@"posts" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    });

    self.isLoaded = self.isLoading = self.isAppendTriggered = NO;
    self.currentPage = 1;
    self.orientation = UIApplication.sharedApplication.statusBarOrientation;
    [self.refreshControl addTarget:self action:@selector(update) forControlEvents:UIControlEventValueChanged];
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

    if (!self.isLoaded && AFNetworkReachabilityStatusNotReachable < RKObjectManager.sharedManager.HTTPClient.networkReachabilityStatus)
        [self update];

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onNetworkReachabilityChanged:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    });

    TRACK(@"APPEAR", self.navigationItem.title);
}
//------------------------------------------------------------------------------
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    self.orientation = UIApplication.sharedApplication.statusBarOrientation;
    [self.tableView reloadData];
}
//------------------------------------------------------------------------------
- (void)onNetworkReachabilityChanged:(NSNotification *)notification
{
    if (!self.isLoaded && AFNetworkReachabilityStatusNotReachable < [notification.userInfo[AFNetworkingReachabilityNotificationStatusItem] integerValue])
        [self update];
}
//------------------------------------------------------------------------------
- (void)update
{
    if (self.isLoading)
        return;

    [self.refreshControl beginRefreshing];

    if (0.0 == self.tableView.contentOffset.y)
    {
        @weakify(self)

        [UIView animateWithDuration:UINavigationControllerHideShowBarDuration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
        {
            @strongify(self)

            self.tableView.contentOffset = CGPointMake(0.0, - self.refreshControl.frame.size.height);
        }
        completion:nil];
    }

    self.currentPage = 1;
    [self load];
}
//------------------------------------------------------------------------------
- (void)load
{
    self.isLoading = YES;

    @weakify(self)

    [RKObjectManager.sharedManager getObjectsAtPath:kGHAPIGetCategory parameters:
    @{
        @"id":@(self.category),
        @"page":@(self.currentPage),
        @"count":@(kPostsPerPage)
    }
    success:^
    (RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
    {
        @strongify(self)

        [NSFetchedResultsController deleteCacheWithName:kFetchCacheName];
        [self.fetchedResultsController performFetch:nil];

        [self.refreshControl endRefreshing];
        self.tableView.tableFooterView.hidden = YES;

        self.isLoading = NO;
        self.isLoaded = YES;
        self.currentPage++;

        TRACK(@"UPDATE SUCCESS", self.navigationItem.title);
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
        
        self.isLoading = NO;

        TRACK(@"UPDATE FAILURE", self.navigationItem.title);
    }];

    ((RKObjectRequestOperation *)RKObjectManager.sharedManager.operationQueue.operations.lastObject).willMapDeserializedResponseBlock = ^
    id (id deserializedResponseBody)
    {
        @strongify(self)

        if (!self.isLoaded)
            [self deleteObsoleteData];

        return deserializedResponseBody;
    };
}
//------------------------------------------------------------------------------
- (void)deleteObsoleteData
{
    [RKManagedObjectStore.defaultStore.mainQueueManagedObjectContext deleteObjectsOfEntity:NSStringFromClass(GHPost.class) withPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:@[self.predicate, [NSPredicate predicateWithFormat:@"YES != favorite"]]] sortDescriptors:nil andFetchLimit:0];
    [RKManagedObjectStore.defaultStore.mainQueueManagedObjectContext saveToPersistentStore:nil];
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
        self.emptyLabel = [UILabel.alloc initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, kUITableViewCellHeightDefault + kUITableViewCellHeightDefault / 2)];
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

    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[self.tabBarController.view convertPoint:point toView:self.tableView]];
    GHWebCell *webCell = (GHWebCell *)[self.tableView cellForRowAtIndexPath:indexPath];

    if (!webCell)
        return;

    GHPost *post = [self.fetchedResultsController objectAtIndexPath:indexPath];

    @weakify(webCell, post)

    SIAlertViewHandler handler = ^
    (SIAlertView *alertView)
    {
        @strongify(webCell, post)

        post.favoriteValue = !post.favoriteValue;
        webCell.bookmarked = post.favoriteValue;
        [RKManagedObjectStore.defaultStore.mainQueueManagedObjectContext saveToPersistentStore:nil];

        TRACK(post.favoriteValue ? @"BOOKMARK" : @"UNBOOKMARK", post.identifier.stringValue);
    };

    if (post.favoriteValue)
    {
        SIAlertView *alertView = [SIAlertView.alloc initWithTitle:nil andMessage:NSLocalizedString(@"REMOVE_FROM_FAVORITES", nil)];

        [alertView addButtonWithTitle:NSLocalizedString(@"YES", nil) type:SIAlertViewButtonTypeDestructive handler:handler];
        [alertView addButtonWithTitle:NSLocalizedString(@"NO", nil) type:SIAlertViewButtonTypeCancel handler:nil];
        alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
        alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
        alertView.messageFont = [UIFont fontWithName:kFontFamily size:kFontSizeSmall];
        alertView.buttonFont = [UIFont fontWithName:kFontFamily size:kFontSize];
        
        [alertView show];
    }
    else
    {
        handler(nil);
        [SVProgressHUD showImage:[UIImage imageNamed:@"anchor"] status:nil];
        [SVProgressHUD dismiss];
    }
}
//------------------------------------------------------------------------------
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (-kUITableViewCellHeightDefault > scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y)
        if (self.isLoaded && !self.isLoading && !self.isAppendTriggered)
        {
            id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[0];
            GHCategory *category = [RKManagedObjectStore.defaultStore.mainQueueManagedObjectContext objectsOfEntity:NSStringFromClass(GHCategory.class) withPredicate:[NSPredicate predicateWithFormat:@"identifier == %i", self.category] sortDescriptors:nil andFetchLimit:1].lastObject;

            if (sectionInfo.numberOfObjects < category.postCount.integerValue)
            {
                self.tableView.tableFooterView.hidden = NO;
                [self load];
                self.isAppendTriggered = YES;

                TRACK(@"APPEND", self.navigationItem.title);
            }
        }
}
//------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.isAppendTriggered = NO;
}
//------------------------------------------------------------------------------
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (!self.tableView.indexPathsForVisibleRows.count)
        return;

    NSIndexPath *indexPath = self.tableView.indexPathsForVisibleRows[0];

    if (velocity.y >= 0.0 && self.tableView.indexPathsForVisibleRows.count > 1)
        indexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

    if (ABS(velocity.y) > 1.0)
        *targetContentOffset = CGPointMake(cell.frame.origin.x, cell.frame.origin.y + (velocity.y >= 0.0 && self.tableView.indexPathsForVisibleRows.count == 1 ? cell.frame.size.height : 0.0));
}
//------------------------------------------------------------------------------
@end
//==============================================================================