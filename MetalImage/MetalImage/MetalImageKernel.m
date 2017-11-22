//
//  MetalImageKernel.m
//  MetalImage
//
//  Created by stonefeng on 2017/3/14.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageKernel.h"
#import "MetalImageFunction.h"
#import "MetalDevice.h"

@implementation MetalImageKernel

- (instancetype)init {
    return [self initWithFunctionName:@"kernel_default"];
}

- (instancetype)initWithFunctionName:(NSString *)fuctionName {
    _functionName = fuctionName;
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    id<MTLLibrary> defaultLibrary = [device newDefaultLibrary];
    id<MTLFunction> function = [defaultLibrary newFunctionWithName:fuctionName];
    return [self initWithFunction:function];
}

- (instancetype)initWithFunction:(id<MTLFunction>)function {
    if (self = [super init]) {
        
        id<MTLDevice> device = [MetalDevice sharedMTLDevice];
        
        NSError *error = nil;
        k_fuction = function;
        k_computePipelineState = [device newComputePipelineStateWithFunction:k_fuction error:&error];
        if (error) {
            NSLog(@"[%@] pipeline state init ERR: %@", _functionName, error);
        }
        
        m_InflightSemaphore = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)computeTexture {
    
    id <MTLCommandBuffer> commandBuffer = [MetalDevice sharedCommandBuffer];
    id <MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];
    [self assembleComputeEncoder:computeEncoder];
    
    [firstInputTexture unlock];
}

#pragma mark - MetalImageInput delegate

- (void)setInputTexture:(MetalImageTexture *)newInputFramebuffer atIndex:(NSInteger)textureIndex {
    firstInputTexture = newInputFramebuffer;
    [firstInputTexture lock];
}

- (void)setInputRotation:(MetalImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex {
    firstInputParameter.rotationMode = newInputRotation;
}

- (void)newTextureReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    [self computeTexture];
    [self notifyTargetsAboutNewTextureAtTime:frameTime];
}

- (void)assembleComputeEncoder:(id<MTLComputeCommandEncoder>)computeEncoder {
    
    MTLUInt res_w = firstInputTexture.size.x;
    MTLUInt res_h = firstInputTexture.size.y;
    MTLFloat computeWidth = 16.0f;
    MTLSize k_ThreadgroupSize = MTLSizeMake(computeWidth, computeWidth, 1);
    MTLSize k_ThreadgroupCount = MTLSizeMake(ceilf(res_w/computeWidth), ceilf(res_h/computeWidth), 1);
    
    outputTexture = [[MetalImageContext sharedTextureCache] fetchTextureWithSize:firstInputTexture.size];
    
    [computeEncoder setComputePipelineState:k_computePipelineState];
    [computeEncoder setTexture:[firstInputTexture texture] atIndex:0];
    [computeEncoder setTexture:[outputTexture texture] atIndex:1];
    [computeEncoder dispatchThreadgroups:k_ThreadgroupCount threadsPerThreadgroup:k_ThreadgroupSize];
    [computeEncoder endEncoding];
}

@end
