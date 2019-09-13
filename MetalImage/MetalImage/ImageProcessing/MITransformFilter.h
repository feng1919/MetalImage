//
//  MITransformFilter.h
//  MetalImage
//
//  Created by fengshi on 2017/10/14.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "MetalImageFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MITransformFilter : MetalImageFilter

// You can either set the transform to apply to be a 2-D affine transform or a 3-D transform.
// The default is the identity transform (the output image is identical to the input).
@property(readwrite, nonatomic) CGAffineTransform affineTransform;
@property(readwrite, nonatomic) CATransform3D transform3D;

// This applies the transform to the raw frame data if set to YES,
// the default of NO takes the aspect ratio of the image input into account when rotating
@property(readwrite, nonatomic) BOOL ignoreAspectRatio;

// sets the anchor point to top left corner, the default is NO.
@property(readwrite, nonatomic) BOOL anchorTopLeft;

@end

NS_ASSUME_NONNULL_END
