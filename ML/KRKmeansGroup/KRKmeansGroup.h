//
//  KRKmeansGroup.h
//  KRKmeans
//
//  Created by Kalvar Lin on 2016/6/4.
//  Copyright © 2016年 Kalvar. All rights reserved.
//

#import "KRKmeansCenter.h"
#import "KRKmeansKernel.h"

@interface KRKmeansGroup : NSObject

// 群組的代表 ID
@property (nonatomic, strong) NSString *identifier;
// 在這群組裡的數據組
@property (nonatomic, strong) NSMutableArray <KRKmeansPattern *> *patterns;
// 這群組的當前中心點 (也為 New Center)
@property (nonatomic, strong) KRKmeansCenter *center;
// 這群組的上一次中心點
@property (nonatomic, strong) KRKmeansCenter *lastCenter;
// 距離運算方法
@property (nonatomic, assign) KRKmeansKernels kernel;
// Kernel Sigma of RBF
@property (nonatomic, assign) double sigma;

- (instancetype)initWithPatterns:(NSArray <KRKmeansPattern *> *)samples groupId:(NSString *)groupId;
- (instancetype)init;

- (void)addPattern:(KRKmeansPattern *)pattern;
- (void)addPatterns:(NSArray <KRKmeansPattern *> *)batchPatterns;
- (void)renewCenter;
- (void)removeAllPatterns;
- (void)resetCenters;

- (double)distanceX1:(NSArray *)x1 x2:(NSArray *)x2;
- (double)distanceCenterToFeatures:(NSArray *)features;
- (double)centerDifference;
- (double)groupDistance;

@end
