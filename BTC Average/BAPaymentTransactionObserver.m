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

        switch(transaction.transactionState) {
            case SKPaymentTransactionStateRestored:
                NSLogDebug(@"SKPaymentTransactionStateRestored",nil);
            case SKPaymentTransactionStatePurchased:
                NSLogDebug(@"SKPaymentTransactionStatePurchased",nil);
                [BASettings hideAds];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;

            case SKPaymentTransactionStatePurchasing:
                NSLogDebug(@"SKPaymentTransactionStatePurchasing",nil);
                // hide the button
                break;
            case SKPaymentTransactionStateFailed:
                NSLogDebug(@"SKPaymentTransactionStateFailed",nil);
                // show the button
                break;
        }

    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads {
    NSLogDebug(@"paymentQueue updatedDownloads",nil);
}

@end
