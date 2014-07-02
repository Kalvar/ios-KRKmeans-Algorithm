//
//  ViewController.m
//  KRKmeans V1.0
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
    [_krKmeans clustering];
    [_krKmeans printResults];
    
    //Two dimesional K-Means, the data set is (x, y)
    KRKmeansTwo *_krKmeansTwo = [KRKmeansTwo sharedKmeans];
    [_krKmeansTwo addSets:[NSMutableArray arrayWithObjects:@[@1, @1], @[@1, @2], @[@2, @2], @[@3, @2], @[@3, @1], nil]];
    [_krKmeansTwo addSets:[NSMutableArray arrayWithObjects:@[@6, @4], @[@7, @6], @[@5, @6], @[@6, @5], nil]];
    _krKmeansTwo.sources = @[@[@5, @4], @[@3, @4], @[@2, @5]];
    [_krKmeansTwo clustering];
    [_krKmeansTwo printResults];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
