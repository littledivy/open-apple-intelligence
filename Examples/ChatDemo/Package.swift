// swift-tools-version: 6.0
import PackageDescription

// ChatDemo — a self-contained SwiftUI example app showing off the
// OpenFoundationModels drop-in polyfill: streaming chat + guided generation.
let package = Package(
    name: "ChatDemo",
    platforms: [
        .macOS(.v14),
    ],
    dependencies: [
        .package(path: "../.."),
    ],
    targets: [
        .executableTarget(
            name: "ChatDemo",
            dependencies: [
                .product(name: "OpenFoundationModels", package: "apple-intelligence"),
            ]
        ),
    ]
)
