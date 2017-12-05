//
//  MIGaussianBlurFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/9/2.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MIGaussianBlurFilter.h"

@implementation MIGaussianBlurFilter

#pragma mark -
#pragma mark Initialization and teardown

- (id)initWithFirstStageVertexShaderFromString:(NSString *)firstStageVertexShaderString
            firstStageFragmentShaderFromString:(NSString *)firstStageFragmentShaderString
             secondStageVertexShaderFromString:(NSString *)secondStageVertexShaderString
           secondStageFragmentShaderFromString:(NSString *)secondStageFragmentShaderString
{
    if (!(self = [super initWithFirstStageVertexShaderFromString:firstStageVertexShaderString
                              firstStageFragmentShaderFromString:firstStageFragmentShaderString
                               secondStageVertexShaderFromString:secondStageVertexShaderString
                             secondStageFragmentShaderFromString:secondStageFragmentShaderString]))
    {
        return nil;
    }
    
    self.blurPasses = 1;
    self.texelSpacingMultiplier = 1.0;
    _blurRadiusInPixels = 2.0;
    shouldResizeBlurRadiusWithImageSize = NO;
    
    return self;
}

//- (id)init
//{
//    NSString *currentGaussianBlurVertexShader = [[self class] vertexShaderForOptimizedBlurOfRadius:4 sigma:2.0];
//    NSString *currentGaussianBlurFragmentShader = [[self class] fragmentShaderForOptimizedBlurOfRadius:4 sigma:2.0];
//    
//    return [self initWithFirstStageVertexShaderFromString:currentGaussianBlurVertexShader
//                       firstStageFragmentShaderFromString:currentGaussianBlurFragmentShader
//                        secondStageVertexShaderFromString:currentGaussianBlurVertexShader
//                      secondStageFragmentShaderFromString:currentGaussianBlurFragmentShader];
//}

#pragma mark - 计算高斯梯度
// "Implementation limit of 32 varying components exceeded" - Max number of varyings for these GPUs
+ (NSArray<NSNumber *> *)gaussianWeightsBufferForRadius:(NSUInteger)blurRadius sigma:(CGFloat)sigma {
    NSMutableArray *gaussianKernelArray = [NSMutableArray array];
    if (blurRadius < 1)
    {
        return @[];
    }
    
    // First, generate the normal Gaussian weights for a given sigma
    GLfloat *standardGaussianWeights = calloc(blurRadius + 1, sizeof(GLfloat));
    GLfloat sumOfWeights = 0.0;
    for (NSUInteger currentGaussianWeightIndex = 0; currentGaussianWeightIndex < blurRadius + 1; currentGaussianWeightIndex++)
    {
        standardGaussianWeights[currentGaussianWeightIndex] = (1.0 / sqrt(2.0 * M_PI * pow(sigma, 2.0))) * exp(-pow(currentGaussianWeightIndex, 2.0) / (2.0 * pow(sigma, 2.0)));
        
        if (currentGaussianWeightIndex == 0)
        {
            sumOfWeights += standardGaussianWeights[currentGaussianWeightIndex];
        }
        else
        {
            sumOfWeights += 2.0 * standardGaussianWeights[currentGaussianWeightIndex];
        }
    }
    
    // Next, normalize these weights to prevent the clipping of the Gaussian curve at the end of the discrete samples from reducing luminance
    for (NSUInteger currentGaussianWeightIndex = 0; currentGaussianWeightIndex < blurRadius + 1; currentGaussianWeightIndex++)
    {
        GLfloat gaussianWeight = standardGaussianWeights[currentGaussianWeightIndex] / sumOfWeights;
        [gaussianKernelArray addObject:@(gaussianWeight)];
    }
    
    free(standardGaussianWeights);
    
    return [NSArray arrayWithArray:gaussianKernelArray];
}

// inputRadius for Core Image's CIGaussianBlur is really sigma in the Gaussian equation, so I'm using that for my blur radius, to be consistent
- (void)setBlurRadiusInPixels:(CGFloat)newValue;
{
    // 7.0 is the limit for blur size for hardcoded varying offsets
    
    if (round(newValue) != _blurRadiusInPixels)
    {
        _blurRadiusInPixels = round(newValue); // For now, only do integral sigmas
        
        NSUInteger calculatedSampleRadius = 0;
        if (_blurRadiusInPixels >= 1) // Avoid a divide-by-zero error here
        {
            // Calculate the number of pixels to sample from by setting a bottom limit for the contribution of the outermost pixel
            CGFloat minimumWeightToFindEdgeOfSamplingArea = 1.0/256.0;
            calculatedSampleRadius = floor(sqrt(-2.0 * pow(_blurRadiusInPixels, 2.0) * log(minimumWeightToFindEdgeOfSamplingArea * sqrt(2.0 * M_PI * pow(_blurRadiusInPixels, 2.0))) ));
            calculatedSampleRadius += calculatedSampleRadius % 2; // There's nothing to gain from handling odd radius sizes, due to the optimizations I use
        }
        
        //        NSLog(@"Blur radius: %f, calculated sample radius: %d", _blurRadiusInPixels, calculatedSampleRadius);
        //
//        NSString *newGaussianBlurVertexShader = [[self class] vertexShaderForOptimizedBlurOfRadius:calculatedSampleRadius sigma:_blurRadiusInPixels];
//        NSString *newGaussianBlurFragmentShader = [[self class] fragmentShaderForOptimizedBlurOfRadius:calculatedSampleRadius sigma:_blurRadiusInPixels];
//
//        //        NSLog(@"Optimized vertex shader: \n%@", newGaussianBlurVertexShader);
//        //        NSLog(@"Optimized fragment shader: \n%@", newGaussianBlurFragmentShader);
//        //
//        [self switchToVertexShader:newGaussianBlurVertexShader fragmentShader:newGaussianBlurFragmentShader];
        
        NSArray<NSNumber *> *gaussianWeights = [[self class] gaussianWeightsBufferForRadius:calculatedSampleRadius sigma:_blurRadiusInPixels];
        
        NSLog(@"gaussian weights: %@", gaussianWeights);
        
    }
    shouldResizeBlurRadiusWithImageSize = NO;
}




@end
