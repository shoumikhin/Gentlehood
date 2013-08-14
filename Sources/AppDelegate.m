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

    return YES;
}
//------------------------------------------------------------------------------
- (void)setupRestKit
{
    RKLogConfigureFromEnvironment();

    RKObjectManager.sharedManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:kGHAPI]];
    RKObjectManager.sharedManager.managedObjectStore = [RKManagedObjectStore.alloc initWithManagedObjectModel:[NSManagedObjectModel mergedModelFromBundles:nil]];
    [RKObjectManager.sharedManager.managedObjectStore addSQLitePersistentStoreAtPath:[NSFileManager.cachesPath stringByAppendingPathComponent:kStorageFilename] fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:nil];
    [RKObjectManager.sharedManager.managedObjectStore createManagedObjectContexts];
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
@end
//==============================================================================