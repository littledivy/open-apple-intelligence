// swift-tools-version: 6.0
import PackageDescription
import CompilerPluginSupport

// OpenFoundationModels — drop-in polyfill for Apple's FoundationModels framework.
// Users swap `import FoundationModels` → `import OpenFoundationModels`; the API names
// match, so the rest of their code is unchanged. On eligible hardware we delegate to
// Apple's real on-device model; elsewhere we route to a configured backend
// (local llama.cpp / OpenAI-compatible / custom).
let package = Package(
    name: "OpenFoundationModels",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .visionOS(.v1),
        .tvOS(.v16),
        .watchOS(.v9),
    ],
    products: [
        .library(name: "OpenFoundationModels", targets: ["OpenFoundationModels"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0"),
    ],
    targets: [
        // The @Generable / @Guide macro implementations.
        .macro(
            name: "OpenFoundationModelsMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "OpenFoundationModels",
            dependencies: ["OpenFoundationModelsMacros"]
        ),
        .testTarget(
            name: "OpenFoundationModelsTests",
            dependencies: ["OpenFoundationModels"]
        ),
        .testTarget(
            name: "OpenFoundationModelsMacrosTests",
            dependencies: [
                "OpenFoundationModelsMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
