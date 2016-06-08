//
//  KRKmeansPattern.h
//  KRKmeans
//
//  Created by Kalvar Lin on 2016/6/4.
//  Copyright © 2016年 Kalvar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KRKmeansPattern : NSObject<NSCopying, NSCoding>

@property (nonatomic, strong) NSMutableArray <NSNumber *> *features;
@property (nonatomic, strong) NSString *identifier;

@property (nonatomic, weak) NSCoder *coder;             // For NSCoding usage and child-class use in inherited this class.

- (instancetype)initWithFeatures:(NSArray <NSNumber *> *)f identifier:(NSString *)i;

@end

@interface KRKmeansPattern (NSCoding)

- (void)encodeObject:(id)object forKey:(NSString *)key;
- (id)decodeForKey:(NSString *)key;

@end