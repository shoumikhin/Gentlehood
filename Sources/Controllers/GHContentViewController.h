//
//  GHContentViewController.h
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-16-05.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GHContentViewController : UITableViewController

@property (nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) NSInteger category;
@property (nonatomic) NSPredicate *predicate;
@property (nonatomic) NSArray *sortDescriptors;
@property (nonatomic) NSUInteger postsPerPage;
@property (nonatomic) NSString *cellID;

@end
