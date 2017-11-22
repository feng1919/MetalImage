//
//  MetalImageTransformFilter.m
//  MetalImage
//
//  Created by fengshi on 2017/10/14.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageTransformFilter.h"
#import "MetalDevice.h"

@interface MetalImageTransformFilter()

@property (nonatomic, strong) id<MTLBuffer> buffer;

@end

@implementation MetalImageTransformFilter

#pragma mark -
#pragma mark Initialization and teardown

- (id)init
{
    if (!(self = [super initWithVertexFunctionName:@"vertex_transform" fragmentFunctionName:@"fragment_common"]))
    {
        return nil;
    }
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _buffer = [device newBufferWithLength:sizeof(MTLFloat)*32 options:MTLResourceOptionCPUCacheModeDefault];
    
    self.anchorTopLeft = NO;
    self.ignoreAspectRatio = NO;
//    self.transform3D = CATransform3DIdentity;
    self.affineTransform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0.5, 0.5);
    
    return self;
}

#pragma mark -
#pragma mark GPUImageInput

- (void)setInputTexture:(MetalImageTexture *)newInputTexture atIndex:(NSInteger)textureIndex {
    [super setInputTexture:newInputTexture atIndex:textureIndex];
    [self setIgnoreAspectRatio:_ignoreAspectRatio];
}

//#define A {0.0f, 1.0f}
//#define B {1.0f, 1.0f}
//#define C {0.0f, 0.0f}
//#define D {1.0f, 0.0f}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
{
    MTLUInt2 textureSizeForOutput = [self textureSizeForOutput];
    MTLFloat normalizedHeight = (MTLFloat)textureSizeForOutput.y / (MTLFloat)textureSizeForOutput.x;
    
    static const MTLFloat TextureCoordinate[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
    
    if (_ignoreAspectRatio)
    {
        if (_anchorTopLeft)
        {
            static const MTLFloat squareVerticesAnchorTL[] = {
                0.0f, 0.0f, 0.0f, 1.0f,
                1.0f, 0.0f, 0.0f, 1.0f,
                0.0f, -1.0f, 0.0f, 1.0f,
                -1.0f, -1.0f, 0.0f, 1.0f,
            };
            
            [self renderToTextureWithVertices:(MTLFloat4 *)squareVerticesAnchorTL
                           textureCoordinates:(MTLFloat2 *)TextureCoordinate];
        }
        else
        {
            static const MTLFloat squareVertices[] = {
                -1.0f, 1.0f, 0.0f, 1.0f,
                1.0f,  1.0f, 0.0f, 1.0f,
                -1.0f, -1.0f, 0.0f, 1.0f,
                1.0f, -1.0f, 0.0f, 1.0f,
            };
            
            [self renderToTextureWithVertices:(MTLFloat4 *)squareVertices
                           textureCoordinates:(MTLFloat2 *)TextureCoordinate];
        }
    }
    else
    {
        if (_anchorTopLeft)
        {
            MTLFloat adjustedVerticesAnchorTL[] = {
                0.0f,  normalizedHeight, 0.0f, 1.0f,
                1.0f,  normalizedHeight, 0.0f, 1.0f,
                0.0f, 0.0f, 0.0f, 1.0f,
                1.0f, 0.0f, 0.0f, 1.0f,
            };
            
            [self renderToTextureWithVertices:(MTLFloat4 *)adjustedVerticesAnchorTL
                           textureCoordinates:(MTLFloat2 *)TextureCoordinate];
        }
        else
        {
            MTLFloat adjustedVertices[] = {
                -1.0f,  normalizedHeight, 0.0f, 1.0f,
                1.0f,  normalizedHeight, 0.0f, 1.0f,
                -1.0f, -normalizedHeight, 0.0f, 1.0f,
                1.0f, -normalizedHeight, 0.0f, 1.0f,
            };
            
            [self renderToTextureWithVertices:(MTLFloat4 *)adjustedVertices
                           textureCoordinates:(MTLFloat2 *)TextureCoordinate];
        }
    }
    
    [self notifyTargetsAboutNewTextureAtTime:frameTime];
}

- (void)assembleRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder {
    
    NSParameterAssert(renderEncoder);
    
    [renderEncoder setDepthStencilState:_depthStencilState];
    [renderEncoder setRenderPipelineState:_pipelineState];
    [renderEncoder setVertexBuffer:_verticsBuffer offset:0 atIndex:0];
    [renderEncoder setVertexBuffer:_coordBuffer offset:0 atIndex:1];
    [renderEncoder setVertexBuffer:_buffer offset:0 atIndex:2];
    [renderEncoder setFragmentTexture:[firstInputTexture texture] atIndex:0];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:MetalImageDefaultRenderVetexCount instanceCount:1];
    [renderEncoder endEncoding];
}

#pragma mark -
#pragma mark Accessors

- (void)setAffineTransform:(CGAffineTransform)newValue;
{
    self.transform3D = CATransform3DMakeAffineTransform(newValue);
}

- (CGAffineTransform)affineTransform;
{
    return CATransform3DGetAffineTransform(self.transform3D);
}

- (void)setTransform3D:(CATransform3D)newValue;
{
    _transform3D = newValue;
    [self updateContentBuffer];
}

- (void)setIgnoreAspectRatio:(BOOL)newValue;
{
    _ignoreAspectRatio = newValue;
    [self updateContentBuffer];
}

- (void)setAnchorTopLeft:(BOOL)newValue
{
    _anchorTopLeft = newValue;
    [self updateContentBuffer];
}

- (void)updateContentBuffer {
    
    MTLFloat4x4 temporaryMatrix;
    
    [self convert3DTransform:&_transform3D toMatrix:&temporaryMatrix];
    
    MTLFloat *bufferContents = (MTLFloat *)[_buffer contents];
    bufferContents[0] = temporaryMatrix.v1.x;
    bufferContents[1] = temporaryMatrix.v1.y;
    bufferContents[2] = temporaryMatrix.v1.z;
    bufferContents[3] = temporaryMatrix.v1.w;
    
    bufferContents[4] = temporaryMatrix.v2.x;
    bufferContents[5] = temporaryMatrix.v2.y;
    bufferContents[6] = temporaryMatrix.v2.z;
    bufferContents[7] = temporaryMatrix.v2.w;
    
    bufferContents[8] = temporaryMatrix.v3.x;
    bufferContents[9] = temporaryMatrix.v3.y;
    bufferContents[10] = temporaryMatrix.v3.z;
    bufferContents[11] = temporaryMatrix.v3.w;
    
    bufferContents[12] = temporaryMatrix.v4.x;
    bufferContents[13] = temporaryMatrix.v4.y;
    bufferContents[14] = temporaryMatrix.v4.z;
    bufferContents[15] = temporaryMatrix.v4.w;
    
    MTLUInt2 outputSize = [self textureSizeForOutput];
    MTLFloat width = (MTLFloat)outputSize.x;
    MTLFloat height = (MTLFloat)outputSize.y;
    MTLFloat ratio = (!_ignoreAspectRatio && width > 0.0f && height > 0.0f)?height / width:1.0;
    
    [self loadOrthoMatrix:(MTLFloat *)&temporaryMatrix
                     left:-1.0 right:1.0
                   bottom:(-1.0 * ratio) top:(1.0 * ratio)
                     near:-1.0 far:1.0];
    
    bufferContents[16] = temporaryMatrix.v1.x;
    bufferContents[17] = temporaryMatrix.v1.y;
    bufferContents[18] = temporaryMatrix.v1.z;
    bufferContents[19] = temporaryMatrix.v1.w;
    
    bufferContents[20] = temporaryMatrix.v2.x;
    bufferContents[21] = temporaryMatrix.v2.y;
    bufferContents[22] = temporaryMatrix.v2.z;
    bufferContents[23] = temporaryMatrix.v2.w;
    
    bufferContents[24] = temporaryMatrix.v3.x;
    bufferContents[25] = temporaryMatrix.v3.y;
    bufferContents[26] = temporaryMatrix.v3.z;
    bufferContents[27] = temporaryMatrix.v3.w;
    
    bufferContents[28] = temporaryMatrix.v4.x;
    bufferContents[29] = temporaryMatrix.v4.y;
    bufferContents[30] = temporaryMatrix.v4.z;
    bufferContents[31] = temporaryMatrix.v4.w;
}

#pragma mark -
#pragma mark Conversion from matrix formats

- (void)loadOrthoMatrix:(MTLFloat *)matrix left:(MTLFloat)left right:(MTLFloat)right bottom:(MTLFloat)bottom top:(MTLFloat)top near:(MTLFloat)near far:(MTLFloat)far;
{
    MTLFloat r_l = right - left;
    MTLFloat t_b = top - bottom;
    MTLFloat f_n = far - near;
    MTLFloat tx = - (right + left) / r_l;
    MTLFloat ty = - (top + bottom) / t_b;
    MTLFloat tz = - (far + near) / f_n;
    
    MTLFloat scale = 2.0f;
    if (_anchorTopLeft)
    {
        scale = 4.0f;
        tx=-1.0f;
        ty=-1.0f;
    }
    
    matrix[0] = scale / r_l;
    matrix[1] = 0.0f;
    matrix[2] = 0.0f;
    matrix[3] = tx;
    
    matrix[4] = 0.0f;
    matrix[5] = scale / t_b;
    matrix[6] = 0.0f;
    matrix[7] = ty;
    
    matrix[8] = 0.0f;
    matrix[9] = 0.0f;
    matrix[10] = scale / f_n;
    matrix[11] = tz;
    
    matrix[12] = 0.0f;
    matrix[13] = 0.0f;
    matrix[14] = 0.0f;
    matrix[15] = 1.0f;
}

- (void)convert3DTransform:(CATransform3D *)transform3D toMatrix:(MTLFloat4x4 *)matrix;
{
    //    struct CATransform3D
    //    {
    //        CGFloat m11, m12, m13, m14;
    //        CGFloat m21, m22, m23, m24;
    //        CGFloat m31, m32, m33, m34;
    //        CGFloat m41, m42, m43, m44;
    //    };
    
    MTLFloat *mappedMatrix = (MTLFloat *)matrix;
    mappedMatrix[0] = (MTLFloat)transform3D->m11;
    mappedMatrix[1] = (MTLFloat)transform3D->m12;
    mappedMatrix[2] = (MTLFloat)transform3D->m13;
    mappedMatrix[3] = (MTLFloat)transform3D->m14;
    mappedMatrix[4] = (MTLFloat)transform3D->m21;
    mappedMatrix[5] = (MTLFloat)transform3D->m22;
    mappedMatrix[6] = (MTLFloat)transform3D->m23;
    mappedMatrix[7] = (MTLFloat)transform3D->m24;
    mappedMatrix[8] = (MTLFloat)transform3D->m31;
    mappedMatrix[9] = (MTLFloat)transform3D->m32;
    mappedMatrix[10] = (MTLFloat)transform3D->m33;
    mappedMatrix[11] = (MTLFloat)transform3D->m34;
    mappedMatrix[12] = (MTLFloat)transform3D->m41;
    mappedMatrix[13] = (MTLFloat)transform3D->m42;
    mappedMatrix[14] = (MTLFloat)transform3D->m43;
    mappedMatrix[15] = (MTLFloat)transform3D->m44;
}

@end
