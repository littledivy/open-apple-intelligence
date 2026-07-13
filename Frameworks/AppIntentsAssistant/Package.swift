// swift-tools-version: 6.0
import PackageDescription
import CompilerPluginSupport

// OpenAppIntentsAssistant — source-compatibility polyfill for Apple's AppIntents
// "Assistant Schemas" layer (the Apple-Intelligence / Siri subset). The AppIntents
// framework itself ships everywhere; only the *assistant schema* macros and types
// (`@AssistantIntent`, `@AssistantEntity`, `@AssistantEnum`, `AssistantSchema`,
// `AssistantSchemas.*`) are gated to newer OSes. This package mirrors that surface,
// with `@available` gating stripped, so code annotated with the assistant schema
// macros COMPILES on older deployment targets.
//
// IMPORTANT: this is SOURCE compatibility, not runtime parity. The macros expand to
// minimal conformances / pass-throughs; the real behavior (routing to the system
// Siri / Assistant) is system-side and NOT polyfillable. See README.
let package = Package(
    name: "OpenAppIntentsAssistant",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(name: "OpenAppIntentsAssistant", targets: ["OpenAppIntentsAssistant"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0"),
        // Optional functional bonus: the LocalAssistant router uses the sibling
        // OpenFoundationModels package for guided generation.
        .package(path: "../.."),
    ],
    targets: [
        // The @AssistantIntent / @AssistantEntity / @AssistantEnum macro implementations.
        .macro(
            name: "OpenAppIntentsAssistantMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "OpenAppIntentsAssistant",
            dependencies: [
                "OpenAppIntentsAssistantMacros",
                .product(name: "OpenFoundationModels", package: "apple-intelligence"),
            ]
        ),
        .testTarget(
            name: "OpenAppIntentsAssistantTests",
            dependencies: [
                "OpenAppIntentsAssistant",
                .product(name: "OpenFoundationModels", package: "apple-intelligence"),
            ]
        ),
    ]
)
