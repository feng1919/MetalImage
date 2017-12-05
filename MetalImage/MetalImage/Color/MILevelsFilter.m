//
//  MILevelsFilter.m
//  MetalImage
//
//  Created by stonefeng on 2017/3/20.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MILevelsFilter.h"
#import "MetalDevice.h"

@interface MILevelsFilter ()

@property (nonatomic,strong) id<MTLBuffer> buffer;

@end

@implementation MILevelsFilter

- (instancetype)init {
    if (self = [super initWithFragmentFunctionName:@"fragment_levels"]) {
        id<MTLDevice> device = [MetalDevice sharedMTLDevice];
        _buffer = [device newBufferWithLength:sizeof(MTLFloat3)*5 options:MTLResourceOptionCPUCacheModeDefault];
        
        self.minVector = MTLFloat3Make(0.0f, 0.0f, 0.0f);
        self.midVector = MTLFloat3Make(1.0f, 1.0f, 1.0f);
        self.maxVector = MTLFloat3Make(1.0f, 1.0f, 1.0f);
        self.minOutputVector = MTLFloat3Make(0.0f, 0.0f, 0.0f);
        self.maxOutputVector = MTLFloat3Make(1.0f, 1.0f, 1.0f);
        
        [self updateVectorBuffer];
    }
    return self;
}

- (void)updateVectorBuffer {
    MTLFloat *contents = (MTLFloat *)[_buffer contents];
    contents[0] = _minVector.x;
    contents[1] = _minVector.y;
    contents[2] = _minVector.z;
    
    contents[3] = _midVector.x;
    contents[4] = _midVector.y;
    contents[5] = _midVector.z;
    
    contents[6] = _maxVector.x;
    contents[7] = _maxVector.y;
    contents[8] = _maxVector.z;
    
    contents[9] = _minOutputVector.x;
    contents[10] = _minOutputVector.y;
    contents[11] = _minOutputVector.z;
    
    contents[12] = _maxOutputVector.x;
    contents[13] = _maxOutputVector.y;
    contents[14] = _maxOutputVector.z;
}

- (void)assembleRenderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder {
    [renderEncoder setDepthStencilState:_depthStencilState];
    [renderEncoder setRenderPipelineState:_pipelineState];
    [renderEncoder setVertexBuffer:_verticsBuffer offset:0 atIndex:0];
    [renderEncoder setVertexBuffer:_coordBuffer offset:0 atIndex:1];
    [renderEncoder setFragmentTexture:[firstInputTexture texture] atIndex:0];
    [renderEncoder setFragmentBuffer:_buffer offset:0 atIndex:0];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:MetalImageDefaultRenderVetexCount instanceCount:1];
    [renderEncoder endEncoding];
}

#pragma mark - Accessors
- (void)setMin:(MTLFloat)min gamma:(MTLFloat)mid max:(MTLFloat)max {
    [self setMin:min gamma:mid max:max minOut:0.0 maxOut:1.0];
}
- (void)setMin:(MTLFloat)min gamma:(MTLFloat)mid max:(MTLFloat)max minOut:(MTLFloat)minOut maxOut:(MTLFloat)maxOut {
    [self setRedMin:min gamma:mid max:max minOut:minOut maxOut:maxOut];
    [self setGreenMin:min gamma:mid max:max minOut:minOut maxOut:maxOut];
    [self setBlueMin:min gamma:mid max:max minOut:minOut maxOut:maxOut];
}

- (void)setRedMin:(MTLFloat)min gamma:(MTLFloat)mid max:(MTLFloat)max {
    [self setRedMin:min gamma:mid max:max minOut:0.0 maxOut:1.0];
}
- (void)setRedMin:(MTLFloat)min gamma:(MTLFloat)mid max:(MTLFloat)max minOut:(MTLFloat)minOut maxOut:(MTLFloat)maxOut {
    _minVector.x = min;
    _midVector.x = mid;
    _maxVector.x = max;
    _minOutputVector.x = minOut;
    _maxOutputVector.x = maxOut;
    
    [self updateVectorBuffer];
}

- (void)setGreenMin:(MTLFloat)min gamma:(MTLFloat)mid max:(MTLFloat)max {
    [self setGreenMin:min gamma:mid max:max minOut:0.0 maxOut:1.0];
}
- (void)setGreenMin:(MTLFloat)min gamma:(MTLFloat)mid max:(MTLFloat)max minOut:(MTLFloat)minOut maxOut:(MTLFloat)maxOut {
    _minVector.y = min;
    _midVector.y = mid;
    _maxVector.y = max;
    _minOutputVector.y = minOut;
    _maxOutputVector.y = maxOut;
    
    [self updateVectorBuffer];
}

- (void)setBlueMin:(MTLFloat)min gamma:(MTLFloat)mid max:(MTLFloat)max {
    [self setBlueMin:min gamma:mid max:max minOut:0.0 maxOut:1.0];
}
- (void)setBlueMin:(MTLFloat)min gamma:(MTLFloat)mid max:(MTLFloat)max minOut:(MTLFloat)minOut maxOut:(MTLFloat)maxOut {
    _minVector.z = min;
    _midVector.z = mid;
    _maxVector.z = max;
    _minOutputVector.z = minOut;
    _maxOutputVector.z = maxOut;
    
    [self updateVectorBuffer];
}

@end
