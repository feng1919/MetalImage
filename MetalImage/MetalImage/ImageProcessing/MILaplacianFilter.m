//
//  MILaplacianFilter.m
//  MetalImage
//
//  Created by Feng Stone on 2017/10/18.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MILaplacianFilter.h"
#import "MetalDevice.h"

@implementation MILaplacianFilter

- (id)init
{
    if (!(self = [super initWithFragmentFunctionName:@"fragment_LaplacianFilter"]))
    {
        return nil;
    }
    
    id<MTLDevice> device = [MetalDevice sharedMTLDevice];
    self.buffer = [device newBufferWithLength:sizeof(MTLFloat)*9 options:MTLResourceOptionCPUCacheModeDefault];
    
    MTLFloat3x3 convolutionKernel;
    convolutionKernel.v1 = MTLFloat3Make(0.5, 1.0, 0.5);
    convolutionKernel.v2 = MTLFloat3Make(1.0, -6.0, 1.0);
    convolutionKernel.v3 = MTLFloat3Make(0.5, 1.0, 0.5);
    self.convolutionKernel = convolutionKernel;
    
    return self;
}


@end
