//
//  BAGraphViewController.m
//  ฿ Average
//
//  Created by Adam Dann on 2014-04-25.
//  Copyright (c) 2014 Nullriver. All rights reserved.
//

#import "BAGraphViewController.h"
#import "BACurrency.h"


@interface BAGraphViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end


@implementation BAGraphViewController

- (void)viewWillAppear:(BOOL)animated {
    static NSString *format = @"24hr %@ price movement";
    self.titleLabel.text = [NSString stringWithFormat:format,[BACurrency get]];
}

@end
