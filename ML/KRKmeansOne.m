//
//  KRKmeans V2.4.m
//  KRKmeans V2.4
//
//  Created by Kalvar on 2014/6/29.
//  Copyright (c) 2014 - 2015年 Kalvar Lin, ilovekalvar@gmail.com. All rights reserved.
//

#import "KRKmeansOne.h"
#import "NSArray+Statistics.h"

@interface KRKmeansOne ()

//是否使用自訂的中位數
@property (nonatomic, assign) BOOL useCustomMedian;

@end

@implementation KRKmeansOne

+(instancetype)sharedKmeans
{
    static dispatch_once_t pred;
    static KRKmeansOne *_object = nil;
    dispatch_once(&pred, ^
    {
        _object = [[KRKmeansOne alloc] init];
    });
    return _object;
}

-(instancetype)init
{
    self = [super init];
    if( self )
    {
        _sources         = nil;
        _knowledgeLine   = 0.0f;
        _maxClusters     = nil;
        _minClusters     = nil;
        _midClusters     = nil;
        _overlappings    = nil;
        _customMedian    = 0.0f;
        _useCustomMedian = NO;
    }
    return self;
}

/*
 * @ 1 維 K-Means
 *   - One dimensional K-Means
 */
-(void)clusteringWithCompletion:(KRKmeansOneCompletion)_completion
{
    //找出陣列裡最大值
    float _maxValue = [_sources maximum];
    //找出陣列裡最小值
    float _minValue = [_sources minimum];
    //中位數 = 不使用自訂值 ? 用程式找出中位數 : 自訂值;
    float _midValue = ( !_useCustomMedian ) ? [_sources median] : _customMedian;
    //存放重疊的數值( 重複出現的最大值、最小值、中位數 ), Key = 重疊的 Index 位置，Value = 重疊的值
    if( !_overlappings )
    {
        _overlappings = [NSMutableDictionary new];
    }
    [_overlappings removeAllObjects];
    
    if( !_maxClusters )
    {
        _maxClusters = [NSMutableArray new];
    }
    [_maxClusters removeAllObjects];
    [_maxClusters addObject:[NSNumber numberWithFloat:_maxValue]];
    
    if( !_minClusters )
    {
        _minClusters = [NSMutableArray new];
    }
    [_minClusters removeAllObjects];
    [_minClusters addObject:[NSNumber numberWithFloat:_minValue]];
    
    if( !_midClusters )
    {
        _midClusters = [NSMutableArray new];
    }
    [_midClusters removeAllObjects];
    [_midClusters addObject:[NSNumber numberWithFloat:_midValue]];
    
    NSUInteger _index            = 0;
    NSUInteger _overlappingIndex = 0;
    for( NSNumber *_everyNumber in _sources )
    {
        //Max 群聚的平均值
        float _averageMax = [_maxClusters average];
        //Min 群聚的平均值
        float _averageMin = [_minClusters average];
        //Mid 群聚的平均值
        float _averageMid = [_midClusters average];
        
        float _someValue  = _everyNumber.floatValue;
        
        //計算與各群聚相差的絕對值( 求出距離差異 )
        float _absMax     = fabsf(_someValue - _averageMax);
        float _absMin     = fabsf(_someValue - _averageMin);
        float _absMid     = fabsf(_someValue - _averageMid);
        
        //準備將距離越相近的數值放在一起
        //如果為 0 就代表已經在同一群裡了
        if( _maxValue - _someValue == 0 || _minValue - _someValue == 0 || _midValue - _someValue == 0 )
        {
            //記錄重複出現的最大值、最小值、中位數
            _overlappingIndex += _index;
            [_overlappings setObject:[_everyNumber copy] forKey:[NSNumber numberWithUnsignedInteger:_overlappingIndex]];
            //後續動作不做
            //...
        }
        //判斷目前 _someValue 之距離最接近最大數的群聚
        else if( _absMax < _absMin && _absMax < _absMid )
        {
            //放入至最大值群聚裡
            [_maxClusters addObject:[_everyNumber copy]];
        }
        //判斷目前 _someValue 之距離最最接近最小數的群聚
        else if ( _absMin < _absMax && _absMin < _absMid )
        {
            //放入至最小值群聚裡
            [_minClusters addObject:[_everyNumber copy]];
        }
        //判斷目前 _someValue 之距離最接近中位數的群聚
        else if( _absMid < _absMax && _absMid < _absMin )
        {
            [_midClusters addObject:[_everyNumber copy]];
        }
        else
        {
            //如果值都相等，就放入中位數群聚裡
            [_midClusters addObject:[_everyNumber copy]];
        }
        
        ++_index;
    }
    
    _knowledgeLine = ([_maxClusters maximum] + [_minClusters minimum] + [_midClusters median]) / 3;
    
    if( _completion )
    {
        _completion(YES, _knowledgeLine, _maxClusters, _minClusters, _midClusters, _overlappings);
    }
}

-(void)clustering
{
    [self clusteringWithCompletion:nil];
}

-(void)printResults
{
    NSLog(@"knowledgeLine : %f", _knowledgeLine);
    NSLog(@"maxClusters : %@", _maxClusters);
    NSLog(@"minClusters : %@", _minClusters);
    NSLog(@"midClusters : %@", _midClusters);
    NSLog(@"overlappings : %@", _overlappings);
}

#pragma --mark Setters
-(void)setCustomMedian:(float)_median
{
    _useCustomMedian = YES;
    _customMedian    = _median;
}

@end

