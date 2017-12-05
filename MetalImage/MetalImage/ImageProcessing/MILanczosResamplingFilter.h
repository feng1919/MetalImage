//
//  MILanczosResamplingFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/12/5.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageTwoPassTextureSamplingFilter.h"

@interface MILanczosResamplingFilter : MetalImageTwoPassTextureSamplingFilter {
    
@protected
    BOOL fixedOriginalImageSize;
}

@property (nonatomic, assign) MTLUInt2 originalImageSize;

@end
