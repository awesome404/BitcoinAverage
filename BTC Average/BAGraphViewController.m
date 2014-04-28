//
//  BAGraphViewController.m
//  ฿ Average
//
//  Created by Adam Dann on 2014-04-25.
//  Copyright (c) 2014 Nullriver. All rights reserved.
//

#import "BAGraphViewController.h"
#import "BACurrency.h"

@interface BAGraphViewController () {
    NSNumber *highPrice,
             *lowPrice,
             *startTime,
             *endTime;
    NSArray *theData;
}

@property NSString *currency;

- (void)refreshData;

@end

@implementation BAGraphViewController

/*- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}*/

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [self refreshData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshData {
    static NSString *urlFormat = @"https://api.bitcoinaverage.com/history/%@/per_minute_24h_sliding_window.csv";

    self.currency = [BACurrency get];
    NSStringEncoding *encoding=nil;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:urlFormat,self.currency]];
    NSString *urlData = [NSString stringWithContentsOfURL:url usedEncoding:encoding error:nil];
    
    NSMutableArray *mutableData = [NSMutableArray array];

    if(urlData) {
        NSArray *lines = [urlData componentsSeparatedByString:@"\n"];
        urlData = nil;

        BOOL firstLine = YES;
        NSRange range;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
        [dateFormatter setDateFormat:@"y-M-d HH:mm:ss"];
        NSNumber *average = nil;
        
        highPrice = nil;
        lowPrice = nil;

        for(NSString *line in lines) {
            if(firstLine) firstLine = NO;
            else if([line length]>0) {
                
                range = [line rangeOfString:@","];
                average = [NSNumber numberWithDouble:[[line substringFromIndex:(range.location+range.length)] doubleValue]];
                
                if(highPrice == nil || average>highPrice) highPrice = average;
                if(lowPrice == nil || average<lowPrice) lowPrice = average;

                [mutableData addObject:
                    [NSArray arrayWithObjects:
                        [NSNumber numberWithDouble:[[dateFormatter dateFromString:[line substringToIndex:range.location]] timeIntervalSince1970]],
                        average, //[NSNumber numberWithDouble:[[line substringFromIndex:(range.location+range.length)] doubleValue]],
                        nil
                     ]
                ];

            }
        }
        
        theData = [NSArray arrayWithArray:mutableData];
        
        startTime = theData[0][0];
        endTime = theData[[theData count]-1][0];

    } else NSLogDebug(@"No urlData",nil);
}

/*
 
 - (NSString*)reformatTimestamp:(NSString*)stamp {
 
 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
 [dateFormatter setDateFormat:@"EEE, dd LLL yyyy HH:mm:ss ZZZ"];
 NSDate *theDate = [dateFormatter dateFromString:stamp];
 
 [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
 [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
 [dateFormatter setLocale:[NSLocale currentLocale]];
 
 return [dateFormatter stringFromDate:theDate];
 }
 
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
