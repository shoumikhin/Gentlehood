//
//  AppDelegate.m
//  Gentlehood
//
//  Created by Anthony Shoumikhin on 2013-15-05.
//  Copyright (c) 2013 Anthony Shoumikhin. All rights reserved.
//

#import "AppDelegate.h"

//==============================================================================
@implementation AppDelegate
//------------------------------------------------------------------------------
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight takeOff:@"8479d244-c81d-43bf-bb75-a08850177b38"];

    return YES;
}
//------------------------------------------------------------------------------
@end
//==============================================================================