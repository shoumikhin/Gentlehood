//
//  AppDelegate.m
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-15-05.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import "AppDelegate.h"

#import "GHPost.h"

//==============================================================================
@implementation AppDelegate
//------------------------------------------------------------------------------
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupRestKit];
    [self deleteObsoleteContent];

    return YES;
}
//------------------------------------------------------------------------------
- (void)setupRestKit
{
    RKLogConfigureFromEnvironment();

    RKObjectManager.sharedManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:kGHAPI]];
    RKObjectManager.sharedManager.managedObjectStore = [RKManagedObjectStore.alloc initWithManagedObjectModel:[NSManagedObjectModel mergedModelFromBundles:nil]];
    [RKObjectManager.sharedManager.managedObjectStore addSQLitePersistentStoreAtPath:[NSFileManager.documentsPath stringByAppendingPathComponent:kStorageFilename] fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:nil];
    [RKObjectManager.sharedManager.managedObjectStore createManagedObjectContexts];
}
//------------------------------------------------------------------------------
- (void)deleteObsoleteContent
{
    [RKManagedObjectStore.defaultStore.mainQueueManagedObjectContext deleteObjectsOfEntity:NSStringFromClass(GHPost.class) withPredicate:[NSPredicate predicateWithFormat:@"(date == NIL || date < %@) && favorite != YES", [NSDate dateWithTimeIntervalSinceNow:-30 * 24 * 60 * 60]] sortDescriptors:nil andFetchLimit:0];
    [RKManagedObjectStore.defaultStore.mainQueueManagedObjectContext saveToPersistentStore:nil];
}
//------------------------------------------------------------------------------
@end
//==============================================================================