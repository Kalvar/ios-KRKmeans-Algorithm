//
//  KRKmeans.h
//  KRKmeans V2.4.1
//
//  Created by Kalvar on 2014/6/30.
//  Copyright (c) 2014 - 2015年 Kalvar Lin, ilovekalvar@gmail.com. All rights reserved.
//
/*
 * @ K-Means
 *   - 演譯原則 :
 *     1. 求出 A 集合與 B 集合之中心位置，或將 A, B 集合直接當成初始群聚中心點 (如果該集合裡只有 1 組資料時)
 *     2. 將 C 集合依 K-Means 理論放置於 A 與 B 集合裡。
 *
 *   - 設計方法 :
 *     1. 先求出各群聚( Cluster )的中心位置( Center Point )。
 *     2. 依照歐基里德定律，求出要歸納分群( Clustering )的集合與各群聚的 Center Point 距離。
 *     3. 最後依照最短距離分至該群。
 *     4. 迭代運算，將其重新計算每群聚中心點，再重新分群，直至 MIN(新舊中心點誤差值) 小於設定值或與上次群聚中心點相等時，即停止 1 ~ 3 步驟的迭代運算。
 *     5. 使用 SSE 來評估每一次的分群結果，把每一次分群後的結果 SSE 值記錄起來，再逐步去調整起始中心點，直至比較出最小的 SSE 值，則該群聚結果即為最佳解。
 *
 *   - K-Means 就是將相關聯( 例如距離最近、數字相關、倍數相關、特徵點相關等 )的數字分類在一起，而後再依照分群結果去做對應結果的方法。
 *
 *   - 已擴充 :
 *     1. 將一群隨機產生的 100 組 (x, y) 2 維資料集合，先做分群分類成 N 組集合群聚( N 可自訂 )。
 *     2. 再做現在將 C 集合分群的動作。
 *     3. 進行分群迭代運算，將每一個分類好的群組重新分群
 *
 *   - 距離公式說明 :
 *     1. Cosine Similarity 是種歸屬度的概念，數字越大代表越相近 ( 或是用 1 - 歸屬度，取其差值，就能跟距離概念一樣越小越近了 )
 *     2. Euclidean Distance 是距離的概念，數字越小代表越相近
 *
 */

#import <Foundation/Foundation.h>
#import "KRKmeansOne.h"
#import "KRKmeansKernel.h"
#import "KRKmeansGroup.h"

@class KRKmeans;

/*
 * @ 訓練完成時
 *   - success     : 是否訓練成功
 *   - centers     : 分群結果
 *   - centrals    : 群聚中心點
 *   - totalTimes  : 共迭代了幾次即達到收斂
 */
typedef void(^KRKmeansClusteringCompletion)(BOOL success, KRKmeans *kmeansObject, NSInteger totalTimes);

/*
 * @ 每一次的迭代資料
 *   - times       : 第幾迭代運算
 *   - clusters    : 本次的分群結果
 *   - centers     : 本次的群聚中心點
 */
typedef void(^KRKmeansPerIteration)(NSInteger times, KRKmeans *kmeansObject, BOOL *pause);

@interface KRKmeans : NSObject

// 每一個分類好的群聚
@property (nonatomic, strong) NSMutableArray <KRKmeansGroup *> *classifiedGroups;
// 要分群的集合數據
@property (nonatomic, strong) NSMutableArray <KRKmeansPattern *> *patterns;
// 每群的中心點物件
@property (nonatomic, readonly) NSArray <KRKmeansCenter *> *centers;
// 每群的中心點特幑值
@property (nonatomic, readonly) NSArray <NSArray *> *featuresOfCenters;
// 收斂誤差
@property (nonatomic, assign) double convergenceError;
// 迭代運算上限次數
@property (nonatomic, assign) NSInteger maxIteration;
// 訓練完後是否自動儲存
@property (nonatomic, assign) BOOL saveAfterDone;
// If we used RBF be the kernel that can setup this considition
@property (nonatomic, assign) double sigma;
@property (nonatomic, readonly) double sse;
@property (nonatomic, readonly) BOOL isPaused;

@property (nonatomic, copy) KRKmeansClusteringCompletion clusterCompletion;
@property (nonatomic, copy) KRKmeansPerIteration perIteration;

+ (instancetype)sharedKmeans;
- (instancetype)init;

- (KRKmeansPattern *)createPatternWithFeatures:(NSArray <NSNumber *> *)features patternId:(NSString *)patternId;
- (KRKmeansCenter *)createCenterWithFeatures:(NSArray <NSNumber *> *)features centerId:(NSString *)centerId;
- (KRKmeansGroup *)createGroupWithCenter:(KRKmeansCenter *)groupCenter ownPatterns:(NSArray <KRKmeansPattern *> *)groupPatterns groupId:(NSString *)groupId;

- (void)addGroup:(KRKmeansGroup *)group copy:(BOOL)copy;
- (void)addGroup:(KRKmeansGroup *)group;
- (void)addPattern:(KRKmeansPattern *)pattern forGroupId:(NSString *)groupId;
- (void)addPattern:(KRKmeansPattern *)pattern;
- (void)addPatterns:(NSArray <KRKmeansPattern *> *)samples;
- (void)addPatternWithFeatures:(NSArray <NSNumber *> *)features patternId:(NSString *)patternId;

- (void)randomChooseCenters:(NSInteger)chooseNumber; // 隨機選取中心點
- (void)predicatePatterns:(NSArray <KRKmeansPattern *> *)samples completion:(KRKmeansClusteringCompletion)completion;
- (void)clusteringWithCompletion:(KRKmeansClusteringCompletion)completion perIteration:(KRKmeansPerIteration)iteration;

- (void)pause;
- (void)restart;

- (void)recallCenters;
- (void)printResults;

- (void)setKernel:(KRKmeansKernels)kernel; // 要用哪個算法進行分類

#pragma mark - Blocks
- (void)setClusterCompletion:(KRKmeansClusteringCompletion)block;
- (void)setPerIteration:(KRKmeansPerIteration)block;

@end
