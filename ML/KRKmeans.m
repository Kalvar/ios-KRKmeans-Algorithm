//
//  KRKmeans.m
//  KRKmeans V2.3.1
//
//  Created by Kalvar on 2014/6/30.
//  Copyright (c) 2014 - 2015年 Kalvar Lin, ilovekalvar@gmail.com. All rights reserved.
//

#import "KRKmeans.h"
#import "NSArray+Statistics.h"

typedef enum KRKmeansDimensional
{
    // Two Dimensions
    KRKmeansDimensionalTwo   = 0,
    // Multi-Dimensions
    KRKmeansDimensionalMulti = 1
}KRKmeansDimensional;
    
@interface KRKmeans ()

// 上一次運算的群聚中心點集合
@property (nonatomic, strong) NSMutableArray *lastCenters;
// 上一次群聚的最大距離
@property (nonatomic, assign) float lastDistance;
// 當前的迭代數
@property (nonatomic, assign) NSInteger currentGenerations;
// 要進行什麼維度的分群
@property (nonatomic, assign) KRKmeansDimensional dimensional;

@end

@implementation KRKmeans (fixCentrals)

// 使用歐基里德 2 點距離公式
-(NSArray *)_useEuclidCalculateSetsCenters:(NSArray *)_someSets
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
    return _centrals;
}

// 使用 Cosine Similarity method 距離公式
-(NSArray *)_useCosineCalculateSetsCenters:(NSArray *)_someSets
{
    //存放 i 集合中心位置
    NSMutableArray *_centrals = [NSMutableArray new];
    for( NSArray *_everySets in _someSets )
    {
        NSMutableArray *_vectors = [NSMutableArray new];
        //對每一個子集合做同維度累加和平均其累加值的動作
        NSInteger _masterCount   = [_everySets count];
        NSInteger _subCount      = [[_everySets firstObject] count];
        for( NSInteger _subIndex=0; _subIndex<_subCount; _subIndex++ )
        {
            float _sumVector     = 0.0f;
            for( NSInteger _index=0; _index<_masterCount; _index++ )
            {
                NSNumber *_vectorValue  = [[_everySets objectAtIndex:_index] objectAtIndex:_subIndex];
                _sumVector             += [_vectorValue floatValue];
            }
            float _centralVector = _sumVector / _masterCount;
            [_vectors addObject:[NSNumber numberWithFloat:_centralVector]];
        }
        //NSLog(@"_vectors : %@", _vectors);
        [_centrals addObject:_vectors];
    }
    return _centrals;
}

@end

@implementation KRKmeans (fixClusters)

// Euclid distance, 歐基里德 2 點距離公式
-(float)_distanceEuclidX1:(NSArray *)_x1 x2:(NSArray *)_x2
{
    return sqrtf(powf([[_x1 firstObject] floatValue] - [[_x2 firstObject] floatValue], 2) +
                 powf([[_x1 lastObject] floatValue] - [[_x2 lastObject] floatValue], 2));
}

// Calculated by Cosine Similarity method.
-(float)_distanceCosineFeatures:(NSArray *)_classifiedFeatures trainFeatures:(NSArray *)_trainFeatures
{
    float _sumA  = 0.0f;
    float _sumB  = 0.0f;
    float _sumAB = 0.0f;
    int _index   = 0;
    for( NSNumber *_featureValue in _classifiedFeatures )
    {
        NSNumber *_trainValue = [_trainFeatures objectAtIndex:_index];
        float _aValue  = [_featureValue floatValue];
        float _bValue  = [_trainValue floatValue];
        _sumA         += ( _aValue * _aValue );
        _sumB         += ( _bValue * _bValue );
        _sumAB        += ( _aValue * _bValue );
        ++_index;
    }
    return ( _sumAB / sqrtf( _sumA * _sumB ) );
}

-(float)_distanceX1:(NSArray *)_x1 x2:(NSArray *)_x2
{
    float _distance = 0.0f;
    switch (self.dimensional)
    {
        case KRKmeansDimensionalTwo:
            _distance = [self _distanceEuclidX1:_x1 x2:_x2];
            break;
        case KRKmeansDimensionalMulti:
            _distance = [self _distanceCosineFeatures:_x1 trainFeatures:_x2];
            break;
        default:
            break;
    }
    return _distance;
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
            float _lastDistance = 0.0f;
            int _index          = 0;
            //最小距離的索引位置
            int _closeIndex     = 0;
            //跟每一個群聚中心點作比較
            for( NSArray *_xySets in _centrals )
            {
                //個別求出要分群的集合跟其它集合體的距離
                float _distance = [self _distanceX1:_xySets x2:_eachSets];
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
            [_toClusters addObject:_eachSets];
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
    //NSLog(@"_centrals : %@", _centrals);
    [self.centers removeAllObjects];
    [self.centers addObjectsFromArray:_centrals];
    // 取出最小的距離是多少 (也可改取最大距離進行判斷)
    float _minDistance = -1.0f;
    int _index         = 0;
    // 比較新舊群聚中心點的差值
    for( NSArray *_newCenters in _centrals )
    {
        float _distance = [self _distanceX1:[_lastCenters objectAtIndex:_index] x2:_newCenters];
        // 2 點距離不會有負數，直接比較就行
        // 多維距離 (Cosine) 會有負數，必須取絕對值 (?)
        if( _minDistance < 0.0f || _distance < _minDistance )
        {
            _minDistance = _distance;
        }
        ++_index;
    }
    //NSLog(@"_minDistance : %f", _minDistance);
    
    // 當前中心點最小距離與上次距離的誤差 <= 收斂值 || 迭代運算到了限定次數 ( 避免 Memory Leak )
    if( ( _minDistance - self.lastDistance ) <= self.convergenceError || self.currentGenerations >= self.limitGenerations )
    {
        // 即收斂
        //NSLog(@"收斂 : %f", _minDistance - self.lastDistance);
        [self.results removeAllObjects];
        [self.results addObjectsFromArray:_newClusters];
        [self _doneClustering];
    }
    else
    {
        self.lastDistance = _minDistance;
        ++self.currentGenerations;
        _lastCenters      = [NSMutableArray arrayWithArray:_centrals];
        // 繼續跑遞迴分群
        if( [_centrals count] > 0 )
        {
            if( self.eachGeneration )
            {
                self.eachGeneration(self.currentGenerations, _newClusters, _centrals);
            }
            //把所有的群聚全部打散重新變成一個陣列，效率反而比一個一個 Array 處理的要來的快，因為省去了在多個 Array 間重複操作的時間和存取
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
        self.clusterCompletion(YES, self.results, self.centers, self.currentGenerations);
    }
}

@end

@implementation KRKmeans

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
        _centers            = [NSMutableArray new];
        _patterns           = [NSMutableArray new];
        _results            = [NSMutableArray new];
        _convergenceError   = 0.001f;
        _limitGenerations   = 5000;
        _clusterCompletion  = nil;
        _eachGeneration     = nil;
        
        _lastCenters        = nil;
        _lastDistance       = -1.0f;
        _currentGenerations = 0;
        
        _dimensional        = KRKmeansDimensionalTwo;
    }
    return self;
}

/*
 * @ 計算每一個群的中心點
 */
-(NSArray *)calculateSetsCenters:(NSArray *)_someSets
{
    NSArray *_centrals = nil;
    switch (_dimensional)
    {
        case KRKmeansDimensionalTwo:
            _centrals = [self _useEuclidCalculateSetsCenters:_someSets];
            break;
        case KRKmeansDimensionalMulti:
            _centrals = [self _useCosineCalculateSetsCenters:_someSets];
            break;
        default:
            break;
    }
    return _centrals;
}

/*
 * @ 直接分群，不進行迭代運算
 */
-(void)directClusterWithCompletion:(KRKmeansClusteringCompletion)_completion
{
    //If it doesn't have sources, then directly use the original sets to be clustered results.
    if( [_patterns count] < 1 )
    {
        [_results addObjectsFromArray:_sets];
        return;
    }
    
    if( [_sets count] > 0 && [_patterns count] > 0 )
    {
        //先求出每一個集合陣列的中心位置
        NSArray *_centrals             = [self calculateSetsCenters:_sets];
        [_centers removeAllObjects];
        [_centers addObjectsFromArray:_centrals];
        _lastCenters                   = [NSMutableArray arrayWithArray:_centrals];
        NSMutableArray *_clusteredSets = [self _clusterSources:_patterns compareCenters:_centrals];
        int _index = 0;
        for( NSArray *_clusters in _clusteredSets )
        {
            [[_sets objectAtIndex:_index] addObjectsFromArray:[_clusters copy]];
            ++_index;
        }
        [_results addObjectsFromArray:_sets];
    }
    
    if( _completion )
    {
        _completion(YES, _results, _centers, 1);
    }
}

-(void)directCluster
{
    [self directClusterWithCompletion:nil];
}

/*
 * @ K-Means 會進行迭代運算不斷的重新分群
 *   - Two dimensional K-Means
 *   - Multi dimensional K-Means
 */
-(void)clusteringWithCompletion:(KRKmeansClusteringCompletion)_completion eachGeneration:(KRKmeansEachGeneration)_generation
{
    // 由子集合的特徵向量長度來判斷是 2 維或多維
    if( [[[_sets firstObject] firstObject] count] < 3 )
    {
        _dimensional = KRKmeansDimensionalTwo;
    }
    else
    {
        _dimensional = KRKmeansDimensionalMulti;
    }
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

/*
 * @ SSE
 *   - 計算加總所有的分群裡頭每個資料點與中心點距離，
 *     目的是對每次 K-Means 的聚類結果做評量，以找出具有最小SSE的那組聚類結果作為解答。
 */
-(double)calculateSSE
{
    double _sumSSE = 0.0f;
    int _index     = 0;
    for( NSArray *_clusters in _results )
    {
        NSArray *_centrals = [_centers objectAtIndex:_index];
        for( NSArray *_xy in _clusters )
        {
            _sumSSE += [self _distanceX1:_xy x2:_centrals];
        }
        ++_index;
    }
    return _sumSSE;
}

/*
 * @ 新增加集合
 *   - 如果一次只有 1 組，代表該組即為「該群的起始中心點」
 *   - 如果一次有多組，代表「該群的中心點」是該組裡的所有點平均值
 */
-(void)addSets:(NSArray *)_theSets
{
    [_sets addObject:[[NSMutableArray alloc] initWithArray:_theSets]];
}

-(void)addPatterns:(NSArray *)_theSets
{
    [_patterns addObjectsFromArray:_theSets];
}

-(void)printResults
{
    NSLog(@"centers : %@", _centers);
    NSLog(@"====================================\n\n\n");
    int _i = 1;
    for( NSArray *_clusters in _results )
    {
        NSLog(@"clusters (%i) : %@", _i, _clusters);
        NSLog(@"====================================\n\n\n");
        ++_i;
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
