//
//  MISurfaceBlurFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2020/6/23.
//  Copyright © 2020 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MISurfaceBlurFilter : MetalImageFilter

//  Default is 3
@property (nonatomic, assign) int radius;

// Default is 15
@property (nonatomic, assign) float gamma;


@end

NS_ASSUME_NONNULL_END
