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
    application.statusBarStyle = UIStatusBarStyleBlackTranslucent;

    [self setupRestKit];
    [self setupPonyDebugger];
    [self deleteObsoleteContent];

    return YES;
}
//------------------------------------------------------------------------------
- (void)setupPonyDebugger
{
#if DEBUG
    PDDebugger *debugger = PDDebugger.defaultInstance;

    [debugger enableNetworkTrafficDebugging];
    [debugger forwardAllNetworkTraffic];

    [debugger enableCoreDataDebugging];
    [debugger addManagedObjectContext:RKManagedObjectStore.defaultStore.mainQueueManagedObjectContext withName:@"main"];
    
    [debugger enableViewHierarchyDebugging];

    [debugger connectToURL:[NSURL URLWithString:@"ws://localhost:9000/device"]];
#endif
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