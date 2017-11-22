//
//  MetalImagePinchDistortionFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/10/10.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImagePinchDistortionFilter.h"
#import "MetalImageFilterExtension.h"
#import "MetalDevice.h"

@interface MetalImagePinchDistortionFilter()

@property (nonatomic, strong) id<MTLBuffer> buffer;
@property (nonatomic, assign) MTLFloat aspectRatio;

@end

@implementation MetalImagePinchDistortionFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_PinchDistortionFilter"]))
    {
        return nil;
    }
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _buffer = [device newBufferWithLength:sizeof(MTLFloat)*5 options:MTLResourceOptionCPUCacheModeDefault];
    
    self.radius = 1.0;
    self.scale = 0.5;
    self.center = MTLFloat2Make(0.5, 0.5);
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)adjustAspectRatio
{
    MTLFloat inputTextureWidth = (MTLFloat)firstInputTexture.size.x;
    MTLFloat inputTextureHeight = (MTLFloat)firstInputTexture.size.y;
    
    if (MetalImageRotationSwapsWidthAndHeight(firstInputParameter.rotationMode))
    {
        [self setAspectRatio:(inputTextureWidth / inputTextureHeight)];
    }
    else
    {
        [self setAspectRatio:(inputTextureHeight / inputTextureWidth)];
    }
}

- (void)setInputRotation:(MetalImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex;
{
    [super setInputRotation:newInputRotation atIndex:textureIndex];
    [self setCenter:self.center];
    [self adjustAspectRatio];
}

- (void)setAspectRatio:(MTLFloat)newValue;
{
    _aspectRatio = newValue;
    
    MTLFloat *bufferContents = (MTLFloat *)[_buffer contents];
    bufferContents[4] = _aspectRatio;
}

- (void)setRadius:(MTLFloat)radius {
    _radius = radius;
    [self updateContentBuffer];
}

- (void)setScale:(MTLFloat)scale {
    _scale = scale;
    [self updateContentBuffer];
}

- (void)setCenter:(MTLFloat2)center {
    _center = center;
    [self updateContentBuffer];
}

- (void)updateContentBuffer
{
    MTLFloat2 rotatedPoint = [self rotatedPoint:_center forRotation:firstInputParameter.rotationMode];
    
    MTLFloat *bufferContents = (MTLFloat *)[_buffer contents];
    bufferContents[0] = rotatedPoint.x;
    bufferContents[1] = rotatedPoint.y;
    bufferContents[2] = _radius;
    bufferContents[3] = _scale;
    bufferContents[4] = _aspectRatio;
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
