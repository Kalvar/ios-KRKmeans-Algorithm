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

// 當前的迭代數
@property (nonatomic, assign) NSInteger currentIteration;
// 儲存訓練好的群心
@property (nonatomic, strong) KRKmeansSaves *saver;
@property (nonatomic, strong) KRKmeansKernel *kernel;

@end

@implementation KRKmeans (Sorting)
// 用洗牌法進行亂數取出
- (NSArray *)randomizeArray:(NSArray *)_patterns
{
    NSMutableArray *_samples = [_patterns mutableCopy];
    NSInteger _totalLength   = [_patterns count];
    for( NSInteger _i=0; _i<_totalLength; _i++ )
    {
        NSInteger _random1 = ( arc4random() % _totalLength );
        NSInteger _random2 = ( arc4random() % _totalLength );
        // 如果亂數重複，則用範本數長度減去亂數值
        if( _random1 == _random2 )
        {
            _random2 = _totalLength - _random2;
        }
        // 進行陣列交換
        // 先取出 random1 位置的 Object
        NSArray *_temp = [_samples objectAtIndex:_random1];
        // 再將 random2 位置的 Object 塞回去 random1 位置
        [_samples replaceObjectAtIndex:_random1 withObject:[_samples objectAtIndex:_random2]];
        // 最後將剛才取出的 random1 Object 塞回去 random2 即可
        [_samples replaceObjectAtIndex:_random2 withObject:_temp];
    }
    return _samples;
}

@end

@implementation KRKmeans (Clustering)

- (void)operateCompletionBlockForSuccess:(BOOL)success
{
    if( self.clusterCompletion )
    {
        self.clusterCompletion(success, self, self.currentIteration);
    }
}

- (void)operateIterationBlock
{
    if( self.perIteration )
    {
        self.perIteration(self.currentIteration, self, self.isPaused);
    }
}

- (void)removeAllClassifiedPatterns
{
    [self.classifiedGroups enumerateObjectsUsingBlock:^(KRKmeansGroup * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeAllPatterns];
    }];
}

// 計算要分到哪一個最小距離的 Center 去要分到哪一個最小距離的 Center 去 (算每一個 Pattern 對每一個 Center 的距離)
- (void)clusteringToGroupWithPatterns:(NSArray <KRKmeansPattern *> *)samples
{
    // 計算該 Pattern 要被分到哪一個中心點去
    for( KRKmeansPattern *pattern in samples )
    {
        NSInteger groupIndex = -1;
        NSInteger toIndex    = -1;
        double minDistance   = 0.0f;
        for( KRKmeansGroup *group in self.classifiedGroups )
        {
            groupIndex     += 1;
            // 計算到該 Pattern 到該 Group Center 的距離
            double distance = [group distanceCenterToFeatures:pattern.features];
            if( toIndex < 0 || distance < minDistance )
            {
                minDistance = distance;
                toIndex     = groupIndex;
            }
        }
        
        // 分到指定的群裡
        if( toIndex >= 0 )
        {
            KRKmeansGroup *toGroup = [self.classifiedGroups objectAtIndex:toIndex];
            [toGroup addPattern:pattern];
        }
    }
}

- (void)training
{
    if( self.isPaused || [self.patterns count] == 0 )
    {
        [self operateCompletionBlockForSuccess:NO];
        return;
    }
    /*
     * @ Steps
     *   1. 全部分類
     *   2. 重新計算每一個群聚的中心點
     *   3. 計算該次迭代的所有群聚中心點與上一次舊的群聚中心點相減，取出最大距離誤差
     *   4. 比較新舊最大距離誤差是否 <= 收斂誤差，如是，即停止運算，如否，則進行第 4 步驟的遞迴迭代運算
     *   5. 依照這群聚中心點，進行迭代運算，重新計算與分類所有的已分類好的群聚，並重複第 1 到第 4 步驟
     */
    [self removeAllClassifiedPatterns];
    [self clusteringToGroupWithPatterns:self.patterns];
    
    // 計算上一次 Centers 跟當前 Centers 的最大距離差值
    __block double differenceDistance = -1.0f;
    [self.classifiedGroups enumerateObjectsUsingBlock:^(KRKmeansGroup * _Nonnull group, NSUInteger idx, BOOL * _Nonnull stop) {
        // Renew all centers
        [group renewCenter];
        // 計算新舊群聚中心點的距離
        double distance = [group centerDifference];
        // 距離差值 < 0.0f || 距離 > 距離差值
        if( differenceDistance < 0.0f || distance > differenceDistance )
        {
            differenceDistance = distance;
        }
    }];
    
    // abs(當前中心點最大距離上次距離的誤差) <= 收斂值 || 迭代運算到了限定次數 ( 避免 Memory Leak )
    if( self.currentIteration >= self.maxIteration )
    {
        // 已達收斂條件
        //NSLog(@"收斂迭代[%li], 前後中心點距離誤差 %f", self.currentIteration, differenceDistance);
        if( self.saveAfterDone )
        {
//#error 要來補上 saveCenters ...
            //[self.saver saveCenters:self.centers];
        }
        [self operateCompletionBlockForSuccess:YES];
    }
    else
    {
        self.currentIteration += 1;
        [self operateIterationBlock];
        [self training];
    }
}

@end

@implementation KRKmeans

+ (instancetype)sharedKmeans
{
    static dispatch_once_t pred;
    static KRKmeans *_object = nil;
    dispatch_once(&pred, ^{
        _object = [[KRKmeans alloc] init];
    });
    return _object;
}

- (instancetype)init
{
    self = [super init];
    if( self )
    {
        _classifiedGroups   = [NSMutableArray new];
        _patterns           = [NSMutableArray new];
        _convergenceError   = 0.001f;
        _maxIteration       = 5000;
        _saveAfterDone      = NO;
        
        _clusterCompletion  = nil;
        _perIteration       = nil;
        
        _currentIteration   = 0;
        
        _saver              = [[KRKmeansSaves alloc] init];
        _kernel             = [[KRKmeansKernel alloc] init];
        
        _isPaused           = NO;
        
    }
    return self;
}

#pragma mark - Creating
- (KRKmeansPattern *)createPatternWithFeatures:(NSArray <NSNumber *> *)features patternId:(NSString *)patternId
{
    return [[KRKmeansPattern alloc] initWithFeatures:features identifier:patternId];
}

- (KRKmeansCenter *)createCenterWithFeatures:(NSArray <NSNumber *> *)features centerId:(NSString *)centerId
{
    return [[KRKmeansCenter alloc] initWithFeatures:features identifier:centerId];
}

- (KRKmeansGroup *)createGroupWithCenter:(KRKmeansCenter *)groupCenter ownPatterns:(NSArray <KRKmeansPattern *> *)groupPatterns groupId:(NSString *)groupId
{
    KRKmeansGroup *group = [[KRKmeansGroup alloc] initWithPatterns:groupPatterns groupId:groupId];
    [group setCenter:groupCenter];
    return group;
}

#pragma mark - Adding
- (void)addGroup:(KRKmeansGroup *)group copy:(BOOL)copy
{
    [_classifiedGroups addObject:( copy ? [group copy] : group )];
}

- (void)addGroup:(KRKmeansGroup *)group
{
    [self addGroup:group copy:NO];
}

- (void)addPattern:(KRKmeansPattern *)pattern forGroupId:(NSString *)groupId
{
    if( nil == pattern )
    {
        return;
    }
    
    [_patterns addObject:pattern];
    if( nil != groupId && [groupId length] > 0 )
    {
        for( KRKmeansGroup *group in _classifiedGroups )
        {
            if( [group.identifier isEqualToString:groupId] )
            {
                [group addPattern:pattern];
                break;
            }
        }
    }
}

- (void)addPattern:(KRKmeansPattern *)pattern
{
    [self addPattern:pattern forGroupId:nil];
}

- (void)addPatterns:(NSArray <KRKmeansPattern *> *)samples
{
    __weak typeof(self) weakSelf = self;
    [samples enumerateObjectsUsingBlock:^(KRKmeansPattern * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf addPattern:obj];
    }];
}

- (void)addPatternWithFeatures:(NSArray<NSNumber *> *)features patternId:(NSString *)patternId
{
    KRKmeansPattern *pattern = [self createPatternWithFeatures:features patternId:patternId];
    [self addPattern:pattern];
}

#pragma mark - Training & Clustering
// 依期望分幾群來進行隨機自動分群的中心點選擇，如 _pickNumber 代入 0 則為完全由系統決定的隨機分群
// 如有在外部使用此函式，就能不必再設定 autoClusterNumber
- (void)randomChooseCenters:(NSInteger)chooseNumber
{
    NSInteger totalLength = [_patterns count];
    // 先正規化 pickNumber 以避免 <= 0 和 > _totalLength 的狀況
    if( chooseNumber <= 0 || chooseNumber > totalLength )
    {
        chooseNumber = ( arc4random() % totalLength );
    }
    
    NSArray *randomizedPatterns = [self randomizeArray:_patterns];
    for( NSInteger i = 0; i < chooseNumber; ++i )
    {
        NSString *tempId         = [NSString stringWithFormat:@"%li", i];
        KRKmeansPattern *pattern = [randomizedPatterns objectAtIndex:i];
        KRKmeansCenter *center   = [self createCenterWithFeatures:pattern.features centerId:tempId];
        KRKmeansGroup *group     = [self createGroupWithCenter:center ownPatterns:nil groupId:tempId];
        [self addGroup:group];
    }
}

- (void)predicatePatterns:(NSArray <KRKmeansPattern *> *)samples completion:(KRKmeansClusteringCompletion)completion
{
    if( nil != samples && [samples count] > 0 )
    {
        [self removeAllClassifiedPatterns];
        [self clusteringToGroupWithPatterns:samples];
        if( completion )
        {
            completion(YES, self, 1);
        }
    }
}

- (void)clusteringWithCompletion:(KRKmeansClusteringCompletion)completion perIteration:(KRKmeansPerIteration)iteration
{
    _clusterCompletion  = completion;
    _perIteration       = iteration;
    _currentIteration   = 0;
    _isPaused           = NO;
    [self training];
}

#pragma mark - Status
- (void)pause
{
    _isPaused = YES;
}

- (void)restart
{
    _isPaused = NO;
    [self training];
}

- (void)reset
{
    _isPaused          = NO;
    [_classifiedGroups removeAllObjects];
    [_patterns removeAllObjects];
    _clusterCompletion = nil;
    _perIteration      = nil;
    _currentIteration  = 0;
    _maxIteration      = 0;
    _saveAfterDone     = NO;
}

#pragma mark - Results
// Recalling trained centers which saved in KRKmeansSaves
- (void)recallCenters
{
    NSArray *savedCenters = [_saver fetchCenters];
    if( nil != savedCenters )
    {
        // TODO:
    }
}

- (void)printResults
{
    [_classifiedGroups enumerateObjectsUsingBlock:^(KRKmeansGroup * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"Clustering Group ID is %@, its own patterns are : ", obj.identifier);
        NSLog(@"Center ID is %@, its features are %@", obj.center.identifier, obj.center.features);
        [obj.patterns enumerateObjectsUsingBlock:^(KRKmeansPattern * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"Pattern ID is %@", obj.identifier);
            NSLog(@"Features are %@", obj.features);
        }];
        NSLog(@"====================================\n\n");
    }];
}

- (void)setKernel:(KRKmeansKernels)kernel
{
    [_classifiedGroups enumerateObjectsUsingBlock:^(KRKmeansGroup * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.kernel = kernel;
    }];
}

#pragma mark - Blocks
-(void)setClusterCompletion:(KRKmeansClusteringCompletion)block
{
    _clusterCompletion = block;
}

-(void)setPerIteration:(KRKmeansPerIteration)block
{
    _perIteration = block;
}

#pragma mark - Getters
- (NSArray <KRKmeansCenter *> *)centers
{
    if( _classifiedGroups && [_classifiedGroups count] > 0 )
    {
        NSMutableArray *groupCenters = [NSMutableArray new];
        for( KRKmeansGroup *group in _classifiedGroups )
        {
            [groupCenters addObject:group.center];
        }
        return groupCenters;
    }
    return nil;
}

- (NSArray <NSArray *> *)featuresOfCenters
{
    NSMutableArray *features                 = nil;
    NSArray <KRKmeansCenter *> *groupCenters = self.centers;
    if( nil != groupCenters )
    {
        features = [NSMutableArray new];
        for( KRKmeansCenter *center in groupCenters )
        {
            [features addObject:center.features];
        }
    }
    return features;
}

// SSE, 計算加總所有的分群裡頭每個資料點與中心點距離，用於對每次 K-Means 的聚類結果做評量，以找出具有最小SSE的那組聚類結果作為解答
-(double)sse
{
    __block double sumSSE = 0.0f;
    if( _classifiedGroups )
    {
        [_classifiedGroups enumerateObjectsUsingBlock:^(KRKmeansGroup * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            sumSSE += obj.groupDistance;
        }];
    }
    return sumSSE;
}

#pragma mark - Setters
- (void)setSigma:(double)sigma
{
    if( _classifiedGroups )
    {
        for( KRKmeansGroup *group in _classifiedGroups )
        {
            group.sigma = sigma;
        }
    }
}

@end
