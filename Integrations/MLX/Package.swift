// swift-tools-version: 6.0
import PackageDescription

// OpenFoundationModelsMLX — TRUE on-device inference for OpenFoundationModels via
// Apple's MLX (runs in-process on Apple Silicon: M-series Macs, A-series iPhones/iPads).
// Kept in a SEPARATE sibling package so the core OpenFoundationModels stays dep-light
// (swift-syntax only) and Linux-buildable. Depends on the core by path.
let package = Package(
    name: "OpenFoundationModelsMLX",
    platforms: [
        .macOS(.v14),
        .iOS(.v16),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "OpenFoundationModelsMLX", targets: ["OpenFoundationModelsMLX"]),
    ],
    dependencies: [
        .package(path: "../.."),
        // Pin to the 2.25.x line: it is the last released series that still ships the
        // MLXLLM / MLXLMCommon SwiftPM products. `main` and 2.29.x dropped them.
        .package(url: "https://github.com/ml-explore/mlx-swift-examples", .upToNextMinor(from: "2.25.9")),
        // Pin swift-jinja to a pre-traits (tools-version < 6.0) release so SwiftPM does
        // not disable default traits on swift-transformers 1.0.0 (which declares none),
        // which otherwise fails resolution with a "disabled default traits" error.
        .package(url: "https://github.com/huggingface/swift-jinja.git", "2.0.0" ..< "2.1.0"),
    ],
    targets: [
        .target(
            name: "OpenFoundationModelsMLX",
            dependencies: [
                .product(name: "OpenFoundationModels", package: "apple-intelligence"),
                .product(name: "MLXLLM", package: "mlx-swift-examples"),
                .product(name: "MLXLMCommon", package: "mlx-swift-examples"),
            ]
        ),
        .testTarget(
            name: "OpenFoundationModelsMLXTests",
            dependencies: ["OpenFoundationModelsMLX"]
        ),
    ]
)
