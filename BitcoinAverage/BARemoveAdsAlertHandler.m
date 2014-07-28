//
//  BARemoveAdsAlertHandler.m
//  BitcoinAverage
//
//  Created by Adam Dann on 2014-06-02.
//  Copyright (c) 2014 Nullriver. All rights reserved.
//

#import "BARemoveAdsAlertHandler.h"

@interface BARemoveAdsAlertHandler() {
    SKProduct *_product;
}

@end

@implementation BARemoveAdsAlertHandler

- (void)showAlert:(SKProduct *)product {
    _product = product;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:_product.priceLocale];
    
    NSString *message = [NSString stringWithFormat:@"Would you like to remove the ads from ฿ Average for %@?",[numberFormatter stringFromNumber:_product.price]];
    
    [[[UIAlertView alloc] initWithTitle:_product.localizedTitle
                                message:message
                               delegate:self
                      cancelButtonTitle:@"No, Thanks"
                      otherButtonTitles:@"Yes, Please",@"Restore Purchase",nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex!=[alertView cancelButtonIndex]) {
        if(buttonIndex == 1) {
            SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:_product];
            payment.quantity = 1;
            [[SKPaymentQueue defaultQueue] addPayment:payment];
            NSLogDebug(@"Purchased \"%@\"",_product.localizedTitle);
        } else if(buttonIndex==2) {
            [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
            NSLogDebug(@"Restore",nil);
        }
    }
    _product = nil;
}

@end
