//
//  MIJFAVoronoiFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/10/12.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MIJFAVoronoiFilter : MetalImageFilter

@property (nonatomic, readwrite) MTLUInt2 sizeInPixels;

@end

NS_ASSUME_NONNULL_END
