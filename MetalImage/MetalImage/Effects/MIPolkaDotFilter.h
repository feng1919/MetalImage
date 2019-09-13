//
//  MIPolkaDotFilter.h
//  MetalImage
//
//  Created by Feng Stone on 2017/10/13.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MIPixellateFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MIPolkaDotFilter : MIPixellateFilter

@property(readwrite, nonatomic) MTLFloat dotScaling;

@end

NS_ASSUME_NONNULL_END
