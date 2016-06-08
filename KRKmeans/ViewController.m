//
//  ViewController.m
//  KRKmeans V2.4.1
//
//  Created by Kalvar on 2014/6/29.
//  Copyright (c) 2014 - 2015年 Kalvar Lin, ilovekalvar@gmail.com. All rights reserved.
//

#import "ViewController.h"
#import "KRKmeans.h"

@interface ViewController ()

@end

@implementation ViewController (fixSamples)

-(void)oneDemensionalClustering
{
    //One dimensional K-Means, the data set is any number means.
    KRKmeansOne *kmeansOne = [KRKmeansOne sharedKmeans];
    kmeansOne.sources      = @[@0.33, @0.88, @1, @0.52, @146, @120, @45, @43, @0.4];
    
    //If you wanna customize the median value
    //_krKmeansOne.customMedian = 45.0f;
    
    [kmeansOne clusteringWithCompletion:^(BOOL success, float knowledgeLine, NSArray *maxClusters, NSArray *minClusters, NSArray *midClusters, NSDictionary *overlappings)
    {
        NSLog(@"knowledgeLine : %f", knowledgeLine);
        NSLog(@"maxClusters : %@", maxClusters);
        NSLog(@"minClusters : %@", minClusters);
        NSLog(@"midClusters : %@", midClusters);
        NSLog(@"overlappings : %@", overlappings);
        //[_krKmeansOne printResults];
    }];
    /*
     Output :
     
         Conditions :
             n    = 3
             Tmax = 146
             Tmin = 0.33
             Tmid = 1
         
         Answer :
         
             Max Clusters : 0.33, 0.52, 0.4
             Min Clusters : 0.88, 1, 45, 43
             Mid Clusters : 146, 120
         
         Knowledge Line :
         
             63.110001
     */
}

-(void)multiClustering
{
    KRKmeans *kmeans     = [KRKmeans sharedKmeans];
    kmeans.saveAfterDone = YES;
    kmeans.maxIteration  = 10;
    
    // Adding patterns
    NSArray *patterns = @[@[@5, @4], @[@3, @4], @[@2, @5], @[@9, @8], @[@3, @20],
                          @[@1, @1], @[@1, @2], @[@2, @2], @[@3, @2], @[@3, @1],
                          @[@6, @4], @[@7, @6], @[@5, @6], @[@6, @5], @[@7, @8],
                          @[@3, @12], @[@5, @20]];
    NSInteger index   = -1;
    for( NSArray *features in patterns )
    {
        index += 1;
        NSString *patternId      = [NSString stringWithFormat:@"%li", index];
        KRKmeansPattern *pattern = [kmeans createPatternWithFeatures:features patternId:patternId];
        [kmeans addPattern:pattern];
    }
    
    [kmeans randomChooseCenters:3];
    [kmeans setKernel:KRKmeansKernelEuclidean];
    
    [kmeans clusteringWithCompletion:^(BOOL success, KRKmeans *kmeansObject, NSInteger totalTimes) {
        NSLog(@"totalTimes : %li", totalTimes);
        NSLog(@"featuresOfCenters : %@", kmeansObject.featuresOfCenters);
        NSLog(@"centers objects: %@", kmeansObject.centers);
        NSLog(@"SSE : %lf", kmeansObject.sse);
    } perIteration:^(NSInteger times, KRKmeans *kmeansObject, BOOL *pause) {
        NSLog(@"times : %li", times);
    }];
    
    /*
     Output :
     
         Center Point of Sets :
         
             A Sets : (2.142857, 2.428571)
             B Sets : (5.8, 5)
             C Sets : (8, 8)
             D Sets : (3.666667, 17.33333)
         
         Results :
         
             A Sets : (1, 1) (1, 2) (2, 2) (3, 2) (3, 1) (3, 4) (2, 5)
             B Sets : (6, 4) (7, 6) (5, 6) (6, 5) (5, 4)
             C Sets : (7, 8) (9, 8)
             D Sets : (3, 12) (5, 20) (3, 20)
     */
}

//// Recalling the tranined groups to directly classify patterns
//-(void)recallingTraninedCenters
//{
//    KRKmeans *_krKmeans = [KRKmeans sharedKmeans];
//    [_krKmeans recallCenters];
//    [_krKmeans addPatterns:@[@[@21, @12], @[@13, @21], @[@12, @5], @[@3, @8]]];
//    [_krKmeans predicateWithCompletion:^(BOOL success, NSArray *clusters, NSArray *centers, NSInteger totalTimes) {
//        [_krKmeans printResults];
//    }];
//}

//-(void)randomClustering
//{
//    KRKmeans *kmeans      = [[KRKmeans alloc] init];
//    kmeans.saveAfterDone  = YES;
//    kmeans.kernelFormula  = KRKmeansKernelEuclidean;
//    [kmeans addPatterns:@[@[@1, @1], @[@1, @2], @[@2, @2], @[@3, @2],
//                             @[@3, @1], @[@5, @4], @[@3, @4], @[@2, @5],
//                             @[@9, @8], @[@3, @20], @[@6, @4], @[@7, @6],
//                             @[@5, @6], @[@6, @5], @[@7, @8], @[@3, @12],
//                             @[@5, @20]]];
//    [kmeans randomChooseCenters:3]; // 自動由 Patterns 裡隨機選 3 個點 (分 3 群), 如果 number 設 0, 代表自動隨機分群
//    [kmeans clusteringWithCompletion:^(BOOL success, KRKmeans *kmeansObject, NSInteger totalTimes) {
//        NSLog(@"totalTimes : %li", totalTimes);
//        NSLog(@"featuresOfCenters : %@", kmeansObject.featuresOfCenters);
//        NSLog(@"centers objects: %@", kmeansObject.centers);
//        NSLog(@"SSE : %lf", kmeansObject.sse);
//    } perIteration:^(NSInteger times, KRKmeans *kmeansObject, BOOL *pause) {
//        NSLog(@"times : %li", times);
//    }];
//}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self oneDemensionalClustering];
    [self multiClustering];
    //[self randomClustering];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
