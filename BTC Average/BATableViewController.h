//
//  BATableViewController.h
//  BTC Average
//
//  Created by Adam Dann on 2/14/2014.
//  Copyright (c) 2014 Nullriver. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BATableViewController : UITableViewController {
    // NSString *selection;
    NSArray *theKeys;
    NSDictionary *theData;
}

- (void)refreshData;
@property (strong, nonatomic) IBOutlet UILabel *primarylabel;
@property (strong, nonatomic) IBOutlet UILabel *secondaryLabel;
@property (strong, nonatomic) IBOutlet UILabel *otherLabel;

@end
