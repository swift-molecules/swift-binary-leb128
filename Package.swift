// swift-tools-version: 6.3.1

import PackageDescription

let package = Package(
    name: "swift-binary-leb128-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        // MARK: - Namespace + Error (root)
        .library(
            name: "Binary LEB128 Primitive",
            targets: ["Binary LEB128 Primitive"]
        ),

        // MARK: - Codec mechanism
        .library(
            name: "Binary LEB128 Decode Primitives",
            targets: ["Binary LEB128 Decode Primitives"]
        ),
        .library(
            name: "Binary LEB128 Encode Primitives",
            targets: ["Binary LEB128 Encode Primitives"]
        ),

        // MARK: - Umbrella
        .library(
            name: "Binary LEB128 Primitives",
            targets: ["Binary LEB128 Primitives"]
        ),

        // MARK: - Test Support
        .library(
            name: "Binary LEB128 Primitives Test Support",
            targets: ["Binary LEB128 Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-binary-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-byte-primitives.git", branch: "main"),
    ],
    targets: [
        // MARK: - Namespace + Error (root; zero external deps beyond the Binary anchor per [MOD-017])
        .target(
            name: "Binary LEB128 Primitive",
            dependencies: [
                .product(name: "Binary Primitive", package: "swift-binary-primitives"),
            ]
        ),

        // MARK: - Decode core (the shared, bit-width-parameterized decode arithmetic)
        .target(
            name: "Binary LEB128 Decode Primitives",
            dependencies: [
                "Binary LEB128 Primitive",
            ]
        ),

        // MARK: - Encode (serializer)
        .target(
            name: "Binary LEB128 Encode Primitives",
            dependencies: [
                "Binary LEB128 Primitive",
                .product(name: "Byte Primitives", package: "swift-byte-primitives"),
            ]
        ),

        // MARK: - Umbrella
        .target(
            name: "Binary LEB128 Primitives",
            dependencies: [
                "Binary LEB128 Primitive",
                "Binary LEB128 Decode Primitives",
                "Binary LEB128 Encode Primitives",
            ]
        ),

        // MARK: - Test Support
        .target(
            name: "Binary LEB128 Primitives Test Support",
            dependencies: [
                "Binary LEB128 Primitives",
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
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
