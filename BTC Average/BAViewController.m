//
//  BAViewController.m
//  BTC Average
//
//  Created by Adam Dann on 2/13/2014.
//  Copyright (c) 2014 Nullriver. All rights reserved.
//

#import "BAViewController.h"
#import "BASettings.h"

@interface BAViewController ()

@property NSDate *lastUpdate;

@property NSTimer *refreshTimer;
@property ADBannerView *bannerView;

@property (weak, nonatomic) IBOutlet UIButton *currencyButton;
@property (weak, nonatomic) IBOutlet UIButton *smallCurrencyButton;

@property (weak, nonatomic) IBOutlet UILabel *lastLabel;
@property (weak, nonatomic) IBOutlet UILabel *bidLabel;
@property (weak, nonatomic) IBOutlet UILabel *askLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UITextField *currencyEdit;
@property (weak, nonatomic) IBOutlet UITextField *bitcoinEdit;

- (void)refreshData;
- (NSString*)reformatTimestamp:(NSString*)stamp;
- (void)orientationChanged:(NSNotification *)notification;

//- (IBAction)donatePush:(UIButton *)sender;
- (IBAction)infoPush:(UIButton *)sender;
- (IBAction)downSwipe:(UISwipeGestureRecognizer *)sender;
- (IBAction)tapAction:(UITapGestureRecognizer *)sender;

@end

@implementation BAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    _isShowingLandscapeView = NO;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];

/*    NSLayoutConstraint * proptionConstraint =
    [NSLayoutConstraint constraintWithItem:_equalLabel
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:_theView
                                 attribute:NSLayoutAttributeHeight
                                multiplier:(1.0/4.0)
                                  constant:0];
[_theView addConstraint:proptionConstraint];*/
    
    // if they haven't paid
    _bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    _bannerView.delegate = self;
    //_bannerView.hidden = YES;
    [self.view addSubview:_bannerView];
    
    // trivial value to start with
    self.lastUpdate = [NSDate dateWithTimeIntervalSinceNow:-300.0];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLogDebug(@"viewWillAppear",nil);
    [self refreshData];
}

#pragma mark Rotation

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)orientationChanged:(NSNotification *)notification {
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (!_isShowingLandscapeView && UIDeviceOrientationIsLandscape(deviceOrientation) && self.presentedViewController==nil) {
        [self performSegueWithIdentifier:@"Graph" sender:self];
        _isShowingLandscapeView = YES;
    } else if(_isShowingLandscapeView && UIDeviceOrientationIsPortrait(deviceOrientation)) {
        [self dismissViewControllerAnimated:YES completion:nil];
        _isShowingLandscapeView = NO;
    }
}

#pragma mark Timer

- (void)startRefreshTimer {
    NSLogDebug(@"startRefreshTimer",nil);
    [self refreshData];
    _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(timerFireRefresh:) userInfo:nil repeats:YES];
}

- (void)stopRefreshTimer {
    NSLogDebug(@"stopRefreshTimer",nil);
    [_refreshTimer invalidate];
    _refreshTimer=nil;
}

- (void)timerFireRefresh:(NSTimer *)timer {
    NSLogDebug(@"timerFireRefresh",nil);
    [self refreshData];
}

#pragma mark Data Management

- (void)refreshData {
    static NSString *urlFormat = @"https://api.bitcoinaverage.com/ticker/global/%@", *floatFormat = @"%0.2f";

    NSError *error=nil;
    NSString *currency = [BASettings getCurrency];//, *timeStamp = nil;
    NSData *urlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:urlFormat,currency]] options:NSDataReadingUncached error:&error];

    if(urlData) {
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:urlData options:0 error:&error];
        if(data) {
            double bid  = [[data valueForKey:@"bid"]  doubleValue],
                   ask  = [[data valueForKey:@"ask"]  doubleValue];

            _last = [[data valueForKey:@"last"] doubleValue];
            // timeStamp = [data valueForKey:@"timestamp"];
            NSString *timeStamp = [self reformatTimestamp:[data valueForKey:@"timestamp"]];

            // Currency Buttons
            [self.currencyButton setTitle:currency forState:UIControlStateNormal];
            [self.smallCurrencyButton setTitle:currency forState:UIControlStateNormal];
            
            // Change the labels
            self.lastLabel.text = [NSString stringWithFormat:floatFormat,_last];
            self.bidLabel.text  = [NSString stringWithFormat:floatFormat,bid];
            self.askLabel.text  = [NSString stringWithFormat:floatFormat,ask];
            self.dateLabel.text = /*[dateFormatter stringFromDate:date];*/(timeStamp!=nil)?timeStamp:@"";
            
            // Change the edit boxes
            self.currencyEdit.placeholder = [NSString stringWithFormat:floatFormat,_last];

            if([self.bitcoinEdit.text length]) {
                double newval = [self.bitcoinEdit.text doubleValue]*_last;
                self.currencyEdit.text = [NSString stringWithFormat:floatFormat,newval];
            }
            
            // Change the badge icon devided down to under 10000
            unsigned int iLast = (unsigned int)(_last+0.5);
            while(iLast>=10000) iLast/=10;
            [UIApplication sharedApplication].applicationIconBadgeNumber = iLast;

        } else NSLogDebug(@"JSON to NSDictionary failed: %@",error);
    } else NSLogDebug(@"No urlData: %@",error);

    NSLogDebug(@"refreshData %.2f",_last);
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
            self.bitcoinEdit.text = [NSString stringWithFormat:@"%.8f",([newText doubleValue]/_last)];
        } else if(textField == self.bitcoinEdit) {
            self.currencyEdit.text = [NSString stringWithFormat:@"%.2f",([newText doubleValue]*_last)];
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

#pragma mark Buttons with Alerts

- (IBAction)infoPush:(UIButton *)sender {
    [[[UIAlertView alloc] initWithTitle:@"BitcoinAverage Price Index"
                                message:@"All data is from BitcoinAverage.com\nOpen in Safari?"
                               delegate:self
                      cancelButtonTitle:@"No Thanks"
                      otherButtonTitles:@"Open",nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex==[alertView cancelButtonIndex]) return;
    
    //if([alertView.title isEqualToString:@"BitcoinAverage Price Index"])
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://bitcoinaverage.com/#%@-nomillibit",[BASettings getCurrency]]]];
}

#pragma mark iAd - ADBannerViewDelegate

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    //banner.hidden = NO;
    
    CGRect contentFrame = self.view.bounds;
    contentFrame.size.height -= banner.frame.size.height;
    self.view.frame = contentFrame;
    
    CGRect bannerFrame = banner.frame;
    bannerFrame.origin.y = contentFrame.size.height;
    banner.frame = bannerFrame;

    NSLogDebug(@"bannerViewDidLoadAd",nil);
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    //banner.hidden = YES;

    CGRect contentFrame = self.view.bounds;
    //if(self.view.frame.size.height != contentFrame.size.height)
        self.view.frame = contentFrame;

    CGRect bannerFrame = banner.frame;
    bannerFrame.origin.y = contentFrame.size.height;
    banner.frame = bannerFrame;

    NSLogDebug(@"bannerView:didFailToReceiveAdWithError:%@",[error localizedDescription]);
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
    [self stopRefreshTimer];
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
    [self startRefreshTimer];
}

@end
