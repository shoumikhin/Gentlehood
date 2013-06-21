//
//  GHCategory.m
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-17-06.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import "GHCategory.h"
#import "GHPost.h"

//==============================================================================
@implementation GHCategory
//------------------------------------------------------------------------------
@dynamic identifier;
@dynamic postCount;
@dynamic posts;
//------------------------------------------------------------------------------
+ (RKEntityMapping *)mapping
{
    static RKEntityMapping *mapping;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass(self.class) inManagedObjectStore:RKManagedObjectStore.defaultStore];
        [mapping addAttributeMappingsFromDictionary:@{@"id":@"identifier", @"post_count":@"postCount"}];
        mapping.identificationAttributes = @[@"identifier"];
    });

    return mapping;
}
//------------------------------------------------------------------------------
@end
//==============================================================================
