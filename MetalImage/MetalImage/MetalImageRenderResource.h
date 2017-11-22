//
//  MetalImageRenderResource.h
//  MetalImage
//
//  Created by Feng Stone on 2017/10/21.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

@interface MetalImageRenderBuffer : NSObject

@property (nonatomic,strong) id<MTLBuffer> buffer;
@property (nonatomic,assign) NSUInteger offset;
@property (nonatomic,assign) NSUInteger index;

@end

@interface MetalImageVertexBuffer : MetalImageRenderBuffer
@end

@interface MetalImageFragmentBuffer : MetalImageRenderBuffer
@end

@interface MetalImageRenderTexture : NSObject

@property (nonatomic,strong) id<MTLTexture> texture;
@property (nonatomic,assign) NSUInteger index;

@end

@interface MetalImageVertexTexture : MetalImageRenderTexture
@end

@interface MetalImageFragmentTexture : MetalImageRenderTexture
@end
