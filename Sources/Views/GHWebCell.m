//
//  GHWebCell.m
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-17-05.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import "GHWebCell.h"

//==============================================================================
@interface GHWebCell () <UIWebViewDelegate>

@end
//==============================================================================
@implementation GHWebCell
//------------------------------------------------------------------------------
- (void)awakeFromNib
{
    [super awakeFromNib];

    self.webView.suppressesIncrementalRendering = YES;
    self.webView.scrollView.scrollEnabled = NO;
    self.webView.scrollView.minimumZoomScale = 1.0;
    self.webView.scrollView.maximumZoomScale = 1.0;
    self.webView.scrollView.zoomScale = 1.0;
    self.webView.delegate = self;
}
//------------------------------------------------------------------------------
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGSize viewSize = self.contentView.bounds.size;

    viewSize.height = webView.scrollView.contentSize.height;

    if ([self.delegate respondsToSelector:@selector(updateCell:atIndexPath:)])
        [self.delegate updateCell:self atIndexPath:self.indexPath];
}
//------------------------------------------------------------------------------
@end
//==============================================================================