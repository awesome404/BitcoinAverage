//
//  BAAppDelegate.m
//  BTC Average
//
//  Created by Adam Dann on 2/13/2014.
//  Copyright (c) 2014 Nullriver. All rights reserved.
//

#import "BACurrency.h"
#import "BAAppDelegate.h"
#import "BAViewController.h"

@implementation BAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    if([controller isKindOfClass:[BAViewController class]]) {
        [(BAViewController*)controller stopRefreshTimer];
    }
}
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {

    static NSDate *lastUpdate=nil;
    if(lastUpdate==nil) lastUpdate = [NSDate date];

#ifndef NDEBUG
    NSLog(@"got a time slice!");
#endif
    
    UIBackgroundFetchResult result = UIBackgroundFetchResultFailed;

    if([lastUpdate timeIntervalSinceNow] < -60.0) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.bitcoinaverage.com/ticker/global/%@",[BACurrency get]]];
        NSData *urlData;

        if((urlData = [NSData dataWithContentsOfURL:url])!=nil) {
            NSDictionary *data = [NSJSONSerialization JSONObjectWithData:urlData options:0 error:NULL];
            if(data) {
                // Change the badge icon devided down to under 10000
                unsigned int iLast = (unsigned int)([[data valueForKey:@"last"] doubleValue]+0.5);
                while(iLast>=10000) iLast/=10;
                application.applicationIconBadgeNumber = iLast;
                lastUpdate = [NSDate date];
    #ifndef NDEBUG
                NSLog(@"background update: %d",iLast);
    #endif
                result = UIBackgroundFetchResultNewData;

            } else result = UIBackgroundFetchResultFailed;
        } else result = UIBackgroundFetchResultFailed;
    } else { result = UIBackgroundFetchResultNoData; // refuse the update
#ifndef NDEBUG
        NSLog(@"background update: refused");
#endif
    }
    completionHandler(result);
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    if([controller isKindOfClass:[BAViewController class]]) {
        [(BAViewController*)controller startRefreshTimer];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
