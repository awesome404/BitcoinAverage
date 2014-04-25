//
//  BAViewController.m
//  BTC Average
//
//  Created by Adam Dann on 2/13/2014.
//  Copyright (c) 2014 Nullriver. All rights reserved.
//

#import "BAViewController.h"
#import "BACurrency.h"

@interface BAViewController () {
    NSTimer *refreshTimer;
    double last;
    BOOL isShowingLandscapeView;
    //NSArray *storeProducts;
}

- (void)refreshData;
- (NSString*)reformatTimestamp:(NSString*)stamp;
- (void)orientationChanged:(NSNotification *)notification;

@property (weak, nonatomic) IBOutlet UIButton *currencyButton;
@property (weak, nonatomic) IBOutlet UIButton *smallCurrencyButton;

@property (weak, nonatomic) IBOutlet UILabel *lastLabel;
@property (weak, nonatomic) IBOutlet UILabel *bidLabel;
@property (weak, nonatomic) IBOutlet UILabel *askLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UITextField *currencyEdit;
@property (weak, nonatomic) IBOutlet UITextField *bitcoinEdit;

//- (IBAction)donatePush:(UIButton *)sender;
- (IBAction)infoPush:(UIButton *)sender;
- (IBAction)downSwipe:(UISwipeGestureRecognizer *)sender;
- (IBAction)tapAction:(UITapGestureRecognizer *)sender;

@end

@implementation BAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    isShowingLandscapeView = NO;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    // trivial value to start with
    self.lastUpdate = [NSDate dateWithTimeIntervalSinceNow:-300.0];
}

- (void)viewWillAppear:(BOOL)animated {

    /*storeProducts = nil;
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"InAppProductIDs" withExtension:@"plist"];
    NSArray *productIdentifiers = [NSArray arrayWithContentsOfURL:url];
    
    NSSet *productSet = [NSSet setWithArray:productIdentifiers];
    
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productSet];
    productsRequest.delegate = self;
    [productsRequest start];*/
    
    
    [self refreshData];
}

#pragma mark Rotation

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)orientationChanged:(NSNotification *)notification {
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (!isShowingLandscapeView && UIDeviceOrientationIsLandscape(deviceOrientation) && self.presentedViewController==nil) {
        [self performSegueWithIdentifier:@"Graph" sender:self];
        isShowingLandscapeView = YES;
    } else if(isShowingLandscapeView && UIDeviceOrientationIsPortrait(deviceOrientation)) {
        [self dismissViewControllerAnimated:YES completion:nil];
        isShowingLandscapeView = NO;
    }
}

#pragma mark Timer

- (void)startRefreshTimer {
    [self refreshData];
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(timerFireRefresh:) userInfo:nil repeats:YES];
}

- (void)stopRefreshTimer {
    [refreshTimer invalidate];
    refreshTimer=nil;
}

- (void)timerFireRefresh:(NSTimer *)timer {
    [self refreshData];
}

#pragma mark Data Management

- (void)refreshData {
    static NSString *urlFormat = @"https://api.bitcoinaverage.com/ticker/global/%@", *floatFormat = @"%0.2f";

    NSString *currency = [BACurrency get], *timeStamp = nil;
    NSData *urlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:urlFormat,currency]]];
    
    if(urlData) {
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:urlData options:0 error:NULL];
        if(data) {
            double bid  = [[data valueForKey:@"bid"]  doubleValue],
                   ask  = [[data valueForKey:@"ask"]  doubleValue];

            last = [[data valueForKey:@"last"] doubleValue];
            // timeStamp = [data valueForKey:@"timestamp"];
            timeStamp = [self reformatTimestamp:[data valueForKey:@"timestamp"]];

            // Currency Buttons
            [self.currencyButton setTitle:currency forState:UIControlStateNormal];
            [self.smallCurrencyButton setTitle:currency forState:UIControlStateNormal];
            
            // Change the labels
            self.lastLabel.text = [NSString stringWithFormat:floatFormat,last];
            self.bidLabel.text  = [NSString stringWithFormat:floatFormat,bid];
            self.askLabel.text  = [NSString stringWithFormat:floatFormat,ask];
            self.dateLabel.text = /*[dateFormatter stringFromDate:date];*/(timeStamp!=nil)?timeStamp:@"";
            
            // Change the edit boxes
            self.currencyEdit.placeholder = [NSString stringWithFormat:floatFormat,last];

            if([self.bitcoinEdit.text length]) {
                double newval = [self.bitcoinEdit.text doubleValue]*last;
                self.currencyEdit.text = [NSString stringWithFormat:floatFormat,newval];
            }
            
            // Change the badge icon devided down to under 10000
            unsigned int iLast = (unsigned int)(last+0.5);
            while(iLast>=10000) iLast/=10;
            [UIApplication sharedApplication].applicationIconBadgeNumber = iLast;

        } else NSLogDebug(@"JSON to NSDictionary failed",nil);
    } else NSLogDebug(@"No urlData",nil);

    NSLogDebug(@"refreshData %.2f",last);
}

- (NSString*)reformatTimestamp:(NSString*)stamp {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, dd LLL yyyy HH:mm:ss ZZZ"];
    NSDate *theDate = [dateFormatter dateFromString:stamp];

    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];

    return [dateFormatter stringFromDate:theDate];
}

#pragma mark Text Boxes

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if(textField == self.currencyEdit) self.bitcoinEdit.text = nil;
    else if(textField == self.bitcoinEdit) self.currencyEdit.text = nil;
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    BOOL rVal = YES;

    if([string length]) {
        unsigned int x=0;
        char c,cReplace[[string length]+1];

        BOOL found = ([textField.text rangeOfString:@"."].location!=NSNotFound);
            
        NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        for(unsigned int i=0,l=(unsigned int)[string length]; i<l; i++) {
            c=[string characterAtIndex:i];
            if([charSet characterIsMember:c]) {
                cReplace[x++]=c;

            } else if(c=='.'&&!found) {
                cReplace[x++]=c;
                found=TRUE;
            }
            cReplace[x]=0;
        }
        if([string length]!=x) {
            string = [NSString stringWithCString:cReplace encoding:NSUTF8StringEncoding];
            rVal = NO;
        }
    } // else it's removal

    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];

    if([newText length]) {
        if(textField == self.currencyEdit) {
            self.bitcoinEdit.text = [NSString stringWithFormat:@"%.8f",([newText doubleValue]/last)];
        } else if(textField == self.bitcoinEdit) {
            self.currencyEdit.text = [NSString stringWithFormat:@"%.2f",([newText doubleValue]*last)];
        }
        if(!rVal) textField.text = newText; // AND move the cursor
    } else {
        if(textField == self.currencyEdit) self.bitcoinEdit.text = nil;
        else if(textField == self.bitcoinEdit) self.currencyEdit.text = nil;
    }
    
    return rVal;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    // sanitize the bitch
    double btc = [self.bitcoinEdit.text doubleValue], currency = [self.currencyEdit.text doubleValue];
    self.bitcoinEdit.text = (btc==0.0)?nil:[NSString stringWithFormat:@"%.8f",btc];
    self.currencyEdit.text = (currency==0.0)?nil:[NSString stringWithFormat:@"%.2f",currency];
}

#pragma Touches

- (IBAction)downSwipe:(UISwipeGestureRecognizer *)sender {
    // skip an update if it's been under ~30 seconds since the last one.
    if([self.lastUpdate timeIntervalSinceNow] < -29.5) {
        [self refreshData];
        self.lastUpdate = [NSDate date];
    }
}

- (IBAction)tapAction:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

/*- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    storeProducts = response.products;
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"SKProductsRequest Failed !!\n%@\n%@",request,error);
}*/

#pragma mark Buttons with Alerts

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

- (IBAction)infoPush:(UIButton *)sender {
    [[[UIAlertView alloc] initWithTitle:@"BitcoinAverage Price Index"
                                message:@"All data is from BitcoinAverage.com\nOpen in Safari?"
                               delegate:self
                      cancelButtonTitle:@"No Thanks"
                      otherButtonTitles:@"Open",nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex==[alertView cancelButtonIndex]) return;
    
    //if([alertView.title isEqualToString:@"BitcoinAverage Price Index"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://bitcoinaverage.com/#%@-nomillibit",[BACurrency get]]]];
    //} else {
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
    //}
}

@end
