// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MetalImage",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "MetalImage",
            targets: ["MetalImage"]
        )
    ],
    targets: [
        .target(
            name: "MetalImage",
            path: "Framework/MetalImage",
            exclude: [
                "Info.plist"
            ],
            resources: [
                .process("MetalImage/Blend/Blend.metal"),
                .process("MetalImage/Color/MIAdaptiveLuminanceFilter.metal"),
                .process("MetalImage/Color/MIAdaptiveThresholdFilter.metal"),
                .process("MetalImage/Color/MIBrightnessFilter.metal"),
                .process("MetalImage/Color/MIChromaKeyFilter.metal"),
                .process("MetalImage/Color/MIColorInvertFilter.metal"),
                .process("MetalImage/Color/MIColorMatrixFilter.metal"),
                .process("MetalImage/Color/MIContrastFilter.metal"),
                .process("MetalImage/Color/MIExposureFilter.metal"),
                .process("MetalImage/Color/MIFalseColorFilter.metal"),
                .process("MetalImage/Color/MIGammaFilter.metal"),
                .process("MetalImage/Color/MIGrayscaleFilter.metal"),
                .process("MetalImage/Color/MIHazeFilter.metal"),
                .process("MetalImage/Color/MIHighlightShadowFilter.metal"),
                .process("MetalImage/Color/MIHistogramGenerator.metal"),
                .process("MetalImage/Color/MIHSBFilter.metal"),
                .process("MetalImage/Color/MIHueFilter.metal"),
                .process("MetalImage/Color/MILevelsFilter.metal"),
                .process("MetalImage/Color/MILookupFilter.metal"),
                .process("MetalImage/Color/MILuminanceRangeFilter.metal"),
                .process("MetalImage/Color/MILuminanceThresholdFilter.metal"),
                .process("MetalImage/Color/MIMonochromeFilter.metal"),
                .process("MetalImage/Color/MIOpacityFilter.metal"),
                .process("MetalImage/Color/MIRGBFilter.metal"),
                .process("MetalImage/Color/MISaturationFilter.metal"),
                .process("MetalImage/Color/MISolarizeFilter.metal"),
                .process("MetalImage/Color/MIWhiteBalanceFilter.metal"),
                .process("MetalImage/Effects/MetalImageDistortionFilter.metal"),
                .process("MetalImage/Effects/MetalImageSphereFilter.metal"),
                .process("MetalImage/Effects/MICGAColorspaceFilter.metal"),
                .process("MetalImage/Effects/MICrosshatchFilter.metal"),
                .process("MetalImage/Effects/MIJFAVoronoiFilter.metal"),
                .process("MetalImage/Effects/MIKuwaharaFilter.metal"),
                .process("MetalImage/Effects/MIKuwaharaRadius3Filter.metal"),
                .process("MetalImage/Effects/MIMosaicFilter.metal"),
                .process("MetalImage/Effects/MIPerlinNoiseFilter.metal"),
                .process("MetalImage/Effects/MIPixellateFilter.metal"),
                .process("MetalImage/Effects/MIPolarPixellateFilter.metal"),
                .process("MetalImage/Effects/MIPosterizeFilter.metal"),
                .process("MetalImage/Effects/MISwirlFilter.metal"),
                .process("MetalImage/Effects/MIVignetteFilter.metal"),
                .process("MetalImage/ImageProcessing/MI3x3ConvolutionFilter.metal"),
                .process("MetalImage/ImageProcessing/MIBilateralFilter.metal"),
                .process("MetalImage/ImageProcessing/MIColorLocalBinaryPatternFilter.metal"),
                .process("MetalImage/ImageProcessing/MIColorPackingFilter.metal"),
                .process("MetalImage/ImageProcessing/MIDilationAndErosion.metal"),
                .process("MetalImage/ImageProcessing/MIDilationFilter.metal"),
                .process("MetalImage/ImageProcessing/MIDirectionalNonMaximumSuppressionFilter.metal"),
                .process("MetalImage/ImageProcessing/MIDirectionalSobelEdgeDetectionFilter.metal"),
                .process("MetalImage/ImageProcessing/MIErosionFilter.metal"),
                .process("MetalImage/ImageProcessing/MIGaussianBlurFilter.metal"),
                .process("MetalImage/ImageProcessing/MILanczosResamplingFilter.metal"),
                .process("MetalImage/ImageProcessing/MILocalBinaryPatternFilter.metal"),
                .process("MetalImage/ImageProcessing/MIMaskBilateralFilter.metal"),
                .process("MetalImage/ImageProcessing/MIMedianFilter.metal"),
                .process("MetalImage/ImageProcessing/MINonMaximumSuppressionFilter.metal"),
                .process("MetalImage/ImageProcessing/MIPrewittEdgeDetectionFilter.metal"),
                .process("MetalImage/ImageProcessing/MIRGBDilationFilter.metal"),
                .process("MetalImage/ImageProcessing/MIRGBErosionFilter.metal"),
                .process("MetalImage/ImageProcessing/MISharpenFilter.metal"),
                .process("MetalImage/ImageProcessing/MISobelEdgeDetectionFilter.metal"),
                .process("MetalImage/ImageProcessing/MISurfaceBlurFilter.metal"),
                .process("MetalImage/ImageProcessing/MITransformFilter.metal"),
                .process("MetalImage/ImageProcessing/MIWeakPixelInclusionFilter.metal"),
                .process("MetalImage/ImageProcessing/MIXYDerivativeFilter.metal"),
                .process("MetalImage/Matrix/MetalMatrixMulti.metal"),
                .process("MetalImage/Metal/CommonShader.metal"),
                .process("MetalImage/Metal/CommonStruct.metal"),
                .process("MetalImage/Metal/Convolution.metal"),
                .process("MetalImage/MetalImageColorConversion.metal")
            ],
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath("."),
                .headerSearchPath("MetalImage")
            ],
            linkerSettings: [
                .linkedFramework("AVFoundation", .when(platforms: [.iOS])),
                .linkedFramework("Accelerate", .when(platforms: [.iOS])),
                .linkedFramework("CoreGraphics", .when(platforms: [.iOS])),
                .linkedFramework("CoreMedia", .when(platforms: [.iOS])),
                .linkedFramework("CoreVideo", .when(platforms: [.iOS])),
                .linkedFramework("Metal", .when(platforms: [.iOS])),
                .linkedFramework("MetalKit", .when(platforms: [.iOS])),
                .linkedFramework("QuartzCore", .when(platforms: [.iOS])),
                .linkedFramework("UIKit", .when(platforms: [.iOS]))
            ]
        )
    ]
)
