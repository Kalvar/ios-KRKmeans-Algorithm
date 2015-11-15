//
//  KRFuzzySaves.h
//  KRFuzzyCMeans
//
//  Created by Kalvar Lin on 2015/11/15.
//  Copyright © 2015年 Kalvar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KRKmeansSaves : NSObject

+(instancetype)sharedInstance;
-(instancetype)init;

-(void)saveCenters:(NSArray *)_centers;
-(NSArray *)fetchCenters;
-(void)deleteCenters;

@end
