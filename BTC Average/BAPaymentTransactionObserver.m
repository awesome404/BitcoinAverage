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
    NSLogDebug(@"paymentQueue updatedTransactions",nil);
    
    for(SKPaymentTransaction *transaction in transactions) {
        
        if((transaction.transactionState == SKPaymentTransactionStatePurchased) ||
           (transaction.transactionState == SKPaymentTransactionStateRestored)) {
            [BASettings hideAds];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }

#ifndef NDEBUG
        switch(transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:  NSLogDebug(@"SKPaymentTransactionStatePurchased",nil);  break;
            case SKPaymentTransactionStateRestored:   NSLogDebug(@"SKPaymentTransactionStateRestored",nil);   break;
            case SKPaymentTransactionStatePurchasing: NSLogDebug(@"SKPaymentTransactionStatePurchasing",nil); break;
            case SKPaymentTransactionStateFailed:     NSLogDebug(@"SKPaymentTransactionStateFailed",nil);     break;
        }
#endif

    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads {
    NSLogDebug(@"paymentQueue updatedDownloads",nil);
}

@end
