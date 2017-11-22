//
//  MetalImageMaskFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageMaskFilter.h"
#import "MetalDevice.h"

@implementation MetalImageMaskFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_maskFilter"]))
    {
        return nil;
    }
    
    return self;
}

- (BOOL)prepareRenderPipeline {
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    
    MTLRenderPipelineDescriptor *pQuadPipelineStateDescriptor = [MTLRenderPipelineDescriptor new];
    pQuadPipelineStateDescriptor.depthAttachmentPixelFormat      = MTLPixelFormatInvalid;
    pQuadPipelineStateDescriptor.stencilAttachmentPixelFormat    = MTLPixelFormatInvalid;
    //    pQuadPipelineStateDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pQuadPipelineStateDescriptor.sampleCount                     = 1;
    pQuadPipelineStateDescriptor.vertexFunction                  = _vertexFunction;
    pQuadPipelineStateDescriptor.fragmentFunction                = _fragmentFunction;
    
    MTLRenderPipelineColorAttachmentDescriptor *pipelineColorAttachment = [[MTLRenderPipelineColorAttachmentDescriptor alloc] init];
    [pipelineColorAttachment setBlendingEnabled:YES];
    [pipelineColorAttachment setSourceRGBBlendFactor:MTLBlendFactorSourceAlpha];
    [pipelineColorAttachment setDestinationRGBBlendFactor:MTLBlendFactorOneMinusSourceAlpha];
    [pipelineColorAttachment setRgbBlendOperation:MTLBlendOperationAdd];
    [pipelineColorAttachment setPixelFormat:MTLPixelFormatBGRA8Unorm];
    [[pQuadPipelineStateDescriptor colorAttachments] setObject:pipelineColorAttachment atIndexedSubscript:0];
    
    NSError *pError = nil;
    _pipelineState = [device newRenderPipelineStateWithDescriptor:pQuadPipelineStateDescriptor error:&pError];
    if (pError) {
        NSLog(@">> ERROR: Failed acquiring pipeline state descriptor: %@", pError);
    }
    
    return _pipelineState != nil;
}



@end
