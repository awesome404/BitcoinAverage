//
//  BAPaymentTransactionObserver.m
//  ฿ Average
//
//  Created by Adam Dann on 2014-04-20.
//  Copyright (c) 2014 Nullriver. All rights reserved.
//

#import "BAPaymentTransactionObserver.h"

@implementation BAPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    
    for(SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
                // Call the appropriate custom method.
            case SKPaymentTransactionStatePurchased:
                //[self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                //[self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                //[self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads {
    
}

@end
