@import UIKit;

@protocol MTLTexture;

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (MTLTexture)

+ (UIImage *)imageWithMTLTexture:(id<MTLTexture>)texture orientation:(UIImageOrientation)orientation;

@end

NS_ASSUME_NONNULL_END

bool CGRectIsValid(CGRect rect);
