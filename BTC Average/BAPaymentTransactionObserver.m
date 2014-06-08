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

            case SKPaymentTransactionStatePurchased:
                NSLogDebug(@"SKPaymentTransactionStatePurchased",nil);
                [BASettings hideAds];
                break;
            case SKPaymentTransactionStateRestored:
                NSLogDebug(@"SKPaymentTransactionStateRestored",nil);
                [BASettings hideAds];
                break;
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
