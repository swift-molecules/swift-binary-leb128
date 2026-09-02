// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-binary-leb128",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [

        .library(
            name: "Binary LEB128",
            targets: ["Binary LEB128"]
        ),

        .library(
            name: "Binary LEB128 Decode",
            targets: ["Binary LEB128 Decode"]
        ),
        .library(
            name: "Binary LEB128 Encode",
            targets: ["Binary LEB128 Encode"]
        ),

        .library(
            name: "Binary LEB128 Test Support",
            targets: ["Binary LEB128 Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-atoms/swift-binary.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-byte.git",
            branch: "main"
        ),
    ],
    targets: [

        .target(
            name: "Binary LEB128",
            dependencies: [
                .product(name: "Binary", package: "swift-binary")
            ]
        ),

        .target(
            name: "Binary LEB128 Decode",
            dependencies: [
                "Binary LEB128"
            ]
        ),

        .target(
            name: "Binary LEB128 Encode",
            dependencies: [
                "Binary LEB128",
                .product(name: "Byte", package: "swift-byte"),
            ]
        ),

        .target(
            name: "Binary LEB128 Test Support",
            dependencies: [
                "Binary LEB128",
                "Binary LEB128 Decode",
                "Binary LEB128 Encode",
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Binary LEB128 Tests",
            dependencies: [
                "Binary LEB128",
                "Binary LEB128 Test Support",
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
