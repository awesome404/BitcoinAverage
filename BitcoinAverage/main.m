//
//  main.m
//  BitcoinAverage
//
//  Created by Adam Dann on 2/13/2014.
//  Copyright (c) 2014 Nullriver. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BAAppDelegate.h"

double iOSVersion = 7;

int main(int argc, char * argv[])
{
    @autoreleasepool {
        iOSVersion = [[[UIDevice currentDevice] systemVersion] doubleValue];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([BAAppDelegate class]));
    }
}
