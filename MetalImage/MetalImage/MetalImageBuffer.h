//
//  MetalImageBuffer.h
//  MetalImage
//
//  Created by Feng Stone on 2017/10/20.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MetalImageBuffer : MetalImageFilter
{
    NSMutableArray *bufferedFramebuffers;
}

@property(readwrite, nonatomic) NSUInteger bufferSize;

@end

NS_ASSUME_NONNULL_END
