//
//  BAGraphView.m
//  ฿ Average
//
//  Created by Adam Dann on 2014-05-02.
//  Copyright (c) 2014 Nullriver. All rights reserved.
//

#import "BAGraphView.h"
#import "BACurrency.h"

@interface BAGraphView () {
    double highPrice, lowPrice;
    //unsigned long startTime,endTime;
    NSArray *theData;
}

@property NSString *currency;

- (void)refreshData;
- (NSArray*)getDataLines;

@end


@implementation BAGraphView

/*- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}*/


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [self refreshData];

    CGContextRef    context = UIGraphicsGetCurrentContext();
    
    double eighth = rect.size.height/8;

    CGContextSetRGBStrokeColor(context, 0.9, 0.9, 0.9, 1.0);

    CGContextMoveToPoint(context,0,eighth*2);
    CGContextAddLineToPoint(context,rect.size.width,eighth*2);

    CGContextMoveToPoint(context,0,eighth*4);
    CGContextAddLineToPoint(context,rect.size.width,eighth*4);

    CGContextMoveToPoint(context,0,eighth*6);
    CGContextAddLineToPoint(context,rect.size.width,eighth*6);
    
    CGContextStrokePath(context);
    
    CGContextSetRGBStrokeColor(context, 0.97, 0.97, 0.97, 1.0);
    
    CGContextMoveToPoint(context,0,eighth*3);
    CGContextAddLineToPoint(context,rect.size.width,eighth*3);
    
    CGContextMoveToPoint(context,0,eighth*5);
    CGContextAddLineToPoint(context,rect.size.width,eighth*5);
    
    CGContextStrokePath(context);
    
    CGContextSetRGBStrokeColor(context, 0.2, 0.2, 0.7, 1.0);
    
    double x,y;
    for(unsigned long i=0, c=[theData count];i<c;i++) {
        x = ((double)i/(double)(c-1))*rect.size.width;
        y = ([theData[i] doubleValue] * (rect.size.height/2))+(rect.size.height/4);
        if(!i) CGContextMoveToPoint(context,x,y);
        else CGContextAddLineToPoint(context,x,y);
    }

    CGContextStrokePath(context);
}

- (NSArray*)getDataLines {
    NSString *urlFormat = @"https://api.bitcoinaverage.com/history/%@/per_minute_24h_sliding_window.csv";
    NSStringEncoding *encoding = nil;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:urlFormat,[BACurrency get]]];
    NSString *urlData = [NSString stringWithContentsOfURL:url usedEncoding:encoding error:nil];
    
    NSMutableArray *arrayData = [NSMutableArray arrayWithArray:[urlData componentsSeparatedByString:@"\n"]];
    [arrayData removeObjectAtIndex:0];
    
    for(NSString *str in arrayData) if([str length]==0) {
        [arrayData removeObject:str];
        NSLog(@"dropped one");
    }

    return arrayData;
}

- (void)refreshData {

    NSArray *lines = [self getDataLines];
    if(lines) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
        [dateFormatter setDateFormat:@"y-M-d HH:mm:ss"];
        
        double percent[[lines count]];
        
        //BOOL firstLine = YES;
        NSRange range;
        //double average;
        
        highPrice = 0.0;
        lowPrice = 100000000.0;

        unsigned long ii=0,base=5;
        for(unsigned long i=(base-1),c=[lines count];i<c;i+=base) {
            if([lines[i] length]>0) {
                // split the line up

                //timeStamp = [[dateFormatter dateFromString:[lines[i] substringToIndex:range.location]] timeIntervalSince1970]/300;
                
                percent[ii] = 0;
                for(unsigned long x=0;x<base;x++) {
                    range = [lines[i-x] rangeOfString:@","];
                    percent[ii] += [[lines[i-x] substringFromIndex:(range.location+range.length)] doubleValue];
                }
                percent[ii] /= base;
                
                if(percent[ii] > highPrice) highPrice = percent[ii];
                if(percent[ii] < lowPrice)  lowPrice  = percent[ii];
                ii++;
            }
        }

        NSMutableArray *mutableData = [NSMutableArray arrayWithCapacity:ii];
        for(unsigned int i=0;i<ii;i++) {
            mutableData[i] = [NSNumber numberWithDouble:(1.0-(percent[i]-lowPrice)/(highPrice-lowPrice))];
        }
        
        theData = [NSArray arrayWithArray:mutableData];

        
    } else NSLogDebug(@"No urlData",nil);
}

@end
