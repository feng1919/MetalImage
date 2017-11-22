//
//  MetalImageVoronoiConsumerFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/10/12.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageTwoInputFilter.h"

@interface MetalImageVoronoiConsumerFilter : MetalImageTwoInputFilter

@property (nonatomic, readwrite) MTLUInt2 sizeInPixels;

@end
