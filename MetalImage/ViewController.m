//
//  ViewController.m
//  MetalImage
//
//  Created by stonefeng on 2017/2/7.
//  Copyright © 2017年 fengshi. All rights reserved.
//

#import "ViewController.h"
#import "MetalImageVideoCamera.h"
#import "MetalImageView.h"
#import "MetalImageDebugView.h"
#import "MetalImageContext.h"
#import "MetalImageContrastFilter.h"
#import "MetalImageBrightnessFilter.h"
#import "MetalImageLevelsFilter.h"
#import "MetalImageColorMatrixFilter.h"
#import "MetalImageTwoInputFilter.h"
#import "MetalImageRGBFilter.h"
#import "MetalImageColorInvertFilter.h"
#import "MetalImageFilterGroup.h"
#import "MetalImageTwoPassFilter.h"
#import "MetalImageGaussianBlurFilter.h"
#import "MetalImageSolarizeFilter.h"
#import "MetalImagePerlinNoiseFilter.h"
#import "MetalImagePolarPixellateFilter.h"
#import "MetalImageCrosshatchFilter.h"
#import "MetalImageCGAColorspaceFilter.h"
#import "MetalImagePosterizeFilter.h"
#import "MetalImageSwirlFilter.h"
#import "MetalImageBulgeDistortionFilter.h"
#import "MetalImagePinchDistortionFilter.h"
#import "MetalImageStretchDistortionFilter.h"
#import "MetalImageSphereRefractionFilter.h"
#import "MetalImageGlassSphereFilter.h"
#import "MetalImageKuwaharaFilter.h"
#import "MetalImageKuwaharaRadius3Filter.h"
#import "MetalImageVignetteFilter.h"
#import "MetalImageJFAVoronoiFilter.h"
#import "MetalImagePicture.h"
#import "MetalImageMosaicFilter.h"
#import "MetalImagePixellateFilter.h"
#import "MetalImagePolkaDotFilter.h"
#import "MetalImageHalftoneFilter.h"
#import "MetalImageCropFilter.h"
#import "MetalImageTransformFilter.h"
#import "MetalImageSharpenFilter.h"
#import "MetalImageMedianFilter.h"
#import "MetalImage3x3ConvolutionFilter.h"
#import "MetalImageLaplacianFilter.h"
#import "MetalImageSobelEdgeDetectionFilter.h"
#import "MetalImageThresholdEdgeDetectionFilter.h"
#import "MetalImageDirectionalSobelEdgeDetectionFilter.h"
#import "MetalImageDirectionalNonMaximumSuppressionFilter.h"
#import "MetalImageWeakPixelInclusionFilter.h"
#import "MetalImagePrewittEdgeDetectionFilter.h"
#import "MetalImageNonMaximumSuppressionFilter.h"
#import "MetalImageDilationFilter.h"
#import "MetalImageRGBDilationFilter.h"
#import "MetalImageErosionFilter.h"
#import "MetalImageRGBErosionFilter.h"
#import "MetalImageOpeningFilter.h"
#import "MetalImageRGBOpeningFilter.h"
#import "MetalImageClosingFilter.h"
#import "MetalImageRGBClosingFilter.h"
#import "MetalImageColorPackingFilter.h"

#define METAL_DEBUG 0

@interface ViewController ()

@property (nonatomic,strong) IBOutlet UILabel *label;
#if METAL_DEBUG
@property (nonatomic,strong) MetalImageDebugView *metalView;
#else
@property (nonatomic,strong) MetalImageView *metalView;
#endif

@property (nonatomic,strong) MetalImageVideoCamera *videoCamera;

@end

@implementation ViewController

- (instancetype)init {
    if (self = [super initWithNibName:@"ViewController" bundle:nil]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
#if METAL_DEBUG
    self.metalView = [[MetalImageDebugView alloc] initWithFrame:self.view.bounds];
#else
    self.metalView = [[MetalImageView alloc] initWithFrame:self.view.bounds];
#endif
    self.metalView.fillMode = kMetalImageFillModePreserveAspectRatio;
    self.metalView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self.view addSubview:self.metalView];
    
    self.videoCamera = [[MetalImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetiFrame960x540 cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    self.videoCamera.horizontallyMirrorRearFacingCamera = NO;
    
    MetalImageOutput *lastNode = _videoCamera;
    
//    for (int i = 0; i < 200; i++) {
//        MetalImageContrastFilter *filter = [[MetalImageContrastFilter alloc] init];
//        filter.contrast = 0.5f;
    
//    MetalImageColorMatrixFilter *filter = [[MetalImageColorMatrixFilter alloc] init];
    
//    MetalImageBrightnessFilter *filter = [[MetalImageBrightnessFilter alloc] init];
//    filter.brightness = 0.5f;
    
//        MetalImageLevelsFilter *filter = [[MetalImageLevelsFilter alloc] init];
//            [filter setRedMin:0.7 gamma:0.6 max:0.9];
    
//    MetalImageRGBFilter *filter = [[MetalImageRGBFilter alloc] init];
//    filter.red = 0.0f;
//    filter.green = 0.5;
//    filter.blue = 0.5f;
    
//    MetalImageFilterGroup *filterGroup = [[MetalImageFilterGroup alloc] init];
//
//    MetalImageColorInvertFilter *filter = [[MetalImageColorInvertFilter alloc] init];
//    [filterGroup addFilter:filter];
//
//    MetalImageBrightnessFilter *filter1 = [[MetalImageBrightnessFilter alloc] init];
//    filter1.brightness = 0.0f;
//    [filterGroup addFilter:filter1];
//
//    [filter addTarget:filter1];
//    filterGroup.terminalFilter = filter1;
//    filterGroup.initialFilters = @[filter];
//
//            [lastNode addTarget:filterGroup];
//            lastNode = filterGroup;
    
//    MetalImageFilter *filter1 = [[MetalImageFilter alloc] init];
//    [lastNode addTarget:filter1];
//    lastNode = filter1;
    
//    MetalImageTwoPassFilter *filter = [[MetalImageTwoPassFilter alloc] initWithFirstStageFragmentFunctionName:@"fragment_common"
//                                                                              secondStageFragmentFunctionName:@"fragment_common"];
//    [lastNode addTarget:filter];
//    lastNode = filter;
    
//    MetalImageSolarizeFilter *solarizeFilter = [[MetalImageSolarizeFilter alloc] init];
//    [lastNode addTarget:solarizeFilter];
//    lastNode = solarizeFilter;
    
//    MetalImageFilter *filter1 = [[MetalImageFilter alloc] init];
////    filter1.outputImageSize = MTLUInt2Make(27, 48);
//    [lastNode addTarget:filter1];
//    lastNode = filter1;
    
    MetalImageColorPackingFilter *filter = [[MetalImageColorPackingFilter alloc] init];
//    [filter setAffineTransform:CGAffineTransformIdentity];
    [lastNode addTarget:filter];
    lastNode = filter;

//    }

//    TestTwoInputFilter *twoInputFilter = [[TestTwoInputFilter alloc] init];
//    [lastNode addTarget:twoInputFilter];
//    lastNode = twoInputFilter;
    [lastNode addTarget:_metalView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.videoCamera performSelector:@selector(startCameraCapture) withObject:nil afterDelay:1.0f];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
