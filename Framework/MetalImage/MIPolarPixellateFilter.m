//
//  MIPolarPixellateFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/9/9.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MIPolarPixellateFilter.h"
#import "MetalImageFilterExtension.h"
#import "MetalDevice.h"

@interface MIPolarPixellateFilter()

@property (nonatomic, strong) id<MTLBuffer> buffer;

@end

@implementation MIPolarPixellateFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_polarPixellate"]))
    {
        return nil;
    }
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _buffer = [device newBufferWithLength:sizeof(MTLFloat)*4 options:MTLResourceOptionCPUCacheModeDefault];
    
    self.pixelSize = MTLFloat2Make(0.05, 0.05);
    self.center = MTLFloat2Make(0.5, 0.5);
    
    return self;
}

- (void)setInputRotation:(MetalImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex {
    [super setInputRotation:newInputRotation atIndex:textureIndex];
    [self setCenter:_center];
}

#pragma mark -
#pragma mark Accessors

- (void)setPixelSize:(MTLFloat2)pixelSize
{
    _pixelSize = pixelSize;
    [self updateContentBuffer];
}

- (void)setCenter:(MTLFloat2)newValue;
{
    _center = newValue;
    [self updateContentBuffer];
}

- (void)updateContentBuffer
{
    MTLFloat2 rotatedPoint = [self rotatedPoint:_center forRotation:firstInputParameter.rotationMode];
    
    MTLFloat *bufferContents = (MTLFloat *)[_buffer contents];
    bufferContents[0] = _pixelSize.x;
    bufferContents[1] = _pixelSize.y;
    bufferContents[2] = rotatedPoint.x;
    bufferContents[3] = rotatedPoint.y;
}

- (void)assembleRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder {
    NSParameterAssert(renderEncoder);
    
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
