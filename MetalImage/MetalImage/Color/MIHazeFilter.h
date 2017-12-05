//
//  MIHazeFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/8/23.
//  Copyright © 2017年 fengshi. All rights reserved.
//

/*
 * The haze filter can be used to add or remove haze (similar to a UV filter)
 *
 * @author Alaric Cole
 * @creationDate 03/10/12
 *
 */

/** The haze filter can be used to add or remove haze
 
 This is similar to a UV filter
 */

#import "MetalImageFilter.h"

@interface MIHazeFilter : MetalImageFilter

/** Strength of the color applied. Default 0. Values between -.3 and .3 are best
 */
@property (readwrite, nonatomic) CGFloat distance;

/** Amount of color change. Default 0. Values between -.3 and .3 are best
 */
@property (readwrite, nonatomic) CGFloat slope;

@property (nonatomic, strong) id<MTLBuffer> buffer;

@end
