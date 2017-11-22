//
//  MetalImageVideoCamera.m
//  MetalImage
//
//  Created by stonefeng on 2017/3/1.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "MetalImageVideoCamera.h"
#import <AVFoundation/AVFoundation.h>
#import "MetalImageContext.h"
#import "MetalImageTexture.h"
#import "MetalImageTextureCache.h"
#import "MetalImageColorConversion.h"

@interface MetalImageVideoCamera() <AVCaptureVideoDataOutputSampleBufferDelegate> {
    
    dispatch_queue_t cameraProcessingQueue;
    OSType _videoOutputPixelFormat;
    MetalImageColorConversion *_conversion;
}

- (void)updateColorConversionWithAttachments:(CFTypeRef)colorAttachments;

@end

@implementation MetalImageVideoCamera

- (id)init {
    return [self initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
}

- (id)initWithSessionPreset:(NSString *)sessionPreset cameraPosition:(AVCaptureDevicePosition)cameraPosition {
    if (!(self = [super init]))
    {
        return nil;
    }
    
    cameraProcessingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0);
    
    frameRenderingSemaphore = dispatch_semaphore_create(1);
    
    _frameRate = 0; // This will not set frame rate unless this value gets set to 1 or above
//    _runBenchmark = NO;
    capturePaused = NO;
    outputRotation = kMetalImageNoRotation;
//    internalRotation = kMetalImageNoRotation;
    
    // Grab the back-facing or front-facing camera
    _inputCamera = nil;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == cameraPosition)
        {
            _inputCamera = device;
        }
    }
    
    if (!_inputCamera) {
        return nil;
    }
    
    // Create the capture session
    _captureSession = [[AVCaptureSession alloc] init];
    
    [_captureSession beginConfiguration];
    
    // Add the video input
    NSError *error = nil;
    videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:_inputCamera error:&error];
    if ([_captureSession canAddInput:videoInput])
    {
        [_captureSession addInput:videoInput];
    }
    
    // Add the video frame output
    videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    [videoOutput setAlwaysDiscardsLateVideoFrames:NO];
    
    if ([MetalImageTexture supportsFastTextureUpload]) {
        
        _videoOutputPixelFormat = kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange;
        
        NSArray *supportedPixelFormats = videoOutput.availableVideoCVPixelFormatTypes;
        for (NSNumber *currentPixelFormat in supportedPixelFormats)
        {
            if ([currentPixelFormat intValue] == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
            {
                _videoOutputPixelFormat = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
                break;
            }
        }
        
        [videoOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey:@(_videoOutputPixelFormat)}];
        _conversion = [[MetalImageColorConversion alloc] init];
    }
    else {
        _videoOutputPixelFormat = kCVPixelFormatType_32BGRA;
        [videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    }
    
    [videoOutput setSampleBufferDelegate:self queue:cameraProcessingQueue];
    
    if ([_captureSession canAddOutput:videoOutput]) {
        [_captureSession addOutput:videoOutput];
    }
    else {
        NSAssert(NO, @"Couldn't add video output");
        return nil;
    }
    
    _captureSessionPreset = sessionPreset;
    [_captureSession setSessionPreset:_captureSessionPreset];
    [_captureSession commitConfiguration];
    
    return self;
}

- (void)dealloc {
    [self stopCameraCapture];
    [videoOutput setSampleBufferDelegate:nil queue:dispatch_get_main_queue()];
    
    [_captureSession beginConfiguration];
    if (videoInput) {
        [_captureSession removeInput:videoInput];
        videoInput = nil;
    }
    if (videoOutput) {
        [_captureSession removeOutput:videoOutput];
        videoOutput = nil;
    }
    [_captureSession commitConfiguration];
}

#pragma mark - Config API

- (BOOL)isCameraRunning {
    return [_captureSession isRunning];
}

- (void)startCameraCapture;
{
    if (![_captureSession isRunning])
    {
        [_captureSession startRunning];
    }
}

- (void)stopCameraCapture;
{
    if ([_captureSession isRunning])
    {
        [_captureSession stopRunning];
    }
}

- (void)pauseCameraCapture;
{
    capturePaused = YES;
}

- (void)resumeCameraCapture;
{
    capturePaused = NO;
}

- (void)switchCameraDevice {
    
    if ([MetalImageVideoCamera isFrontFacingCameraPresent] == NO) {
        return;
    }
    
    NSError *error;
    AVCaptureDeviceInput *newVideoInput;
    AVCaptureDevicePosition currentCameraPosition = [[videoInput device] position];
    
    if (currentCameraPosition == AVCaptureDevicePositionBack)
    {
        currentCameraPosition = AVCaptureDevicePositionFront;
    }
    else
    {
        currentCameraPosition = AVCaptureDevicePositionBack;
    }
    
    AVCaptureDevice *backFacingCamera = nil;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == currentCameraPosition)
        {
            backFacingCamera = device;
        }
    }
    newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:backFacingCamera error:&error];
    
    if (newVideoInput != nil)
    {
        [_captureSession beginConfiguration];
        
        [_captureSession removeInput:videoInput];
        if ([_captureSession canAddInput:newVideoInput])
        {
            [_captureSession addInput:newVideoInput];
            videoInput = newVideoInput;
        }
        else
        {
            [_captureSession addInput:videoInput];
        }
        
        [_captureSession commitConfiguration];
    }
    
    _inputCamera = backFacingCamera;
    [self setOutputImageOrientation:_outputImageOrientation];
}

- (AVCaptureDevicePosition)cameraPosition {
    return [[videoInput device] position];
}

+ (BOOL)isBackFacingCameraPresent {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == AVCaptureDevicePositionBack)
            return YES;
    }
    
    return NO;
}

+ (BOOL)isFrontFacingCameraPresent {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == AVCaptureDevicePositionFront)
            return YES;
    }
    
    return NO;
}

- (void)setFrameRate:(int32_t)frameRate;
{
    _frameRate = frameRate;
    
    if (_frameRate > 0)
    {
        if ([_inputCamera respondsToSelector:@selector(setActiveVideoMinFrameDuration:)] &&
            [_inputCamera respondsToSelector:@selector(setActiveVideoMaxFrameDuration:)]) {
            
            NSError *error;
            [_inputCamera lockForConfiguration:&error];
            if (error == nil) {
#if defined(__IPHONE_7_0)
                [_inputCamera setActiveVideoMinFrameDuration:CMTimeMake(1, _frameRate)];
                [_inputCamera setActiveVideoMaxFrameDuration:CMTimeMake(1, _frameRate)];
#endif
            }
            [_inputCamera unlockForConfiguration];
            
        } else {
            
            for (AVCaptureConnection *connection in videoOutput.connections)
            {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                if ([connection respondsToSelector:@selector(setVideoMinFrameDuration:)])
                    connection.videoMinFrameDuration = CMTimeMake(1, _frameRate);
                
                if ([connection respondsToSelector:@selector(setVideoMaxFrameDuration:)])
                    connection.videoMaxFrameDuration = CMTimeMake(1, _frameRate);
#pragma clang diagnostic pop
            }
        }
        
    }
    else
    {
        if ([_inputCamera respondsToSelector:@selector(setActiveVideoMinFrameDuration:)] &&
            [_inputCamera respondsToSelector:@selector(setActiveVideoMaxFrameDuration:)]) {
            
            NSError *error;
            [_inputCamera lockForConfiguration:&error];
            if (error == nil) {
#if defined(__IPHONE_7_0)
                [_inputCamera setActiveVideoMinFrameDuration:kCMTimeInvalid];
                [_inputCamera setActiveVideoMaxFrameDuration:kCMTimeInvalid];
#endif
            }
            [_inputCamera unlockForConfiguration];
            
        } else {
            
            for (AVCaptureConnection *connection in videoOutput.connections)
            {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                if ([connection respondsToSelector:@selector(setVideoMinFrameDuration:)])
                    connection.videoMinFrameDuration = kCMTimeInvalid; // This sets videoMinFrameDuration back to default
                
                if ([connection respondsToSelector:@selector(setVideoMaxFrameDuration:)])
                    connection.videoMaxFrameDuration = kCMTimeInvalid; // This sets videoMaxFrameDuration back to default
#pragma clang diagnostic pop
            }
        }
    }
}

#pragma mark - Image Processing

- (void)processVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
    if (capturePaused) {
        return;
    }
    
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    int bytesPerRow = (int) CVPixelBufferGetBytesPerRow(pixelBuffer);
//    int width = (int)CVPixelBufferGetWidth(pixelBuffer);
    int height = (int)CVPixelBufferGetHeight(pixelBuffer);
    
    if (CVPixelBufferIsPlanar(pixelBuffer)) {
        
        // Check for YUV planar inputs to do RGB conversion
        if (CVPixelBufferGetPlaneCount(pixelBuffer) > 1) {
            
            CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
            
            CVMetalTextureCacheRef coreVideoTextureCache = [[MetalImageContext sharedImageProcessingContext] coreVideoTextureCache];
            NSAssert(coreVideoTextureCache != NULL, @"Invalid texture cache");
            
            int width = (int)CVPixelBufferGetWidth(pixelBuffer);
            int height = (int)CVPixelBufferGetHeight(pixelBuffer);
            
            CVMetalTextureRef y_texture;
            int y_width = (int)CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
            int y_height = (int)CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
            CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, coreVideoTextureCache, pixelBuffer, nil, MTLPixelFormatR8Unorm, y_width, y_height, 0, &y_texture);
            
            CVMetalTextureRef uv_texture;
            int uv_width = (int)CVPixelBufferGetWidthOfPlane(pixelBuffer, 1);
            int uv_height = (int)CVPixelBufferGetHeightOfPlane(pixelBuffer, 1);
            CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, coreVideoTextureCache, pixelBuffer, nil, MTLPixelFormatRG8Unorm, uv_width, uv_height, 1, &uv_texture);
            
            NSAssert(y_width == (uv_width<<1) && y_height == (uv_height<<1), @"Data Invalid...");
            
            id<MTLTexture> luma = CVMetalTextureGetTexture(y_texture);
            id<MTLTexture> chroma = CVMetalTextureGetTexture(uv_texture);
            
            if (luma && chroma) {
                CFTypeRef colorAttachments = CVBufferGetAttachment(pixelBuffer, kCVImageBufferYCbCrMatrixKey, NULL);
                [self updateColorConversionWithAttachments:colorAttachments];
                
                outputTexture = [[MetalImageContext sharedTextureCache] fetchTextureWithSize:MTLUInt2Make(width, height)];
                [_conversion generateBGROutputTexture:[outputTexture texture] YPlane:luma UVPlane:chroma];
            }
            
            CVBufferRelease(y_texture);
            CVBufferRelease(uv_texture);
            
            CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
        }
        else {
            NSAssert(NO, @"Data Invalid...");
        }
    }
    else {
        
        NSAssert(_videoOutputPixelFormat == kCVPixelFormatType_32BGRA, @"Wrong pixel format");
        CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
        int width_expand = bytesPerRow >> 2;
        
        outputTexture = [[MetalImageContext sharedTextureCache] fetchTextureWithSize:MTLUInt2Make(width_expand, height)];
        [[outputTexture texture] replaceRegion:MTLRegionMake2D(0,0,width_expand,height)
                                   mipmapLevel:0
                                     withBytes:CVPixelBufferGetBaseAddress(pixelBuffer)
                                   bytesPerRow:bytesPerRow];
        
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    }
}

- (void)updateColorConversionWithAttachments:(CFTypeRef)colorAttachments {
    if (colorAttachments != NULL)
    {
        if (CFStringCompare(colorAttachments, kCVImageBufferYCbCrMatrix_ITU_R_601_4, 0) == kCFCompareEqualTo)
        {
            if (_videoOutputPixelFormat == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
            {
                _conversion.function = ColorConversionKernalFunction601f;
            }
            else
            {
                _conversion.function = ColorConversionKernalFunction601v;
            }
        }
        else
        {
            _conversion.function = ColorConversionKernalFunction709v;
        }
    }
    else
    {
        if (_videoOutputPixelFormat == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
        {
            _conversion.function = ColorConversionKernalFunction601f;
        }
        else
        {
            _conversion.function = ColorConversionKernalFunction601v;
        }
    }
}

#pragma mark - Orientation

- (void)updateOrientation {
    
    runMetalSynchronouslyOnVideoProcessingQueue(^{
        
        //    From the iOS 5.0 release notes:
        //    In previous iOS versions, the front-facing camera would always deliver buffers in AVCaptureVideoOrientationLandscapeLeft and the back-facing camera would always deliver buffers in AVCaptureVideoOrientationLandscapeRight.
        /*
        if ([MetalImageTexture supportsFastTextureUpload])
        {
            outputRotation = kMetalImageNoRotation;
            if ([self cameraPosition] == AVCaptureDevicePositionBack)
            {
                if (_horizontallyMirrorRearFacingCamera)
                {
                    switch(_outputImageOrientation)
                    {
                        case UIInterfaceOrientationPortrait:internalRotation = kMetalImageRotateRightFlipVertical; break;
                        case UIInterfaceOrientationPortraitUpsideDown:internalRotation = kMetalImageRotate180; break;
                        case UIInterfaceOrientationLandscapeLeft:internalRotation = kMetalImageFlipHorizonal; break;
                        case UIInterfaceOrientationLandscapeRight:internalRotation = kMetalImageFlipVertical; break;
                        default:internalRotation = kMetalImageNoRotation;
                    }
                }
                else
                {
                    switch(_outputImageOrientation)
                    {
                        case UIInterfaceOrientationPortrait:internalRotation = kMetalImageRotateRight; break;
                        case UIInterfaceOrientationPortraitUpsideDown:internalRotation = kMetalImageRotateLeft; break;
                        case UIInterfaceOrientationLandscapeLeft:internalRotation = kMetalImageRotate180; break;
                        case UIInterfaceOrientationLandscapeRight:internalRotation = kMetalImageNoRotation; break;
                        default:internalRotation = kMetalImageNoRotation;
                    }
                }
            }
            else
            {
                if (_horizontallyMirrorFrontFacingCamera)
                {
                    switch(_outputImageOrientation)
                    {
                        case UIInterfaceOrientationPortrait:internalRotation = kMetalImageRotateRightFlipVertical; break;
                        case UIInterfaceOrientationPortraitUpsideDown:internalRotation = kMetalImageRotateRightFlipHorizontal; break;
                        case UIInterfaceOrientationLandscapeLeft:internalRotation = kMetalImageFlipHorizonal; break;
                        case UIInterfaceOrientationLandscapeRight:internalRotation = kMetalImageFlipVertical; break;
                        default:internalRotation = kMetalImageNoRotation;
                    }
                }
                else
                {
                    switch(_outputImageOrientation)
                    {
                        case UIInterfaceOrientationPortrait:internalRotation = kMetalImageRotateRight; break;
                        case UIInterfaceOrientationPortraitUpsideDown:internalRotation = kMetalImageRotateLeft; break;
                        case UIInterfaceOrientationLandscapeLeft:internalRotation = kMetalImageNoRotation; break;
                        case UIInterfaceOrientationLandscapeRight:internalRotation = kMetalImageRotate180; break;
                        default:internalRotation = kMetalImageNoRotation;
                    }
                }
            }
        }
        else
        {*/
            if ([self cameraPosition] == AVCaptureDevicePositionBack)
            {
                if (_horizontallyMirrorRearFacingCamera)
                {
                    switch(_outputImageOrientation)
                    {
                        case UIInterfaceOrientationPortrait:outputRotation = kMetalImageRotateRightFlipVertical; break;
                        case UIInterfaceOrientationPortraitUpsideDown:outputRotation = kMetalImageRotate180; break;
                        case UIInterfaceOrientationLandscapeLeft:outputRotation = kMetalImageFlipHorizonal; break;
                        case UIInterfaceOrientationLandscapeRight:outputRotation = kMetalImageFlipVertical; break;
                        default:outputRotation = kMetalImageNoRotation;
                    }
                }
                else
                {
                    switch(_outputImageOrientation)
                    {
                        case UIInterfaceOrientationPortrait:outputRotation = kMetalImageRotateRight; break;
                        case UIInterfaceOrientationPortraitUpsideDown:outputRotation = kMetalImageRotateLeft; break;
                        case UIInterfaceOrientationLandscapeLeft:outputRotation = kMetalImageRotate180; break;
                        case UIInterfaceOrientationLandscapeRight:outputRotation = kMetalImageNoRotation; break;
                        default:outputRotation = kMetalImageNoRotation;
                    }
                }
            }
            else
            {
                if (_horizontallyMirrorFrontFacingCamera)
                {
                    switch(_outputImageOrientation)
                    {
                        case UIInterfaceOrientationPortrait:outputRotation = kMetalImageRotateRightFlipVertical; break;
                        case UIInterfaceOrientationPortraitUpsideDown:outputRotation = kMetalImageRotateRightFlipHorizontal; break;
                        case UIInterfaceOrientationLandscapeLeft:outputRotation = kMetalImageFlipHorizonal; break;
                        case UIInterfaceOrientationLandscapeRight:outputRotation = kMetalImageFlipVertical; break;
                        default:outputRotation = kMetalImageNoRotation;
                    }
                }
                else
                {
                    switch(_outputImageOrientation)
                    {
                        case UIInterfaceOrientationPortrait:outputRotation = kMetalImageRotateRight; break;
                        case UIInterfaceOrientationPortraitUpsideDown:outputRotation = kMetalImageRotateLeft; break;
                        case UIInterfaceOrientationLandscapeLeft:outputRotation = kMetalImageNoRotation; break;
                        case UIInterfaceOrientationLandscapeRight:outputRotation = kMetalImageRotate180; break;
                        default:outputRotation = kMetalImageNoRotation;
                    }
                }
            }
//        }
    });
}

- (void)setOutputImageOrientation:(UIInterfaceOrientation)newValue;
{
    _outputImageOrientation = newValue;
    [self updateOrientation];
}

- (void)setHorizontallyMirrorFrontFacingCamera:(BOOL)newValue
{
    _horizontallyMirrorFrontFacingCamera = newValue;
    [self updateOrientation];
}

- (void)setHorizontallyMirrorRearFacingCamera:(BOOL)newValue
{
    _horizontallyMirrorRearFacingCamera = newValue;
    [self updateOrientation];
}

- (MetalImageRotationMode)rotationForOutput {
    return outputRotation;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    if (capturePaused) {
        return;
    }
    
    if (dispatch_semaphore_wait(frameRenderingSemaphore, DISPATCH_TIME_NOW) != 0) {
        return;
    }
    
    CFRetain(sampleBuffer);
    runMetalAsynchronouslyOnVideoProcessingQueue(^{
        
        [self processVideoSampleBuffer:sampleBuffer];
        [self notifyTargetsAboutNewTextureAtTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
        
        CFRelease(sampleBuffer);
        dispatch_semaphore_signal(frameRenderingSemaphore);
    });
}



@end
