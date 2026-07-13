// swift-tools-version: 6.0
import PackageDescription

// OpenWritingTools — a drop-in polyfill for Apple's Writing Tools + Genmoji
// (the Apple-Intelligence-gated UIKit surface). It mirrors the UIKit type/enum
// names (strip availability gating) so host code compiles on older OSes, and it
// backs the *text transforms* with the sibling `OpenFoundationModels` polyfill as
// the LLM engine. The system-UI parts (responder-chain inline editing, on-device
// glyph generation) are not polyfillable off-device; those are provided as a
// source-compatible surface plus practical, working host helpers.
let package = Package(
    name: "OpenWritingTools",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(name: "OpenWritingTools", targets: ["OpenWritingTools"]),
    ],
    dependencies: [
        .package(path: "../.."),
    ],
    targets: [
        .target(
            name: "OpenWritingTools",
            dependencies: [
                .product(name: "OpenFoundationModels", package: "apple-intelligence"),
            ]
        ),
        .testTarget(
            name: "WritingToolsTests",
            dependencies: [
                "OpenWritingTools",
                .product(name: "OpenFoundationModels", package: "apple-intelligence"),
            ]
        ),
    ]
)
