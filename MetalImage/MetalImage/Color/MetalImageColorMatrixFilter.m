//
//  MetalImageColorMatrixFilter.m
//  MetalImage
//
//  Created by stonefeng on 2017/3/21.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageColorMatrixFilter.h"
#import "MetalImageContext.h"
#import "MetalDevice.h"

@implementation MetalImageColorMatrixFilter

- (instancetype)init {
    if (self = [super initWithFragmentFunctionName:@"fragment_colorMatrix"]) {
        id<MTLDevice> device = [MetalDevice sharedMTLDevice];
        _buffer = [device newBufferWithLength:sizeof(MTLFloat)*17 options:MTLResourceOptionCPUCacheModeDefault];
        self.intensity = 1.0f;
        
        MTLFloat4x4 colorMatrix;
        colorMatrix.v1 = MTLFloat4Make(1.0f, 0.0f, 0.0f, 0.0f);
        colorMatrix.v2 = MTLFloat4Make(0.0f, 1.0f, 0.0f, 0.0f);
        colorMatrix.v3 = MTLFloat4Make(0.0f, 0.0f, 1.0f, 0.0f);
        colorMatrix.v4 = MTLFloat4Make(0.0f, 0.0f, 0.0f, 1.0f);
        self.colorMatrix = colorMatrix;
        
    }
    return self;
}

- (void)setIntensity:(MTLFloat)intensity {
    _intensity = intensity;
    [self updateBufferContents];
}

- (void)setColorMatrix:(MTLFloat4x4)colorMatrix {
    _colorMatrix = colorMatrix;
    [self updateBufferContents];
}

- (void)updateBufferContents {
    MTLFloat *bufferContents = (MTLFloat *)[_buffer contents];
    bufferContents[0] = _colorMatrix.v1.x;
    bufferContents[1] = _colorMatrix.v1.y;
    bufferContents[2] = _colorMatrix.v1.z;
    bufferContents[3] = _colorMatrix.v1.w;
    
    bufferContents[4] = _colorMatrix.v2.x;
    bufferContents[5] = _colorMatrix.v2.y;
    bufferContents[6] = _colorMatrix.v2.z;
    bufferContents[7] = _colorMatrix.v2.w;
    
    bufferContents[8] = _colorMatrix.v3.x;
    bufferContents[9] = _colorMatrix.v3.y;
    bufferContents[10] = _colorMatrix.v3.z;
    bufferContents[11] = _colorMatrix.v3.w;
    
    bufferContents[12] = _colorMatrix.v4.x;
    bufferContents[13] = _colorMatrix.v4.y;
    bufferContents[14] = _colorMatrix.v4.z;
    bufferContents[15] = _colorMatrix.v4.w;
    
    bufferContents[16] = _intensity;
}

- (void)assembleRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder {
    [renderEncoder setDepthStencilState:_depthStencilState];
    [renderEncoder setRenderPipelineState:_pipelineState];
    [renderEncoder setVertexBuffer:_verticsBuffer offset:0 atIndex:0];
    [renderEncoder setVertexBuffer:_coordBuffer offset:0 atIndex:1];
    [renderEncoder setFragmentTexture:[firstInputTexture texture] atIndex:0];
    [renderEncoder setFragmentBuffer:_buffer offset:0 atIndex:0];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:MetalImageDefaultRenderVetexCount instanceCount:1];
    [renderEncoder endEncoding];
}

@end
