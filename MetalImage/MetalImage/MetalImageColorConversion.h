//
//  MetalImageColorConversion.h
//  MetalImage
//
//  Created by stonefeng on 2017/3/3.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MetalImageTexture.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ColorConversionKernalFunction) {
    ColorConversionKernalFunction601v,
    ColorConversionKernalFunction601f,
    ColorConversionKernalFunction709v,
};

@interface MetalImageColorConversion : NSObject

@property (nonatomic,assign) ColorConversionKernalFunction function;

- (void)generateBGROutputTexture:(nonnull id<MTLTexture>)texture
                          YPlane:(nonnull id<MTLTexture>)y_texture
                         UVPlane:(nonnull id<MTLTexture>)uv_texture;

@end

NS_ASSUME_NONNULL_END
