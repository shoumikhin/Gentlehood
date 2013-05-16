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
    #define IJLOG(...)
#endif
//==============================================================================
#import <objc/runtime.h>

#if __has_feature(objc_arc)
    #define SYNTHESIZE_SINGLETON_RETAIN_METHODS
#else
    #define SYNTHESIZE_SINGLETON_RETAIN_METHODS \
- (id)retain \
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
- (id)autorelease \
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
+ (id)allocWithZone:(NSZone *)zone \
{ \
    return [self accessorMethodName]; \
} \
\
- (id)copyWithZone:(NSZone *)zone \
{ \
    return self; \
} \
- (id)onlyInitOnce \
{ \
    return self;\
} \
\
SYNTHESIZE_SINGLETON_RETAIN_METHODS

#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname) SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(classname, shared)
//==============================================================================
