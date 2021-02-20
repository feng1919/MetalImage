//
//  MIHistogramEqualizationFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2021/2/19.
//  Copyright © 2021 fengshi. All rights reserved.
//

#import <MetalImage/MetalImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface MIHistogramEqualizationFilter : MetalImageFilter

// Rather than sampling every pixel, this dictates what fraction of the image is sampled. By default, this is 16 with a minimum of 1.
@property (readwrite, nonatomic) NSUInteger downsamplingFactor;

@property (readwrite, nonatomic) NSTimeInterval duration;

@end

NS_ASSUME_NONNULL_END
