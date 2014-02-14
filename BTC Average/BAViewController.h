//
//  BAViewController.h
//  BTC Average
//
//  Created by Adam Dann on 2/13/2014.
//  Copyright (c) 2014 Nullriver. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BAViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSArray *theKeys;
    NSMutableDictionary *theData;
}

- (void)refreshData;

@end
