# MetalImage

MetalImage is an iOS image and video processing framework built on **Apple Metal**.  
It follows the chaining style of GPUImage, but replaces the OpenGL ES rendering path with Metal and ships a large set of filters, blend modes, and image-processing operators.

## Highlights

- **Metal-based rendering pipeline** for camera, image, and intermediate texture processing
- **Chainable node model** built around `MetalImageOutput` -> `MetalImageInput`
- **Real-time camera processing** via `MetalImageVideoCamera`
- **On-screen rendering** via `MetalImageView` / `MetalImageDebugView`
- **Static image processing** via `MetalImagePicture`
- **Rich built-in filters**, including:
  - Color adjustment: `MIBrightnessFilter`, `MIContrastFilter`, `MISaturationFilter`, `MILookupFilter`
  - Image processing: `MIGaussianBlurFilter`, `MIBilateralFilter`, `MIMedianFilter`, `MICannyEdgeDetectionFilter`
  - Blend filters: `MIOverlayBlendFilter`, `MIScreenBlendFilter`, `MIAlphaBlendFilter`
  - Effects: `MISwirlFilter`, `MIPixellateFilter`, `MIVignetteFilter`, `MIKuwaharaFilter`
  - Matrix helpers: `MetalMatrixMult`, `BlasMatrixMult`

All public headers are exported through:

```objc
#import <MetalImage/MetalImage.h>
```

## Requirements

| Item | Requirement |
| --- | --- |
| Platform | iOS |
| Deployment target | iOS 13.0+ |
| Hardware | Metal-capable physical device |
| Architecture | arm64 device runtime |
| Camera features | Require camera permission and supported hardware |

> The framework does **not** support the iOS Simulator.

## Project Layout

```text
MetalImage.xcodeproj                       Xcode project
Package.swift                              Swift Package Manager manifest
Framework/MetalImage/                      All framework sources, headers,
                                           shaders and resources (flat layout)
Framework/MetalImage/default.metallib      Prebuilt shader library for SPM
Scripts/build-metallib.sh                  Regenerates default.metallib
Example/MetalImageDemo/                    Demo app sources and assets
Tests/MetalImageTests/                     Unit tests
MetalImageShader                           Metal shader library target (Xcode)
```

> After changing any `.metal` file, run `Scripts/build-metallib.sh` and commit
> the regenerated `default.metallib` so the SwiftPM integration keeps working.

## Getting Started

This repository now separates the reusable framework code from the runnable example:

- `Framework/MetalImage/`: headers, sources, resources, and framework plist
- `Example/MetalImageDemo/`: app entry, UI, assets, and example plist

You can integrate `MetalImage` in two ways:

1. **Swift Package Manager**
   - In Xcode, choose **Add Package Dependencies...**
   - Use this repository URL
   - Link the `MetalImage` product to your iOS app target
2. **Open the sample project**
   - Open `MetalImage.xcodeproj`
   - Select the `MetalImageDemo` scheme and a physical iOS device
   - Build and run

SwiftPM support is source-based and packages the framework's Metal shaders with the target. Camera-based features still require `NSCameraUsageDescription`, and runtime use still targets Metal-capable iOS devices rather than the simulator.

## Basic Usage

### Process a still image

```objc
#import <MetalImage/MetalImage.h>

UIImage *image = [UIImage imageNamed:@"sample"];
MetalImagePicture *source = [[MetalImagePicture alloc] initWithImage:image];

MIBrightnessFilter *brightness = [[MIBrightnessFilter alloc] init];
brightness.brightness = 0.1;

MIGaussianBlurFilter *blur = [[MIGaussianBlurFilter alloc] init];
blur.radius = 4;

MetalImageView *renderView = [[MetalImageView alloc] initWithFrame:self.view.bounds];
[self.view addSubview:renderView];

[source addTarget:brightness];
[brightness addTarget:blur];
[blur addTarget:renderView];

[source processImage];
```

### Process camera frames in real time

```objc
#import <MetalImage/MetalImage.h>

MetalImageView *renderView = [[MetalImageView alloc] initWithFrame:self.view.bounds];
renderView.fillMode = kMetalImageFillModePreserveAspectRatio;
[self.view addSubview:renderView];

MetalImageVideoCamera *camera =
    [[MetalImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720
                                          cameraPosition:AVCaptureDevicePositionFront];
camera.outputImageOrientation = UIInterfaceOrientationPortrait;
camera.horizontallyMirrorFrontFacingCamera = YES;

MIBilateralFilter *bilateral = [[MIBilateralFilter alloc] init];
MIMedianFilter *median = [[MIMedianFilter alloc] init];

[camera addTarget:bilateral];
[bilateral addTarget:median];
[median addTarget:renderView];

[camera startCameraCapture];
```

### Two-input filters

For filters derived from `MetalImageTwoInputFilter` such as `MILookupFilter`, use `addTarget:atTextureLocation:` to bind the secondary texture input.

## Core Types

| Type | Role |
| --- | --- |
| `MetalImageOutput` | Upstream node that produces textures |
| `MetalImageInput` | Consumer protocol for downstream nodes |
| `MetalImageFilter` | Base class for most single-input filters |
| `MetalImageTwoInputFilter` | Base class for blend / LUT / dual-texture filters |
| `MetalImageFilterGroup` | Composite pipeline wrapper |
| `MetalImagePicture` | Static image source |
| `MetalImageVideoCamera` | Camera frame source |
| `MetalImageView` | Final display view |

## Notes

- The demo app shows the intended real-time filter-chain usage.
- `MetalImageDebugView` can be used when you need a debug-oriented render target.
- Most filters map one-to-one to a `.metal` shader file in the repository, which makes extension straightforward.

## Author

Feng Shi  
redpark@qq.com

## License

MIT. See [LICENSE](./LICENSE).
