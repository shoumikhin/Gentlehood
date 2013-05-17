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
    self.webView.suppressesIncrementalRendering = YES;
    self.webView.scrollView.scrollEnabled = NO;
    self.webView.delegate = self;
}
//------------------------------------------------------------------------------
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGSize contentSize = webView.scrollView.contentSize;
    CGSize viewSize = self.contentView.bounds.size;

    float factor = viewSize.width / contentSize.width;

    webView.scrollView.minimumZoomScale = factor;
    webView.scrollView.maximumZoomScale = factor;
    webView.scrollView.zoomScale = factor;
    viewSize.height = contentSize.height * factor;
    webView.scrollView.contentSize = viewSize;

    if ([self.delegate respondsToSelector:@selector(updateCell:atIndexPath:)])
        [self.delegate updateCell:self atIndexPath:self.indexPath];
}
//------------------------------------------------------------------------------
@end
//==============================================================================