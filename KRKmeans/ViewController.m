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
    //kmeansOne.customMedian = 45.0f;
    
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
    kmeans.modelKey      = @"MyKmeans1";
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
        NSString *patternId      = [NSString stringWithFormat:@"Training_%li", index];
        KRKmeansPattern *pattern = [kmeans createPatternWithFeatures:features patternId:patternId];
        [kmeans addPattern:pattern];
    }
    
    [kmeans randomChooseCenters:3];
    
    // @ Distance formula are :
    // KRKmeansKernelCosine is Cosine Similarity
    // KRKmeansKernelEuclidean is Euclidean
    // KRKmeansKernelRBF is Radial Basis Function
    [kmeans setupKernel:KRKmeansKernelEuclidean];
    
    [kmeans clusteringWithCompletion:^(BOOL success, KRKmeans *kmeansObject, NSInteger totalTimes) {
        NSLog(@"totalTimes : %li", totalTimes);
        NSLog(@"featuresOfCenters : %@", kmeansObject.featuresOfCenters);
        NSLog(@"centers objects: %@", kmeansObject.centers);
        NSLog(@"SSE : %lf", kmeansObject.sse);
    } perIteration:^(NSInteger times, KRKmeans *kmeansObject, BOOL *pause) {
        NSLog(@"times : %li", times);
        // If you want to direct pause that next iteration running, then you could set :
        //*pause = YES;
    }];
    
}

// Recovering the tranined groups to predicate patterns.
-(void)predicatingByTrainedModel
{
    KRKmeans *kmeans = [KRKmeans sharedKmeans];
    [kmeans recoverGroupsForKey:@"MyKmeans1"];
    
    NSMutableArray *samples = [NSMutableArray new];
    NSArray *patterns       = @[@[@21, @12], @[@13, @21], @[@12, @5], @[@3, @8]];
    NSInteger index         = -1;
    for( NSArray *features in patterns )
    {
        index += 1;
        NSString *patternId      = [NSString stringWithFormat:@"Predication_%li", index];
        KRKmeansPattern *pattern = [kmeans createPatternWithFeatures:features patternId:patternId];
        [samples addObject:pattern];
    }
    
    [kmeans predicatePatterns:samples completion:^(BOOL success, KRKmeans *kmeansObject, NSInteger totalTimes) {
        NSLog(@"\n\n====================== Predication ===========================\n\n");
        [kmeansObject printResults];
    }];
    
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self oneDemensionalClustering];
    [self multiClustering];
    [self predicatingByTrainedModel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
