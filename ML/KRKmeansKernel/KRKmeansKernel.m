//
//  KRKmeansKernel.m
//  KRKmeans
//
//  Created by Kalvar Lin on 2016/6/4.
//  Copyright © 2016年 Kalvar. All rights reserved.
//

#import "KRKmeansKernel.h"

@implementation KRKmeansKernel

- (instancetype)initWithKernel:(KRKmeansKernels)useKernel
{
    self = [super init];
    if( self )
    {
        _kernel = useKernel;
        _sigma  = 2.0f;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithKernel:KRKmeansKernelEuclidean];
}

// Euclidean distance which multi-dimensional formula, 距離越小越近
- (double)euclideanX1:(NSArray *)_x1 x2:(NSArray *)_x2
{
    NSInteger _index = 0;
    double _sum      = 0.0f;
    for( NSNumber *_x in _x1 )
    {
        _sum        += powf([_x doubleValue] - [[_x2 objectAtIndex:_index] doubleValue], 2);
        ++_index;
    }
    // 累加完距離後直接開根號
    return (_index > 0) ? sqrtf(_sum) : _sum;
}

// Cosine Similarity method that multi-dimensional, 同歸屬度越大越近
- (double)cosineSimilarityX1:(NSArray *)_x1 x2:(NSArray *)_x2
{
    double _sumA     = 0.0f;
    double _sumB     = 0.0f;
    double _sumAB    = 0.0f;
    NSInteger _index = 0;
    for( NSNumber *_featureValue in _x1 )
    {
        NSNumber *_trainValue = [_x2 objectAtIndex:_index];
        float _aValue  = [_featureValue doubleValue];
        float _bValue  = [_trainValue doubleValue];
        _sumA         += ( _aValue * _aValue );
        _sumB         += ( _bValue * _bValue );
        _sumAB        += ( _aValue * _bValue );
        ++_index;
    }
    float _ab = _sumA * _sumB;
    return ( _ab > 0.0f ) ? ( _sumAB / sqrtf( _ab ) ) : 0.0f;
}

- (double)rbf:(NSArray *)_x1 x2:(NSArray *)_x2 sigma:(double)_rbfSigma
{
    double _sum      = 0.0f;
    NSInteger _index = 0;
    for( NSNumber *_value in _x1 )
    {
        // Formula : s = s + ( v1[i] - v2[i] )^2
        double _v  = [_value doubleValue] - [[_x2 objectAtIndex:_index] doubleValue];
        _sum      += ( _v * _v );
        ++_index;
    }
    // Formula : exp^( -s / ( 2.0f * sigma * sigma ) )
    return pow(M_E, ((-_sum) / ( 2.0f * _rbfSigma * _rbfSigma )));
}

// 距離概念是越小越近，歸屬度概念是越大越近 ( 或取其差值，使歸屬度同距離越小越近 )
- (double)distanceBetweenX1:(NSArray *)_x1 x2:(NSArray *)_x2
{
    double _distance = 0.0f;
    if( nil != _x1 && nil != _x2 )
    {
        switch (_kernel)
        {
            case KRKmeansKernelCosine:
                _distance = 1.0f - [self cosineSimilarityX1:_x1 x2:_x2];
                break;
            case KRKmeansKernelEuclidean:
                _distance = [self euclideanX1:_x1 x2:_x2];
                break;
            case KRKmeansKernelRBF:
                _distance = [self rbf:_x1 x2:_x2 sigma:_sigma];
                break;
            default:
                break;
        }
    }
    return _distance;
}

- (NSInteger)randomIntegerWithMax:(NSInteger)_maxValue min:(NSInteger)_minValue
{
    return ( arc4random() / ( RAND_MAX * 2.0f ) ) * (_maxValue - _minValue) + _minValue;;
}

@end
