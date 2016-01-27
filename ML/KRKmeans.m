//
//  KRKmeans.m
//  KRKmeans V2.4.1
//
//  Created by Kalvar on 2014/6/30.
//  Copyright (c) 2014 - 2015年 Kalvar Lin, ilovekalvar@gmail.com. All rights reserved.
//

#import "KRKmeans.h"
#import "NSArray+Statistics.h"
#import "KRKmeansSaves.h"
    
@interface KRKmeans ()

// 上一次運算的群聚中心點集合
@property (nonatomic, strong) NSMutableArray *lastCenters;
// 上一次群聚的最大距離
@property (nonatomic, assign) float lastDistance;
// 當前的迭代數
@property (nonatomic, assign) NSInteger currentIteration;
// 儲存訓練好的群心
@property (nonatomic, strong) KRKmeansSaves *trainedSaves;

@end

@implementation KRKmeans(fixMaths)

-(NSInteger)_randomMax:(NSInteger)_maxValue min:(NSInteger)_minValue
{
    return ( arc4random() / ( RAND_MAX * 2.0f ) ) * (_maxValue - _minValue) + _minValue;;
}

@end

@implementation KRKmeans(fixSaves)

-(void)_saveCenters
{
    [self.trainedSaves saveCenters:self.centers];
}

-(NSArray *)_fetchSavedCenters
{
    return [self.trainedSaves fetchCenters];
}

@end

@implementation KRKmeans (fixCentrals)

// To average multi-dimensional sub-vectors be central vectors
-(NSArray *)_useAverageVectorCalculateCenters:(NSArray *)_clusteredSets
{
    NSMutableArray *_centrals = [NSMutableArray new];
    for( NSArray *_everySets in _clusteredSets )
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

@implementation KRKmeans (fixDistances)

// Euclidean distance which multi-dimensional formula, 距離越小越近
-(float)_euclideanX1:(NSArray *)_x1 x2:(NSArray *)_x2
{
    NSInteger _index = 0;
    float _sum       = 0.0f;
    for( NSNumber *_x in _x1 )
    {
        _sum        += powf([_x floatValue] - [[_x2 objectAtIndex:_index] floatValue], 2);
        ++_index;
    }
    // 累加完距離後直接開根號
    return (_index > 0) ? sqrtf(_sum) : _sum;
}

// Cosine Similarity method that multi-dimensional, 同歸屬度越大越近
-(float)_cosineSimilarityX1:(NSArray *)_x1 x2:(NSArray *)_x2
{
    float _sumA  = 0.0f;
    float _sumB  = 0.0f;
    float _sumAB = 0.0f;
    int _index   = 0;
    for( NSNumber *_featureValue in _x1 )
    {
        NSNumber *_trainValue = [_x2 objectAtIndex:_index];
        float _aValue  = [_featureValue floatValue];
        float _bValue  = [_trainValue floatValue];
        _sumA         += ( _aValue * _aValue );
        _sumB         += ( _bValue * _bValue );
        _sumAB        += ( _aValue * _bValue );
        ++_index;
    }
    float _ab = _sumA * _sumB;
    return ( _ab > 0.0f ) ? ( _sumAB / sqrtf( _ab ) ) : 0.0f;
}

-(double)_rbf:(NSArray *)_x1 x2:(NSArray *)_x2
{
    double _sum      = 0.0f;
    NSInteger _index = 0;
    for( NSNumber *_value in _x1 )
    {
        // Formula : s = s + ( v1[i] - v2[i] )^2
        double _v  = [_value doubleValue] - [[_x2 objectAtIndex:_index] doubleValue];
        _sum      += ( _v * _v );
        ++_index;
    }
    // Formula : exp^( -s / ( 2.0f * sigma * sigma ) )
    return pow(M_E, ((-_sum) / ( 2.0f * self.sigma * self.sigma )));
}

// 距離概念是越小越近，歸屬度概念是越大越近 ( 或取其差值，使歸屬度同距離越小越近 )
-(float)_distanceX1:(NSArray *)_x1 x2:(NSArray *)_x2
{
    float _distance = 0.0f;
    switch (self.distanceFormula)
    {
        case KRKmeansDistanceFormulaCosine:
            _distance = 1.0f - [self _cosineSimilarityX1:_x1 x2:_x2];
            break;
        case KRKmeansDistanceFormulaEuclidean:
            _distance = [self _euclideanX1:_x1 x2:_x2];
            break;
        case KRKmeansDistanceFormulaRBF:
            _distance = [self _rbf:_x1 x2:_x2];
            break;
        default:
            break;
    }
    return _distance;
}

@end

@implementation KRKmeans (fixClusters)
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
                //是第 1 筆 || 當前距離 < 上一次的距離 ( 如距離為歸屬度，則因已在 _distanceX1:X2: 裡使用了差值運算，故這裡一樣使用 < 即可 )
                if( _index == 0 || _distance < _lastDistance )
                {
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
    NSArray *_centrals   = [self calculateSetsCenters:_newClusters];
    [self.centers removeAllObjects];
    [self.centers addObjectsFromArray:_centrals];
    // 取出最大的距離是多少 (也可改取最小距離進行判斷)
    float _errorDistance = -1.0f;
    int _index           = 0;
    // 比較新舊群聚中心點的差值
    for( NSArray *_newCenters in _centrals )
    {
        float _distance = [self _distanceX1:[_lastCenters objectAtIndex:_index] x2:_newCenters];
        if( _errorDistance < 0.0f || _distance > _errorDistance )
        {
            _errorDistance = _distance;
        }
        ++_index;
    }
    
    // 當前中心點最大距離與上次距離的誤差 <= 收斂值 || 迭代運算到了限定次數 ( 避免 Memory Leak )
    if( ( _errorDistance - self.lastDistance ) <= self.convergenceError || self.currentIteration >= self.maxIteration )
    {
        // 即收斂
        //NSLog(@"收斂 : %f", _errorDistance - self.lastDistance);
        [self.results removeAllObjects];
        [self.results addObjectsFromArray:_newClusters];
        [self _doneClustering];
    }
    else
    {
        self.lastDistance = _errorDistance;
        ++self.currentIteration;
        _lastCenters      = [NSMutableArray arrayWithArray:_centrals];
        // 繼續跑遞迴分群
        if( [_centrals count] > 0 )
        {
            if( self.perIteration )
            {
                self.perIteration(self.currentIteration, _newClusters, _centrals);
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
    if( self.doneThenSave )
    {
        [self _saveCenters];
    }
    
    if( self.clusterCompletion )
    {
        self.clusterCompletion(YES, self.results, self.centers, self.currentIteration);
    }
}

@end

@implementation KRKmeans

+(instancetype)sharedKmeans
{
    static dispatch_once_t pred;
    static KRKmeans *_object = nil;
    dispatch_once(&pred, ^{
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
        _maxIteration       = 5000;
        _doneThenSave       = YES;
        _autoClusterNumber  = 0;
        _clusterCompletion  = nil;
        _perIteration       = nil;
        
        _lastCenters        = nil;
        _lastDistance       = -1.0f;
        _currentIteration   = 0;
        
        _distanceFormula    = KRKmeansDistanceFormulaEuclidean;
        _trainedSaves       = [KRKmeansSaves sharedInstance];
        
        _sigma              = 2.0f;
    }
    return self;
}

/*
 * @ 計算每一個群的中心點
 */
-(NSArray *)calculateSetsCenters:(NSArray *)_clusteredSets
{
    return [self _useAverageVectorCalculateCenters:_clusteredSets];
}

// 依期望分幾群來進行自動分群的中心點選擇
// 如有在外部使用此函式，就能不必再設定 autoClusterNumber
-(void)autoPickingCentersByNumber:(NSInteger)_pickNumber
{
    // Random picking some patterns to be default centers.
    // 均分要分多少群的區塊來進行亂數選取其中要當 Default Centers 的點
    NSInteger _patternsCount = [_patterns count];
    if( _patternsCount < _pickNumber )
    {
        _pickNumber = _patternsCount;
    }
    _autoClusterNumber     = _pickNumber;
    NSInteger _chunkLength = ( _patternsCount - 1 ) / _pickNumber;
    NSInteger _maxValue    = 0;
    NSInteger _minValue    = 0;
    for( NSInteger _i = 0; _i < _pickNumber; ++_i )
    {
        _maxValue += _chunkLength;
        [self addSets:@[[_patterns objectAtIndex:[self _randomMax:_maxValue min:_minValue]]]];
        _minValue  = _maxValue + 1;
    }
}

/*
 * @ 直接分群，不進行迭代運算
 *   - 但這裡會被重覆在別的函式裡用於迭代運算裡
 */
-(void)directClusterWithCompletion:(KRKmeansClusteringCompletion)_completion
{
    // If it doesn't have sources, then directly use the original sets to be clustered results, just run this.
    if( [_patterns count] < 1 )
    {
        [_results addObjectsFromArray:_sets];
        return;
    }
    
    // If we wanna directly cluster patterns without already classified group-sets, just run this.
    if( [_sets count] < 1 )
    {
        // If we wanna auto cluster the patterns without setting classified group-sets.
        // 自動分群，不事先預設分類好的群聚
        if( _autoClusterNumber > 0 )
        {
            [self autoPickingCentersByNumber:_autoClusterNumber];
        }
        else
        {
            [_results addObjectsFromArray:_patterns];
            return;
        }
    }
    
    // We already decided the classified group-sets and wanna be clustered patterns, then run this.
    if( [_sets count] > 0 && [_patterns count] > 0 )
    {
        // 先求出每一個集合陣列的中心位置
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
        [_results removeAllObjects];
        [_results addObjectsFromArray:_sets];
    }
    
    if( _completion )
    {
        _completion(YES, _results, _centers, 1);
    }
}

-(void)directClusterPatterns:(NSArray *)_newPatterns completion:(KRKmeansClusteringCompletion)_completion
{
    if( _newPatterns != nil && [_newPatterns count] > 0 )
    {
        [_patterns removeAllObjects];
        [self addPatterns:_newPatterns];
        [self directClusterWithCompletion:_completion];
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
-(void)clusteringWithCompletion:(KRKmeansClusteringCompletion)_completion perIteration:(KRKmeansPerIteration)_generation
{
    _clusterCompletion  = _completion;
    _perIteration       = _generation;
    _currentIteration   = 0;
    [self directCluster];
    // Then directly passing the results array to renew the group-sets of classification.
    [self _renewClusters:_results];
}

-(void)clusteringWithCompletion:(KRKmeansClusteringCompletion)_completion
{
    [self clusteringWithCompletion:_completion perIteration:nil];
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
    [_sets addObject:[_theSets mutableCopy]];
}

-(void)addPatterns:(NSArray *)_theSets
{
    [_patterns addObjectsFromArray:_theSets];
}

// Recalling trained centers which saved in KRKmeansSaves
-(void)recallCenters
{
    NSArray *_savedCenters = [self _fetchSavedCenters];
    if( nil != _savedCenters )
    {
        [_centers removeAllObjects];
        [_centers addObjectsFromArray:_savedCenters];
    }
}

-(void)printResults
{
    NSLog(@"centers : %@", _centers);
    NSLog(@"====================================\n\n\n");
    int _i = 1;
    for( NSArray *_clusters in _results )
    {
        NSLog(@"clusters (#%i) : %@", _i, _clusters);
        NSLog(@"====================================\n\n\n");
        ++_i;
    }
}

#pragma --mark Blocks
-(void)setClusterCompletion:(KRKmeansClusteringCompletion)_theBlock
{
    _clusterCompletion = _theBlock;
}

-(void)setPerIteration:(KRKmeansPerIteration)_theBlock
{
    _perIteration = _theBlock;
}

#pragma --mark Setters
// 設定要自動分類為幾群
-(void)setAutoClusterNumber:(NSInteger)_number
{
    _autoClusterNumber = _number;
}

@end
