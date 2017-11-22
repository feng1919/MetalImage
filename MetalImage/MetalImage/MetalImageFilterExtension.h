//
//  MetalImageFilterExtension.h
//  MetalImage
//
//  Created by fengshi on 2017/9/10.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

@interface MetalImageFilter (Extension)

- (MTLFloat2)rotatedPoint:(MTLFloat2)pointToRotate forRotation:(MetalImageRotationMode)rotation;

@end
