//
//  MetalImageJFAVoronoiFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/12.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageJFAVoronoiFilter.h"
#import "MetalDevice.h"

@interface MetalImageJFAVoronoiFilter()

@property (nonatomic, strong) id<MTLBuffer> vertexBuffer;
@property (nonatomic, strong) id<MTLBuffer> fragmentBuffer;
@property (nonatomic, assign) MTLFloat sampleStep;

@end

@implementation MetalImageJFAVoronoiFilter

- (id)init
{
    if (!(self = [super initWithVertexFunctionName:@"vertex_JFAVoronoiFilter"
                              fragmentFunctionName:@"fragment_JFAVoronoiFilter"]))
    {
        return nil;
    }
    
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _vertexBuffer = [device newBufferWithLength:sizeof(MTLFloat)*1 options:MTLResourceOptionCPUCacheModeDefault];
    _fragmentBuffer = [device newBufferWithLength:sizeof(MTLFloat)*2 options:MTLResourceOptionCPUCacheModeDefault];
    
    self.sizeInPixels = MTLUInt2Make(512, 512);
    self.sampleStep = 0.5;
    
    return self;
}

- (void)setSampleStep:(MTLFloat)sampleStep {
    _sampleStep = sampleStep;
    
    MTLFloat *bufferContents = (MTLFloat *)[_vertexBuffer contents];
    bufferContents[0] = _sampleStep;
}

-(void)setSizeInPixels:(MTLUInt2)sizeInPixels {
    _sizeInPixels = sizeInPixels;
    
    //validate that it's a power of 2
    
    float width = log2(sizeInPixels.x);
    float height = log2(sizeInPixels.y);
    
    if (width != height) {
        NSLog(@"Voronoi point texture must be square");
        return;
    }
    
    if (width != floor(width) || height != floor(height)) {
        NSLog(@"Voronoi point texture must be a power of 2.  Texture size: %d, %d", sizeInPixels.x, sizeInPixels.y);
        return;
    }
    
    MTLFloat *bufferContents = (MTLFloat *)[_fragmentBuffer contents];
    bufferContents[0] = (MTLFloat)_sizeInPixels.x;
    bufferContents[1] = (MTLFloat)_sizeInPixels.y;
}

- (void)assembleRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder {
    NSParameterAssert(renderEncoder);
    
    [renderEncoder setDepthStencilState:_depthStencilState];
    [renderEncoder setRenderPipelineState:_pipelineState];
    [renderEncoder setVertexBuffer:_verticsBuffer offset:0 atIndex:0];
    [renderEncoder setVertexBuffer:_coordBuffer offset:0 atIndex:1];
    [renderEncoder setVertexBuffer:_vertexBuffer offset:0 atIndex:2];
    [renderEncoder setFragmentTexture:[firstInputTexture texture] atIndex:0];
    [renderEncoder setFragmentBuffer:_fragmentBuffer offset:0 atIndex:0];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:MetalImageDefaultRenderVetexCount instanceCount:1];
    [renderEncoder endEncoding];
}


@end
