//
//  BAViewController.m
//  BTC Average
//
//  Created by Adam Dann on 2/13/2014.
//  Copyright (c) 2014 Nullriver. All rights reserved.
//

// 1sBXjFVV163oF5ndf2Tjv3JFHpnfzK1vu

#import "BAViewController.h"
#import "BACurrency.h"

@interface BAViewController ()

@end

@implementation BAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    /*UIRefreshControl *tempRefreshControl = [[UIRefreshControl alloc] init];
    refreshControl =[[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [theTable addSubview:refreshControl];*/
    //refreshControl = tempRefreshControl;

    // trivial value to start with
    self.lastUpdate = [NSDate dateWithTimeIntervalSinceNow:-300.0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [self refreshData];
}

- (void)becomeActive:(NSNotification *)notification {
    [self refreshData];
    // create the timer
}

- (void)refreshData {
    static NSString *urlFormat = @"https://api.bitcoinaverage.com/ticker/global/%@", *floatFormat = @"%0.2f";

    // skip an update if it's been under ~30 seconds since the last one.
    if([self.lastUpdate timeIntervalSinceNow] < -29.5) {

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
                       ask  = [[data valueForKey:@"ask"]  doubleValue],
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
                self.bitcoinEdit.placeholder = @"1.00";
                self.currencyEdit.placeholder = [NSString stringWithFormat:floatFormat,last];
                
                // Change the badge icon devided down to under 10000
                unsigned int iLast = (unsigned int)(last+0.5);
                while(iLast>=10000) iLast/=10;
                [UIApplication sharedApplication].applicationIconBadgeNumber = iLast;
                
                self.lastUpdate = [NSDate date];
                
            } else NSLog(@"JSON to NSDictionary failed");
        } else NSLog(@"No urlData");
    }
}

/*-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // for backspace
    if([string length]==0){
        return YES;
    }
    
    //  limit to only numeric characters
    
    NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    for (int i = 0; i < [string length]; i++) {
        unichar c = [string characterAtIndex:i];
        if ([myCharSet characterIsMember:c]) {
            return YES;
        }
    }
    
    return NO;
}*/

- (IBAction)downSwipe:(UISwipeGestureRecognizer *)sender {
    [self refreshData];
}

- (IBAction)tapAction:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (IBAction)donatePush:(UIButton *)sender {
    [[[UIAlertView alloc] initWithTitle:@"Donate Bitcoins"
                                message:@"Please consider donating bitcoins to support this probjcet. Copy bitcoin address to the clipboard?"
                               delegate:self
                      cancelButtonTitle:@"No Thanks"
                      otherButtonTitles:@"Copy",nil] show];
}

- (IBAction)infoPush:(UIButton *)sender {
    [[[UIAlertView alloc] initWithTitle:@"BitcoinAverage.com"
                                message:@"All data is from BitcoinAverage.com\nOpen in Safari?"
                               delegate:self
                      cancelButtonTitle:@"No Thanks"
                      otherButtonTitles:@"Open",nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex) {
        if([alertView.title isEqualToString:@"BitcoinAverage.com"]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://bitcoinaverage.com/#%@",[BACurrency get]]]];
        } else {
            [[UIPasteboard generalPasteboard] setString:@"1sBXjFVV163oF5ndf2Tjv3JFHpnfzK1vu"];
        }
    }
}

@end
