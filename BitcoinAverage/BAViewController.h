//
//  BAViewController.h
//  BitcoinAverage
//
//  Created by Adam Dann on 2/13/2014.
//  Copyright (c) 2014 Nullriver. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import <iAd/iAd.h>

@interface BAViewController : UIViewController <UITextFieldDelegate, ADBannerViewDelegate, /*SKRequestDelegate,*/ SKProductsRequestDelegate, SKPaymentTransactionObserver>

- (void)startRefreshTimer;
- (void)stopRefreshTimer;

@end
