//
//  MetalImageMosaicFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/13.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageMosaicFilter.h"
#import "MetalImageFilterExtension.h"
#import "MetalImagePicture.h"
#import "MetalDevice.h"

@interface MetalImageMosaicFilter()

@property (nonatomic, strong) id<MTLBuffer> buffer;
@property (nonatomic ,strong) MetalImagePicture *pic;

@end

@implementation MetalImageMosaicFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_MosaicFilter"]))
    {
        return nil;
    }
    
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    _buffer = [device newBufferWithLength:sizeof(MTLFloat)*6 options:MTLResourceOptionCPUCacheModeDefault];
    
    self.displayTileSize = MTLFloat2Make(0.025, 0.025);
    self.inputTileSize = MTLFloat2Make(0.125, 0.125);
    self.numTiles = 64.0f;
    self.colorOn = YES;
    
    return self;
}


- (void)setTileSetImage:(UIImage *)tileSetImage {
    self.pic = [[MetalImagePicture alloc] initWithImage:tileSetImage smoothlyScaleOutput:YES removePremultiplication:NO];
    [self.pic addTarget:self atTextureLocation:1];
}

- (void)setInputTileSize:(MTLFloat2)inputTileSize {
    
    _inputTileSize = inputTileSize;
    
    if (inputTileSize.x > 1.0) {
        _inputTileSize.x = 1.0;
    }
    if (inputTileSize.y > 1.0) {
        _inputTileSize.y = 1.0;
    }
    if (inputTileSize.x < 0.0) {
        _inputTileSize.x = 0.0;
    }
    if (inputTileSize.y < 0.0) {
        _inputTileSize.y = 0.0;
    }
    
    [self updateContentBuffer];
}

- (void)setDisplayTileSize:(MTLFloat2)displayTileSize {
    
    _displayTileSize = displayTileSize;
    
    if (displayTileSize.x > 1.0) {
        _displayTileSize.x = 1.0;
    }
    if (displayTileSize.y > 1.0) {
        _displayTileSize.y = 1.0;
    }
    if (displayTileSize.x < 0.0) {
        _displayTileSize.x = 0.0;
    }
    if (displayTileSize.y < 0.0) {
        _displayTileSize.y = 0.0;
    }
    
    [self updateContentBuffer];
}

- (void)setNumTiles:(float)numTiles {
    _numTiles = numTiles;
    [self updateContentBuffer];
}

- (void)setColorOn:(BOOL)colorOn {
    _colorOn = colorOn;
    [self updateContentBuffer];
}

- (void)updateContentBuffer
{
    MTLFloat *bufferContents = (MTLFloat *)[_buffer contents];
    bufferContents[0] = _inputTileSize.x;
    bufferContents[1] = _inputTileSize.y;
    bufferContents[2] = _displayTileSize.x;
    bufferContents[3] = _displayTileSize.y;
    bufferContents[4] = _numTiles;
    bufferContents[5] = _colorOn?1.0:0.0;
}

- (void)assembleRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder {
    NSParameterAssert(renderEncoder);
    
    [renderEncoder setDepthStencilState:_depthStencilState];
    [renderEncoder setRenderPipelineState:_pipelineState];
    [renderEncoder setVertexBuffer:_verticsBuffer offset:0 atIndex:0];
    [renderEncoder setVertexBuffer:_coordBuffer offset:0 atIndex:1];
    [renderEncoder setVertexBuffer:_coordBuffer2 offset:0 atIndex:2];
    [renderEncoder setFragmentTexture:[firstInputTexture texture] atIndex:0];
    [renderEncoder setFragmentTexture:[secondInputTexture texture] atIndex:1];
    [renderEncoder setFragmentBuffer:_buffer offset:0 atIndex:0];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:MetalImageDefaultRenderVetexCount instanceCount:1];
    [renderEncoder endEncoding];
}

- (void)newTextureReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    
    [super newTextureReadyAtTime:frameTime atIndex:textureIndex];
    
    if (textureIndex == 0) {
        [self.pic notifyTargetsAboutNewTextureAtTime:frameTime];
    }
}

@end
