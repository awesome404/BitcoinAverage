//
//  BAInfoAlertHandler.m
//  ฿ Average
//
//  Created by Adam Dann on 2014-05-30.
//  Copyright (c) 2014 Nullriver. All rights reserved.
//

#import "BAInfoAlertHandler.h"
#import "BASettings.h"

@implementation BAInfoAlertHandler

- (void)showAlert {
    [[[UIAlertView alloc] initWithTitle:@"BitcoinAverage Price Index"
                                message:@"All data is from BitcoinAverage.com\nOpen in Safari?"
                               delegate:self
                      cancelButtonTitle:@"No, Thanks"
                      otherButtonTitles:@"Open",nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex!=[alertView cancelButtonIndex]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://bitcoinaverage.com/#%@",[BASettings getCurrency]]]];
    }
}

@end
