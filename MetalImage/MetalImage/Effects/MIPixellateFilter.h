//
//  MIPixellateFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/10/13.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MIPixellateFilter : MetalImageFilter

// The fractional width of the image to use as a size for the pixels in the resulting image.
// Values below one pixel width in the source image are ignored.
@property(readwrite, nonatomic) MTLFloat fractionalWidthOfAPixel;

@property (readwrite, nonatomic) id<MTLBuffer> buffer;
@property (readwrite, nonatomic) MTLFloat aspectRatio;
- (void)adjustAspectRatio;

@end

NS_ASSUME_NONNULL_END
