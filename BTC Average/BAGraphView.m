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
    
    if(theData==nil) return;

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    double x,y; // reusable coords
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
    
    for(unsigned long i=0, c=[theData count]-1;i<=c;i++) {
        x = ((double)i/(double)c) * width;
        y = ([theData[i] doubleValue] * (eighth*4))+(eighth*2);
        if(!i) CGContextMoveToPoint(context,x,y);
        else CGContextAddLineToPoint(context,x,y);
    }
    CGContextStrokePath(context);

    // red daily average line
    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 0.15);
    
    y = (averagePosition * (eighth*4))+(eighth*2);
    CGContextMoveToPoint(context, 0, y);
    CGContextAddLineToPoint(context, width, y);
    
    CGContextStrokePath(context);

    NSString *strOut = nil;
    CGSize cgSize;
    
    //CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 0.6);
    //[[UIColor redColor] set];
    
    
    strOut = [NSString stringWithFormat:@"high: %.2f",highPrice];
    cgSize = [strOut sizeWithAttributes:nil];
    [strOut drawAtPoint:CGPointMake(10,eighth*2-cgSize.height) withAttributes:nil];
    
    strOut = [NSString stringWithFormat:@"low: %.2f",lowPrice];
    [strOut drawAtPoint:CGPointMake(10,eighth*6) withAttributes:nil];

    double mid = (highPrice+lowPrice)/2;
    
    if(averagePrice > mid) { // mid below, average on top
        strOut = [NSString stringWithFormat:@"mid: %.2f",mid];
        [strOut drawAtPoint:CGPointMake(10,eighth*4) withAttributes:nil];

        strOut = [NSString stringWithFormat:@"avg: %.2f",averagePrice];
        cgSize = [strOut sizeWithAttributes:nil];
        [strOut drawAtPoint:CGPointMake(10,(averagePosition * (eighth*4))+(eighth*2)-cgSize.height) withAttributes:nil];
    } else { // mid on top, average below
        strOut = [NSString stringWithFormat:@"mid: %.2f",mid];
        cgSize = [strOut sizeWithAttributes:nil];
        [strOut drawAtPoint:CGPointMake(10,eighth*4-cgSize.height) withAttributes:nil];
        
        strOut = [NSString stringWithFormat:@"avg: %.2f",averagePrice];
        [strOut drawAtPoint:CGPointMake(10,(averagePosition * (eighth*4))+(eighth*2)) withAttributes:nil];
    }
    
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
        
        averagePrice = 0.0;
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
                averagePrice += percent[ii];
                percent[ii] /= base;
                
                if(percent[ii] > highPrice) highPrice = percent[ii];
                if(percent[ii] < lowPrice)  lowPrice  = percent[ii];
                ii++;
            }
        }
        
        averagePrice /= (ii*base);
        NSLogDebug(@"dailyAverage: %f",averagePrice);
        averagePosition = 1.0-(averagePrice-lowPrice)/(highPrice-lowPrice);

        NSMutableArray *mutableData = [NSMutableArray arrayWithCapacity:ii];
        for(i=0;i<ii;i++) {
            mutableData[i] = [NSNumber numberWithDouble:(1.0-(percent[i]-lowPrice)/(highPrice-lowPrice))];
        }
        
        return mutableData;

        
    } else NSLogDebug(@"No urlData",nil);
    return nil;
}

@end
