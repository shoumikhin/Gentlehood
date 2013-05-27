//
//  GHWebCell.m
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-17-05.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import "GHWebCell.h"

//==============================================================================
static NSString * const kFontFamily = @"Georgia";
static CGFloat const kFontSize = 20.0;
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
- (void)loadContent:(NSString *)content
{
    NSUInteger const kContentWidth = UIApplication.frame.size.width - 15.0;

    [self.webView loadHTMLString:[NSString.alloc initWithFormat:@"<html><head><meta name=\"viewport\" content=\"user-scalable=no, width=device-width, initial-scale=1.0, maximum-scale=1.0\"/><meta name=\"apple-mobile-web-app-capable\" content=\"yes\" /><style type=\"text/css\">p { max-width:%upx; font-family: \"%@\"; font-size: %f; text-align:center; } img {max-width:%upx; height:auto; margin-left:auto; margin-right:auto; }</style></head><body>%@</body></html>", kContentWidth, kFontFamily, kFontSize, kContentWidth, content] baseURL:nil];
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