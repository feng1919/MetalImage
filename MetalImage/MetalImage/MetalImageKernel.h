//
//  MetalImageKernel.h
//  MetalImage
//
//  Created by stonefeng on 2017/3/14.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageOutput.h"

@interface MetalImageKernel : MetalImageOutput <MetalImageInput> {
    
@protected
    MetalImageTexture *firstInputTexture;
    MetalImageInputParameter firstInputParameter;
    
    dispatch_semaphore_t  m_InflightSemaphore;
    id <MTLFunction> k_fuction;
    id <MTLComputePipelineState> k_computePipelineState;
}

@property (nonatomic,readonly) NSString *functionName;

- (instancetype)initWithFunctionName:(NSString *)fuctionName;
- (instancetype)initWithFunction:(id<MTLFunction>)function;

- (void)computeTexture;
- (void)assembleComputeEncoder:(id<MTLComputeCommandEncoder>)computeEncoder;

@end
