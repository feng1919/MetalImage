//
//  MetalImageTexture.m
//  MetalImage
//
//  Created by stonefeng on 2017/2/7.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageTexture.h"
#import "MetalImageFunction.h"
#import "MetalImageContext.h"
#import "MetalDevice.h"
#import "UIImage+Texture.h"

static int MetalSupportFastTextureLoad = -1;

// Maps the CoreVideo pixel format the texture was created with to the matching
// Metal pixel format for CVMetalTexture wrapping / descriptor creation.
static MTLPixelFormat MTLPixelFormatFromCVPixelFormat(int cvFormat) {
    switch (cvFormat) {
        case kCVPixelFormatType_32BGRA:     return MTLPixelFormatBGRA8Unorm;
        case kCVPixelFormatType_32RGBA:     return MTLPixelFormatRGBA8Unorm;
        case kCVPixelFormatType_64RGBAHalf: return MTLPixelFormatRGBA16Float;
        default:                            return MTLPixelFormatBGRA8Unorm;
    }
}

@interface MetalImageTexture () {
    struct {
        NSUInteger count;
        BOOL enabled;
    }_reference;
    
    NSUInteger _readLockCount;
    CVMetalTextureRef _textureRef;
    CVPixelBufferRef _renderTarget;
    MTLTextureUsage _usage;
}

- (void)buildupFramebuffer;
- (void)buildupTexture;
- (void)teardownFramebuffer;

@end

@implementation MetalImageTexture
@synthesize size = _size;

- (instancetype)init {
    NSAssert(NO, @"Do not call this method to initialize.");
    return nil;
}

- (instancetype)initWithTextureSize:(MTLUInt2)size {
//    if (self = [super init]) {
//        _reference.enabled = YES;
//        _reference.count = 0;
//        _size = size;
//        [self buildupFramebuffer];
//    }
//    return self;
    return [self initWithTextureSize:size pixelFormat:[[self class] defaultPixelFormat]];
}

- (instancetype)initWithTextureSize:(MTLUInt2)size pixelFormat:(int)pixelFormat {
    if (self = [super init]) {
        _reference.enabled = YES;
        _reference.count = 0;
        _size = size;
        _pixelFormat = pixelFormat;
        [self buildupFramebuffer];
    }
    return self;
}

- (instancetype)initWithTextureSize:(MTLUInt2)size textureUsage:(MTLTextureUsage)usage {
    if (self = [super init]) {
        _reference.enabled = NO;
        _reference.count = 0;
        _size = size;
        _usage = usage;
        [self buildupTexture];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[%p] <%@><label:%@> %dx%dx%d reference count: %d",
            self, NSStringFromClass([self class]), _label, (int)[_texture width], (int)[_texture height],
            (int)[_texture depth], (int)_reference.count];
}

- (void)dealloc {
    [self teardownFramebuffer];
}

+ (int)defaultPixelFormat {
    return kCVPixelFormatType_32BGRA;
}

#pragma mark - Internal
- (void)buildupFramebuffer {
    if ([MetalImageTexture supportsFastTextureUpload]) {
        CVMetalTextureCacheRef coreVideoTextureCache = [[MetalImageContext sharedImageProcessingContext] coreVideoTextureCache];
        // Code originally sourced from http://allmybrain.com/2011/12/08/rendering-to-a-texture-with-ios-5-texture-cache-api/
        
        CFDictionaryRef empty; // empty value for attr value.
        CFMutableDictionaryRef attrs;
        empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks); // our empty IOSurface properties dictionary
        attrs = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);
        
        CVReturn err = CVPixelBufferCreate(kCFAllocatorDefault, _size.x, _size.y, _pixelFormat, attrs, &_renderTarget);
        if (err)
        {
            NSLog(@"FBO size: %d, %d", _size.x, _size.y);
            NSAssert(NO, @"Error at CVPixelBufferCreate %d", err);
        }
        
        CVReturn error = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, coreVideoTextureCache, _renderTarget, NULL, MTLPixelFormatFromCVPixelFormat(_pixelFormat), _size.x, _size.y, 0, &_textureRef);
        
        NSAssert(error == kCVReturnSuccess, @">>>>ERR: Failed to create CVMetalTextureRef.");
        
        CFRelease(attrs);
        CFRelease(empty);
        
        if (_textureRef != NULL) {
            _texture = CVMetalTextureGetTexture(_textureRef);
            NSAssert(_texture != NULL, @">>>>ERR: Failed to obtain texture from CVMetalTextureRef.");
        }
        
        NSLog(@"Create Texture Framebuffer: %@",[self description]);
    }
}

- (void)buildupTexture {
    MTLTextureDescriptor *descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatFromCVPixelFormat(_pixelFormat) width:_size.x height:_size.y mipmapped:NO];
    descriptor.usage = _usage;
    _texture = [[MetalDevice sharedMTLDevice] newTextureWithDescriptor:descriptor];
}

- (void)teardownFramebuffer {
    if ([MetalImageTexture supportsFastTextureUpload]) {
        if (_renderTarget)
        {
            CFRelease(_renderTarget);
            _renderTarget = NULL;
            NSLog(@"Dealloc Texture Framebuffer: %@",[self description]);
        }
        
        if (_textureRef) {
            CFRelease(_textureRef);
            _textureRef = NULL;
        }
    }
}

#pragma mark - Manage fast texture upload

+ (BOOL)supportsFastTextureUpload1 {
    return NO;
}

+ (BOOL)supportsFastTextureUpload {
#if TARGET_IPHONE_SIMULATOR
    return NO;
#else
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wtautological-pointer-compare"
    if (MetalSupportFastTextureLoad == -1) {
        MetalSupportFastTextureLoad = (CVMetalTextureCacheCreate != NULL);
    }
    return MetalSupportFastTextureLoad;
#pragma clang diagnostic pop
    
#endif
}

#pragma mark - Reference counting

- (MetalImageTexture *)lock
{
    if (_reference.enabled)
    {
        _reference.count ++;
    }
    
    return self;
}

- (void)unlock
{
    if (_reference.enabled)
    {
        NSAssert(_reference.count > 0, @"Tried to overrelease a texture.");
        _reference.count--;
        if (_reference.count < 1)
        {
            [[MetalImageContext sharedTextureCache] cacheTexture:self];
        }
    }
}

- (void)clearAllLocks
{
    _reference.count = 0;
}

- (BOOL)isReferenceCountingEnable {
    return _reference.enabled;
}

- (void)disableReferenceCounting
{
    _reference.enabled = NO;
}

- (void)enableReferenceCounting {
    _reference.enabled = YES;
}

- (NSUInteger)referenceCounting {
    return _reference.count;
}

#pragma mark -
#pragma mark Raw data bytes

- (void)lockForReading
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    if ([MetalImageTexture supportsFastTextureUpload])
    {
        if (_readLockCount == 0)
        {
            CVPixelBufferLockBaseAddress(_renderTarget, 0);
        }
        _readLockCount++;
    }
#endif
}

- (void)unlockAfterReading
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    if ([MetalImageTexture supportsFastTextureUpload])
    {
        NSAssert(_readLockCount > 0, @"Unbalanced call to -[GPUImageFramebuffer unlockAfterReading]");
        _readLockCount--;
        if (_readLockCount == 0)
        {
            CVPixelBufferUnlockBaseAddress(_renderTarget, 0);
        }
    }
#endif
}

- (NSUInteger)bytesPerRow;
{
    if ([MetalImageTexture supportsFastTextureUpload])
    {
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        return CVPixelBufferGetBytesPerRow(_renderTarget);
#else
        return _size.x * 4; // TODO: do more with this on the non-texture-cache side
#endif
    }
    else
    {
        return _size.x * 4;
    }
}

- (Byte *)byteBuffer;
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    // The CVPixelBuffer base address is only valid between lockForReading and
    // unlockAfterReading. The lock is held on return; callers must pair this
    // call with -unlockAfterReading.
    [self lockForReading];
    return CVPixelBufferGetBaseAddress(_renderTarget);
#else
    return NULL; // TODO: do more with this on the non-texture-cache side
#endif
}

+ (NSUInteger)maximum2DTextureSize {
    static NSUInteger maximum2DTextureSize = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Metal exposes no direct API for the 2D texture dimension limit, so
        // probe the device with cheap (lazily-backed) texture allocations.
        // 2048 stays as the conservative floor, matching the old hard limit.
        // Cap probing at 8192 (256MB BGRA): that already covers the largest
        // camera stills (4032x3024) while avoiding a 16384^2 x 4 = 1GB
        // speculative allocation on the synchronous MetalImagePicture init
        // path of 16K-capable devices (Jetsam risk under memory pressure).
        maximum2DTextureSize = 2048;
        id<MTLDevice> device = [MetalDevice sharedMTLDevice];
        for (NSUInteger candidate = 8192; candidate >= 4096; candidate >>= 1) {
            MTLTextureDescriptor *descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm
                                                                                                    width:candidate
                                                                                                   height:candidate
                                                                                                mipmapped:NO];
            descriptor.usage = MTLTextureUsageShaderRead;
            if ([device newTextureWithDescriptor:descriptor] != nil) {
                maximum2DTextureSize = candidate;
                break;
            }
        }
    });
    return maximum2DTextureSize;
}

+ (CGSize)sizeThatFitsWithinATextureForSize:(CGSize)inputSize
{
    GLint maxTextureSize = (GLint)[self maximum2DTextureSize];
    if ( (inputSize.width < maxTextureSize) && (inputSize.height < maxTextureSize) )
    {
        return inputSize;
    }
    
    CGSize adjustedSize;
    if (inputSize.width > inputSize.height)
    {
        adjustedSize.width = (CGFloat)maxTextureSize;
        adjustedSize.height = ((CGFloat)maxTextureSize / inputSize.width) * inputSize.height;
    }
    else
    {
        adjustedSize.height = (CGFloat)maxTextureSize;
        adjustedSize.width = ((CGFloat)maxTextureSize / inputSize.height) * inputSize.width;
    }
    
    return adjustedSize;
}

- (UIImage *)imageFromTexture {
    return [UIImage imageWithMTLTexture:self.texture orientation:UIImageOrientationUp];
}

@end









