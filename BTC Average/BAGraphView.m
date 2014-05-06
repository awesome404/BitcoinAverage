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
    NSDate *startTime, *endTime;
    double averagePosition, highPrice, lowPrice, averagePrice;
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
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    unsigned long i,c; // reusable counters
    double x, y; // reusable coords
    double width = rect.size.width, eighth = rect.size.height/8;

    // strong grey lines
    CGContextSetRGBStrokeColor(context, 0.9, 0.9, 0.9, 1);

    for(i=2;i<=6;i+=2) {
        CGContextMoveToPoint(context, 0, eighth*i);
        CGContextAddLineToPoint(context, width, eighth*i);
    }

    CGContextStrokePath(context);

    // weak grey lines
    CGContextSetRGBStrokeColor(context, 0.95, 0.95, 0.95, 1);

    for(i=3;i<=5;i+=2) {
        CGContextMoveToPoint(context, 0, eighth*i);
        CGContextAddLineToPoint(context, width, eighth*i);
    }
    
    CGContextStrokePath(context);

    if(theData==nil) {
        NSString *error = @"Error: Could not fetch graph data.";
        CGSize cgSize = [error sizeWithAttributes:nil];
        [error drawAtPoint:CGPointMake((rect.size.width-cgSize.width)/2,(rect.size.height/2)-cgSize.height) withAttributes:nil];
        return;
    }
    
    // red daily average line
    CGContextSetRGBStrokeColor(context, 1, 0.8, 0.8, 1);
    
    y = (averagePosition * (eighth*4))+(eighth*2);
    CGContextMoveToPoint(context, 0, y);
    CGContextAddLineToPoint(context, width, y);
    
    CGContextStrokePath(context);
    
    // graph data
    CGContextSetRGBStrokeColor(context, 0.2, 0.2, 0.8, 0.8);
        
    for(i=0, c=[theData count]-1; i<=c; i++) {
        x = ((double)i/(double)c) * width;
        y = ([theData[i] doubleValue] * (eighth*4))+(eighth*2);
        if(!i) CGContextMoveToPoint(context,x,y);
        else CGContextAddLineToPoint(context,x,y);
    }
    CGContextStrokePath(context);

    NSString *strOut = nil;
    CGSize cgSize;

    NSDictionary *red = @{NSForegroundColorAttributeName:[UIColor colorWithRed:1 green:0.8 blue:0.8 alpha:1]};
    NSDictionary *grey = @{NSForegroundColorAttributeName:[UIColor lightGrayColor]};

    strOut = [NSString stringWithFormat:@"high: %.2f",highPrice];
    cgSize = [strOut sizeWithAttributes:grey];
    [strOut drawAtPoint:CGPointMake(10,eighth*2-cgSize.height) withAttributes:grey];
    
    strOut = [NSString stringWithFormat:@"low: %.2f",lowPrice];
    [strOut drawAtPoint:CGPointMake(10,eighth*6) withAttributes:grey];

    double mid = (highPrice+lowPrice)/2;
    
    if(averagePrice > mid) { // mid below, average on top
        strOut = [NSString stringWithFormat:@"mid: %.2f",mid];
        [strOut drawAtPoint:CGPointMake(10,eighth*4) withAttributes:grey];

        strOut = [NSString stringWithFormat:@"avg: %.2f",averagePrice];
        cgSize = [strOut sizeWithAttributes:red];
        [strOut drawAtPoint:CGPointMake(10,(averagePosition * (eighth*4))+(eighth*2)-cgSize.height) withAttributes:red];
    } else { // mid on top, average below
        strOut = [NSString stringWithFormat:@"mid: %.2f",mid];
        cgSize = [strOut sizeWithAttributes:grey];
        [strOut drawAtPoint:CGPointMake(10,eighth*4-cgSize.height) withAttributes:grey];
        
        strOut = [NSString stringWithFormat:@"avg: %.2f",averagePrice];
        [strOut drawAtPoint:CGPointMake(10,(averagePosition * (eighth*4))+(eighth*2)) withAttributes:red];
    }
    
    // output the date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];;
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    strOut = [dateFormatter stringFromDate:endTime];
    cgSize = [strOut sizeWithAttributes:grey];
    [strOut drawAtPoint:CGPointMake(width-8-cgSize.width,eighth*6) withAttributes:grey];
}

- (NSArray*)getDataLines {

    NSString *urlFormat = @"https://api.bitcoinaverage.com/history/%@/per_minute_24h_sliding_window.csv";
    NSStringEncoding *encoding = nil;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:urlFormat,[BACurrency get]]];
    NSString *urlData = [NSString stringWithContentsOfURL:url usedEncoding:encoding error:nil];
    
    if(urlData) {
        NSMutableArray *arrayData = [NSMutableArray arrayWithArray:[urlData componentsSeparatedByString:@"\n"]];
        [arrayData removeObjectAtIndex:0];
        
        for(NSString *str in arrayData) if([str length]==0) [arrayData removeObject:str];

        return ([arrayData count]>0)?arrayData:nil;
    }
    return nil;
}

- (NSArray*)refreshData {

    NSArray *lines = [self getDataLines];
    if(lines) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
        [dateFormatter setDateFormat:@"y-M-d HH:mm:ss"];
        
        NSRange range = [[lines firstObject] rangeOfString:@","];
        startTime = [dateFormatter dateFromString:[[lines firstObject] substringToIndex:range.location]];

        range = [[lines lastObject] rangeOfString:@","];
        endTime = [dateFormatter dateFromString:[[lines lastObject] substringToIndex:range.location]];
        
        averagePrice = 0.0;
        highPrice = 0.0;
        lowPrice = 100000000.0;

        unsigned long i=0,ii=0,c,base=5;
        double prices[([lines count]/base)+base];

        for(i=(base-1),c=[lines count];i<c;i+=base) {
            if([lines[i] length]>0) {
                prices[ii] = 0;
                for(unsigned long x=0;x<base;x++) {
                    range = [lines[i-x] rangeOfString:@","];
                    prices[ii] += [[lines[i-x] substringFromIndex:(range.location+range.length)] doubleValue];
                }
                averagePrice += prices[ii];
                prices[ii] /= base;
                
                if(prices[ii] > highPrice) highPrice = prices[ii];
                if(prices[ii] < lowPrice)  lowPrice  = prices[ii];
                ii++;
            }
        }
        
        averagePrice /= (ii*base);
        averagePosition = 1.0-(averagePrice-lowPrice)/(highPrice-lowPrice);

        NSMutableArray *mutableData = [NSMutableArray arrayWithCapacity:ii];
        for(i=0;i<ii;i++) {
            mutableData[i] = [NSNumber numberWithDouble:(1.0-(prices[i]-lowPrice)/(highPrice-lowPrice))];
        }
        
        return mutableData;

    } else NSLogDebug(@"No urlData",nil);
    return nil;
}

@end
