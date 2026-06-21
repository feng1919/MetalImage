//
//  MIVoronoiConsumerFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/10/12.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageTwoInputFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MIVoronoiConsumerFilter : MetalImageTwoInputFilter

@property (nonatomic, readwrite) MTLUInt2 sizeInPixels;

@end

NS_ASSUME_NONNULL_END
