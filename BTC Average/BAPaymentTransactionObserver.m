//
//  BAPaymentTransactionObserver.m
//  ฿ Average
//
//  Created by Adam Dann on 2014-04-20.
//  Copyright (c) 2014 Nullriver. All rights reserved.
//

#import "BAPaymentTransactionObserver.h"
#import "BASettings.h"

@implementation BAPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    
    for(SKPaymentTransaction *transaction in transactions) {
        switch(transaction.transactionState) {
#ifdef NDEBUG
            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateRestored:
                [BASettings hideAds];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
#else
            case SKPaymentTransactionStatePurchased:
                NSLogDebug(@"SKPaymentTransactionStatePurchased",nil);
                [BASettings hideAds];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                NSLogDebug(@"SKPaymentTransactionStateRestored",nil);
                [BASettings hideAds];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
#endif
            case SKPaymentTransactionStatePurchasing:
            case SKPaymentTransactionStateFailed:
            default:
                break;
        }
    }
    
    NSLogDebug(@"paymentQueue updatedTransactions",nil);
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads {
    NSLogDebug(@"paymentQueue updatedDownloads",nil);
}

@end
