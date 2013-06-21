//
//  GHCategory.h
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-17-06.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GHPost;

@interface GHCategory : NSManagedObject

@property (nonatomic, retain) NSNumber *identifier;
@property (nonatomic, retain) NSNumber *postCount;
@property (nonatomic, retain) NSSet *posts;

+ (RKEntityMapping *)mapping;

@end

@interface GHCategory (CoreDataGeneratedAccessors)

- (void)addPostsObject:(GHPost *)value;
- (void)removePostsObject:(GHPost *)value;
- (void)addPosts:(NSSet *)values;
- (void)removePosts:(NSSet *)values;

@end
