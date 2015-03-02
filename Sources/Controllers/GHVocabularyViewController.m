//
//  GHVocabularyViewController.m
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-10-09.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import "GHVocabularyViewController.h"

#import "GHVocabularyDefinitionViewController.h"

//==============================================================================
@implementation GHVocabularyViewController
//------------------------------------------------------------------------------
- (void)awakeFromNib
{
    [super awakeFromNib];

    self.category = GHPostVocabulary;
    self.predicate = [NSPredicate predicateWithFormat:@"ANY categories.identifier == %i", self.category];
    self.sortDescriptors = @[[NSSortDescriptor.alloc initWithKey:@"title" ascending:YES]];
    self.postsPerPage = 10 * kGHPostsPerPageDefault;
    self.cellID = kGHVocabularyCellID;
}
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", [UIDevice systemVersionIsAtLeast:@"7.0"] ? @"" : @"6_", NSLocalizedString(@"VOCABULARY_TITLE", nil)]];

    if (image)
        self.navigationItem.titleView = [UIImageView.alloc initWithImage:image];

    self.tableView.tableFooterView = UIView.new;
    self.tableView.sectionIndexBackgroundColor = UIColor.clearColor;
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
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    GHPost *post = [self.fetchedResultsController objectAtIndexPath:indexPath];

    cell.textLabel.text = post.title.uppercaseString;
    cell.textLabel.textColor = [UIColor colorWithHTMLColor:kHTMLColorDefault];
}
//------------------------------------------------------------------------------
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *alphabet = NSMutableArray.new;

    for (GHPost *post in self.fetchedResultsController.fetchedObjects)
        if (![alphabet containsObject:[post.title substringToIndex:1]])
            [alphabet addObject:[post.title substringToIndex:1]];

    return alphabet;
}
//------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSInteger row = 0;

    for (GHPost *post in self.fetchedResultsController.fetchedObjects)
    {
        if ([post.title hasPrefix:title])
        {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];

            break;
        }

        row++;
    }

    return row;
}
//------------------------------------------------------------------------------
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kGHVocabularyDefineSegue])
    {
        GHPost *post = (GHPost *)[self.fetchedResultsController objectAtIndexPath:self.tableView.indexPathForSelectedRow];

        ((GHVocabularyDefinitionViewController *)segue.destinationViewController).predicate = [NSPredicate predicateWithFormat:@"ANY categories.identifier == %i AND title == %@", self.category, post.title];

        TRACK(@"DEFINE", post.title);
    }
}
//------------------------------------------------------------------------------
@end
//==============================================================================
