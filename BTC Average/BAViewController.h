//
//  BAViewController.h
//  BTC Average
//
//  Created by Adam Dann on 2/13/2014.
//  Copyright (c) 2014 Nullriver. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BAViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSString *selection;
    NSArray *theKeys;
    NSMutableDictionary *theData;
    __weak IBOutlet UITableView *theTable;
    __weak IBOutlet UILabel *theLabel;
    UIRefreshControl *refreshControl;
}

- (void)refreshData;

@end
