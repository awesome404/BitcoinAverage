//
//  BACurrency.h
//  ฿ Average
//
//  Created by Adam Dann on 2/23/2014.
//  Copyright (c) 2014 Nullriver. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BASettings : NSObject

+ (NSString*) getCurrency;
+ (NSString*) setCurrency:(NSString*)value;

@end