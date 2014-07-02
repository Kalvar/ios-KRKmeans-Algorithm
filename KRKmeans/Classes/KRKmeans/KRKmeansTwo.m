//
//  KRKmeans V1.0Two.m
//  KRKmeans V1.0
//
//  Created by Kalvar on 2014/6/30.
//  Copyright (c) 2014年 Kalvar. All rights reserved.
//

#import "KRKmeansTwo.h"
#import "NSArray+Statistics.h"

@implementation KRKmeansTwo

@synthesize sets     = _sets;
@synthesize sources  = _sources;
@synthesize results  = _results;

+(instancetype)sharedKmeans
{
    static dispatch_once_t pred;
    static KRKmeansTwo *_object = nil;
    dispatch_once(&pred, ^
    {
        _object = [[KRKmeansTwo alloc] init];
    });
    return _object;
}

-(instancetype)init
{
    self = [super init];
    if( self )
    {
        _sets     = [NSMutableArray new];
        _sources  = nil;
        _results  = [NSMutableArray new];
    }
    return self;
}

/*
 * @ 2 維 K-Means
 *   - Two dimensional K-Means
 */
-(void)clustering
{    
    if( [_sets count] > 0 )
    {
        /*
         * @ 先求出每一個集合陣列的中心位置
         */
        //存放 i 集合中心位置
        NSMutableArray *_centrals = [NSMutableArray new];
        for( NSArray *_everySets in _sets )
        {
            //對每一個子集合做(x, y)累加的動作
            float _sumX = 0.0f;
            float _sumY = 0.0f;
            for( NSArray *_subSets in _everySets )
            {
                _sumX += [[_subSets firstObject] floatValue];
                _sumY += [[_subSets lastObject] floatValue];
            }
            NSInteger _length = [_everySets count];
            float _x          = _sumX / _length;
            float _y          = _sumY / _length;
            NSArray *_xySets  = @[[NSNumber numberWithFloat:_x], [NSNumber numberWithFloat:_y]];
            [_centrals addObject:[_xySets copy]];
        }
        
        if( [_centrals count] > 0 )
        {
            //進行將目標集合分類至所屬分群的動作
            for( NSArray *_eachSets in _sources )
            {
                float _x            = [[_eachSets firstObject] floatValue];
                float _y            = [[_eachSets lastObject] floatValue];
                float _lastDistance = 0.0f;
                int _index          = 0;
                //最小距離的位置
                int _closeIndex     = 0;
                float _closeX       = 0.0f;
                float _closeY       = 0.0f;
                for( NSArray *_xySets in _centrals )
                {
                    //各別求出要分群的集合跟其它集合體的距離( 歐基里德定律, 求 2 個座標標的距離 )
                    float _differX  = _x - [[_xySets firstObject] floatValue];
                    float _differY  = _y - [[_xySets lastObject] floatValue];
                    float _distance = sqrtf( powf(_differX, 2) + powf(_differY, 2) );
                    //比較出最小的距離，即為歸納分群的對象
                    //是第 1 筆 || 現在距離 < 上一次的距離
                    if( _index == 0 || _distance < _lastDistance )
                    {
                        //記錄起來
                        _lastDistance = _distance;
                        _closeIndex   = _index;
                        _closeX       = _x;
                        _closeY       = _y;
                    }
                    ++_index;
                }
                //取出最接近的群體
                NSMutableArray *_closeClusters = [_sets objectAtIndex:_closeIndex];
                //記憶體淺層連結
                [_closeClusters addObject:@[[NSNumber numberWithFloat:_closeX], [NSNumber numberWithFloat:_closeY]]];
                //[_sets replaceObjectAtIndex:_closeIndex withObject:_closeClusters];
            }
        }
        [_results addObjectsFromArray:_sets];
    }
    
}

-(void)addSets:(NSMutableArray *)_theSets
{
    [_sets addObject:_theSets];
}

-(void)printResults
{
    for( NSArray *_clusters in _results )
    {
        NSLog(@"_clusters : %@", _clusters);
        NSLog(@"================== \n\n\n");
    }
}

@end
