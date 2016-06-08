//
//  KRKmeansKernel.h
//  KRKmeans
//
//  Created by Kalvar Lin on 2016/6/4.
//  Copyright © 2016年 Kalvar. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, KRKmeansKernels)
{
    // Distance formula by Cosine Similarity
    KRKmeansKernelCosine    = 0,
    // Distance formula by Euclidean Distance
    KRKmeansKernelEuclidean = 1,
    // Distance formula by RBF
    KRKmeansKernelRBF       = 2
};

@interface KRKmeansKernel : NSObject

@property (nonatomic, assign) KRKmeansKernels kernel;
@property (nonatomic, assign) double sigma;

- (instancetype)initWithKernel:(KRKmeansKernels)useKernel;
- (instancetype)init;

- (double)euclideanX1:(NSArray *)_x1 x2:(NSArray *)_x2;
- (double)cosineSimilarityX1:(NSArray *)_x1 x2:(NSArray *)_x2;
- (double)rbf:(NSArray *)_x1 x2:(NSArray *)_x2 sigma:(double)_sigma;
- (double)distanceBetweenX1:(NSArray *)_x1 x2:(NSArray *)_x2;

- (NSInteger)randomIntegerWithMax:(NSInteger)_maxValue min:(NSInteger)_minValue;

@end
