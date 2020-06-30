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
#import "MIContrastFilter.h"
#import "MIBrightnessFilter.h"
#import "MILevelsFilter.h"
#import "MIColorMatrixFilter.h"
#import "MetalImageTwoInputFilter.h"
#import "MIRGBFilter.h"
#import "MIColorInvertFilter.h"
#import "MetalImageFilterGroup.h"
#import "MetalImageTwoPassFilter.h"
#import "MIGaussianBlurFilter.h"
#import "MISolarizeFilter.h"
#import "MIPerlinNoiseFilter.h"
#import "MIPolarPixellateFilter.h"
#import "MICrosshatchFilter.h"
#import "MICGAColorspaceFilter.h"
#import "MIPosterizeFilter.h"
#import "MISwirlFilter.h"
#import "MIBulgeDistortionFilter.h"
#import "MIPinchDistortionFilter.h"
#import "MIStretchDistortionFilter.h"
#import "MISphereRefractionFilter.h"
#import "MIGlassSphereFilter.h"
#import "MIKuwaharaFilter.h"
#import "MIKuwaharaRadius3Filter.h"
#import "MIVignetteFilter.h"
#import "MIJFAVoronoiFilter.h"
#import "MetalImagePicture.h"
#import "MIMosaicFilter.h"
#import "MIPixellateFilter.h"
#import "MIPolkaDotFilter.h"
#import "MIHalftoneFilter.h"
#import "MICropFilter.h"
#import "MITransformFilter.h"
#import "MISharpenFilter.h"
#import "MIMedianFilter.h"
#import "MI3x3ConvolutionFilter.h"
#import "MILaplacianFilter.h"
#import "MISobelEdgeDetectionFilter.h"
#import "MIThresholdEdgeDetectionFilter.h"
#import "MIDirectionalSobelEdgeDetectionFilter.h"
#import "MIDirectionalNonMaximumSuppressionFilter.h"
#import "MIWeakPixelInclusionFilter.h"
#import "MIPrewittEdgeDetectionFilter.h"
#import "MINonMaximumSuppressionFilter.h"
#import "MIDilationFilter.h"
#import "MIRGBDilationFilter.h"
#import "MIErosionFilter.h"
#import "MIRGBErosionFilter.h"
#import "MIOpeningFilter.h"
#import "MIRGBOpeningFilter.h"
#import "MIClosingFilter.h"
#import "MIRGBClosingFilter.h"
#import "MIColorPackingFilter.h"
#import "MILocalBinaryPatternFilter.h"
#import "MIColorLocalBinaryPatternFilter.h"
#import "MILanczosResamplingFilter.h"
#import "MILowPassFilter.h"
#import "MIHistogramFilter.h"
#import "MISurfaceBlurFilter.h"
#import "MIBilateralFilter.h"
#import "MIMaskBilateralFilter.h"

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
    
    self.videoCamera = [[MetalImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1920x1080 cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    self.videoCamera.horizontallyMirrorRearFacingCamera = NO;
    
    MetalImageOutput *lastNode = _videoCamera;
    
//    MIGaussianBlurFilter *filter = [[MIGaussianBlurFilter alloc] init];
//    [lastNode addTarget:filter];
//    lastNode = filter;
    
//    MIHistogramFilter *filter1 = [[MIHistogramFilter alloc] init];
//    [lastNode addTarget:filter1];
//    lastNode = filter1;
    
    MetalImageFilter *filter1 = [[MetalImageFilter alloc] init];
//    filter1.outputImageSize = MTLUInt2Make(27, 48);
    [lastNode addTarget:filter1];
    lastNode = filter1;
    
    MIBilateralFilter *filter = [[MIBilateralFilter alloc] init];
//    filter.radius = 6;
    [lastNode addTarget:filter];
    lastNode = filter;
    
    MIMedianFilter *filer2 = [[MIMedianFilter alloc] init];
    [lastNode addTarget:filer2];
    lastNode = filer2;

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
