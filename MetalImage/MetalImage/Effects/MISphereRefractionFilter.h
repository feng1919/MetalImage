//
//  MISphereRefractionFilter.h
//  MetalImage
//
//  Created by fengshi on 2017/10/10.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

@interface MISphereRefractionFilter : MetalImageFilter

/// The center about which to apply the distortion, with a default of (0.5, 0.5)
@property(readwrite, nonatomic) MTLFloat2 center;
/// The radius of the distortion, ranging from 0.0 to 1.0, with a default of 0.25
@property(readwrite, nonatomic) MTLFloat radius;
/// The index of refraction for the sphere, with a default of 0.71
@property(readwrite, nonatomic) MTLFloat refractiveIndex;

@end
