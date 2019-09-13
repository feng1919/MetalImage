//
//  MIHistogramFilter.h
//  MetalImage
//
//  Created by fengshi on 2017/11/3.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "MetalImageFilter.h"

typedef enum {
    kMetalImageHistogramRed,
    kMetalImageHistogramGreen,
    kMetalImageHistogramBlue,
    kMetalImageHistogramRGB,
    kMetalImageHistogramLuminance
} MetalImageHistogramType;

NS_ASSUME_NONNULL_BEGIN

@interface MIHistogramFilter : MetalImageFilter
{
    MetalImageHistogramType histogramType;
    
//    GLubyte *vertexSamplingCoordinates;
}


// Rather than sampling every pixel, this dictates what fraction of the image is sampled. By default, this is 16 with a minimum of 1.
@property(readwrite, nonatomic) NSUInteger downsamplingFactor;

@property (nonatomic, strong) id<MTLBuffer> pixelBuffer;

// Initialization and teardown
- (id)initWithHistogramType:(MetalImageHistogramType)newHistogramType;

@end

NS_ASSUME_NONNULL_END
