//
//  KRKmeans V1.0.h
//  KRKmeans V1.0
//
//  Created by Kalvar on 2014/6/29.
//  Copyright (c) 2014年 Kalvar. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * @ 計算 1 維 K-Means 並分為 3 群
 *   - Max : 最大數群
 *   - Min : 最小數群
 *   - Mid : 中位數群
 */
@interface KRKmeansOne : NSObject

@property (nonatomic, strong) NSArray *sources;
//知識界線
@property (nonatomic, assign) float knowledgeLine;
//最大數群
@property (nonatomic, strong) NSMutableArray *maxClusters;
//最小數群
@property (nonatomic, strong) NSMutableArray *minClusters;
//中位數群
@property (nonatomic, strong) NSMutableArray *midClusters;
//重複出現的數值
@property (nonatomic, strong) NSMutableDictionary *overlappings;

+(instancetype)sharedKmeans;
-(instancetype)init;
-(void)clustering;
-(void)printResults;

@end
