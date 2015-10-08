ios-KRKmeans-Algorithm
=================

KRKmeans has implemented K-Means the clustering and classification algorithm (クラスタリング分類). It could be used in data mining (データマイニング) and image compression (画像圧縮). If you wanna know how to use and the details, you could contact me via email.

#### Podfile

```ruby
platform :ios, '7.0'
pod "KRKmeans", "~> 2.3"
```

## How to use

``` objective-c
#import "KRKmeans.h"

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //One dimensional K-Means, the data set is any number means.
    KRKmeansOne *_krKmeansOne = [KRKmeansOne sharedKmeans];
    _krKmeansOne.sources      = @[@0.33, @0.88, @1, @0.52, @146, @120, @45, @43, @0.4];
    //If you wanna customize the median value
    //_krKmeansOne.useCustomMedian = YES;
    //_krKmeansOne.customMedian    = 45.0f;
    [_krKmeansOne clustering];
    [_krKmeansOne printResults];
    /*
    Output :
     
        Conditions :
            n    = 3
            Tmax = 146
            Tmin = 0.33
            Tmid = 1 ( Auto-calculate the median number, _krKmeans.useCustomMedian = NO )
        
        Answer :
        
            Max Clusters : 0.33, 0.52, 0.4
            Min Clusters : 0.88, 1, 45, 43
            Mid Clusters : 146, 120
        
        Knowledge Line :
        
            63.110001
    */
    
    //Two dimesional K-Means, the data set is (x, y)
    KRKmeans *_krKmeans = [KRKmeans sharedKmeans];
    //It means A sets.
    [_krKmeans addSets:@[@[@1, @1], @[@1, @2], @[@2, @2], @[@3, @2], @[@3, @1]]];
    
    //It means B sets.
    [_krKmeans addSets:@[@[@6, @4], @[@7, @6], @[@5, @6], @[@6, @5]]];
    
    //It means C sets.
    //[_krKmeans addSets:@[@[@7, @9], @[@7, @8], @[@5, @5], @[@9, @3]]];
    
    //It means D sets.
    //[_krKmeans addSets:@[@[@3, @12], @[@5, @20]]];
    
    //It means X sets which wanna be clustered, if you don't setup this, the KRKmeans will cluster the original sets to be new groups.
    _krKmeans.sources = @[@[@5, @4], @[@3, @4], @[@2, @5], @[@9, @8], @[@3, @20]];
    
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
    //[_krKmeans directCluster];
    //[_krKmeans printResults];
    /*
    Output :
    
        Center Point of Sets :
        
            A Sets : (2, 1.6)
            B Sets : (6, 5.25)
     
        Results :
        
            A Sets : (1, 1) (1, 2) (2, 2) (3, 2) (3, 1) (3, 4) (2, 5) (6, 4) (7, 6) (5, 6) (6, 5) (5, 4)
            B Sets : (9, 8) (3, 20)
     */

    // Multi-Dimensional K-Means
    KRKmeans *_multiKmeans = [[KRKmeans alloc] init];
    [_multiKmeans addSets:@[@[@20, @9, @1, @3, @6, @2], @[@52, @32, @18, @7, @0, @1], @[@30, @18, @2, @27, @18, @5]]];
    [_multiKmeans addSets:@[@[@2, @20, @15, @5, @9, @16], @[@7, @11, @2, @12, @1, @0]]];
    
    [_multiKmeans addPatterns:@[@[@20, @1, @10, @2, @12, @3], @[@20, @8, @3, @21, @8, @25], @[@2, @30, @8, @6, @33, @29]]];
    [_multiKmeans addPatterns:@[@[@10, @3, @5, @12, @9, @8], @[@2, @1, @9, @30, @28, @13], @[@22, @50, @43, @22, @11, @2]]];
    [_multiKmeans addPatterns:@[@[@18, @10, @20, @42, @32, @13], @[@5, @4, @28, @16, @3, @9]]];
    
    [_multiKmeans clusteringWithCompletion:^(BOOL success, NSArray *clusters, NSArray *centers, NSInteger totalTimes)
    {
        NSLog(@"totalTimes : %li", totalTimes);
        NSLog(@"clusters : %@", clusters);
        NSLog(@"centers : %@", centers);
        NSLog(@"SSE : %lf", [_multiKmeans calculateSSE]);
    } eachGeneration:^(NSInteger times, NSArray *clusters, NSArray *centers)
    {
        NSLog(@"times : %li", times);
    }];
}
```

## Version

V2.3

## License

MIT.
