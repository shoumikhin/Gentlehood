//
//  GHWebCell.h
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-17-05.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GHWebCell;

@protocol GHWebCellDelegate <NSObject>

@optional
- (void)updateCell:(GHWebCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@interface GHWebCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) id <GHWebCellDelegate> delegate;
@property (nonatomic, copy) NSIndexPath *indexPath;

@end
