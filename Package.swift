// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-binary-leb128-primitives",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [

        .library(
            name: "Binary LEB128 Primitive",
            targets: ["Binary LEB128 Primitive"]
        ),

        .library(
            name: "Binary LEB128 Decode Primitives",
            targets: ["Binary LEB128 Decode Primitives"]
        ),
        .library(
            name: "Binary LEB128 Encode Primitives",
            targets: ["Binary LEB128 Encode Primitives"]
        ),

        .library(
            name: "Binary LEB128 Primitives",
            targets: ["Binary LEB128 Primitives"]
        ),

        .library(
            name: "Binary LEB128 Primitives Test Support",
            targets: ["Binary LEB128 Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-primitives/swift-binary-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-byte-primitives.git",
            branch: "main"
        ),
    ],
    targets: [

        .target(
            name: "Binary LEB128 Primitive",
            dependencies: [
                .product(name: "Binary Primitive", package: "swift-binary-primitives")
            ]
        ),

        .target(
            name: "Binary LEB128 Decode Primitives",
            dependencies: [
                "Binary LEB128 Primitive"
            ]
        ),

        .target(
            name: "Binary LEB128 Encode Primitives",
            dependencies: [
                "Binary LEB128 Primitive",
                .product(name: "Byte Primitives", package: "swift-byte-primitives"),
            ]
        ),

        .target(
            name: "Binary LEB128 Primitives",
            dependencies: [
                "Binary LEB128 Primitive",
                "Binary LEB128 Decode Primitives",
                "Binary LEB128 Encode Primitives",
            ]
        ),

        .target(
            name: "Binary LEB128 Primitives Test Support",
            dependencies: [
                "Binary LEB128 Primitives"
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Binary LEB128 Primitives Tests",
            dependencies: [
                "Binary LEB128 Primitives",
                "Binary LEB128 Primitives Test Support",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
