//
//  GHWebCell.m
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-17-05.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import "GHWebCell.h"

//==============================================================================
#define REGEX_SKIP_TAG(tag) \
    "<" tag ">[\\S\\s]*?<\\/" tag ">(?!)"

#define REGEX_MATCH_ATTRIBUTE_VALUE(attr) \
    attr "\\s*?=\\s*?['\"]([^'\">]*)"

#define REGEX_MATCH_TAG_ATTRIBUTE_VALUE(tag, attr) \
    "<" tag "[^>]+?" REGEX_MATCH_ATTRIBUTE_VALUE(attr) "['\"][^>]*?>"

#define REGEX_MATCH_TAG_ATTRIBUTE_VALUE_2(tag, attr, attr2) \
    "(?=" REGEX_MATCH_TAG_ATTRIBUTE_VALUE(tag, attr) ")(?=" REGEX_MATCH_TAG_ATTRIBUTE_VALUE(tag, attr2) ")"

#define REGEX_MATCH_IMG_ATTRIBUTE_VALUE(attr) \
    REGEX_SKIP_TAG("noscript") "|" REGEX_MATCH_TAG_ATTRIBUTE_VALUE("img", attr)

#define REGEX_MATCH_IMG_ATTRIBUTE_VALUE_2(attr, attr2) \
    REGEX_SKIP_TAG("noscript") "|" REGEX_MATCH_TAG_ATTRIBUTE_VALUE_2("img", attr, attr2)
//==============================================================================
@interface GHWebCell () <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIImageView *bookmarkedView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingActivityView;
@property (nonatomic, weak) IBOutlet UILabel *loadingLabel;
@property (nonatomic) BOOL isLoaded;
@property (nonatomic) BOOL hasValidSize;
@property (nonatomic) NSString *text;
@property (nonatomic) NSMutableSet *images;

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
- (NSString *)text
{
    if (_text)
        return _text;

    _text = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerText"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];

    if (!_text.length)
        _text = nil;

    return _text;
}
//------------------------------------------------------------------------------
- (NSSet *)images
{
    if (_images)
        return _images;

    NSMutableSet __block *images = NSMutableSet.new;
    NSString *content = [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];

    [[NSRegularExpression regularExpressionWithPattern:@REGEX_MATCH_IMG_ATTRIBUTE_VALUE("src") options:0 error:nil] enumerateMatchesInString:content options:0 range:NSMakeRange(0, content.length) usingBlock:
     ^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
     {
         if (2 != result.numberOfRanges)
             return;

         NSURL *src = [NSURL URLWithString:[content substringWithRange:[result rangeAtIndex:1]]];

         if (src)
             [images addObject:src];
     }];

    if (images.count)
        _images = images;

    return _images;
}
//------------------------------------------------------------------------------
- (void)loadContent:(NSString *)content
{
    unsigned const kContentWidth = UIApplication.frame.size.width - 17.0;

    [self.webView loadHTMLString:[NSString.alloc initWithFormat:
    @"<html>\
        <head>\
            <meta name=\"viewport\" content=\"user-scalable=no, width=device-width, initial-scale=1.0, maximum-scale=1.0\"/>\
            <meta name=\"apple-mobile-web-app-capable\" content=\"yes\" />\
            <style type=\"text/css\">\
                p { max-width:%upx; font-family:\"%@\"; font-size:%f; text-align:center; }\
                img { max-width:%upx; height:auto; margin-left:auto; margin-right:auto; padding-bottom:5px; font-family:\"%@\"; font-size:%f; color:%@}\
            </style>\
        </head>\
        <body>%@<hr/></body>\
    </html>",
        kContentWidth,
        kFontFamily,
        kFontSize,
        kContentWidth,
        kFontFamilyItalic,
        kFontSizeSmall,
        kHTMLColorDefault,
        [self filterContent:content]]
    baseURL:[NSURL fileURLWithPath:NSFileManager.cachesPath]];
}
//------------------------------------------------------------------------------
- (NSString *)filterContent:(NSString *)content
{
    NSMutableString __block *filteredContent = content.mutableCopy;

    [[NSRegularExpression regularExpressionWithPattern:@REGEX_MATCH_IMG_ATTRIBUTE_VALUE_2("src", "data-lazy-original") options:0 error:nil] enumerateMatchesInString:content options:0 range:NSMakeRange(0, content.length) usingBlock:
    ^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
    {
        if (3 != result.numberOfRanges)
            return;

        NSString *src = [content substringWithRange:[result rangeAtIndex:1]];
        NSString *dataLazyOriginal = [content substringWithRange:[result rangeAtIndex:2]];

        if (dataLazyOriginal.length > 0 && [src hasPrefix:@"data"])
        {
            [filteredContent replaceCharactersInRange:[result rangeAtIndex:1] withString:dataLazyOriginal];
            [filteredContent replaceCharactersInRange:[result rangeAtIndex:2] withString:src];
        }
    }];

    return filteredContent;
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
        var images = document.getElementsByTagName('img'); \
      \
        for (var i = 0; i < images.length; ++i) \
        { \
            images[i].alt = \"%@\"; \
        } \
      \
        var divsToHide = document.getElementsByClassName('ratingtext'); \
      \
        for(var i = 0; i < divsToHide.length; ++i) \
        { \
            divsToHide[i].style.display = 'none'; \
        } \
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