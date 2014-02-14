//
//  BAViewController.m
//  BTC Average
//
//  Created by Adam Dann on 2/13/2014.
//  Copyright (c) 2014 Nullriver. All rights reserved.
//

#import "BAViewController.h"

@interface BAViewController ()

@end

@implementation BAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self refreshData];
}

- (void)refreshData
{
    NSString *stringURL =  @"https://api.bitcoinaverage.com/ticker/all";
    NSURL  *url = [NSURL URLWithString:stringURL];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    
    if(urlData) {
        theData = [NSJSONSerialization JSONObjectWithData:urlData options:0 /*NSJSONReadingMutableContainers*/ error:NULL];
        
        if(theData) {

            NSMutableArray *tempKeys = [[theData allKeys] mutableCopy];
            [tempKeys removeObject:@"timestamp"];
            theKeys = [tempKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            
            //NSLog(@"%@",theKeys);
            //NSLog(@"%@",theData);
        }
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
    NSString *bid = [[theData valueForKey:key] valueForKey:@"bid"];
    NSString *ask = [[theData valueForKey:key] valueForKey:@"ask"];
    NSString *last = [[theData valueForKey:key] valueForKey:@"last"];

    double avg = (([bid doubleValue]+[ask doubleValue])/2) + 0.05f;
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %0.2f", key, avg];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"  bid: %@ • ask: %@ • last: %@",bid, ask, last];

    return cell;
}

@end
