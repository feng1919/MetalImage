//
//  MIKuwaharaFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/10/12.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

NS_ASSUME_NONNULL_BEGIN
/** Kuwahara image abstraction, drawn from the work of Kyprianidis, et. al. in their publication "Anisotropic Kuwahara Filtering on the GPU" within the GPU Pro collection. This produces an oil-painting-like image, but it is extremely computationally expensive, so it can take seconds to render a frame on an iPad 2. This might be best used for still images.
 */
@interface MIKuwaharaFilter : MetalImageFilter

/// The radius to sample from when creating the brush-stroke effect, with a default of 3. The larger the radius, the slower the filter.
@property(readwrite, nonatomic) NSUInteger radius;

@end

NS_ASSUME_NONNULL_END
