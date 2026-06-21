// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MetalImage",
    platforms: [
        .iOS(.v15)
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
            exclude: ["Info.plist"],
            resources: [
                .process("Blend.metal"),
                .process("MIAdaptiveLuminanceFilter.metal"),
                .process("MIAdaptiveThresholdFilter.metal"),
                .process("MIBrightnessFilter.metal"),
                .process("MIChromaKeyFilter.metal"),
                .process("MIColorInvertFilter.metal"),
                .process("MIColorMatrixFilter.metal"),
                .process("MIContrastFilter.metal"),
                .process("MIExposureFilter.metal"),
                .process("MIFalseColorFilter.metal"),
                .process("MIGammaFilter.metal"),
                .process("MIGrayscaleFilter.metal"),
                .process("MIHazeFilter.metal"),
                .process("MIHighlightShadowFilter.metal"),
                .process("MIHistogramGenerator.metal"),
                .process("MIHSBFilter.metal"),
                .process("MIHueFilter.metal"),
                .process("MILevelsFilter.metal"),
                .process("MILookupFilter.metal"),
                .process("MILuminanceRangeFilter.metal"),
                .process("MILuminanceThresholdFilter.metal"),
                .process("MIMonochromeFilter.metal"),
                .process("MIOpacityFilter.metal"),
                .process("MIRGBFilter.metal"),
                .process("MISaturationFilter.metal"),
                .process("MISolarizeFilter.metal"),
                .process("MIWhiteBalanceFilter.metal"),
                .process("MetalImageDistortionFilter.metal"),
                .process("MetalImageSphereFilter.metal"),
                .process("MICGAColorspaceFilter.metal"),
                .process("MICrosshatchFilter.metal"),
                .process("MIJFAVoronoiFilter.metal"),
                .process("MIKuwaharaFilter.metal"),
                .process("MIKuwaharaRadius3Filter.metal"),
                .process("MIMosaicFilter.metal"),
                .process("MIPerlinNoiseFilter.metal"),
                .process("MIPixellateFilter.metal"),
                .process("MIPolarPixellateFilter.metal"),
                .process("MIPosterizeFilter.metal"),
                .process("MISwirlFilter.metal"),
                .process("MIVignetteFilter.metal"),
                .process("MI3x3ConvolutionFilter.metal"),
                .process("MIBilateralFilter.metal"),
                .process("MIColorLocalBinaryPatternFilter.metal"),
                .process("MIColorPackingFilter.metal"),
                .process("MIDilationAndErosion.metal"),
                .process("MIDilationFilter.metal"),
                .process("MIDirectionalNonMaximumSuppressionFilter.metal"),
                .process("MIDirectionalSobelEdgeDetectionFilter.metal"),
                .process("MIErosionFilter.metal"),
                .process("MIGaussianBlurFilter.metal"),
                .process("MILanczosResamplingFilter.metal"),
                .process("MILocalBinaryPatternFilter.metal"),
                .process("MIMaskBilateralFilter.metal"),
                .process("MIMedianFilter.metal"),
                .process("MINonMaximumSuppressionFilter.metal"),
                .process("MIPrewittEdgeDetectionFilter.metal"),
                .process("MIRGBDilationFilter.metal"),
                .process("MIRGBErosionFilter.metal"),
                .process("MISharpenFilter.metal"),
                .process("MISobelEdgeDetectionFilter.metal"),
                .process("MISurfaceBlurFilter.metal"),
                .process("MITransformFilter.metal"),
                .process("MIWeakPixelInclusionFilter.metal"),
                .process("MIXYDerivativeFilter.metal"),
                .process("MetalMatrixMulti.metal"),
                .process("CommonShader.metal"),
                .process("CommonStruct.metal"),
                .process("Convolution.metal"),
                .process("MetalImageColorConversion.metal")
            ],
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath("."),
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
