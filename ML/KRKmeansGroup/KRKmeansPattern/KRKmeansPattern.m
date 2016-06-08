//
//  KRKmeansPattern.m
//  KRKmeans
//
//  Created by Kalvar Lin on 2016/6/4.
//  Copyright © 2016年 Kalvar. All rights reserved.
//

#import "KRKmeansPattern.h"

@implementation KRKmeansPattern (NSCoding)

- (void)encodeObject:(id)object forKey:(NSString *)key
{
    if( nil != object )
    {
        [self.coder encodeObject:object forKey:key];
    }
}

- (id)decodeForKey:(NSString *)key
{
    return [self.coder decodeObjectForKey:key];
}

@end

@implementation KRKmeansPattern

- (instancetype)initWithFeatures:(NSArray <NSNumber *> *)f identifier:(NSString *)i
{
    self = [super init];
    if( self )
    {
        _features   = [[NSMutableArray alloc] initWithArray:f copyItems:YES];
        _identifier = i;
    }
    return self;
}

#pragma --mark NSCopying
-(instancetype)copyWithZone:(NSZone *)zone
{
    KRKmeansPattern *p = [[KRKmeansPattern alloc] init];
    p.features         = [[NSMutableArray alloc] initWithArray:_features copyItems:YES];
    p.identifier       = _identifier;
    return p;
}

#pragma --mark NSCoding
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    self.coder = aCoder;
    [self encodeObject:_features forKey:@"features"];
    [self encodeObject:_identifier forKey:@"identifier"];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.coder  = aDecoder;
        _features   = [self decodeForKey:@"features"];
        _identifier = [self decodeForKey:@"identifier"];
    }
    return self;
}

@end
