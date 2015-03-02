//
//  GHPostViewController.m
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-23-09.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import "GHPostViewController.h"

#import "GHWebCell.h"

//==============================================================================
#define INDEX_PATH_HOOK @selector(__index_path__)
//==============================================================================
@interface GHPostViewController () <GHWebCellDelegate>

@end
//==============================================================================
@implementation GHPostViewController
//------------------------------------------------------------------------------
- (void)awakeFromNib
{
    [super awakeFromNib];

    self.cellID = kGHWebCellID;
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GHPost *post = [self.fetchedResultsController objectAtIndexPath:indexPath];

    return post.height.floatValue;
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
- (GHWebCell *)cellAtPoint:(CGPoint)point
{
    return (GHWebCell *)[self.tableView cellForRowAtIndexPath:[self.tableView indexPathForRowAtPoint:[self.tabBarController.view convertPoint:point toView:self.tableView]]];
}
//------------------------------------------------------------------------------
- (void)bookmarkContentAtPoint:(CGPoint)point
{
    GHWebCell *webCell = [self cellAtPoint:point];

    if (!webCell)
        return;

    GHPost *post = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:webCell]];

    @weakify(webCell, post)

    UIAlertViewCompletionBlock completionBlock = ^
    (UIAlertView *alertView, NSInteger buttonIndex)
    {
        if (1 == buttonIndex)
            return;

        @strongify(webCell, post)

        post.favoriteValue = !post.favoriteValue;
        webCell.bookmarked = post.favoriteValue;
        [RKManagedObjectStore.defaultStore.mainQueueManagedObjectContext saveToPersistentStore:nil];

        TRACK(post.favoriteValue ? @"BOOKMARK" : @"UNBOOKMARK", post.identifier.stringValue);
    };

    if (post.favoriteValue)
        [[UIAlertView.alloc initWithTitle:nil message:NSLocalizedString(@"REMOVE_FROM_FAVORITES", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"YES", nil) otherButtonTitles:NSLocalizedString(@"NO", nil), nil] showWithCompletion:completionBlock];
    else
    {
        completionBlock(nil, 0);
        [SVProgressHUD showImage:[UIImage imageNamed:@"anchor"] status:nil];
    }
}
//------------------------------------------------------------------------------
- (void)showMenuAtPoint:(CGPoint)point
{
    GHWebCell *webCell = [self cellAtPoint:point];

    if (!webCell)
        return;

    point = [self.tabBarController.view convertPoint:point toView:self.tableView];

    UIMenuController.sharedMenuController.menuItems =
    @[
        [UIMenuItem.alloc initWithTitle:NSLocalizedString(@"OPEN_POST", nil) action:@selector(onOpenURL:)],
        [UIMenuItem.alloc initWithTitle:NSLocalizedString(@"SHARE_POST", nil) action:@selector(onShare:)],
        [UIMenuItem.alloc initWithTitle:[self.tableView indexPathForCell:webCell].stringValue action:INDEX_PATH_HOOK]
    ];
    [UIMenuController.sharedMenuController setTargetRect:CGRectMake(point.x, point.y, 0.0, 0.0) inView:self.view];
    [UIMenuController.sharedMenuController setMenuVisible:YES animated:YES];

    [self becomeFirstResponder];
}
//------------------------------------------------------------------------------
- (BOOL)canBecomeFirstResponder
{
    return YES;
}
//------------------------------------------------------------------------------
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return  @selector(onOpenURL:) == action ||
            @selector(onShare:)   == action;
}
//------------------------------------------------------------------------------
- (NSIndexPath *)indexPathFromMenuController:(UIMenuController *)menuController
{
    for (UIMenuItem *menuItem in menuController.menuItems)
        if (INDEX_PATH_HOOK == menuItem.action)
            return [NSIndexPath indexPathWithString:menuItem.title];

    return nil;
}
//------------------------------------------------------------------------------
- (void)onOpenURL:(id)sender
{
    GHPost *post = [self.fetchedResultsController objectAtIndexPath:[self indexPathFromMenuController:sender]];

    if (post)
    {
        [UIApplication openURL:[NSURL URLWithString:post.url] andShowReturn:YES];

        TRACK(@"OPEN", post.url);
    }

    [self resignFirstResponder];
}
//------------------------------------------------------------------------------
- (NSArray *)sharedItemsFromIndexPath:(NSIndexPath *)indexPath
{
    GHPost *post = [self.fetchedResultsController objectAtIndexPath:indexPath];
    GHWebCell *webCell = (GHWebCell *)[self.tableView cellForRowAtIndexPath:indexPath];

    if (!post)
        return nil;

    NSMutableArray *sharedItems = NSMutableArray.new;

    if (webCell.text)
        [sharedItems addObject:webCell.text];

    NSURL *url = [NSURL URLWithString:post.url];

    if (url)
        [sharedItems addObject:url];

    NSMutableSet *images = NSMutableSet.new;

    [images addObjectsFromArray:webCell.images.allObjects];

    for (GHAttachment *attachment in post.attachments)
    {
        NSURL *imageURL = [NSURL URLWithString:attachment.url];

        if (imageURL)
            [images addObject:imageURL];
    }

    for (NSURL *imageURL in images)
    {
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];

        if (image)
            [sharedItems addObject:image];
    }

    return sharedItems;
}
//------------------------------------------------------------------------------
- (void)onShare:(id)sender
{
    NSIndexPath *indexPath = [self indexPathFromMenuController:sender];
    NSArray *sharedItems = [self sharedItemsFromIndexPath:indexPath];

    if (!sharedItems.count)
        return;

    UIActivityViewController *shareController = [UIActivityViewController.alloc initWithActivityItems:sharedItems applicationActivities:nil];

    shareController.excludedActivityTypes = @[
                                                UIActivityTypePostToWeibo,
                                                UIActivityTypePrint,
                                                UIActivityTypeCopyToPasteboard,
                                                UIActivityTypeAssignToContact,
                                                UIActivityTypeSaveToCameraRoll,
                                                UIActivityTypeAddToReadingList,
                                                UIActivityTypePostToFlickr,
                                                UIActivityTypePostToVimeo,
                                                UIActivityTypePostToTencentWeibo,
                                                UIActivityTypeAirDrop
                                            ];
    shareController.completionHandler =
    ^(NSString *activityType, BOOL completed)
    {
        if (completed)
        {
            GHPost *post = [self.fetchedResultsController objectAtIndexPath:indexPath];

            TRACK(@"SHARE", post.url);
        }
    };

    [self presentViewController:shareController animated:YES completion:nil];
    [self resignFirstResponder];
}
//------------------------------------------------------------------------------
@end
//==============================================================================