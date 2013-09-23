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
        [SVProgressHUD dismiss];
    }
}
//------------------------------------------------------------------------------
- (void)showMenuAtPoint:(CGPoint)point
{
    GHWebCell *webCell = [self cellAtPoint:point];

    if (!webCell)
        return;

    GHPost *post = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:webCell]];

    point = [self.tabBarController.view convertPoint:point toView:self.tableView];
    [self becomeFirstResponder];
    UIMenuController.sharedMenuController.menuItems = @[[UIMenuItem.alloc initWithTitle:NSLocalizedString(@"OPEN_POST", nil) action:@selector(onOpenURL:)], [UIMenuItem.alloc initWithTitle:post.url action:@selector(_onOpenURL:)]];
    [UIMenuController.sharedMenuController setTargetRect:CGRectMake(point.x, point.y, 0.0, 0.0) inView:self.view];
    [UIMenuController.sharedMenuController setMenuVisible:YES animated:YES];
}
//------------------------------------------------------------------------------
- (void)onOpenURL:(id)sender
{
    for (UIMenuItem *menuItem in [sender menuItems])
        if (@selector(_onOpenURL:) == menuItem.action)
        {
            [UIApplication openURL:[NSURL URLWithString:menuItem.title] andShowReturn:YES];

            TRACK(@"OPEN", menuItem.title);

            break;
        }

    [self resignFirstResponder];
}
//------------------------------------------------------------------------------
- (BOOL)canBecomeFirstResponder
{
    return YES;
}
//------------------------------------------------------------------------------
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (@selector(onOpenURL:) == action)
        return YES;
    
    return NO;
}
//------------------------------------------------------------------------------
@end
//==============================================================================