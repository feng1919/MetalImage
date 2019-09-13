//
//  MIHighPassFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/12/5.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilterGroup.h"
#import "MILowPassFilter.h"
#import "MIDifferenceBlendFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MIHighPassFilter : MetalImageFilterGroup
{
@protected
    MILowPassFilter *lowPassFilter;
    MIDifferenceBlendFilter *differenceBlendFilter;
}

// This controls the degree by which the previous accumulated frames are blended and then subtracted from the current one. This ranges from 0.0 to 1.0, with a default of 0.5.
@property(readwrite, nonatomic) MTLFloat filterStrength;

@end

NS_ASSUME_NONNULL_END
