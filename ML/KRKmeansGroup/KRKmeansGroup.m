//
//  KRKmeansGroup.m
//  KRKmeans
//
//  Created by Kalvar Lin on 2016/6/4.
//  Copyright © 2016年 Kalvar. All rights reserved.
//

#import "KRKmeansGroup.h"

@interface KRKmeansGroup ()

@property (nonatomic, strong) KRKmeansKernel *calculator;
@property (nonatomic, weak) NSCoder *coder;

@end

@implementation KRKmeansGroup (NSCoding)

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

@implementation KRKmeansGroup

- (instancetype)initWithPatterns:(NSArray <KRKmeansPattern *> *)samples groupId:(NSString *)groupId
{
    self = [super init];
    if( self )
    {
        _identifier = groupId;
        
        _patterns   = [NSMutableArray new];
        [self addPatterns:samples];
        
        _center     = nil;
        _lastCenter = nil;
        
        _calculator = [[KRKmeansKernel alloc] init];
        self.kernel = KRKmeansKernelEuclidean;
        self.sigma  = 2.0f;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithPatterns:nil groupId:@""];
}

- (void)addPattern:(KRKmeansPattern *)pattern
{
    if( nil == pattern )
    {
        return;
    }
    // To use weak reference with outside patterns.
    [_patterns addObject:pattern];
}

- (void)addPatterns:(NSArray <KRKmeansPattern *> *)batchPatterns
{
    if( nil == batchPatterns )
    {
        return;
    }
    [_patterns addObjectsFromArray:batchPatterns];
}

- (void)renewCenter
{
    _lastCenter = [_center copy];
    if( nil == _patterns || [_patterns count] == 0 )
    {
        return;
    }
    
    [_center removeAllFeatures];
    // To average multi-dimensional sub-vectors be central vectors
    NSInteger patternCount        = [_patterns count];
    // 取出 Pattern 裡的 Features 個數
    KRKmeansPattern *firstPattern = [_patterns firstObject];
    NSInteger featuresCount       = [firstPattern.features count];
    for( NSInteger i=0; i<featuresCount; i++ )
    {
        __block double dimensionSum = 0.0f;
        [_patterns enumerateObjectsUsingBlock:^(KRKmeansPattern * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSNumber *featureValue  = [obj.features objectAtIndex:i];
            dimensionSum           += [featureValue doubleValue];
        }];
        dimensionSum /= patternCount;
        [_center addOneFeature:@(dimensionSum)];
    }

}

- (void)removeAllPatterns
{
    if( _patterns )
    {
        [_patterns removeAllObjects];
    }
}

- (void)resetCenters
{
    _center     = nil;
    _lastCenter = nil;
}

- (double)distanceX1:(NSArray *)x1 x2:(NSArray *)x2
{
    return [_calculator distanceBetweenX1:x1 x2:x2];
}

- (double)distanceCenterToFeatures:(NSArray *)features
{
    return [self distanceX1:_center.features x2:features];
}

// To calculate difference distance between last center and current new center.
- (double)centerDifference
{
    return _calculator ? [_calculator distanceBetweenX1:_lastCenter.features x2:_center.features] : 0.0f;
}

// To calculate all patterns to current center that distance summation. The SSE will use this value to do judgement.
// 計算本群裡所有 Patterns 對 Center 的距離總和，要計算 SSE 用的。
- (double)groupDistance
{
    __block double sum = 0.0f;
    if( _patterns && [_patterns count] > 0 )
    {
        for( KRKmeansPattern *pattern in _patterns )
        {
            sum += [self distanceX1:pattern.features x2:_center.features];
        }
    }
    return sum;
}

#pragma mark - Setters
- (void)setKernel:(KRKmeansKernels)kernel
{
    if( _calculator )
    {
        _calculator.kernel = kernel;
    }
}

- (void)setSigma:(double)sigma
{
    if( _calculator )
    {
        _calculator.sigma = sigma;
    }
}

// Copy that setting center.
- (void)setCenter:(KRKmeansCenter *)center
{
    _center = ( nil != center ) ? [center copy] : center;
}

#pragma mark - Getters
- (KRKmeansKernels)kernel
{
    return _calculator ? _calculator.kernel : KRKmeansKernelEuclidean;
}

- (double)sigma
{
    return _calculator ? _calculator.sigma : 0.0f;
}

#pragma --mark NSCoding
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    self.coder = aCoder;
    [self encodeObject:_identifier forKey:@"identifier"];
    [self encodeObject:_center forKey:@"center"];
    [self encodeObject:_calculator forKey:@"calculator"]; // Kernel & Sigma are use in KRKmeansKernel.
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.coder  = aDecoder;
        _identifier = [self decodeForKey:@"identifier"];
        _center     = [self decodeForKey:@"center"];
        _calculator = [self decodeForKey:@"calculator"];
        
        // Don't forget to alloc new memory for them since we didn't save it with self.coder before.
        _patterns   = [NSMutableArray new];
    }
    return self;
}

@end


