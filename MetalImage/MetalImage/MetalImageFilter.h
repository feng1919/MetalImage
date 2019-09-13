//
//  MetalImageFilter.h
//  MetalImage
//
//  Created by stonefeng on 2017/2/11.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageOutput.h"
#import "MetalImageRenderResource.h"

NS_ASSUME_NONNULL_BEGIN

@interface MetalImageFilter : MetalImageOutput <MetalImageInput> {
    
@protected
    MetalImageTexture *firstInputTexture;
    MetalImageInputParameter firstInputParameter;
    
    id<MTLFunction> _vertexFunction;
    id<MTLFunction> _fragmentFunction;
    
    id<MTLBuffer> _verticsBuffer;
    id<MTLBuffer> _coordBuffer;
    id<MTLRenderPipelineState>  _pipelineState;
    id<MTLDepthStencilState> _depthStencilState;
    MTLRenderPassDescriptor *_renderPassDescriptor;
    
//    NSMutableArray <MetalImageVertexBuffer *> *vertexBufferArray;
//    NSMutableArray <MetalImageFragmentBuffer *> *fragmentBufferArray;
//    NSMutableArray <MetalImageVertexTexture *> *vertexTextureArray;
//    NSMutableArray <MetalImageFragmentTexture *> *fragmentTextureArray;
    
}

@property (nonatomic,assign) MTLUInt2 outputImageSize;
@property (nonatomic,assign) MTLClearColor bgClearColor;

- (nonnull instancetype)initWithFragmentFunctionName:(nonnull NSString *)fragmentFunctionName;
- (nonnull instancetype)initWithFragmentFunction:(nonnull id<MTLFunction>)fragmentFunction;
- (nonnull instancetype)initWithVertexFunctionName:(nonnull NSString *)vertexFunctionName fragmentFunctionName:(nonnull NSString *)fragmentFunctionName;
- (nonnull instancetype)initWithVertexFunction:(nonnull id<MTLFunction>)vertexFunction fragmentFunction:(nonnull id<MTLFunction>)fragmentFunction;

- (BOOL)prepareRenderPipeline;
- (BOOL)prepareRenderDepthStencilState;
- (BOOL)prepareRenderPassDescriptor;

- (void)updateTextureVertexBuffer:(nonnull id<MTLBuffer>)buffer withNewContents:(nonnull const MTLFloat4 *)newContents size:(size_t)size;
- (void)updateTextureCoordinateBuffer:(nonnull id<MTLBuffer>)buffer withNewContents:(nonnull const MTLFloat2 *)newContents size:(size_t)size;
- (void)renderToTextureWithVertices:(nonnull const MTLFloat4 *)vertices textureCoordinates:(nonnull const MTLFloat2 *)textureCoordinates;

// set up render resources
- (void)setVertexBuffer:(nonnull id <MTLBuffer>)buffer offset:(NSUInteger)offset atIndex:(NSUInteger)index;
- (void)setVertexTexture:(nonnull id <MTLTexture>)texture atIndex:(NSUInteger)index;
- (void)setFragmentBuffer:(nonnull id <MTLBuffer>)buffer offset:(NSUInteger)offset atIndex:(NSUInteger)index;
- (void)setFragmentTexture:(nonnull id <MTLTexture>)texture atIndex:(NSUInteger)index;
- (void)assembleRenderEncoder:(nonnull id<MTLRenderCommandEncoder>)encoder;

@end

NS_ASSUME_NONNULL_END
