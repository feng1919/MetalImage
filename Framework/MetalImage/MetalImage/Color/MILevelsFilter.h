//
//  MILevelsFilter.h
//  MetalImage
//
//  Created by stonefeng on 2017/3/20.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

/**
 * Levels like Photoshop.
 *
 * The min, max, minOut and maxOut parameters are floats in the range [0, 1].
 * If you have parameters from Photoshop in the range [0, 255] you must first
 * convert them to be [0, 1].
 * The gamma/mid parameter is a float >= 0. This matches the value from Photoshop.
 *
 * If you want to apply levels to RGB as well as individual channels you need to use
 * this filter twice - first for the individual channels and then for all channels.
 */
NS_ASSUME_NONNULL_BEGIN

@interface MILevelsFilter : MetalImageFilter

@property (nonatomic,assign) MTLFloat3 minVector;
@property (nonatomic,assign) MTLFloat3 midVector;
@property (nonatomic,assign) MTLFloat3 maxVector;
@property (nonatomic,assign) MTLFloat3 minOutputVector;
@property (nonatomic,assign) MTLFloat3 maxOutputVector;

/** Set levels for the red channel */
- (void)setRedMin:(MTLFloat)min gamma:(MTLFloat)mid max:(MTLFloat)max;
- (void)setRedMin:(MTLFloat)min gamma:(MTLFloat)mid max:(MTLFloat)max minOut:(MTLFloat)minOut maxOut:(MTLFloat)maxOut;

/** Set levels for the green channel */
- (void)setGreenMin:(MTLFloat)min gamma:(MTLFloat)mid max:(MTLFloat)max;
- (void)setGreenMin:(MTLFloat)min gamma:(MTLFloat)mid max:(MTLFloat)max minOut:(MTLFloat)minOut maxOut:(MTLFloat)maxOut;

/** Set levels for the blue channel */
- (void)setBlueMin:(MTLFloat)min gamma:(MTLFloat)mid max:(MTLFloat)max;
- (void)setBlueMin:(MTLFloat)min gamma:(MTLFloat)mid max:(MTLFloat)max minOut:(MTLFloat)minOut maxOut:(MTLFloat)maxOut;

/** Set levels for all channels at once */
- (void)setMin:(MTLFloat)min gamma:(MTLFloat)mid max:(MTLFloat)max minOut:(MTLFloat)minOut maxOut:(MTLFloat)maxOut;
- (void)setMin:(MTLFloat)min gamma:(MTLFloat)mid max:(MTLFloat)max;

- (void)updateVectorBuffer;

@end

NS_ASSUME_NONNULL_END
