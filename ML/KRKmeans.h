//
//  KRKmeans.h
//  KRKmeans V2.4.1
//
//  Created by Kalvar on 2014/6/30.
//  Copyright (c) 2014 - 2015年 Kalvar Lin, ilovekalvar@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KRKmeansOne.h"
#import "KRKmeansKernel.h"
#import "KRKmeansGroup.h"

@class KRKmeans;

typedef void(^KRKmeansClusteringCompletion)(BOOL success, KRKmeans *kmeansObject, NSInteger totalTimes);
typedef void(^KRKmeansPerIteration)(NSInteger times, KRKmeans *kmeansObject, BOOL *pause);

@interface KRKmeans : NSObject

// This modelKey used in saving that tained groups in KRKmeansSaver,
// If it is nil or @"" before saving k-means trained groups, this modelKey will be automatic created by milliseconds of current timestamp.
@property (nonatomic, strong) NSString *modelKey;
// 每一個分類好的群聚
@property (nonatomic, strong) NSMutableArray <KRKmeansGroup *> *classifiedGroups;
// 要分群的集合數據
@property (nonatomic, strong) NSMutableArray <KRKmeansPattern *> *patterns;
// 每群的中心點物件, Center-objects of groups
@property (nonatomic, readonly) NSArray <KRKmeansCenter *> *centers;
// 每群的中心點特幑值, Features of centers of each groups
@property (nonatomic, readonly) NSArray <NSArray *> *featuresOfCenters;
// 收斂誤差
@property (nonatomic, assign) double convergenceError;
// Max iterations of limitation
@property (nonatomic, assign) NSInteger maxIteration;
// Saving trained model after done
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

- (void)recoverGroupsForKey:(NSString *)saveKey;
- (void)printResults;

- (void)setupKernel:(KRKmeansKernels)kernel; // 要用哪個算法進行分類

- (void)setClusterCompletion:(KRKmeansClusteringCompletion)block;
- (void)setPerIteration:(KRKmeansPerIteration)block;

@end
