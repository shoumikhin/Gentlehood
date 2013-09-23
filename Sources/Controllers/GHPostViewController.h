//
//  GHPostViewController.h
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-23-09.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GHContentViewController.h"

@interface GHPostViewController : GHContentViewController

- (void)bookmarkContentAtPoint:(CGPoint)point;
- (void)showMenuAtPoint:(CGPoint)point;

@end
