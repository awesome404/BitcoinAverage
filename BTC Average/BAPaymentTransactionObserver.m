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

/*
 - (void)viewWillAppear:(BOOL)animated {
 
 storeProducts = nil;
 NSURL *url = [[NSBundle mainBundle] URLForResource:@"InAppProductIDs" withExtension:@"plist"];
 NSArray *productIdentifiers = [NSArray arrayWithContentsOfURL:url];
 
 NSSet *productSet = [NSSet setWithArray:productIdentifiers];
 
 SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productSet];
 productsRequest.delegate = self;
 [productsRequest start];*/

/*- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
 storeProducts = response.products;
 }
 
 - (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
 NSLog(@"SKProductsRequest Failed !!\n%@\n%@",request,error);
 }*/

/*- (IBAction)donatePush:(UIButton *)sender {
 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Support ฿ Average"
 message:@"Please consider making a donatoin to support this project."
 delegate:self
 cancelButtonTitle:@"No Thanks"
 otherButtonTitles:nil];
 
 NSNumberFormatter *numberFormatter = nil;
 
 if(storeProducts!= nil) {
 for(SKProduct *product in storeProducts) {
 if(numberFormatter==nil) {
 numberFormatter = [[NSNumberFormatter alloc] init];
 [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
 [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
 [numberFormatter setLocale:product.priceLocale];
 }
 [alert addButtonWithTitle:[NSString stringWithFormat:@"%@ ~ %@",product.localizedTitle,[numberFormatter stringFromNumber:product.price]]];
 }
 } else {
 [alert addButtonWithTitle:@"QR Code"];
 }
 
 [alert show];
 }*/

/*NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
 NSRange range = {0,0};
 for(SKProduct *product in storeProducts) {
 range.length = [product.localizedTitle length];
 if([title compare:product.localizedTitle options:NSLiteralSearch range:range] == NSOrderedSame) {
 // go to store
 NSLogDebug(@"%@",product.localizedTitle);
 
 //SKProduct *product = <# Product returned by a products request #>;
 SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
 payment.quantity = 1;
 
 [[SKPaymentQueue defaultQueue] addPayment:payment];
 
 return; // out of for loop
 }
 }
 [self performSegueWithIdentifier:@"QRCode" sender:nil];*/