//
//  MILowPassFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/12/5.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilterGroup.h"
#import "MetalImageBuffer.h"
#import "MIDissolveBlendFilter.h"

@interface MILowPassFilter : MetalImageFilterGroup
{    
@protected
    MetalImageBuffer *bufferFilter;
    MIDissolveBlendFilter *dissolveBlendFilter;
}

// This controls the degree by which the previous accumulated frames are blended with the current one.
// This ranges from 0.0 to 1.0, with a default of 0.5.
@property(readwrite, nonatomic) MTLFloat filterStrength;

@end
