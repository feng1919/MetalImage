//
//  MetalImage.h"
//  MetalImage
//
//  Created by Feng Stone on 2019/9/13.
//  Copyright © 2019 fengshi. All rights reserved.
//

#if TARGET_IPHONE_SIMULATOR
#warning <MetalImage> framework does not support SIMULATOR.
#endif

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
// COLOR
#import "MIBrightnessFilter.h"
#import "MIColorMatrixFilter.h"
#import "MIContrastFilter.h"
#import "MIExposureFilter.h"
#import "MIGammaFilter.h"
#import "MILevelsFilter.h"
#import "MISaturationFilter.h"
#import "MIRGBFilter.h"
#import "MIHSBFilter.h"
#import "MIHueFilter.h"
#import "MIMonochromeFilter.h"
#import "MIFalseColorFilter.h"
#import "MIHazeFilter.h"
#import "MISepiaFilter.h"
#import "MIColorInvertFilter.h"
#import "MIGrayscaleFilter.h"
#import "MILuminanceThresholdFilter.h"
#import "MIAdaptiveThresholdFilter.h"
#import "MISolarizeFilter.h"
#import "MIAverageLuminanceThresholdFilter.h"
#import "MIHistogramGenerator.h"
#import "MIHistogramGenerator.h"
#import "MIHistogramFilter.h"
#import "MIHighlightShadowFilter.h"
#import "MILookupFilter.h"
#import "MIOpacityFilter.h"
#import "MIChromaKeyFilter.h"
#import "MIWhiteBalanceFilter.h"
#import "MILuminanceRangeFilter.h"

// Image Processing
#import "MITransformFilter.h"
#import "MICropFilter.h"
#import "MIGaussianBlurFilter.h"
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
#import "MIXYDerivativeFilter.h"
#import "MIFASTCornerDetectionFilter.h"
#import "MINonMaximumSuppressionFilter.h"
#import "MICrosshairGenerator.h"
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
#import "MIHighPassFilter.h"

// Blend
#import "MISourceOverBlendFilter.h"
#import "MIColorBurnBlendFilter.h"
#import "MIColorDodgeBlendFilter.h"
#import "MIDarkenBlendFilter.h"
#import "MIDifferenceBlendFilter.h"
#import "MIDissolveBlendFilter.h"
#import "MIExclusionBlendFilter.h"
#import "MIHardLightBlendFilter.h"
#import "MISoftLightBlendFilter.h"
#import "MILightenBlendFilter.h"
#import "MIAddBlendFilter.h"
#import "MISubtractBlendFilter.h"
#import "MIDivideBlendFilter.h"
#import "MIMultiplyBlendFilter.h"
#import "MIOverlayBlendFilter.h"
#import "MIScreenBlendFilter.h"
#import "MIChromaKeyBlendFilter.h"
#import "MIAlphaBlendFilter.h"
#import "MINormalBlendFilter.h"
#import "MIColorBlendFilter.h"
#import "MIHueBlendFilter.h"
#import "MISaturationBlendFilter.h"
#import "MILuminosityBlendFilter.h"
#import "MILinearBurnBlendFilter.h"
#import "MIMaskFilter.h"

// Effects
#import "MIPerlinNoiseFilter.h"
#import "MIPixellateFilter.h"
#import "MIPolkaDotFilter.h"
#import "MIHalftoneFilter.h"
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
#import "MIMosaicFilter.h"
#import "MIVoronoiConsumerFilter.h"

// Matrix
#import "MetalMatrixBuffers.h"
#import "BlasMatrixMult.h"
#import "MetalMatrixMult.h"

// Foundation
#import "MetalDevice.h"
#import "MetalImageColorConversion.h"
#import "MetalImageContext.h"
#import "MetalImageDebugView.h"
#import "MetalImageFilter.h"
#import "MetalImageRenderResource.h"
#import "MetalImageBuffer.h"
#import "MetalImageFilterExtension.h"
#import "MetalImageTwoPassFilter.h"
#import "MITwoPassTextureSamplingFilter.h"
#import "MI3x3TextureSamplingFilter.h"
#import "MetalImageTwoInputFilter.h"
#import "MetalImageFilterGroup.h"
#import "MetalImageFunction.h"
#import "MetalImageGlobal.h"
#import "MetalImageTypes.h"
#import "MetalImageInput.h"
#import "MetalImageKernel.h"
#import "MetalImageTwoInputKernel.h"
#import "MetalImageOutput.h"
#import "MetalImagePicture.h"
#import "MetalImageTexture.h"
#import "MetalImageTextureCache.h"
#import "MetalImageVideoCamera.h"
#import "MetalImageView.h"
#import "UIImage+Texture.h"
#import "MetalImageMath.h"
