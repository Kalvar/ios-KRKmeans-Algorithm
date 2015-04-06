ios-KRKmeans-Algorithm
=================

KRKmeans has implemented K-Means that is a classification algorithm. If you wanna know how to use and the details, you could contact me via email.

``` objective-c
#import "KRKmeansOne.h"
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
            Tmid = 1 ( 使用自動計算中位數, _krKmeans.useCustomMedian = NO )
        
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
}
```

## Version

V2.1

## License

MIT.
