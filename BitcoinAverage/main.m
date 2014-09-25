//
//  main.m
//  BitcoinAverage
//
//  Created by Adam Dann on 2/13/2014.
//  Copyright (c) 2014 Nullriver. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BAAppDelegate.h"

struct iOSVersionStruct iOSVersion = {7,0};

int main(int argc, char * argv[])
{
    @autoreleasepool {
        NSArray *parts = [[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."];
        iOSVersion._major = (int)[[NSString stringWithString:parts[0]] integerValue];
        iOSVersion._minor = (int)[[NSString stringWithString:parts[1]] integerValue];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([BAAppDelegate class]));
    }
}
