//
//  MIVoronoiConsumerFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/12.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MIVoronoiConsumerFilter.h"
#import "MetalDevice.h"

@interface MIVoronoiConsumerFilter()

@property (nonatomic, strong) id<MTLBuffer> fragmentBuffer;

@end

@implementation MIVoronoiConsumerFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_VoronoiConsumerFilter"]))
    {
        return nil;
    }
    
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _fragmentBuffer = [device newBufferWithLength:sizeof(MTLFloat)*2 options:MTLResourceOptionCPUCacheModeDefault];
    
    self.sizeInPixels = MTLUInt2Make(512, 512);
    
    return self;
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
    [renderEncoder setFragmentTexture:[firstInputTexture texture] atIndex:0];
    [renderEncoder setFragmentTexture:[secondInputTexture texture] atIndex:1];
    [renderEncoder setFragmentBuffer:_fragmentBuffer offset:0 atIndex:0];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:MetalImageDefaultRenderVetexCount instanceCount:1];
    [renderEncoder endEncoding];
}

@end
