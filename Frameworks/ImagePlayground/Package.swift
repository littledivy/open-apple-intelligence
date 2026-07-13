// swift-tools-version: 6.0
import PackageDescription

// OpenImagePlayground — drop-in polyfill for Apple's ImagePlayground framework.
// Users swap `import ImagePlayground` → `import OpenImagePlayground`; the public API
// names/signatures match Apple's, so the rest of their code is unchanged. Apple gates
// image generation behind Apple Intelligence on new OSes; this polyfill runs on OLD
// OSes by routing generation to a configured image backend (OpenAI-compatible
// `/v1/images/generations`, or a custom one), with a deterministic stub for tests.
//
// Independent of the core LLM package: ImagePlayground needs IMAGE generation, not text.
let package = Package(
    name: "OpenImagePlayground",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(name: "OpenImagePlayground", targets: ["OpenImagePlayground"]),
    ],
    dependencies: [
        // Apple's Core ML Stable Diffusion — the REAL on-device generation pipeline that
        // backs `ImageCreator` by default (zero external config). Runs entirely on-device
        // (Neural Engine / GPU) via Core ML; no server. macOS 13+/iOS 16+ compatible,
        // matching this package's platforms.
        .package(url: "https://github.com/apple/ml-stable-diffusion.git", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "OpenImagePlayground",
            dependencies: [
                .product(name: "StableDiffusion", package: "ml-stable-diffusion"),
            ]
        ),
        .testTarget(
            name: "OpenImagePlaygroundTests",
            dependencies: ["OpenImagePlayground"]
        ),
    ]
)
