//
//  MetalImageTwoInputFilter.h
//  MetalImage
//
//  Created by stonefeng on 2017/3/29.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MetalImageTwoInputFilter : MetalImageFilter {
    
@protected
    MetalImageTexture *secondInputTexture;
    MetalImageInputParameter secondInputParameter;
    
    id<MTLBuffer> _coordBuffer2;
}

- (void)disableFirstFrameCheck;
- (void)disableSecondFrameCheck;

@end

NS_ASSUME_NONNULL_END
