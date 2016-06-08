//
//  KRKmeansCenter.h
//  KRKmeans
//
//  Created by Kalvar Lin on 2016/6/4.
//  Copyright © 2016年 Kalvar. All rights reserved.
//

#import "KRKmeansPattern.h"

@interface KRKmeansCenter : KRKmeansPattern

- (instancetype)initWithFeatures:(NSArray <NSNumber *> *)f identifier:(NSString *)i;
- (void)addOneFeature:(NSNumber *)oneFeature;
- (void)removeAllFeatures;

@end
