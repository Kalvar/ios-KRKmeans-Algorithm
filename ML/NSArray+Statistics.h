//
//  NSArray+Statistics.h
//  KRKmeans V2.4
//
//  Created by Kalvar on 2014/6/29.
//  Copyright (c) 2014 - 2015年 Kalvar Lin, ilovekalvar@gmail.com. All rights reserved.
//

@interface NSArray(extensionStatistics)

-(float)median;
-(float)maximum;
-(float)minimum;
-(float)sum;
-(float)average;

@end

@implementation NSArray(extensionStatistics)

//求中位數
-(float)median
{
    return [[[self sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:[self count]/2] floatValue];
}

//求最大數
-(float)maximum
{
    float xmax   = [[self firstObject] floatValue];
    //float xmax = -MAXFLOAT;
    //float xmin = MAXFLOAT;
    for (NSNumber *num in self)
    {
        float x = num.floatValue;
        //if (x < xmin) xmin = x;
        if (x > xmax)
        {
            xmax = x;
        }
    }
    return xmax;
}

//求最小數
-(float)minimum
{
    float xmin   = [[self firstObject] floatValue];
    //float xmax = -MAXFLOAT;
    //float xmin = MAXFLOAT;
    for (NSNumber *num in self)
    {
        float x = num.floatValue;
        if (x < xmin) xmin = x;
        //if (x > xmax) xmax = x;
    }
    return xmin;
}

-(float)sum
{
    float _sum = 0.0f;
    for( NSNumber *_number in self )
    {
        _sum += [_number floatValue];
    }
    return _sum;
}

-(float)average
{
    return ( [self sum] / [self count] );
}

@end
