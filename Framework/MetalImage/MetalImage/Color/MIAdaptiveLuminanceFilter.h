//
//  MIAdaptiveLuminanceFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2021/2/19.
//  Copyright © 2021 fengshi. All rights reserved.
//

#import "MetalImageFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MIAdaptiveLuminanceFilter : MetalImageFilter

@property (nonatomic, assign) MTLFloat scale;

@property (nonatomic, assign) MTLFloat offset;

@end

NS_ASSUME_NONNULL_END
