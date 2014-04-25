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
#import "BAPaymentTransactionObserver.h"

@implementation BAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // [[SKPaymentQueue defaultQueue] addTransactionObserver:observer];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    UIViewController *controller = application.keyWindow.rootViewController;
    if([controller isKindOfClass:[BAViewController class]]) {
        [(BAViewController*)controller stopRefreshTimer];
    }
    [application setMinimumBackgroundFetchInterval:60.0];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    NSLogDebug(@"got a time slice!",nil);

    static NSDate *lastUpdate=nil;
    if(lastUpdate==nil) lastUpdate = [NSDate dateWithTimeIntervalSinceNow:-300.0];
    
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
                result = UIBackgroundFetchResultNewData;
                NSLogDebug(@"background update: %d",iLast);
            } else {
                result = UIBackgroundFetchResultFailed;
                NSLogDebug(@"background update: failed to convert to JSON",nil);
            }
        } else {
            result = UIBackgroundFetchResultFailed;
            NSLogDebug(@"background update: failed to fetch data",nil);
        }
    } else {
        result = UIBackgroundFetchResultNoData; // refuse the update
        NSLogDebug(@"background update: refused",nil);
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
    UIViewController *controller = application.keyWindow.rootViewController;
    if([controller isKindOfClass:[BAViewController class]]) {
        [(BAViewController*)controller startRefreshTimer];
    }
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
