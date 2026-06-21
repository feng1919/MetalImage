//
//  MIThresholdEdgeDetectionFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/20.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MIThresholdEdgeDetectionFilter.h"
#import "MetalDevice.h"

@implementation MIThresholdEdgeDetectionFilter

- (id)initWithFragmentFunctionName:(NSString *)fragmentFunctionName
{
    // Do a luminance pass first to reduce the calculations performed at each fragment in the edge detection phase
    
    if (self = [super initWithFirstStageVertexFunctionName:@"vertex_common"
                            firstStageFragmentFunctionName:@"fragment_luminance"
                             secondStageVertexFunctionName:@"vertex_nearbyTexelSampling"
                           secondStageFragmentFunctionName:fragmentFunctionName]) {
        
        id<MTLDevice> device = [MetalDevice sharedMTLDevice];
        self.vertexSlotBuffer = [device newBufferWithLength:sizeof(MTLFloat2) options:MTLResourceOptionCPUCacheModeDefault];
        self.fragmentSlotBuffer = [device newBufferWithLength:sizeof(MTLFloat)*2 options:MTLResourceOptionCPUCacheModeDefault];
        
        self.threshold = 0.25;
        self.edgeStrength = 1.0;
        
        hasOverriddenImageSizeFactor = NO;
    }
    
    return self;
}


- (id)init
{
    return [self initWithFragmentFunctionName:@"fragment_ThresholdEdgeDetectionFilter"];
}

- (void)setThreshold:(MTLFloat)threshold {
    _threshold = threshold;
    
    MTLFloat *contentBuffer = (MTLFloat *)[self.fragmentSlotBuffer contents];
    contentBuffer[1] = _threshold;
}

@end
