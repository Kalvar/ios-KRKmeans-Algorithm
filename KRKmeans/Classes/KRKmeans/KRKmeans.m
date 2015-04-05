//
//  KRKmeans.m
//  KRKmeans V2.0
//
//  Created by Kalvar on 2014/6/30.
//  Copyright (c) 2014 - 2015年 Kalvar Lin, ilovekalvar@gmail.com. All rights reserved.
//

#import "KRKmeans.h"
#import "NSArray+Statistics.h"

@interface KRKmeans()

//上一次運算的群聚中心點集合
@property (nonatomic, strong) NSMutableArray *lastCenters;
//上一次群聚的最大距離
@property (nonatomic, assign) float lastDistance;
//當前的迭代數
@property (nonatomic, assign) NSInteger currentGenerations;

@end

@implementation KRKmeans(fixClusters)
/*
 * @ 計算 2 點距離
 */
-(float)_distanceX1:(NSArray *)_x1 x2:(NSArray *)_x2
{
    return sqrtf(powf([[_x1 firstObject] floatValue] - [[_x2 firstObject] floatValue], 2) +
                 powf([[_x1 lastObject] floatValue] - [[_x2 lastObject] floatValue], 2));
}

/*
 * @ 依照群聚中心點 _centers 進行 _sources 群聚分類
 */
-(NSMutableArray *)_clusterSources:(NSArray *)_sources compareCenters:(NSArray *)_centers
{
    NSMutableArray *_clusters = nil;
    NSArray *_centrals        = _centers;
    if( [_centrals count] > 0 )
    {
        _clusters = [NSMutableArray new];
        //先建立對應空間給要分群的陣列，這樣後續直接將數據放入該對應位置的群聚即可，ex : _centrals[0] = _sets[0], _centrals[n] = _sets[n] ...
        NSInteger _totalClusters = [_centrals count];
        for(int _i=0; _i<_totalClusters; _i++)
        {
            [_clusters addObject:[NSMutableArray new]];
        }
        //進行將目標集合分類至所屬分群的動作
        for( NSArray *_eachSets in _sources )
        {
            float _x            = [[_eachSets firstObject] floatValue];
            float _y            = [[_eachSets lastObject] floatValue];
            float _lastDistance = 0.0f;
            int _index          = 0;
            //最小距離的索引位置
            int _closeIndex     = 0;
            //跟每一個群聚中心點作比較
            for( NSArray *_xySets in _centrals )
            {
                //個別求出要分群的集合跟其它集合體的距離( 歐基里德定律, 求 2 個座標點的距離 )
                float _differX  = _x - [[_xySets firstObject] floatValue];
                float _differY  = _y - [[_xySets lastObject] floatValue];
                float _distance = sqrtf( powf(_differX, 2) + powf(_differY, 2) );
                //比較出最小的距離，即為歸納分群的對象
                //是第 1 筆 || 當前距離 < 上一次的距離
                if( _index == 0 || _distance < _lastDistance )
                {
                    //記錄起來
                    _lastDistance = _distance;
                    _closeIndex   = _index;
                }
                ++_index;
            }
            //直接將將當前 (x, y) 放入群聚裡
            NSMutableArray *_toClusters = [_clusters objectAtIndex:_closeIndex];
            [_toClusters addObject:@[[NSNumber numberWithFloat:_x], [NSNumber numberWithFloat:_y]]];
        }
    }
    return _clusters;
}

-(void)_renewClusters:(NSArray *)_newClusters
{
    NSMutableArray *_lastCenters = self.lastCenters;
    /*
     * @ Steps
     *   - 1. 全部分類完後，開始重新計算每一個群聚的中心點
     *   - 2. 計算該次迭代的所有群聚中心點與上一次舊的群聚中心點相減，取出最大距離誤差
     *   - 3. 比較是否 <= 收斂誤差，如是，即停止運算，如否，則進行第 4 步驟的遞迴迭代運算
     *   - 4. 依照這群聚中心點，進行迭代運算，重新計算與分類所有的已分類好的群聚，並重複第 1 到第 3 步驟
     */
    NSArray *_centrals = [self calculateSetsCenters:_newClusters];
    //取出最大的距離是多少 (也可改取最小距離進行判斷)
    float _maxDistance = -1.0f;
    int _index         = 0;
    for( NSArray *_newCenters in _centrals )
    {
        float _distance = [self _distanceX1:[_lastCenters objectAtIndex:_index] x2:_newCenters];
        //距離不會有負數，所以直接比較就行
        if( _maxDistance <= _distance )
        {
            _maxDistance = _distance;
        }
        ++_index;
    }
    //NSLog(@"_maxDistance : %f", _maxDistance);
    
    //當前中心點與上次距離的誤差 <= 收斂值 || 迭代運算到了限定次數 ( 避免 Memory Leak )
    if( ( _maxDistance - self.lastDistance ) <= self.convergenceError || self.currentGenerations >= self.limitGenerations )
    {
        //即收斂
        //NSLog(@"收斂 : %f", _maxDistance - self.lastDistance);
        [self.results removeAllObjects];
        [self.results addObjectsFromArray:_newClusters];
        [self _doneClustering];
    }
    else
    {
        self.lastDistance = _maxDistance;
        ++self.currentGenerations;
        _lastCenters      = [NSMutableArray arrayWithArray:_centrals];
        //繼續跑遞迴分群
        if( [_centrals count] > 0 )
        {
            if( self.eachGeneration )
            {
                self.eachGeneration(self.currentGenerations, _newClusters);
            }
            //把所有的群聚全部打散重新變成一個陣列
            NSMutableArray *_combinedSources = [NSMutableArray new];
            for( NSArray *_clusters in _newClusters )
            {
                [_combinedSources addObjectsFromArray:_clusters];
            }
            [self _renewClusters:[self _clusterSources:(NSArray *)_combinedSources compareCenters:_centrals]];
        }
    }
}

-(void)_doneClustering
{
    if( self.clusterCompletion )
    {
        self.clusterCompletion(YES, self.results, self.currentGenerations);
    }
}

@end

@implementation KRKmeans

@synthesize sets               = _sets;
@synthesize sources            = _sources;
@synthesize results            = _results;
@synthesize convergenceError   = _convergenceError;
@synthesize limitGenerations   = _limitGenerations;
@synthesize clusterCompletion  = _clusterCompletion;
@synthesize eachGeneration     = _eachGeneration;

@synthesize lastCenters        = _lastCenters;
@synthesize lastDistance       = _lastDistance;
@synthesize currentGenerations = _currentGenerations;

+(instancetype)sharedKmeans
{
    static dispatch_once_t pred;
    static KRKmeans *_object = nil;
    dispatch_once(&pred, ^
    {
        _object = [[KRKmeans alloc] init];
    });
    return _object;
}

-(instancetype)init
{
    self = [super init];
    if( self )
    {
        _sets               = [NSMutableArray new];
        _sources            = nil;
        _results            = [NSMutableArray new];
        _convergenceError   = 0.001f;
        _limitGenerations   = 5000;
        _clusterCompletion  = nil;
        _eachGeneration     = nil;
        
        _lastCenters        = nil;
        _lastDistance       = -1.0f;
        _currentGenerations = 0;
    }
    return self;
}

/*
 * @ 計算每一個群的中心點
 */
-(NSArray *)calculateSetsCenters:(NSArray *)_someSets
{
    //存放 i 集合中心位置
    NSMutableArray *_centrals = [NSMutableArray new];
    for( NSArray *_everySets in _someSets )
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
    
    /*
    if( nil == _lastCenters )
    {
        _lastCenters = [_centrals copy];
    }
     */
    
    return _centrals;
}

/*
 * @ 直接分群，不進行迭代運算
 */
-(void)directCluster
{
    if( _sources == nil )
    {
        [_results addObjectsFromArray:_sets];
        return;
    }
    
    if( [_sets count] > 0 && [_sources count] > 0 )
    {
        //先求出每一個集合陣列的中心位置
        NSArray *_centrals             = [self calculateSetsCenters:_sets];
        _lastCenters                   = [NSMutableArray arrayWithArray:_centrals];
        NSMutableArray *_clusteredSets = [self _clusterSources:_sources compareCenters:_centrals];
        int _index = 0;
        for( NSArray *_clusters in _clusteredSets )
        {
            [[_sets objectAtIndex:_index] addObjectsFromArray:[_clusters copy]];
            ++_index;
        }
        [_results addObjectsFromArray:_sets];
        //[self _doneClustering];
    }
}

/*
 * @ 2 維 K-Means，會進行迭代運算不斷的重新分群
 *   - Two dimensional K-Means
 */
-(void)clusteringWithCompletion:(KRKmeansClusteringCompletion)_completion eachGeneration:(KRKmeansEachGeneration)_generation
{
    _clusterCompletion  = _completion;
    _eachGeneration     = _generation;
    _currentGenerations = 0;
    [self directCluster];
    [self _renewClusters:_results];
}

-(void)clusteringWithCompletion:(KRKmeansClusteringCompletion)_completion
{
    [self clusteringWithCompletion:_completion eachGeneration:nil];
}

-(void)clustering
{
    [self clusteringWithCompletion:nil];
}

-(void)addSets:(NSArray *)_theSets
{
    [_sets addObject:[[NSMutableArray alloc] initWithArray:_theSets]];
}

-(void)printResults
{
    for( NSArray *_clusters in _results )
    {
        NSLog(@"_clusters : %@", _clusters);
        NSLog(@"================== \n\n\n");
    }
}

#pragma --mark Blocks
-(void)setClusterCompletion:(KRKmeansClusteringCompletion)_theBlock
{
    _clusterCompletion = _theBlock;
}

-(void)setEachGeneration:(KRKmeansEachGeneration)_theBlock
{
    _eachGeneration    = _theBlock;
}

@end
