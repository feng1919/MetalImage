//
//  MetalImageTwoPassFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/10/29.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

@interface MetalImageTwoPassFilter : MetalImageFilter {
    
@protected
    MetalImageTexture *secondOutputTexture;
    
    id<MTLFunction> _secondStageVertexFunction;
    id<MTLFunction> _secondStageFragmetnFunction;

    id<MTLBuffer> _secondCoordBuffer;
    id<MTLRenderPipelineState>  _secondStagePipelineState;
    id<MTLDepthStencilState> _secondStageDepthStencilState;
    MTLRenderPassDescriptor *_secondStageRenderPassDescriptor;
}

- (nonnull instancetype)initWithFirstStageFragmentFunctionName:(nonnull NSString *)firstStageFragmentFunctionName
                               secondStageFragmentFunctionName:(nonnull NSString *)secondStageFragmentFunctionName;
- (nonnull instancetype)initWithFirstStageFragmentFunction:(nonnull id<MTLFunction>)firstStageFragmentFunction
                               secondStageFragmentFunction:(nonnull id<MTLFunction>)secondStageFragmentFunction;
- (nonnull instancetype)initWithFirstStageVertexFunctionName:(nonnull NSString *)firstStageVertexFunctionName
                              firstStageFragmentFunctionName:(nonnull NSString *)firstStageFragmentFunctionName
                               secondStageVertexFunctionName:(nonnull NSString *)secondStageVertexFunctionName
                             secondStageFragmentFunctionName:(nonnull NSString *)secondStageFragmentFunctionName;
- (nonnull instancetype)initWithFirstStageVertexFunction:(nonnull id<MTLFunction>)firstStageVertexFunction
                              firstStageFragmentFunction:(nonnull id<MTLFunction>)firstStageFragmentFunction
                               secondStageVertexFunction:(nonnull id<MTLFunction>)secondStageVertexFunction
                             secondStageFragmentFunction:(nonnull id<MTLFunction>)secondStageFragmentFunction;
- (nonnull instancetype)initWithFirstStageVertexShaderFromString:(nonnull NSString *)firstStageVertexShaderString
                              firstStageFragmentShaderFromString:(nonnull NSString *)firstStageFragmentShaderString
                               secondStageVertexShaderFromString:(nonnull NSString *)secondStageVertexShaderString
                             secondStageFragmentShaderFromString:(nonnull NSString *)secondStageFragmentShaderString;

@end
