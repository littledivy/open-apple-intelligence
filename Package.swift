// swift-tools-version: 6.1
import PackageDescription
import CompilerPluginSupport

// apple-intelligence — a single SwiftPM package that vends drop-in polyfills for Apple's
// Apple Intelligence frameworks as individual library products. Add one dependency:
//
//     .package(url: "https://github.com/littledivy/apple-intelligence", from: "…")
//
// …and depend on whichever `Open*` product you need. Users swap
// `import FoundationModels` → `import OpenFoundationModels` (and friends); the API names
// match, so the rest of their code is unchanged.
//
// HEAVY ON-DEVICE BACKENDS ARE TRAIT-GATED (SE-0450 package traits) so a default
// `swift build` stays dep-light and does NOT clone the large MLX / Core ML Stable
// Diffusion dependency trees:
//
//   • MLX             — enables the in-process MLX LLM backend (mlx-swift-examples).
//                       `swift build --traits MLX`
//   • CoreMLDiffusion — enables the on-device Core ML Stable Diffusion image backend
//                       (apple/ml-stable-diffusion). `swift build --traits CoreMLDiffusion`
//
// With the traits off, `OpenFoundationModelsMLX` compiles as an (empty) present module and
// `OpenImagePlayground` still works via its HTTP / OpenAI-compatible image backend.
let package = Package(
    name: "apple-intelligence",
    platforms: [
        .iOS(.v16),
        .macOS(.v14),
        .visionOS(.v1),
        .tvOS(.v16),
        .watchOS(.v9),
    ],
    products: [
        .library(name: "OpenFoundationModels", targets: ["OpenFoundationModels"]),
        .library(name: "OpenWritingTools", targets: ["OpenWritingTools"]),
        .library(name: "OpenImagePlayground", targets: ["OpenImagePlayground"]),
        .library(name: "OpenVisualIntelligence", targets: ["OpenVisualIntelligence"]),
        .library(name: "OpenAppIntentsAssistant", targets: ["OpenAppIntentsAssistant"]),
        .library(name: "OpenFoundationModelsMLX", targets: ["OpenFoundationModelsMLX"]),
    ],
    traits: [
        // Enables the in-process on-device MLX LLM backend (Apple Silicon). Off by default
        // so `mlx-swift-examples` (+ its swift-jinja pin) are not resolved for normal builds.
        .trait(
            name: "MLX",
            description: "On-device MLX LLM backend for OpenFoundationModelsMLX (Apple Silicon)."
        ),
        // Enables the on-device Core ML Stable Diffusion image backend. Off by default so
        // `apple/ml-stable-diffusion` is not resolved for normal builds.
        .trait(
            name: "CoreMLDiffusion",
            description: "On-device Core ML Stable Diffusion backend for OpenImagePlayground."
        ),
    ],
    dependencies: [
        // Always-on: powers the @Generable/@Guide and @AssistantIntent macros. Light.
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0"),

        // TRAIT-GATED (MLX): the last released series that still ships MLXLLM / MLXLMCommon
        // SwiftPM products (`main` and 2.29.x dropped them). Only resolved when the `MLX`
        // trait is enabled — the target's product references below are `.when(traits:["MLX"])`,
        // so a default build never clones this tree.
        .package(url: "https://github.com/ml-explore/mlx-swift-examples", .upToNextMinor(from: "2.25.9")),
        // Pin swift-jinja to a pre-traits (tools-version < 6.0) release so SwiftPM does not
        // disable default traits on swift-transformers 1.0.0 (which declares none), which
        // otherwise fails resolution with a "disabled default traits" error. Part of the MLX
        // dependency tree; only pulled in when `MLX` is enabled.
        .package(url: "https://github.com/huggingface/swift-jinja.git", "2.0.0" ..< "2.1.0"),

        // TRAIT-GATED (CoreMLDiffusion): Apple's Core ML Stable Diffusion — the real on-device
        // generation pipeline. Only resolved when the `CoreMLDiffusion` trait is enabled.
        .package(url: "https://github.com/apple/ml-stable-diffusion.git", from: "1.1.0"),
    ],
    targets: [
        // MARK: OpenFoundationModels (core) + its macros

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

        // MARK: OpenWritingTools

        .target(
            name: "OpenWritingTools",
            dependencies: ["OpenFoundationModels"]
        ),

        // MARK: OpenImagePlayground (Core ML Stable Diffusion backend trait-gated)

        .target(
            name: "OpenImagePlayground",
            dependencies: [
                // The Core ML SD pipeline is only linked when `CoreMLDiffusion` is enabled.
                // The rest of the module (HTTP / OpenAI / stub backends) is always available.
                .product(
                    name: "StableDiffusion",
                    package: "ml-stable-diffusion",
                    condition: .when(traits: ["CoreMLDiffusion"])
                ),
            ]
        ),

        // MARK: OpenVisualIntelligence (no external deps)

        .target(
            name: "OpenVisualIntelligence"
        ),

        // MARK: OpenAppIntentsAssistant + its macros

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
                "OpenFoundationModels",
            ]
        ),

        // MARK: OpenFoundationModelsMLX (MLX backend trait-gated)

        .target(
            name: "OpenFoundationModelsMLX",
            dependencies: [
                "OpenFoundationModels",
                // MLXLLM / MLXLMCommon are only linked when `MLX` is enabled. When off, the
                // module still builds (its MLX-using source is wrapped in `#if MLX`).
                .product(
                    name: "MLXLLM",
                    package: "mlx-swift-examples",
                    condition: .when(traits: ["MLX"])
                ),
                .product(
                    name: "MLXLMCommon",
                    package: "mlx-swift-examples",
                    condition: .when(traits: ["MLX"])
                ),
                // The MLX dependency tree resolves swift-transformers, whose swift-jinja
                // dependency must be pinned to a pre-traits release (see the `swift-jinja`
                // package dependency note above). Referencing `Jinja` here — only under the
                // `MLX` trait — makes that pin a trait-referenced dependency so a default
                // build prunes it (an unreferenced package dependency is always cloned).
                .product(
                    name: "Jinja",
                    package: "swift-jinja",
                    condition: .when(traits: ["MLX"])
                ),
            ]
        ),

        // MARK: Tests

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
        .testTarget(
            name: "WritingToolsTests",
            dependencies: [
                "OpenWritingTools",
                "OpenFoundationModels",
            ]
        ),
        .testTarget(
            name: "OpenImagePlaygroundTests",
            dependencies: ["OpenImagePlayground"]
        ),
        .testTarget(
            name: "OpenVisualIntelligenceTests",
            dependencies: ["OpenVisualIntelligence"]
        ),
        .testTarget(
            name: "OpenAppIntentsAssistantTests",
            dependencies: [
                "OpenAppIntentsAssistant",
                "OpenFoundationModels",
            ]
        ),
        .testTarget(
            name: "OpenFoundationModelsMLXTests",
            dependencies: ["OpenFoundationModelsMLX"]
        ),
    ]
)
