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
    double dailyAverage, highPrice, lowPrice;
    //NSArray *theData;
}

@property NSString *currency;

- (NSArray*)refreshData;
- (NSArray*)getDataLines;

@end


@implementation BAGraphView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    NSArray *theData = [self refreshData];
    
    if(theData==nil) return;

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    double width = rect.size.width, eighth = rect.size.height/8;

    // strong grey lines
    CGContextSetRGBStrokeColor(context, 0.9, 0.9, 0.9, 1.0);

    CGContextMoveToPoint(context, 0, eighth*2);
    CGContextAddLineToPoint(context, width, eighth*2);

    CGContextMoveToPoint(context, 0, eighth*4);
    CGContextAddLineToPoint(context, width, eighth*4);

    CGContextMoveToPoint(context, 0, eighth*6);
    CGContextAddLineToPoint(context, width, eighth*6);
    
    CGContextStrokePath(context);

    // weak grey lines
    CGContextSetRGBStrokeColor(context, 0.97, 0.97, 0.97, 1.0);
    
    CGContextMoveToPoint(context, 0, eighth*3);
    CGContextAddLineToPoint(context, width, eighth*3);
    
    CGContextMoveToPoint(context, 0, eighth*5);
    CGContextAddLineToPoint(context, width, eighth*5);
    
    CGContextStrokePath(context);
    
    // graph data
    CGContextSetRGBStrokeColor(context, 0.2, 0.2, 0.8, 1.0);
    
    double x,y;
    for(unsigned long i=0, c=[theData count]-1;i<=c;i++) {
        x = ((double)i/(double)c) * width;
        y = ([theData[i] doubleValue] * (rect.size.height/2))+(rect.size.height/4);
        if(!i) CGContextMoveToPoint(context,x,y);
        else CGContextAddLineToPoint(context,x,y);
    }

    CGContextStrokePath(context);

    // red daily average line
    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 0.1);
    
    CGContextMoveToPoint(context, 0, (dailyAverage * (rect.size.height/2))+(rect.size.height/4));
    CGContextAddLineToPoint(context, width, (dailyAverage * (rect.size.height/2))+(rect.size.height/4));
    
    CGContextStrokePath(context);
    
    CGContextSetTextPosition(context, 20, eighth*2);
    NSString *test = @"test";
    
    [test drawAtPoint:CGMakePoint() withAttributes:<#(NSDictionary *)#>]
    
}

- (NSArray*)getDataLines {
    NSString *urlFormat = @"https://api.bitcoinaverage.com/history/%@/per_minute_24h_sliding_window.csv";
    NSStringEncoding *encoding = nil;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:urlFormat,[BACurrency get]]];
    NSString *urlData = [NSString stringWithContentsOfURL:url usedEncoding:encoding error:nil];
    
    if(urlData) {
        NSMutableArray *arrayData = [NSMutableArray arrayWithArray:[urlData componentsSeparatedByString:@"\n"]];
        [arrayData removeObjectAtIndex:0];
        
        for(NSString *str in arrayData) if([str length]==0) {
            [arrayData removeObject:str];
        }

        return arrayData;
    }
    return nil;
}

- (NSArray*)refreshData {

    NSArray *lines = [self getDataLines];
    if(lines) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
        [dateFormatter setDateFormat:@"y-M-d HH:mm:ss"];
        
        double percent[[lines count]];
        
        //BOOL firstLine = YES;
        NSRange range;
        //double average;
        
        dailyAverage = 0.0;
        highPrice = 0.0;
        lowPrice = 100000000.0;

        unsigned long i=0,ii=0,c,base=5;
        for(i=(base-1),c=[lines count];i<c;i+=base) {
            if([lines[i] length]>0) {
                // split the line up

                //timeStamp = [[dateFormatter dateFromString:[lines[i] substringToIndex:range.location]] timeIntervalSince1970]/300;
                
                percent[ii] = 0;
                for(unsigned long x=0;x<base;x++) {
                    range = [lines[i-x] rangeOfString:@","];
                    percent[ii] += [[lines[i-x] substringFromIndex:(range.location+range.length)] doubleValue];
                }
                dailyAverage += percent[ii];
                percent[ii] /= base;
                
                if(percent[ii] > highPrice) highPrice = percent[ii];
                if(percent[ii] < lowPrice)  lowPrice  = percent[ii];
                ii++;
            }
        }
        
        dailyAverage /= (ii*base);
        NSLogDebug(@"dailyAverage: %f",dailyAverage);
        dailyAverage = 1.0-(dailyAverage-lowPrice)/(highPrice-lowPrice);

        NSMutableArray *mutableData = [NSMutableArray arrayWithCapacity:ii];
        for(i=0;i<ii;i++) {
            mutableData[i] = [NSNumber numberWithDouble:(1.0-(percent[i]-lowPrice)/(highPrice-lowPrice))];
        }
        
        return mutableData;

        
    } else NSLogDebug(@"No urlData",nil);
    return nil;
}

@end
