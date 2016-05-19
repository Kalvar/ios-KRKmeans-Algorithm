ios-KRKmeans-Algorithm
=================

KRKmeans has implemented K-Means the clustering algorithm (クラスタリング分類) and achieved multi-dimensional clustering in this project. KRKmeans could be used in data mining (データマイニング), image compression (画像圧縮) and classification.

#### Podfile

```ruby
platform :ios, '7.0'
pod "KRKmeans", "~> 2.5.3"
```

## How to use

##### Imports "KRKmeans.h"

``` objective-c
#import "KRKmeans.h"
```

##### Distance Methods

``` objective-c
KRKmeansDistanceFormulaEuclidean
KRKmeansDistanceFormulaCosine
KRKmeansDistanceFormulaRBF
```

#### One dimensonal clustering

``` objective-c
-(void)oneDemensional
{
    //One dimensional K-Means, the data set is any number means.
    KRKmeansOne *_krKmeansOne = [KRKmeansOne sharedKmeans];
    _krKmeansOne.sources      = @[@0.33, @0.88, @1, @0.52, @146, @120, @45, @43, @0.4];
    
    //If you wanna customize the median value
    //_krKmeansOne.customMedian = 45.0f;
    
    [_krKmeansOne clusteringWithCompletion:^(BOOL success, float knowledgeLine, NSArray *maxClusters, NSArray *minClusters, NSArray *midClusters, NSDictionary *overlappings)
    {
        NSLog(@"knowledgeLine : %f", knowledgeLine);
        NSLog(@"maxClusters : %@", maxClusters);
        NSLog(@"minClusters : %@", minClusters);
        NSLog(@"midClusters : %@", midClusters);
        NSLog(@"overlappings : %@", overlappings);
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

```

#### Two dimensonal clustering

``` objective-c
-(void)twoDemensional
{
    //Two dimesional K-Means, the data set is (x, y)
    KRKmeans *_krKmeans = [KRKmeans sharedKmeans];

    // Set to Euclidean Distance method that performance is better
    _krKmeans.dimensional = KRKmeansDistanceFormulaEuclidean;

    //It means A sets. ( and the centers will be calculated here. )
    [_krKmeans addSets:@[@[@1, @1], @[@1, @2], @[@2, @2], @[@3, @2], @[@3, @1]]];
    
    //It means B sets.
    [_krKmeans addSets:@[@[@6, @4], @[@7, @6], @[@5, @6], @[@6, @5]]];
    
    //It means C sets and the center.
    [_krKmeans addSets:@[@[@7, @8]]];
    
    //It means D sets.
    [_krKmeans addSets:@[@[@3, @12], @[@5, @20]]];
    
    //It means X sets which wanna be clustered, if you don't setup this, the KRKmeans will cluster the original sets to be new groups.
    [_krKmeans addPatterns:@[@[@5, @4], @[@3, @4], @[@2, @5], @[@9, @8], @[@3, @20]]];
    
    [_krKmeans clusteringWithCompletion:^(BOOL success, NSArray *clusters, NSArray *centers, NSInteger totalTimes)
    {
        NSLog(@"totalTimes : %li", totalTimes);
        NSLog(@"clusters : %@", clusters);
        NSLog(@"centers : %@", centers);
        NSLog(@"SSE : %lf", [_krKmeans calculateSSE]);
    } eachGeneration:^(NSInteger times, NSArray *clusters, NSArray *centers)
    {
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
```

#### Multi-dimensonal clustering

``` objective-c
-(void)multiDemensional
{
    // Multi-Dimensional K-Means
    KRKmeans *_multiKmeans = [[KRKmeans alloc] init];

    // Suggests to use Cosine Similarity doing multi-dimensional clustering
    _multiKmeans.dimensional = KRKmeansDistanceFormulaCosine;
    
    // A sets
    [_multiKmeans addSets:@[@[@20, @9, @1, @3, @6, @2], @[@52, @32, @18, @7, @0, @1], @[@30, @18, @2, @27, @18, @5]]];
    
    // B sets
    [_multiKmeans addSets:@[@[@2, @20, @15, @5, @9, @16], @[@7, @11, @2, @12, @1, @0]]];
    
    // Clustering samples
    [_multiKmeans addPatterns:@[@[@20, @1, @10, @2, @12, @3], @[@20, @8, @3, @21, @8, @25], @[@2, @30, @8, @6, @33, @29]]];
    [_multiKmeans addPatterns:@[@[@10, @3, @5, @12, @9, @8], @[@2, @1, @9, @30, @28, @13], @[@22, @50, @43, @22, @11, @2]]];
    [_multiKmeans addPatterns:@[@[@18, @10, @20, @42, @32, @13], @[@5, @4, @28, @16, @3, @9]]];
    
    [_multiKmeans clusteringWithCompletion:^(BOOL success, NSArray *clusters, NSArray *centers, NSInteger totalTimes)
    {
        NSLog(@"totalTimes : %li", totalTimes);
        NSLog(@"clusters : %@", clusters);
        NSLog(@"centers : %@", centers);
        NSLog(@"SSE : %lf", [_multiKmeans calculateSSE]);
        [_multiKmeans directClusterPatterns:@[@[@21, @9, @3, @11, @7, @15]] completion:^(BOOL success, NSArray *clusters, NSArray *centers, NSInteger totalTimes)
        {
            [_multiKmeans printResults];
        }];
    } eachGeneration:^(NSInteger times, NSArray *clusters, NSArray *centers)
    {
        NSLog(@"times : %li", times);
    }];
}
```

#### Directly clustering

If you have trained clusters that you could directly put new patterns into directly clustering.

``` objective-c
// Following [self twoDemensional] that classified clusters to direct clustering new patterns.
-(void)directClustering
{
    KRKmeans *_kmeans   = [KRKmeans sharedKmeans];
    _kmeans.dimensional = KRKmeansDistanceFormulaEuclidean;
    [_kmeans addPatterns:@[@[@7, @11], @[@18, @6]]];
    [_kmeans directClusterWithCompletion:^(BOOL success, NSArray *clusters, NSArray *centers, NSInteger totalTimes)
    {
        [_kmeans printResults];
    }];
}
```

#### Automatic clustering

Automatic picking the group-centers by your wishes number.

``` objective-c
-(void)randomClustering
{
    KRKmeans *_krKmeans         = [[KRKmeans alloc] init];
    _krKmeans.doneThenSave      = YES;
    _krKmeans.distanceFormula   = KRKmeansDistanceFormulaEuclidean; // KRKmeansDistanceFormulaCosine
    _krKmeans.autoClusterNumber = 3;
    [_krKmeans addPatterns:@[@[@1, @1], @[@1, @2], @[@2, @2], @[@3, @2],
                             @[@3, @1], @[@5, @4], @[@3, @4], @[@2, @5],
                             @[@9, @8], @[@3, @20], @[@6, @4], @[@7, @6],
                             @[@5, @6], @[@6, @5], @[@7, @8], @[@3, @12],
                             @[@5, @20]]];
    [_krKmeans clusteringWithCompletion:^(BOOL success, NSArray *clusters, NSArray *centers, NSInteger totalTimes) {
        NSLog(@"totalTimes : %li", totalTimes);
        NSLog(@"clusters : %@", clusters);
        NSLog(@"centers : %@", centers);
        NSLog(@"SSE : %lf", [_krKmeans calculateSSE]);
    } perIteration:^(NSInteger times, NSArray *clusters, NSArray *centers) {
        NSLog(@"times : %li", times);
    }];
}
```

#### Recalling tranined clasification group-centers

``` objective-c
// Recalling the tranined groups to directly classify patterns
-(void)recallingTraninedCenters
{
    KRKmeans *_krKmeans = [KRKmeans sharedKmeans];
    [_krKmeans recallCenters];
    [_krKmeans addPatterns:@[@[@21, @12], @[@13, @21], @[@12, @5], @[@3, @8]]];
    [_krKmeans directClusterWithCompletion:^(BOOL success, NSArray *clusters, NSArray *centers, NSInteger totalTimes) {
        [_krKmeans printResults];
    }];
}
```

## Version

V2.5.3

## License

MIT.