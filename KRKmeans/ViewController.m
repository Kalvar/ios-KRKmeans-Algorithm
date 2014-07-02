//
//  ViewController.m
//  KRKmeans V1.1
//
//  Created by Kalvar on 2014/6/29.
//  Copyright (c) 2014年 Kalvar. All rights reserved.
//

#import "ViewController.h"
#import "KRKmeansOne.h"
#import "KRKmeansTwo.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //One dimensional K-Means, the data set is any number means.
	KRKmeansOne *_krKmeans = [KRKmeansOne sharedKmeans];
    _krKmeans.sources = @[@0.33, @0.88, @1, @0.52, @146, @120, @45, @43, @0.4];
    //If you wanna customize the median value
    //_krKmeans.useCustomMedian = YES;
    //_krKmeans.customMedian    = 45.0f;
    [_krKmeans clustering];
    [_krKmeans printResults];
    /*
    Output :
     
        Conditions :
            n    = 3
            Tmax = 146
            Tmin = 0.33
            Tmid = 1 ( 使用自動計算中位數, _krKmeans.useCustomMedian = NO )
        
        Answer :
        
            Max Clusters : 0.33, 0.52, 0.4
            Min Clusters : 0.88, 1, 45, 43
            Mid Clusters : 146, 120
        
        Knowledge Line :
        
            63.110001
    */
    
    //Two dimesional K-Means, the data set is (x, y)
    KRKmeansTwo *_krKmeansTwo = [KRKmeansTwo sharedKmeans];
    //It means A sets.
    [_krKmeansTwo addSets:[NSMutableArray arrayWithObjects:@[@1, @1], @[@1, @2], @[@2, @2], @[@3, @2], @[@3, @1], nil]];
    //It means B sets.
    [_krKmeansTwo addSets:[NSMutableArray arrayWithObjects:@[@6, @4], @[@7, @6], @[@5, @6], @[@6, @5], nil]];
    //It means C sets which wanna be clustered.
    _krKmeansTwo.sources = @[@[@5, @4], @[@3, @4], @[@2, @5]];
    [_krKmeansTwo clustering];
    [_krKmeansTwo printResults];
    /*
    Output :
    
        Center Point of Sets :
        
            A Sets : (2, 1.6)
            B Sets : (6, 5.25)
     
        Results :
        
            A Sets : (1, 1) (1, 2) (2, 2) (3, 2) (3, 1) (3, 4) (2, 5)
            B Sets : (6, 4) (7, 6) (5, 6) (6, 5) (5, 4)
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
