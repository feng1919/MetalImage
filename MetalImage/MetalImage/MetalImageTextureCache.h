//
//  MetalImageTextureCache.h
//  MetalImage
//
//  Created by stonefeng on 2017/2/7.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MetalImageTexture.h"

@interface MetalImageTextureCache : NSObject

// texture management
- (MetalImageTexture *)fetchTextureWithSize:(MTLUInt2)size;

- (void)cacheTexture:(MetalImageTexture *)texture;
- (void)purgeAllUnassignedTextures;

- (void)addFramebufferToActiveImageCaptureList:(MetalImageTexture *)framebuffer;
- (void)removeFramebufferFromActiveImageCaptureList:(MetalImageTexture *)framebuffer;

@end

@interface MTLTextureDescriptor (reuseIdentifier)

- (NSString *)reuseIdentifier;

@end
