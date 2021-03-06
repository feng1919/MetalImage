//
//  MILanczosResamplingFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/12/5.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MITwoPassTextureSamplingFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MILanczosResamplingFilter : MITwoPassTextureSamplingFilter {
    
@protected
    BOOL fixedOriginalImageSize;
}

@property (nonatomic, assign) MTLUInt2 originalImageSize;

@end

NS_ASSUME_NONNULL_END
