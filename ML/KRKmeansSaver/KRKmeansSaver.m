//
//  KRFuzzySaves.h
//  KRFuzzyCMeans
//
//  Created by Kalvar Lin on 2015/11/15.
//  Copyright © 2015年 Kalvar. All rights reserved.
//

#import "KRKmeansSaver.h"
#import "KRKmeansGroup.h"

static NSString *kKRKmeansSavesCentersKey = @"kKRKmeansSavesCentersKey";

@implementation KRKmeansSaver

+ (instancetype)sharedSaver
{
    static dispatch_once_t pred;
    static KRKmeansSaver *_object = nil;
    dispatch_once(&pred, ^{
        _object = [[KRKmeansSaver alloc] init];
    });
    return _object;
}

- (instancetype)init
{
    self = [super init];
    if( self )
    {
        
    }
    return self;
}

- (void)save:(NSMutableArray <KRKmeansGroup *> *)object forKey:(NSString *)key
{
    if( object && key )
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:object] forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)removeForKey:(NSString *)key
{
    if( key )
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSMutableArray <KRKmeansGroup *> *)objectForKey:(NSString *)key
{
    if( key )
    {
        NSData *_objectData = [[NSUserDefaults standardUserDefaults] valueForKey:key];
        return _objectData ? [NSKeyedUnarchiver unarchiveObjectWithData:_objectData] : nil;
    }
    return nil;
}

@end