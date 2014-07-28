//
//  BARemoveAdsAlertHandler.h
//  ฿ Average
//
//  Created by Adam Dann on 2014-06-02.
//  Copyright (c) 2014 Nullriver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface BARemoveAdsAlertHandler : NSObject <UIAlertViewDelegate>

- (void)showAlert:(SKProduct *)product;

@end
