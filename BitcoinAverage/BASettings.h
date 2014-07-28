//
//  BACurrency.h
//  BitcoinAverage
//
//  Created by Adam Dann on 2/23/2014.
//  Copyright (c) 2014 Nullriver. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BASettings : NSObject

+ (NSString*) getCurrency;
+ (NSString*) setCurrency:(NSString*)value;
+ (BOOL) shouldShowAds;
+ (void) hideAds;

#ifdef DEBUG
#warning Debug
+ (void) unhideAds;
#endif

@end
