//==============================================================================
FOUNDATION_EXPORT NSString * const kStorageFilename;
FOUNDATION_EXPORT NSString * const kGHAPI;
FOUNDATION_EXPORT NSString * const kGHAPIGetCategory;
FOUNDATION_EXPORT NSUInteger const kGHPostsPerPageDefault;
FOUNDATION_EXPORT NSString * const kGHWebCellID;
FOUNDATION_EXPORT NSString * const kGHVocabularyCellID;
FOUNDATION_EXPORT NSString * const kGHVocabularyDefineSegue;
FOUNDATION_EXPORT NSString * const kFetchCacheName;
FOUNDATION_EXPORT NSString * const kImageCacheDirectory;
FOUNDATION_EXPORT CGFloat const kUITableViewCellHeightDefault;
FOUNDATION_EXPORT NSString * const kFontFamily;
FOUNDATION_EXPORT NSString * const kFontFamilyItalic;
FOUNDATION_EXPORT CGFloat const kFontSize;
FOUNDATION_EXPORT CGFloat const kFontSizeSmall;
FOUNDATION_EXPORT NSString * const kHTMLColorDefault;
FOUNDATION_EXPORT NSString * const kGHOptionAutoHidePanels;
FOUNDATION_EXPORT NSString * const kGHOptionInterfaceRotation;

typedef NS_ENUM(NSInteger, GHPostCategory)
{
    GHPostAny = -1,
    GHPostThought = 57,
    GHPostStyle = 58,
    GHPostVocabulary = 59,
    GHPostAphorism = 60
};
//==============================================================================
#ifndef __OPTIMIZE__
    #define LOG(...) \
do \
{ \
    NSLog(@"%@", [NSString stringWithFormat:@"Log: %@", [NSString stringWithFormat:__VA_ARGS__]]); \
} \
while (0)
#else
    #define LOG(...)
#endif
//==============================================================================
//FIXME: "Type some real API keys below"
#define COUNTLY_API_KEY "COUNTLY_API_KEY"
#define GA_API_KEY "GA_API_KEY"
#define FLURRY_API_KEY "FLURRY_API_KEY"
//==============================================================================
#define TRACK(__verb__, __noun__) \
do \
{ \
    [Countly.sharedInstance recordEvent:[NSString stringWithFormat:@"%@ -> %@", __verb__, __noun__] count:1]; \
    [Flurry logEvent:[NSString stringWithFormat:@"%@ -> %@", __verb__, __noun__]]; \
    [GAI.sharedInstance.defaultTracker send:[[GAIDictionaryBuilder createEventWithCategory:__verb__ action:__noun__ label:nil value:nil] build]]; \
} \
while (0)
//==============================================================================