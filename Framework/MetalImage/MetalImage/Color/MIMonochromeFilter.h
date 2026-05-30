//
//  MIMonochromeFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/7/22.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MIMonochromeFilter : MetalImageFilter

@property (readwrite, nonatomic) CGFloat intensity;
@property (readwrite, nonatomic) MTLFloat4 color;
@property (nonatomic, strong) id<MTLBuffer> buffer;

@end

NS_ASSUME_NONNULL_END
