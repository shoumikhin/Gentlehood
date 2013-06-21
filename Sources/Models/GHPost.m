//
//  GHPost.m
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-03-06.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import "GHPost.h"

#import "GHCategory.h"

//==============================================================================
@implementation GHPost
//------------------------------------------------------------------------------
@dynamic identifier;
@dynamic content;
@dynamic date;
@dynamic height;
@dynamic favorite;
@dynamic categories;
//------------------------------------------------------------------------------
+ (RKEntityMapping *)mapping
{
    static RKEntityMapping *mapping;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass(self.class) inManagedObjectStore:RKManagedObjectStore.defaultStore];
        [mapping addAttributeMappingsFromArray:@[@"content", @"date"]];
        [mapping addAttributeMappingsFromDictionary:@{@"id":@"identifier"}];
        [mapping addRelationshipMappingWithSourceKeyPath:@"categories" mapping:GHCategory.mapping];
        mapping.identificationAttributes = @[@"identifier"];
    });

    return mapping;
}
//------------------------------------------------------------------------------
@end
//==============================================================================
