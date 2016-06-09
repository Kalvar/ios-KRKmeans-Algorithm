//
//  KRFuzzySaves.h
//  KRFuzzyCMeans
//
//  Created by Kalvar Lin on 2015/11/15.
//  Copyright © 2015年 Kalvar. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KRKmeansGroup;

@interface KRKmeansSaver : NSObject

+ (instancetype)sharedSaver;
- (instancetype)init;

- (void)save:(NSMutableArray <KRKmeansGroup *> *)object forKey:(NSString *)key;
- (void)removeForKey:(NSString *)key;
- (NSMutableArray <KRKmeansGroup *> *)objectForKey:(NSString *)key;

@end
