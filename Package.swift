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
        .package(path: "../swift-binary-primitives"),
    ],
    targets: [
        .target(
            name: "Binary LEB128 Primitives",
            dependencies: [
                .product(name: "Binary Namespace", package: "swift-binary-primitives"),
            ]
        ),
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
