//
//  BACurrency.m
//  BitcoinAverage
//
//  Created by Adam Dann on 2/23/2014.
//  Copyright (c) 2014 Nullriver. All rights reserved.
//

#import "BASettings.h"

#define CURRENCY_KEY @"BTCAverageCurrency"
#define SHOWADS_KEY @"BTCAverageShowAds"

@interface BASettings ()

+ (NSString*)internalCurrency:(NSString*)value;
+ (BOOL)internalShowAds:(BOOL)hide;

@end

@implementation BASettings

// this is hidden from the interface
+ (NSString*)internalCurrency:(NSString*)value {
    static NSString *currency = nil;

    if(value!=nil) {
        currency = value;
        [[NSUserDefaults standardUserDefaults] setObject:currency forKey:CURRENCY_KEY];

    } else if(currency==nil) {
        if((currency = [[NSUserDefaults standardUserDefaults] stringForKey:CURRENCY_KEY]) == nil) {
            currency = @"USD"; // this should only happen once
            [[NSUserDefaults standardUserDefaults] setObject:currency forKey:CURRENCY_KEY]; // (once)
        }
    }

    return currency;
}

+ (NSString*)getCurrency {
    return [self internalCurrency:nil];
}

+ (NSString*)setCurrency:(NSString*)value {
    return [self internalCurrency:value];
}

+ (BOOL)internalShowAds:(BOOL)hide {
    static NSNumber *showAds = nil;
    
    if(hide) {
        showAds = [NSNumber numberWithBool:NO];
        [[NSUserDefaults standardUserDefaults] setObject:showAds forKey:SHOWADS_KEY];
        
    } else
#ifdef DEBUG
#warning Debug
#else
    if(showAds==nil) // in release don't force a reload from user defaults
#endif
    {
        if((showAds = [[NSUserDefaults standardUserDefaults] objectForKey:SHOWADS_KEY]) == nil) {
            showAds = [NSNumber numberWithBool:YES]; // this should only happen once
            [[NSUserDefaults standardUserDefaults] setObject:showAds forKey:SHOWADS_KEY]; // (once)
        }
    }
    
    return [showAds boolValue];
}

+ (BOOL)shouldShowAds {
    return [self internalShowAds:0];
}

+ (void)hideAds {
    [self internalShowAds:YES];
}

#ifndef NDEBUG
+ (void)unhideAds {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:YES] forKey:SHOWADS_KEY];
    [defaults synchronize];
    [self internalShowAds:0]; // force a reload from user defaults
}
#endif

@end
