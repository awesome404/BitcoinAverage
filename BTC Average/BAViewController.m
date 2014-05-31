//
//  BAViewController.m
//  BTC Average
//
//  Created by Adam Dann on 2/13/2014.
//  Copyright (c) 2014 Nullriver. All rights reserved.
//

#import "BAViewController.h"
#import "BASettings.h"
#import "BAInfoAlertHandler.h"

@interface BAViewController ()

@property NSDate *lastUpdate;
@property NSTimer *refreshTimer;
@property ADBannerView *bannerView;
@property NSArray *storeProducts;
@property BAInfoAlertHandler *infoAlertHandler;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adGap;

@property (weak, nonatomic) IBOutlet UIButton *currencyButton;
@property (weak, nonatomic) IBOutlet UIButton *smallCurrencyButton;
@property (weak, nonatomic) IBOutlet UIButton *removeAdsButton;
@property (weak, nonatomic) IBOutlet UIButton *showAdsButton;

@property (weak, nonatomic) IBOutlet UILabel *lastLabel;
@property (weak, nonatomic) IBOutlet UILabel *bidLabel;
@property (weak, nonatomic) IBOutlet UILabel *askLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UITextField *currencyEdit;
@property (weak, nonatomic) IBOutlet UITextField *bitcoinEdit;

- (void)refreshData;
- (NSString*)reformatTimestamp:(NSString*)stamp;
- (void)orientationChanged:(NSNotification *)notification;
- (void)fetchStoreProducts;
- (void)initAds;
- (void)showAds;
- (void)hideAds;

- (IBAction)infoPush:(UIButton *)sender;
- (IBAction)removeAdsPush:(id)sender;
- (IBAction)showAdsPush:(id)sender;
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
    
    if([BASettings shouldShowAds]) { // if they haven't paid
        _removeAdsButton.hidden = NO;
        [self initAds];
        [self fetchStoreProducts];
    }
    
#ifndef NDEBUG
    _showAdsButton.hidden = FALSE;
#endif

    // trivial value to start with
    _lastUpdate = [NSDate dateWithTimeIntervalSinceNow:-300.0];
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
        [_activityIndicator startAnimating];
        _activityIndicator.hidden = NO;
        _isShowingLandscapeView = YES;
        [self performSegueWithIdentifier:@"Graph" sender:self];

    } else if(_isShowingLandscapeView && UIDeviceOrientationIsPortrait(deviceOrientation)) {
        if(![self.presentedViewController isBeingPresented]) { // we can't dismiss it when it's being presented
            [self dismissViewControllerAnimated:YES completion:nil];
            _isShowingLandscapeView = NO;
            [_activityIndicator stopAnimating];
        } // so we fail altogether
    }
}

#pragma mark Timer

- (void)startRefreshTimer {
    NSLogDebug(@"startRefreshTimer",nil);
    if([_lastUpdate timeIntervalSinceNow] < -30.0) [self refreshData];
    _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(timerFireRefresh:) userInfo:nil repeats:YES];
}

- (void)stopRefreshTimer {
    NSLogDebug(@"stopRefreshTimer",nil);
    [_refreshTimer invalidate];
    _refreshTimer=nil;
}

- (void)timerFireRefresh:(NSTimer *)timer {
    NSLogDebug(@"timerFireRefresh",nil);
    if([_lastUpdate timeIntervalSinceNow] < -5.0) [self refreshData];
}

#pragma mark Data Management

- (void)refreshData {
    static NSString *urlFormat = @"https://api.bitcoinaverage.com/ticker/global/%@", *floatFormat = @"%0.2f";
    
    [_activityIndicator startAnimating];
    _activityIndicator.hidden = NO;

    NSError *error=nil;
    NSString *currency = [BASettings getCurrency];
    NSData *urlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:urlFormat,currency]] options:NSDataReadingUncached error:&error];

    if(urlData) {
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:urlData options:0 error:&error];
        if(data) {
            double bid  = [[data valueForKey:@"bid"]  doubleValue],
                   ask  = [[data valueForKey:@"ask"]  doubleValue];

            _last = [[data valueForKey:@"last"] doubleValue];
            NSString *timeStamp = [self reformatTimestamp:[data valueForKey:@"timestamp"]];

            // Currency Buttons
            [_currencyButton setTitle:currency forState:UIControlStateNormal];
            [_smallCurrencyButton setTitle:currency forState:UIControlStateNormal];
            
            // Change the labels
            _lastLabel.text = [NSString stringWithFormat:floatFormat,_last];
            _bidLabel.text  = [NSString stringWithFormat:floatFormat,bid];
            _askLabel.text  = [NSString stringWithFormat:floatFormat,ask];
            _dateLabel.text = (timeStamp!=nil)?timeStamp:@"";
            
            // Change the edit boxes
            _currencyEdit.placeholder = [NSString stringWithFormat:floatFormat,_last];

            if([_bitcoinEdit.text length]) {
                double newval = [_bitcoinEdit.text doubleValue]*_last;
                _currencyEdit.text = [NSString stringWithFormat:floatFormat,newval];
            }
            
            // Change the badge icon devided down to under 10000
            double last_copy = _last;
            while(last_copy>=10000.0) last_copy/=10.0;
            [UIApplication sharedApplication].applicationIconBadgeNumber = (unsigned)(last_copy+0.5);
            
            _lastUpdate = [NSDate date];

        } else {
            _dateLabel.text = @"Failed to parse data.";
            NSLogDebug(@"JSON to NSDictionary failed: %@",error);
        }
    } else {
        _dateLabel.text = @"Failed to fetch data.";
        NSLogDebug(@"No urlData: %@",error);
    }

    [_activityIndicator stopAnimating];
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

#pragma mark Text Boxes - UITextFieldDelegate

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if(textField == _currencyEdit) _bitcoinEdit.text = nil;
    else if(textField == _bitcoinEdit) _currencyEdit.text = nil;
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    BOOL rVal = YES;

    if([string length]) {
        unsigned x=0;
        char c,cReplace[[string length]+1];

        BOOL found = ([textField.text rangeOfString:@"."].location!=NSNotFound);
            
        NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        for(unsigned i=0,l=(unsigned)[string length]; i<l; i++) {
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
        if(textField == _currencyEdit) {
            _bitcoinEdit.text = [NSString stringWithFormat:@"%.8f",([newText doubleValue]/_last)];
        } else if(textField == _bitcoinEdit) {
            _currencyEdit.text = [NSString stringWithFormat:@"%.2f",([newText doubleValue]*_last)];
        }
        if(!rVal) textField.text = newText; // AND move the cursor
    } else {
        if(textField == _currencyEdit) _bitcoinEdit.text = nil;
        else if(textField == _bitcoinEdit) _currencyEdit.text = nil;
    }
    
    return rVal;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    // sanitize the bitch
    double btc = [_bitcoinEdit.text doubleValue], currency = [_currencyEdit.text doubleValue];
    _bitcoinEdit.text = (btc==0.0)?nil:[NSString stringWithFormat:@"%.8f",btc];
    _currencyEdit.text = (currency==0.0)?nil:[NSString stringWithFormat:@"%.2f",currency];
}

#pragma Touches

- (IBAction)downSwipe:(UISwipeGestureRecognizer *)sender {
    // just don't hammer the server
    if([_lastUpdate timeIntervalSinceNow] < -1.0) [self refreshData];
}

- (IBAction)tapAction:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

#pragma mark Buttons with Alerts - UIAlertViewDelegate

- (IBAction)infoPush:(UIButton *)sender {
    if(_infoAlertHandler==nil) _infoAlertHandler = [BAInfoAlertHandler alloc];
    [_infoAlertHandler showAlert];
}

- (IBAction)removeAdsPush:(id)sender {
    [BASettings hideAds];

    _removeAdsButton.hidden = YES;
    if(_adGap.constant>0) { // if the ad is visible
        CGRect newBannerFrame = _bannerView.frame;
        newBannerFrame.origin.y = self.view.frame.size.height;
        
        [UIView animateWithDuration:0.5 animations:^{
            _adGap.constant = 0;
            [self.view layoutIfNeeded];
            _bannerView.frame = newBannerFrame;
        } completion:^(BOOL finsihed){
            [_bannerView removeFromSuperview];
            _bannerView = nil;
        }];
    } else {
        [_bannerView removeFromSuperview];
        _bannerView = nil;
    }
    
    /* Old Store Kit Code
     
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
        [  alert addButtonWithTitle:@"QR Code"];
    }
    
    [alert show];*/
}

- (IBAction)showAdsPush:(id)sender {
#ifndef NDEBUG
    _removeAdsButton.hidden = NO;
    [BASettings unhideAds];
#endif
}

#pragma mark iAd - ADBannerViewDelegate

- (void)initAds {
    _removeAdsButton.hidden = FALSE;
    _bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    _bannerView.delegate = self;
    CGRect newBannerFrame = _bannerView.frame;
    newBannerFrame.origin.y = self.view.frame.size.height;
    _bannerView.frame = newBannerFrame;
    [self.view addSubview:_bannerView];
}

- (void)showAds {
    /*if(_adGap.constant==0) {
        CGRect newBannerFrame = banner.frame;
        newBannerFrame.origin.y = self.view.frame.size.height - newBannerFrame.size.height;
        
        [UIView animateWithDuration:0.5 animations:^{
            _adGap.constant = newBannerFrame.size.height;
            [self.view layoutIfNeeded];
            banner.frame = newBannerFrame;
        }];
    }*/
}

- (void)hideAds {
    /*if(_adGap.constant>0) {
        CGRect newBannerFrame = banner.frame;
        newBannerFrame.origin.y = self.view.frame.size.height;
        
        [UIView animateWithDuration:0.5 animations:^{
            _adGap.constant = 0;
            [self.view layoutIfNeeded];
            banner.frame = newBannerFrame;
        }];
    }*/
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {

    if(_adGap.constant==0) {
        CGRect newBannerFrame = banner.frame;
        newBannerFrame.origin.y = self.view.frame.size.height - newBannerFrame.size.height;
        
        [UIView animateWithDuration:0.5 animations:^{
            _adGap.constant = newBannerFrame.size.height;
            [self.view layoutIfNeeded];
            banner.frame = newBannerFrame;
        }];
    }

    NSLogDebug(@"bannerViewDidLoadAd",nil);
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {

    if(_adGap.constant>0) {
        CGRect newBannerFrame = banner.frame;
        newBannerFrame.origin.y = self.view.frame.size.height;
        
        [UIView animateWithDuration:0.5 animations:^{
            _adGap.constant = 0;
            [self.view layoutIfNeeded];
            banner.frame = newBannerFrame;
        }];
    }

    NSLogDebug(@"bannerView:didFailToReceiveAdWithError:%@",[error localizedDescription]);
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
    [self stopRefreshTimer];
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
    [self startRefreshTimer];
}

#pragma mark StoreKit - SKRequestDelegate & SKProductsRequestDelegates

- (void)fetchStoreProducts {
    if(_storeProducts==nil) _storeProducts = [NSArray array];
    NSSet *productSet = [NSSet setWithObject:@"com.nullriver.BitcoinAverage.RemoveAds"];
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productSet];
    productsRequest.delegate = self;
    [productsRequest start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    _storeProducts = response.products;
}

/*- (void)requestDidFinish:(SKRequest *)request {
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"SKProductsRequest Failed !!\n%@\n%@",request,error);
}*/

@end
