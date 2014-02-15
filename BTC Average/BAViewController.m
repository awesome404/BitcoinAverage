//
//  BAViewController.m
//  BTC Average
//
//  Created by Adam Dann on 2/13/2014.
//  Copyright (c) 2014 Nullriver. All rights reserved.
//

// 1sBXjFVV163oF5ndf2Tjv3JFHpnfzK1vu

#import "BAViewController.h"

@interface BAViewController ()

@end

@implementation BAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self refreshData];

    //UIRefreshControl *tempRefreshControl = [[UIRefreshControl alloc] init];
    refreshControl =[[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [theTable addSubview:refreshControl];
    //refreshControl = tempRefreshControl;
}

- (void)refreshData
{
    NSString *stringURL = @"https://api.bitcoinaverage.com/ticker/all";
    NSURL *url = [NSURL URLWithString:stringURL];
    NSData *urlData = [NSData dataWithContentsOfURL:url];

    if(urlData) {
        theData = [NSJSONSerialization JSONObjectWithData:urlData options:0 /*NSJSONReadingMutableContainers*/ error:NULL];
        
        if(theData) {

            NSMutableArray *tempKeys = [[theData allKeys] mutableCopy];
            [tempKeys removeObject:@"timestamp"];
            theKeys = [tempKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            theLabel.text = [theData valueForKey:@"timestamp"];
            [theTable reloadData];
            
            //NSLog(@"%@\n%@",theKeys,theData);
        }
    }

    if(refreshControl.refreshing) {
        [refreshControl endRefreshing];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [theKeys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
    }

    NSString *key = [theKeys objectAtIndex:indexPath.item];
    NSDictionary *dict = [theData valueForKey:key];
    
    if(dict) {

        double bid = [[dict valueForKey:@"bid"] doubleValue];
        double ask = [[dict valueForKey:@"ask"] doubleValue];
        double last = [[dict valueForKey:@"last"] doubleValue];
        double avg = ((bid+ask)/2);// + 0.05f;
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@: %0.2f", key, avg];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"  bid: %0.2f • ask: %0.2f • last: %0.2f",bid, ask, last];

    } else {
        cell.textLabel.text = key;
        cell.detailTextLabel.text = @"Something is wrong...";
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selection = [theKeys objectAtIndex:indexPath.item];
}

/*
 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Donate Bitcoins"
 message:@"You must be connected to the internet to use this app."
 delegate:nil
 cancelButtonTitle:@"Cancel"
 otherButtonTitles:"Other"];
 [alert show];
 */

@end
