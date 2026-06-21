//
//  MetalImageTwoInputKernel.h
//  MetalImage
//
//  Created by stonefeng on 2017/4/7.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageKernel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MetalImageTwoInputKernel : MetalImageKernel {
    
@protected
    MetalImageTexture *secondInputTexture;
    MetalImageInputParameter secondInputParameter;
}

@end

NS_ASSUME_NONNULL_END
