//
//  MICropFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/10/13.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MICropFilter : MetalImageFilter {
@protected
    MTLFloat2 cropTextureCoordinates[4];
}

// The crop region is the rectangle within the image to crop. It is normalized to a coordinate space from 0.0 to 1.0, with 0.0, 0.0 being the upper left corner of the image
@property(readwrite, nonatomic) CGRect cropRegion;

// Initialization and teardown
- (id)initWithCropRegion:(CGRect)newCropRegion;

- (void)setTextureCropCoordinates:(MTLFloat2[_Nonnull 4])coordinates;

@end

NS_ASSUME_NONNULL_END
