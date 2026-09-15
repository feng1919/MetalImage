//
//  MIMosaicFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/13.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MIMosaicFilter.h"
#import "MetalImageFilterExtension.h"
#import "MetalImagePicture.h"
#import "MetalDevice.h"

@interface MIMosaicFilter()

@property (nonatomic, strong) id<MTLBuffer> buffer;
@property (nonatomic, strong) MetalImageTexture *tileTexture;

@end

@implementation MIMosaicFilter

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
    // The tile set is static, so upload it once through a short-lived
    // picture instead of keeping one alive for the filter's lifetime.
    // The previous design held the picture strongly while the picture's
    // target list held this filter strongly: that cycle prevented BOTH
    // objects from ever deallocating (dealloc -> removeAllTargets never
    // ran), leaking the picture and its textures on the normal release
    // path. Here the picture is only retained by its dispatch block until
    // the tile texture has been delivered to texture index 1, and no
    // reference survives this method.
    MetalImagePicture *picture = [[MetalImagePicture alloc] initWithImage:tileSetImage smoothlyScaleOutput:YES removePremultiplication:NO];
    [picture addTarget:self atTextureLocation:1];
    [picture processImage];

    // The tile texture arrives once; the per-frame second-input check would
    // stall rendering after the first frame (two-input filters reset
    // hasReceivedFrame after every render).
    [self disableSecondFrameCheck];
}

- (void)setInputTexture:(MetalImageTexture *)newInputTexture atIndex:(NSInteger)textureIndex {
    if (textureIndex == 1) {
        // Keep the static tile texture out of the recycle pool: every render
        // unlocks the two-input textures, and a pooled tile texture could be
        // reused (and overwritten) by an unrelated same-size allocation.
        _tileTexture = newInputTexture;
        [_tileTexture disableReferenceCounting];
    }
    [super setInputTexture:newInputTexture atIndex:textureIndex];
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
    [renderEncoder setFragmentTexture:[_tileTexture texture] atIndex:1];
    [renderEncoder setFragmentBuffer:_buffer offset:0 atIndex:0];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:MetalImageDefaultRenderVetexCount instanceCount:1];
    [renderEncoder endEncoding];
}

@end
