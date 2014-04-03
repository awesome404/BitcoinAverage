//
//  BAViewController.m
//  BTC Average
//
//  Created by Adam Dann on 2/13/2014.
//  Copyright (c) 2014 Nullriver. All rights reserved.
//

#import "BAViewController.h"
#import "BACurrency.h"

@interface BAViewController ()

@end

@implementation BAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    // trivial value to start with
    self.lastUpdate = [NSDate dateWithTimeIntervalSinceNow:-300.0];
}

- (void)viewWillAppear:(BOOL)animated {
    
    // clear the editboxes because they will be wrong when currency is changed
    if(self.currencyEdit.text) self.currencyEdit.text = nil;
    if(self.bitcoinEdit.text)  self.bitcoinEdit.text = nil;
    
    [self refreshData];
}

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

- (void)refreshData {
    static NSString *urlFormat = @"https://api.bitcoinaverage.com/ticker/global/%@", *floatFormat = @"%0.2f";

    NSString *currency = [BACurrency get], *timeStamp = nil;
    NSData *urlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:urlFormat,currency]]];

/*    NSDate *date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSLocale *gbLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
    [dateFormatter setLocale:gbLocale];*/
    
    if(urlData) {
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:urlData options:0 error:NULL];
        if(data) {
            double bid  = [[data valueForKey:@"bid"]  doubleValue],
                   ask  = [[data valueForKey:@"ask"]  doubleValue];

            last = [[data valueForKey:@"last"] doubleValue];
            timeStamp = [data valueForKey:@"timestamp"];
            //date=[dateFormatter dateFromString:[data valueForKey:@"timestamp"]];

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
            
            // Change the badge icon devided down to under 10000
            unsigned int iLast = (unsigned int)(last+0.5);
            while(iLast>=10000) iLast/=10;
            [UIApplication sharedApplication].applicationIconBadgeNumber = iLast;

        } else NSLog(@"JSON to NSDictionary failed");
    } else NSLog(@"No urlData");
#ifndef NDEBUG
    NSLog(@"refreshData %.2f",last);
#endif
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
        int x=0;
        char c,cReplace[[string length]+1];

        BOOL found = ([textField.text rangeOfString:@"."].location!=NSNotFound);
            
        NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        for(int i=0; i<[string length]; i++) {
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

#pragma mark Buttons with Alerts

- (IBAction)donatePush:(UIButton *)sender {
    [[[UIAlertView alloc] initWithTitle:@"Donate Bitcoins"
                                message:@"Please consider donating bitcoins to support this project. Copy bitcoin address to the clipboard?"
                               delegate:self
                      cancelButtonTitle:@"No Thanks"
                      otherButtonTitles:@"Copy",/*@"QR",*/nil] show];
}

- (IBAction)infoPush:(UIButton *)sender {
    [[[UIAlertView alloc] initWithTitle:@"BitcoinAverage Price Index"
                                message:@"All data is from BitcoinAverage.com\nOpen in Safari?"
                               delegate:self
                      cancelButtonTitle:@"No Thanks"
                      otherButtonTitles:@"Open",nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex) {
        if([alertView.title isEqualToString:@"BitcoinAverage.com"]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://bitcoinaverage.com/#%@-nomillibit",[BACurrency get]]]];
        } else {
            [[UIPasteboard generalPasteboard] setString:@"1CUCHYnoxacZVxuTLR3nV8z9MKPrbhhqYN"];
        }
    }
}

@end
