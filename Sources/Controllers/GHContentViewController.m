//
//  GHContentViewController.m
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-16-05.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import "GHContentViewController.h"

#import "GHRootViewController.h"

//==============================================================================
@interface GHContentViewController () <NSFetchedResultsControllerDelegate, UIScrollViewDelegate, IASKSettingsDelegate>

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
@synthesize fetchedResultsController = _fetchedResultsController;
//------------------------------------------------------------------------------
- (void)awakeFromNib
{
    [super awakeFromNib];

    self.navigationController.navigationBar.translucent = YES;
    self.postsPerPage = kGHPostsPerPageDefault;
    self.sortDescriptors = @[[NSSortDescriptor.alloc initWithKey:@"date" ascending:NO]];
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
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onNetworkReachabilityChanged:) name:AFNetworkingReachabilityDidChangeNotification object:nil];

    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];

    settingsButton.frame = CGRectMake(0.0, 0.0, 22.0, 22.0);
    [settingsButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@", [UIDevice systemVersionIsAtLeast:@"7.0"] ? @"" : @"6_", @"gear"]] forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(onSettings:) forControlEvents:UIControlEventTouchUpInside];

    self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithCustomView:settingsButton];
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

    if (0.0 >= self.tableView.contentOffset.y)
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
        @"count":@(self.postsPerPage)
    }
    success:^
    (RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
    {
        @strongify(self)

        if (!self.isLoaded)
            [self deleteObsoleteData];

        [NSFetchedResultsController deleteCacheWithName:kFetchCacheName];
        [self.fetchedResultsController performFetch:nil];

        [self.refreshControl endRefreshing];
        self.tableView.tableFooterView.hidden = YES;

        self.isLoading = NO;
        self.isLoaded = YES;
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
        
        self.isLoading = NO;

        TRACK(@"UPDATE FAILURE", self.navigationItem.title);
    }];
}
//------------------------------------------------------------------------------
- (void)deleteObsoleteData
{
    NSMutableArray *objectsToDelete = [RKManagedObjectStore.defaultStore.mainQueueManagedObjectContext objectsOfEntity:NSStringFromClass(GHPost.class) withPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:@[self.predicate, [NSPredicate predicateWithFormat:@"NO == favorite"]]] sortDescriptors:@[[NSSortDescriptor.alloc initWithKey:@"date" ascending:NO]] andFetchLimit:0].mutableCopy;

    [objectsToDelete removeObjectsInRange:NSMakeRange(0, MIN(objectsToDelete.count, self.postsPerPage))];
    [RKManagedObjectStore.defaultStore.mainQueueManagedObjectContext deleteObjects:objectsToDelete];
    [RKManagedObjectStore.defaultStore.mainQueueManagedObjectContext saveToPersistentStore:nil];
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellID forIndexPath:indexPath];

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
    fetchRequest.sortDescriptors = self.sortDescriptors;

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

    cell.textLabel.text = post.title;
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
- (void)onSettings:(id)sender
{
    IASKAppSettingsViewController *settingsController = IASKAppSettingsViewController.new;

    settingsController.showCreditsFooter = NO;
    settingsController.showDoneButton = YES;
    settingsController.delegate = self;

    [self presentViewController:[UINavigationController.alloc initWithRootViewController:settingsController] animated:YES completion:nil];
}
//------------------------------------------------------------------------------
- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
//------------------------------------------------------------------------------
@end
//==============================================================================