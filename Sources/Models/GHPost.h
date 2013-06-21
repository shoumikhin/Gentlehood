//
//  GHPost.h
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-03-06.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GHCategory;

@interface GHPost : NSManagedObject

@property (nonatomic, retain) NSNumber *identifier;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSNumber *height;
@property (nonatomic) BOOL favorite;
@property (nonatomic, retain) NSSet *categories;

+ (RKEntityMapping *)mapping;

@end

@interface GHPost (CoreDataGeneratedAccessors)

- (void)addPostsObject:(GHCategory *)value;
- (void)removePostsObject:(GHCategory *)value;
- (void)addPosts:(NSSet *)values;
- (void)removePosts:(NSSet *)values;

@end