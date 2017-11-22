//
//  MetalImageColorConversion.m
//  MetalImage
//
//  Created by stonefeng on 2017/3/3.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageColorConversion.h"
#import "MetalImageContext.h"
#import "MetalImageTexture.h"
#import "MetalDevice.h"
/*
// Color Conversion Constants (YUV to RGB) including adjustment from 16-235/16-240 (video range)

// BT.601, which is the standard for SDTV.
float kColorConversion601Default[] = {
    1.164,  1.164,  1.164,
    0.0,    -0.392, 2.017,
    1.596,  -0.813, 0.0,
};

// BT.601 full range (ref: http://www.equasys.de/colorconversion.html)
float kColorConversion601FullRangeDefault[] = {
    1.0,    1.0,    1.0,
    0.0,    -0.343, 1.765,
    1.4,    -0.711, 0.0,
};

// BT.709, which is the standard for HDTV.
float kColorConversion709Default[] = {
    1.164,  1.164,  1.164,
    0.0,    -0.213, 2.112,
    1.793,  -0.533, 0.0,
};
*/


@interface MetalImageColorConversion () {
    id<MTLComputePipelineState> k_yuv2rgb;
}

@end

@implementation MetalImageColorConversion

- (instancetype)init {
    if (self = [super init]) {
//        m_InflightSemaphore = dispatch_semaphore_create(1);
        [self setFunction:ColorConversionKernalFunction601f];
        
    }
    return self;
}

- (void)setFunction:(ColorConversionKernalFunction)functionType {
    if (_function != functionType) {
        _function = functionType;
        
        NSString *functionName = [self functionNameWithType:functionType];
        
        id<MTLDevice> device = [MetalDevice sharedMTLDevice];
        id<MTLLibrary> defaultLibrary = [MetalDevice MetalImageLibrary];
        id<MTLFunction> function = [defaultLibrary newFunctionWithName:functionName];
        
        NSError *error = nil;
        k_yuv2rgb = [device newComputePipelineStateWithFunction:function error:&error];
        NSAssert(error == nil, @"Generate compute pipeline state failed.%@",error);
    }
}

- (NSString *)functionNameWithType:(ColorConversionKernalFunction)function {
    switch (function) {
        case ColorConversionKernalFunction601f:
            NSLog(@"YUV Conversion 601f");
            return @"yuv2rgb_601f";
            break;
        case ColorConversionKernalFunction601v:
            NSLog(@"YUV Conversion 601v");
            return @"yuv2rgb_601v";
            break;
        case ColorConversionKernalFunction709v:
            NSLog(@"YUV Conversion 709f");
            return @"yuv2rgb_709v";
            break;
        default:
            NSAssert(NO, @"Invalid function type");
            NSLog(@"YUV Conversion 601v default");
            return @"yuv2rgb_601v";
            break;
    }
}

- (void)generateBGROutputTexture:(id<MTLTexture>)texture YPlane:(id<MTLTexture>)y_texture UVPlane:(id<MTLTexture>)uv_texture {
    NSParameterAssert(texture);
    NSParameterAssert(y_texture);
    NSParameterAssert(uv_texture);
    
//    dispatch_semaphore_wait(m_InflightSemaphore, DISPATCH_TIME_FOREVER);
    
    NSUInteger width = [texture width];
    NSUInteger height = [texture height];
    
    id <MTLCommandBuffer> commandBuffer = [MetalDevice sharedCommandBuffer];
    id <MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];
    NSAssert(computeEncoder != nil, @"Failed to create compute encode.");
    
    MTLSize m_ThreadgroupSize = MTLSizeMake(16, 16, 1);
    MTLSize m_ThreadgroupCount = MTLSizeMake(ceilf(width/16.0f), ceilf(height/16.0f), 1);
    
    [computeEncoder setComputePipelineState:k_yuv2rgb];
    [computeEncoder setTexture:y_texture atIndex:0];
    [computeEncoder setTexture:uv_texture atIndex:1];
    [computeEncoder setTexture:texture atIndex:2];
    [computeEncoder dispatchThreadgroups:m_ThreadgroupCount threadsPerThreadgroup:m_ThreadgroupSize];
    [computeEncoder endEncoding];
    
//    __block dispatch_semaphore_t dispatchSemaphore = m_InflightSemaphore;
//    [commandBuffer addCompletedHandler:^(id <MTLCommandBuffer> cmdb) {
//        dispatch_semaphore_signal(dispatchSemaphore);
//    }];
    
//    [MetalDevice commitCommandBufferWaitUntilDone:YES];
}

@end
