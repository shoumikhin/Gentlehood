//==============================================================================
FOUNDATION_EXPORT NSString * const kStorageFilename;
FOUNDATION_EXPORT NSString * const kGHAPI;
FOUNDATION_EXPORT NSString * const kGHAPIGetCategory;
FOUNDATION_EXPORT NSString * const kGHWebCellID;
FOUNDATION_EXPORT NSString * const kFetchCacheName;
FOUNDATION_EXPORT CGFloat const kUITableViewCellHeightDefault;
FOUNDATION_EXPORT CGFloat const kUINavigationBarTranslucentAlphaDefault;
FOUNDATION_EXPORT NSString * const kFontFamily;
FOUNDATION_EXPORT NSString * const kFontFamilyItalic;
FOUNDATION_EXPORT CGFloat const kFontSize;
FOUNDATION_EXPORT CGFloat const kFontSizeSmall;
FOUNDATION_EXPORT NSString * const kHTMLColorDefault;

typedef NS_ENUM(NSInteger, GHPostCategory)
{
    GHPostAny = -1,
    GHPostThought = 57,
    GHPostStyle = 58,
    GHPostVocabulary = 59,
    GHPostAphorism = 60
};
//==============================================================================
#define QUOTE(__text__) #__text__
#define TODO(__text__) _Pragma(QUOTE(message("TODO: "__text__)))
#define FIXME(__text__) _Pragma(QUOTE(message("FIXME: "__text__)))
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
#import <objc/runtime.h>

#if __has_feature(objc_arc)
    #define SYNTHESIZE_SINGLETON_RETAIN_METHODS
#else
    #define SYNTHESIZE_SINGLETON_RETAIN_METHODS \
- (instancetype)retain \
{ \
    return self; \
} \
\
- (NSUInteger)retainCount \
{ \
    return NSUIntegerMax; \
} \
\
- (oneway void)release {} \
\
- (instancetype)autorelease \
{ \
    return self; \
}
#endif

#define SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(classname, accessorMethodName) \
\
static classname *accessorMethodName##Instance = nil; \
\
+ (classname *)accessorMethodName \
{ \
@synchronized(self) \
{ \
    if (accessorMethodName##Instance == nil) \
    { \
    accessorMethodName##Instance = [super allocWithZone:NULL]; \
    accessorMethodName##Instance = [accessorMethodName##Instance init]; \
    } \
} \
\
return accessorMethodName##Instance; \
} \
\
+ (classname *)lockless_##accessorMethodName \
{ \
    return accessorMethodName##Instance; \
} \
\
+ (instancetype)allocWithZone:(NSZone *)zone \
{ \
    return [self accessorMethodName]; \
} \
\
- (instancetype)copyWithZone:(NSZone *)zone \
{ \
    return self; \
} \
- (instancetype)onlyInitOnce \
{ \
    return self;\
} \
\
SYNTHESIZE_SINGLETON_RETAIN_METHODS

#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname) SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(classname, shared)
//==============================================================================
#define SHOW_ALERT(__title__, __message__, __delegate__, __cancel__, __other__) \
do \
{ \
    [[[UIAlertView alloc] initWithTitle:__title__ message:__message__ delegate:__delegate__ cancelButtonTitle:__cancel__ otherButtonTitles:__other__, nil] show]; \
} \
while(0)
//==============================================================================
FIXME("Type some real API keys below")
#define COUNTLY_API_KEY "COUNTLY_API_KEY"
#define FLURRY_API_KEY "FLURRY_API_KEY"
#define GA_API_KEY "GA_API_KEY"
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