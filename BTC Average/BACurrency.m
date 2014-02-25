//
//  BACurrency.m
//  ฿ Average
//
//  Created by Adam Dann on 2/23/2014.
//  Copyright (c) 2014 Nullriver. All rights reserved.
//

#import "BACurrency.h"

@implementation BACurrency

// this is hidden from the interface
+ (NSString*)singleton:(NSString*)value {
    static NSString *currency = nil;
    static NSString *key = @"BTCAverageCurrency";

    if(value!=nil) {
        currency = value;
        [[NSUserDefaults standardUserDefaults] setObject:currency forKey:key];

    } else if(currency==nil)
        if((currency=[[NSUserDefaults standardUserDefaults] stringForKey:key])==nil)
            currency = @"USD";

    return currency;
}

+ (NSString*)get {
    return [self singleton:nil];
}

+ (NSString*)setTo:(NSString*)value {
    return [self singleton:value];
}

@end
