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

/*- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    UIRefreshControl *tempRefreshControl = [[UIRefreshControl alloc] init];
    refreshControl =[[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [theTable addSubview:refreshControl];
    //refreshControl = tempRefreshControl;
}*/

- (void)viewWillAppear:(BOOL)animated {
    [self refreshData];
}

- (void)refreshData {
    static NSString *urlFormat = @"https://api.bitcoinaverage.com/ticker/global/%@", *floatFormat = @"%0.2f";

    self.activityControl.hidden = NO;
    [self.activityControl startAnimating];
    
    NSString *currency = [BACurrency get];
    NSData *urlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:urlFormat,currency]]];
    double bid=0.0, ask=0.0, last=0.0;

    
    if(urlData) {
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:urlData options:0 error:NULL];
        if(data) {
            bid  = [[data valueForKey:@"bid"]  doubleValue];
            ask  = [[data valueForKey:@"ask"]  doubleValue];
            last = [[data valueForKey:@"last"] doubleValue];

        } else NSLog(@"JSON to NSDictionary failed");
    } else NSLog(@"No urlData");

    // Currency Buttons
    [self.currencyButton setTitle:currency forState:UIControlStateNormal];
    [self.smallCurrencyButton setTitle:currency forState:UIControlStateNormal];

    // Change the labels
    self.lastLabel.text = [NSString stringWithFormat:floatFormat,last];
    self.bidLabel.text  = [NSString stringWithFormat:floatFormat,bid];
    self.askLabel.text  = [NSString stringWithFormat:floatFormat,ask];
    
    // Change the edit boxes
    self.bitcoinEdit.placeholder = @"1.00";
    self.currencyEdit.placeholder = [NSString stringWithFormat:floatFormat,last];
    
    // Change the badge icon devided down to under 10000
    unsigned int iLast = (unsigned int)(last+0.5);
    while(iLast>=10000) iLast/=10;
    [UIApplication sharedApplication].applicationIconBadgeNumber = iLast;
    
    [self.activityControl stopAnimating];
}

- (IBAction)donatePush:(UIButton *)sender {
    [[[UIAlertView alloc] initWithTitle:@"Donate Bitcoins"
                                message:@"Please consider donating bitcoins to support this probjcet. Copy bitcoin address to the clipboard?"
                               delegate:self
                      cancelButtonTitle:@"No Thanks"
                      otherButtonTitles:@"Copy",nil] show];
}

- (IBAction)downSwipe:(UISwipeGestureRecognizer *)sender {
    [self refreshData];
}

- (IBAction)tapAction:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex) [[UIPasteboard generalPasteboard] setString:@"1sBXjFVV163oF5ndf2Tjv3JFHpnfzK1vu"];
}

@end
