//
//  BATableViewController.m
//  BTC Average
//
//  Created by Adam Dann on 2/14/2014.
//  Copyright (c) 2014 Nullriver. All rights reserved.
//

// 1sBXjFVV163oF5ndf2Tjv3JFHpnfzK1vu

#import "BATableViewController.h"

@interface BATableViewController ()

@end

@implementation BATableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if(self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    
    [self refreshData];
}

- (void)refreshData
{
    NSString *stringURL = @"https://api.bitcoinaverage.com/ticker/all";
    NSURL *url = [NSURL URLWithString:stringURL];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    
    if(urlData) {
        theData = [NSJSONSerialization JSONObjectWithData:urlData options:0 error:NULL];
        
        if(theData) {

            NSMutableArray *mainKeys = [NSMutableArray arrayWithObjects:@"USD",@"EUR",@"CNY",@"GBP",@"CAD",nil],
                           *otherKeys = [[theData allKeys] mutableCopy];
            
            [otherKeys removeObject:@"timestamp"];
            
            NSInteger mi,oi;
            for(mi=0;mi<[mainKeys count];mi++)
                if((oi=[otherKeys indexOfObject:mainKeys[mi]])!=NSNotFound)
                    [otherKeys removeObjectAtIndex:oi];
                else
                    [mainKeys removeObjectAtIndex:mi];

            theKeys = [mainKeys arrayByAddingObjectsFromArray:[otherKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];

            [self.tableView reloadData];
            
            //NSLog(@"%@\n%@",theKeys,theData);
        } else theKeys = [NSArray init];
    }

    if(self.refreshControl.refreshing) [self.refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

/*- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [theKeys count];
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [theKeys count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;

    if(indexPath.item==0) {
        static NSString *CellIdentifier = @"TopCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];// forIndexPath:indexPath];
        
        if(cell==nil)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        cell.textLabel.text = @" ";
        cell.detailTextLabel.text = @"Select a currency:";
        return cell;
    } else {
        static NSString *CellIdentifier = @"Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];// forIndexPath:indexPath];
        
        if(cell==nil)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];

        if(indexPath.item==0) {
            cell.textLabel.text = @" ";
            cell.detailTextLabel.text = @"Something something";
            return cell;
        }
        
        // Configure the cell...
        NSString *key = [theKeys objectAtIndex:indexPath.item-1];
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
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
