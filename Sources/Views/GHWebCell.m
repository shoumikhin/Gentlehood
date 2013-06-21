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

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIImageView *bookmarkedView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingActivityView;
@property (nonatomic, weak) IBOutlet UILabel *loadingLabel;
@property (nonatomic) BOOL isLoaded;
@property (nonatomic) BOOL hasValidSize;

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
    self.webView.alpha = 0.0;
    [self prepareForReuse];

    UIImage *image = [UIImage imageNamed:@"favorited"];

    self.bookmarkedView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height / 2, image.size.width / 2, image.size.height / 2, image.size.width / 2)];
    self.loadingLabel.text = NSLocalizedString(@"CELL_LOADING", nil);
    self.isLoaded = self.hasValidSize = NO;
}
//------------------------------------------------------------------------------
- (void)prepareForReuse
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.open();document.close();"];
    self.webView.alpha = self.bookmarkedView.alpha = 0.0;
    self.isLoaded = self.hasValidSize = NO;
}
//------------------------------------------------------------------------------
- (void)loadContent:(NSString *)content
{
    NSUInteger const kContentWidth = UIApplication.frame.size.width - 17.0;

    [self.webView loadHTMLString:[NSString.alloc initWithFormat:
    @"<html>\
        <head>\
            <meta name=\"viewport\" content=\"user-scalable=no, width=device-width, initial-scale=1.0, maximum-scale=1.0\"/>\
            <meta name=\"apple-mobile-web-app-capable\" content=\"yes\" />\
            <style type=\"text/css\">\
                p { max-width:%upx; font-family:\"%@\"; font-size:%f; text-align:center; }\
                img { max-width:%upx; height:auto; margin-left:auto; margin-right:auto; font-family:\"%@\"; font-size:%f; color:%@}\
            </style>\
        </head>\
        <body>%@</body>\
    </html>\
    ", kContentWidth, kFontFamily, kFontSize, kContentWidth, kFontFamilyItalic, kFontSizeSmall, kHTMLColorDefault, content] baseURL:[NSURL fileURLWithPath:NSBundle.mainBundle.bundlePath]];
}
//------------------------------------------------------------------------------
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.loadingActivityView.hidden = self.loadingLabel.hidden = NO;
}
//------------------------------------------------------------------------------
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.loadingActivityView.hidden = self.loadingLabel.hidden = YES;

    [webView stringByEvaluatingJavaScriptFromString:[NSString.alloc initWithFormat:
    @"\
        var images = document.getElementsByTagName('img');\
        \
        for (var i = 0; i < images.length; ++i)\
            images[i].alt = \"%@\";\
    ", NSLocalizedString(@"NO_IMAGE", nil)]];

    if (self.window)
    {
        CGRect frame = webView.frame;

        frame.size.height = kUITableViewCellHeightDefault;
        webView.frame = frame;

        CGSize fittingSize = [webView sizeThatFits:CGSizeZero];

        frame.size = fittingSize;
        webView.frame = frame;

        if ([self.delegate respondsToSelector:@selector(webCellHeight:forIndexPath:)])
            [self.delegate webCellHeight:webView.scrollView.contentSize.height forIndexPath:self.indexPath];

        [UIView animateWithDuration:UINavigationControllerHideShowBarDuration * 2 animations:^
        {
            webView.alpha = 1.0;
        }];

        self.hasValidSize = YES;
    }

    self.isLoaded = YES;
}
//------------------------------------------------------------------------------
- (void)didMoveToWindow
{
    if (!self.hasValidSize && self.isLoaded && self.window)
        [self loadContent:[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"]];
}
//------------------------------------------------------------------------------
- (void)setBookmarked:(BOOL)bookmarked
{
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^
    {
        self.bookmarkedView.alpha = bookmarked ? 1.0 : 0.0;
    }];
}
//------------------------------------------------------------------------------
- (BOOL)bookmarked
{
    return self.bookmarkedView.alpha;
}
//------------------------------------------------------------------------------
@end
//==============================================================================