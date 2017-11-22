//
//  MetalImageDebugView.m
//  MetalImage
//
//  Created by stonefeng on 2017/3/8.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageDebugView.h"
#import "UIImage+Texture.h"
#import "MetalImageFunction.h"

@implementation MetalImageDebugView


#pragma mark - MetalImageInput Protocol

- (void)setInputRotation:(MetalImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex {
    if (inputRotationMode != newInputRotation) {
        inputRotationMode = newInputRotation;
//        [self updateTextureCoordinates];
        
        NSLog(@"update rotaion mode:%ld", newInputRotation);
    }
}

- (void)setInputTexture:(MetalImageTexture *)newInputTexture atIndex:(NSInteger)textureIndex {
    firstInputTexture = newInputTexture;
    [firstInputTexture lock];
}

- (void)newTextureReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    
    runMetalOnMainQueueWithoutDeadlocking(^{
        self.image = [UIImage imageWithMTLTexture:[firstInputTexture texture] orientation:UIImageOrientationUp];
    });
    
    [firstInputTexture unlock];
}

@end
