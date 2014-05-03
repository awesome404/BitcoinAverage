//
//  BAGraphViewController.m
//  ฿ Average
//
//  Created by Adam Dann on 2014-04-25.
//  Copyright (c) 2014 Nullriver. All rights reserved.
//

#import "BAGraphViewController.h"
#import "BACurrency.h"

@interface BAGraphPoint : NSObject

@property double average;
@property unsigned long time;

+(BAGraphPoint*)initWithAverage:(double)average time:(unsigned long)time;

@end

@implementation BAGraphPoint

+(BAGraphPoint*)initWithAverage:(double)average time:(unsigned long)time {
    BAGraphPoint *newObject = [BAGraphPoint alloc];
    newObject.average = average;
    newObject.time = time;
    return newObject;
}

@end


@interface BAGraphViewController () /*{
    unsigned long   highPrice,
                    lowPrice,
                    startTime,
                    endTime;
    NSArray *theData;
}

@property NSString *currency;

- (void)refreshData;*/

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

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*- (void)drawRect:(CGRect)rect {
    
    //UIColor* currentColor = [UIColor redColor];
    CGContextRef    context = UIGraphicsGetCurrentContext();
    
    //Set the width of the "pen" that will be used for drawing
    CGContextSetLineWidth(context,2);
    //Set the color of the pen to be used
    CGContextSetRGBStrokeColor(context, 0.2, 0.2, 0.6, 1.0);
    //CGContextSetStrokeColorWithColor(context, currentColor.CGColor);
    
    CGFloat x = 0.0,y = 0.0;
    BOOL first = YES;
    for(NSArray *item in theData) {
        
        x++;y++;
        
        if(first) {
            CGContextMoveToPoint(context,x,y);
            first = NO;
        } else {
            CGContextAddLineToPoint(context,x,y);
        }
    }
    
    //Move the pen
    /*if(aSwipe.alive) {
        CGContextMoveToPoint(context, aSwipe.pointOne.x , aSwipe.pointOne.y);
        CGContextAddLineToPoint(context, aSwipe.pointTwo.x , aSwipe.pointTwo.y);
    }
    //Apply our stroke settings to the line.
    CGContextStrokePath(context);
    
    CGContextSetRGBStrokeColor(context, 0.2, 0.2, 0.2, 1.0);
    CGContextFillEllipseInRect(context,CGRectMake(5,5,20,20));
}

- (void)refreshData {
    static NSString *urlFormat = @"https://api.bitcoinaverage.com/history/%@/per_minute_24h_sliding_window.csv";

    self.currency = [BACurrency get];
    NSStringEncoding *encoding=nil;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:urlFormat,self.currency]];
    NSString *urlData = [NSString stringWithContentsOfURL:url usedEncoding:encoding error:nil];

    if(urlData) {
        NSArray *lines = [urlData componentsSeparatedByString:@"\n"];
        urlData = nil;

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
        [dateFormatter setDateFormat:@"y-M-d HH:mm:ss"];
        
        struct {unsigned long timeStamp,count; double average;} tempData[[lines count]+1];
        
        tempData[0].timeStamp = 0;
        tempData[0].average = 0;
        tempData[0].count = 0;

        BOOL firstLine = YES;
        NSRange range;
        unsigned long index, timeStamp, baseTime;
        double average;

        for(unsigned long i=1,c=[lines count];i<c;i++) {
            if([lines[i] length]>0) {

                // split the line up
                range = [lines[i] rangeOfString:@","];
                timeStamp = [[dateFormatter dateFromString:[lines[i] substringToIndex:range.location]] timeIntervalSince1970]/600;
                average = [[lines[i] substringFromIndex:(range.location+range.length)] doubleValue];

                // if it's the first line, then we get the time to subtract from the other ones to get the index
                if(firstLine) {
                    startTime = timeStamp*600;
                    baseTime = timeStamp;
                    firstLine = NO;
                    index = 0;
                } else {
                    index = timeStamp - baseTime; // get the index
                }

                // set the data
                if(tempData[index].timeStamp==0) {
                    tempData[index].timeStamp = endTime = timeStamp*600;
                    tempData[index+1].timeStamp = 0;
                    tempData[index+1].average = 0;
                    tempData[index+1].count = 0;
                }
                tempData[index].average += average;
                tempData[index].count++;
            }
        }
        tempData[index].average /= tempData[index].count; // last one has to be done manually

        NSMutableArray *mutableData = [NSMutableArray array];

        highPrice = 0;
        lowPrice = 100000000;
        
        for(unsigned long i=0;i<=index;i++) {
            if(tempData[i].average > highPrice) highPrice = tempData[i].average;
            if(tempData[i].average < lowPrice)  lowPrice  = tempData[i].average;
            [mutableData addObject:[BAGraphPoint initWithAverage:(tempData[i].average/tempData[i].count) time:tempData[i].timeStamp]];
        }

        theData = [NSArray arrayWithArray:mutableData];
        NSLog(@"%@\n%lu",theData,endTime);

    } else NSLogDebug(@"No urlData",nil);
}*/


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
