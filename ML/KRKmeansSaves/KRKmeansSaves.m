//
//  KRFuzzySaves.h
//  KRFuzzyCMeans
//
//  Created by Kalvar Lin on 2015/11/15.
//  Copyright © 2015年 Kalvar. All rights reserved.
//

#warning 要參考 RBFNN 實作存入 NSUserDefaults

#import "KRKmeansSaves.h"

static NSString *kKRKmeansSavesCentersKey = @"kKRKmeansSavesCentersKey";

@implementation KRKmeansSaves (fixSaves)

-(NSUserDefaults *)_userDefaults
{
    return [NSUserDefaults standardUserDefaults];
}

-(void)_synchronize
{
    [[self _userDefaults] synchronize];
}

-(instancetype)_defaultValueForKey:(NSString *)_key
{
    return [[self _userDefaults] objectForKey:_key];
}

-(void)_saveDefaultValue:(NSArray *)_value forKey:(NSString *)_forKey
{
    [[self _userDefaults] setObject:_value forKey:_forKey];
    [self _synchronize];
}

-(void)_removeValueForKey:(NSString *)_key
{
    [[self _userDefaults] removeObjectForKey:_key];
    [self _synchronize];
}

@end

@implementation KRKmeansSaves

+(instancetype)sharedInstance
{
    static dispatch_once_t pred;
    static KRKmeansSaves *_object = nil;
    dispatch_once(&pred, ^{
        _object = [[KRKmeansSaves alloc] init];
    });
    return _object;
}

-(instancetype)init
{
    self = [super init];
    if( self )
    {
        
    }
    return self;
}

-(void)saveCenters:(NSArray *)_centers
{
    [self _saveDefaultValue:[_centers copy] forKey:kKRKmeansSavesCentersKey];
}

-(NSArray *)fetchCenters
{
    return (NSArray *)[self _defaultValueForKey:kKRKmeansSavesCentersKey];
}

-(void)deleteCenters
{
    [self _removeValueForKey:kKRKmeansSavesCentersKey];
}

@end