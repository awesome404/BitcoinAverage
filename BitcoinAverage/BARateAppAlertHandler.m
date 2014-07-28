//
//  BARateAppAlertHandler.m
//  BitcoinAverage
//
//  Created by Adam Dann on 2014-06-12.
//  Copyright (c) 2014 Nullriver. All rights reserved.
//

#import "BARateAppAlertHandler.h"

@implementation BARateAppAlertHandler

- (BOOL)shouldShow {

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    if([prefs boolForKey:@"neverRate"]) return NO;

    // Adjust the number of launches
    int launchCount = ((int)[prefs integerForKey:@"launchCount"])+1;
    [prefs setInteger:launchCount forKey:@"launchCount"];
    [prefs synchronize];

    return (launchCount<=48 && (launchCount%8)==0);
}

- (void)showAlert {
    [[[UIAlertView alloc] initWithTitle:@"Please rate ฿ Average!"
                                message:@"If you like it we'd like to know."
                               delegate:self
                      cancelButtonTitle:nil
                      otherButtonTitles:@"No, Thanks", @"Remind Me Later", @"Rate It Now",nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex==0) { // No, Thanks
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"neverRate"];
    } else if(buttonIndex==2) { // Rate It Now
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"neverRate"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=829877720"]];
    }
    // Remind me later does nothing
}

@end
