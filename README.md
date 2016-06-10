ios-KRKmeans-Algorithm
=================

KRKmeans has implemented K-Means the clustering algorithm (クラスタリング分類) and achieved multi-dimensional clustering in this project. KRKmeans could be used in data mining (データマイニング), image compression (画像圧縮) and classification.

#### Podfile

```ruby
platform :ios, '7.0'
pod "KRKmeans", "~> 2.6.1"
```

## How to use

##### Imports "KRKmeans.h"

``` objective-c
#import "KRKmeans.h"
```

##### Distance Methods

"KRKmeansKernelCosine" is Cosine Similarity.
"KRKmeansKernelEuclidean" is Euclidean.
"KRKmeansKernelRBF" is Radial Basis Function.

#### Choosing Centers of Groups

``` objective-c
// 1. Random choosing the centers of groups from patterns.
[kmeans randomChooseCenters:3];

// 2. Quickly customizing the groups and centers
[kmeans addGroupForCenterFeatures:@[@2, @2] centerId:@"Center_1" groupId:@"Group_1"];
[kmeans addGroupForCenterFeatures:@[@6, @5] centerId:@"Center_2" groupId:@"Group_2"];
[kmeans addGroupForCenterFeatures:@[@3, @17] centerId:@"Center_3" groupId:@"Group_3"];
```

#### One dimensonal clustering

The one dimensonal clustering.

``` objective-c
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
}

```

#### Multi-dimensonal clustering

``` objective-c
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
```

#### Predicating & Recovering

To recover that trained model to predicate the patterns.

``` objective-c
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
```

## Version

V2.6.1

## License

MIT.