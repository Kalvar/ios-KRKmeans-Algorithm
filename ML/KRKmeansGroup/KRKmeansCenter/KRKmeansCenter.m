//
//  KRKmeansCenter.m
//  KRKmeans
//
//  Created by Kalvar Lin on 2016/6/4.
//  Copyright © 2016年 Kalvar. All rights reserved.
//

#import "KRKmeansCenter.h"

@implementation KRKmeansCenter

- (instancetype)initWithFeatures:(NSArray <NSNumber *> *)f identifier:(NSString *)i
{
    self = [super initWithFeatures:f identifier:i];
    if( self )
    {
        
    }
    return self;
}

- (void)addOneFeature:(NSNumber *)oneFeature
{
    [self.features addObject:[oneFeature copy]];
}

- (void)addFeaturesFromArray:(NSArray <NSNumber *> *)f
{
    [self.features addObjectsFromArray:f];
}

- (void)removeAllFeatures
{
    [self.features removeAllObjects];
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    KRKmeansCenter *p = [[KRKmeansCenter alloc] init];
    p.features        = [[NSMutableArray alloc] initWithArray:self.features copyItems:YES];
    p.identifier      = self.identifier;
    return p;
}


@end
