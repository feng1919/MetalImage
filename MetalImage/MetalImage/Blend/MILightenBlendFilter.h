//
//  MILightenBlendFilter.h
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageTwoInputFilter.h"

NS_ASSUME_NONNULL_BEGIN
/// Blends two images by taking the maximum value of each color component between the images
@interface MILightenBlendFilter : MetalImageTwoInputFilter

@end

NS_ASSUME_NONNULL_END
