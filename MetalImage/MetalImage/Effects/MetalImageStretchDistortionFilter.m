//
//  MetalImageStretchDistortionFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/10/10.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageStretchDistortionFilter.h"
#import "MetalImageFilterExtension.h"
#import "MetalDevice.h"

@interface MetalImageStretchDistortionFilter()

@property (nonatomic, strong) id<MTLBuffer> buffer;
@property (nonatomic, assign) MTLFloat aspectRatio;

@end

@implementation MetalImageStretchDistortionFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_StretchDistortionFilter"]))
    {
        return nil;
    }
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _buffer = [device newBufferWithLength:sizeof(MTLFloat)*5 options:MTLResourceOptionCPUCacheModeDefault];
    
    self.center = MTLFloat2Make(0.5, 0.5);
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setInputRotation:(MetalImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex;
{
    [super setInputRotation:newInputRotation atIndex:textureIndex];
    [self setCenter:self.center];
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
    bufferContents[0] = rotatedPoint.x;
    bufferContents[1] = rotatedPoint.y;
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
