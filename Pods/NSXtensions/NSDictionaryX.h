//
//  NSDictionaryX.h
//
//  Copyright (c) 2012 Anthony Shoumikhin. All rights reserved under MIT license.
//  mailto:anthony@shoumikh.in
//

#import <Foundation/Foundation.h>

@interface NSDictionary (X)

/**
 Merge two dictionaries.
 
 @param first One dictionary.
 @param second Another dictionary.
 @return A dictionary with merged contents of two dictionaries.
 */
+ (NSDictionary *)dictionaryByMerging:(NSDictionary *)first with:(NSDictionary *)second;

/**
 Merge another dictionary.
 
 @param second A dictionary to merge with.
 @return A dictionary with merged contents of the receiver and the argument.
 */
- (NSDictionary *)dictionaryByMergingWith:(NSDictionary *)other;

@end
