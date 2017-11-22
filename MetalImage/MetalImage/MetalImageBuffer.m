//
//  MetalImageBuffer.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/20.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageBuffer.h"

@implementation MetalImageBuffer

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    bufferedFramebuffers = [[NSMutableArray alloc] init];
    //    [bufferedTextures addObject:[NSNumber numberWithInt:outputTexture]];
    _bufferSize = 1;
    
    return self;
}

- (void)dealloc
{
    for (MetalImageTexture *currentFramebuffer in bufferedFramebuffers)
    {
        [currentFramebuffer unlock];
    }
}

#pragma mark -
#pragma mark MetalImageInput

- (void)newTextureReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {

    if ([bufferedFramebuffers count] >= _bufferSize)
    {
        outputTexture = [bufferedFramebuffers objectAtIndex:0];
        [bufferedFramebuffers removeObjectAtIndex:0];
    }
    else
    {
        // Nothing yet in the buffer, so don't process further until the buffer is full
        outputTexture = firstInputTexture;
        [firstInputTexture lock];
    }
    
    [bufferedFramebuffers addObject:firstInputTexture];
    
    // Let the downstream video elements see the previous frame from the buffer before rendering a new one into place
    [self notifyTargetsAboutNewTextureAtTime:frameTime];
}

- (void)renderToTextureWithVertices:(const MTLFloat4 *)vertices textureCoordinates:(const MTLFloat2 *)textureCoordinates {
    // No need to render to another texture anymore, since we'll be hanging on to the textures in our buffer
}

#pragma mark -
#pragma mark Accessors

- (void)setBufferSize:(NSUInteger)newValue;
{
    if ( (newValue == _bufferSize) || (newValue < 1) )
    {
        return;
    }
    
    if (newValue > _bufferSize)
    {
        NSUInteger texturesToAdd = newValue - _bufferSize;
        for (NSUInteger currentTextureIndex = 0; currentTextureIndex < texturesToAdd; currentTextureIndex++)
        {
            // TODO: Deal with the growth of the size of the buffer by rotating framebuffers, no textures
        }
    }
    else
    {
        NSUInteger texturesToRemove = _bufferSize - newValue;
        for (NSUInteger currentTextureIndex = 0; currentTextureIndex < texturesToRemove; currentTextureIndex++)
        {
            MetalImageTexture *lastFramebuffer = [bufferedFramebuffers lastObject];
            [bufferedFramebuffers removeObjectAtIndex:([bufferedFramebuffers count] - 1)];
            
            [lastFramebuffer unlock];
            lastFramebuffer = nil;
        }
    }
    
    _bufferSize = newValue;
}

@end
