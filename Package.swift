// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MetalImage",
    platforms: [
        .iOS(.v13)
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
            exclude: ["Info.plist", "default.metallib"],
            resources: [
                
                .process("lookup.png"),
                .process("lookup_amatorka.png"),
                .process("lookup_miss_etikate.png"),
                .process("lookup_soft_elegance_1.png"),
                .process("lookup_soft_elegance_2.png"),
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
