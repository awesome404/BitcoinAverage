//
//  BATableViewController.m
//  BitcoinAverage
//
//  Created by Adam Dann on 2/14/2014.
//  Copyright (c) 2014 Nullriver. All rights reserved.
//


#import "BATableViewController.h"
#import "BASettings.h"

@interface BATableViewController () {
    NSArray *_theKeys;
    NSDictionary *_theData;
}

- (void)refreshData;

@property (strong, nonatomic) IBOutlet UILabel *primarylabel;
@property (strong, nonatomic) IBOutlet UILabel *secondaryLabel;
@property (strong, nonatomic) IBOutlet UILabel *otherLabel;

@end

@implementation BATableViewController

/*- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if(self) {
        // Custom initialization
    }
    return self;
}*/

- (void)viewDidLoad {
    [super viewDidLoad];

    // Account for the table going under the status bar - still busted
    self.navigationController.navigationBar.translucent = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0);
    
    // Set the section background colour
    UIColor *bg = [UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0];
    self.primarylabel.backgroundColor = bg;
    self.secondaryLabel.backgroundColor = bg;
    self.otherLabel.backgroundColor = bg;

    // Preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;

    // Set the selector when you pull down to refresh
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    // Get teh actual data
    [self refreshData];
}

- (void)refreshData {
    
    NSError *error = nil;
    NSData *urlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://api.bitcoinaverage.com/ticker/global/all"] options:NSDataReadingUncached error:&error];

    _theKeys = nil;
    _theData = nil;
    
    NSArray *primaryKeys = [NSArray arrayWithObjects:@"USD",@"CAD",@"EUR",@"CNY",@"GBP",nil];
    
    if(urlData) {
        if((_theData = [NSJSONSerialization JSONObjectWithData:urlData options:0 error:&error])!=nil) {

            NSArray *secondaryKeys = [NSArray arrayWithObjects:@"PLN",@"JPY",@"RUB",@"AUD",@"SEK",@"BRL",@"NZD",
                                                               @"SGD",@"ZAR",@"NOK",@"ILS",@"CHF",@"TRY",nil];
            NSMutableArray *allKeys = [[_theData allKeys] mutableCopy];

            [allKeys removeObject:@"timestamp"];

            _theKeys = [NSArray arrayWithObjects:primaryKeys,secondaryKeys,[allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)],nil];

            [self.tableView reloadData];

        } else NSLogDebug(@"JSON to NSDictionary failed: %@",error);
    } else NSLogDebug(@"No urlData: %@",error);

    if(_theKeys == nil) _theKeys = [NSArray arrayWithObjects:primaryKeys,nil];

    if(self.refreshControl.refreshing) [self.refreshControl endRefreshing];
}

/*- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}*/

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 24; // Return the space between sections
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(section==0) return self.primarylabel;
    else if(section==1) return self.secondaryLabel;
    return self.otherLabel;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_theKeys count]; // Return the number of sections.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_theKeys[section] count]; // Return the number of rows in the section.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [BASettings setCurrency:_theKeys[indexPath.section][indexPath.item]];
    _theData = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"JailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell==nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];

    NSString *key = _theKeys[indexPath.section][indexPath.item];
    NSDictionary *dict;

    if(_theData==nil || (dict=[_theData valueForKey:key])==nil) {
        cell.textLabel.text = key;
        cell.detailTextLabel.text = @"Data is absent...";

    } else {
        double bid  = [[dict valueForKey:@"bid"]  doubleValue],
               ask  = [[dict valueForKey:@"ask"]  doubleValue],
               last = [[dict valueForKey:@"last"] doubleValue];

        cell.textLabel.text = [NSString stringWithFormat:@"%@: %0.2f", key, last];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"  bid: %0.2f • ask: %0.2f",bid, ask];
    }
    
    return cell;
}

@end
