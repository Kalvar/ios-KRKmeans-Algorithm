//
//  KRKmeans V1.0Two.h
//  KRKmeans V1.0
//
//  Created by Kalvar on 2014/6/30.
//  Copyright (c) 2014年 Kalvar. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * @ 2 維 K-Means
 *   - 條件為 :
 *     1. 求出 A 集合與 B 集合之中心位置。
 *     2. 將 C 集合依 K-Means 理論放置於 A 與 B 集合裡。
 *
 *   - 設計方法 : 
 *     1. 先求出各群聚( Cluster )的中心位置( Center Point )。
 *     2. 依照歐基里德定律，求出要歸納分群( Clustering )的集合與各群聚的 Center Point 距離。
 *     3. 最後依照最短距離分至該群。
 *
 *   - K-Means 就是將相關聯( 例如距離最近、數字相關、倍數相關、特徵點相關等 )的數字分類在一起，
 *     而後再依照分群結果去做對應結果的方法。
 *
 *   - 未來擴充 : 
 *     1. 將一群隨機產生的 100 組 (x, y) 2 維資料集合，先做分群分類成 N 組集合群聚( N 可自訂  )。
 *     2. 再做現在將 C 集合分群的動作。
 *
 */
@interface KRKmeansTwo : NSObject

//要訓練分群用的集合樣本
@property (nonatomic, strong) NSMutableArray *sets;
//要分群的集合數據
@property (nonatomic, strong) NSArray *sources;
//分群結果
@property (nonatomic, strong) NSMutableArray *results;

+(instancetype)sharedKmeans;
-(instancetype)init;
-(void)clustering;
-(void)addSets:(NSMutableArray *)_clusters;
-(void)printResults;

@end
