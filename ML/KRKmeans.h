//
//  KRKmeans.h
//  KRKmeans V2.4
//
//  Created by Kalvar on 2014/6/30.
//  Copyright (c) 2014 - 2015年 Kalvar Lin, ilovekalvar@gmail.com. All rights reserved.
//
/*
 * @ K-Means
 *   - 條件為 :
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
 *   - K-Means 就是將相關聯( 例如距離最近、數字相關、倍數相關、特徵點相關等 )的數字分類在一起，
 *     而後再依照分群結果去做對應結果的方法。
 *
 *   - 已擴充 :
 *     1. 將一群隨機產生的 100 組 (x, y) 2 維資料集合，先做分群分類成 N 組集合群聚( N 可自訂 )。
 *     2. 再做現在將 C 集合分群的動作。
 *     3. 進行分群迭代運算，將每一個分類好的群組重新分群
 *
 */

#import <Foundation/Foundation.h>
#import "KRKmeansOne.h"

typedef enum KRKmeansDimensional
{
    // Two Dimensions that (x, y)
    KRKmeansDimensionalTwoPoints        = 0,
    // Multi-Dimensions by Cosine Similarity
    KRKmeansDimensionalMultiByCosine    = 1,
    // Multi-Dimensions by Euclidean Distance
    KRKmeansDimensionalMultiByEuclidean = 2
}KRKmeansDimensional;

/*
 * @ 訓練完成時
 *   - success     : 是否訓練成功
 *   - centers     : 分群結果
 *   - centrals    : 群聚中心點
 *   - totalTimes  : 共迭代了幾次即達到收斂
 */
typedef void(^KRKmeansClusteringCompletion)(BOOL success, NSArray *clusters, NSArray *centers, NSInteger totalTimes);

/*
 * @ 每一次的迭代資料
 *   - times       : 第幾迭代運算
 *   - clusters    : 本次的分群結果
 *   - centers     : 本次的群聚中心點
 */
typedef void(^KRKmeansEachGeneration)(NSInteger times, NSArray *clusters, NSArray *centers);

@interface KRKmeans : NSObject

//要訓練分群用的集合樣本
@property (nonatomic, strong) NSMutableArray *sets;
//每一群的中心點
@property (nonatomic, strong) NSMutableArray *centers;
//要分群的集合數據
@property (nonatomic, strong) NSMutableArray *patterns;
//分群結果
@property (nonatomic, strong) NSMutableArray *results;
//收斂誤差
@property (nonatomic, assign) float convergenceError;
//迭代運算上限次數
@property (nonatomic, assign) NSInteger limitGenerations;
// 要進行什麼維度的分群
@property (nonatomic, assign) KRKmeansDimensional dimensional;

@property (nonatomic, copy) KRKmeansClusteringCompletion clusterCompletion;
@property (nonatomic, copy) KRKmeansEachGeneration eachGeneration;

+(instancetype)sharedKmeans;
-(instancetype)init;
-(NSArray *)calculateSetsCenters:(NSArray *)_someSets;
-(void)directClusterWithCompletion:(KRKmeansClusteringCompletion)_completion;
-(void)directCluster;
-(void)clusteringWithCompletion:(KRKmeansClusteringCompletion)_completion eachGeneration:(KRKmeansEachGeneration)_generation;
-(void)clusteringWithCompletion:(KRKmeansClusteringCompletion)_completion;
-(void)clustering;
-(double)calculateSSE;
-(void)addSets:(NSArray *)_theSets;
-(void)addPatterns:(NSArray *)_theSets;
-(void)printResults;

#pragma --mark Blocks
-(void)setClusterCompletion:(KRKmeansClusteringCompletion)_theBlock;
-(void)setEachGeneration:(KRKmeansEachGeneration)_theBlock;

@end
