// swift-tools-version: 6.0
import PackageDescription

// OpenVisualIntelligence — drop-in polyfill for Apple's VisualIntelligence framework.
// Users swap `import VisualIntelligence` → `import OpenVisualIntelligence`; the public
// type surface matches, so code compiles unchanged on OSes older than iOS 26 / macOS 26
// or on Apple-Intelligence-ineligible hardware.
//
// HONEST SCOPE: Apple's VisualIntelligence is built on system camera / on-screen semantic
// search integration that hooks deep into the OS — that system integration is NOT
// polyfillable in userspace. This package provides the full public type surface
// (SemanticContentDescriptor) so dependent code compiles, plus a *functional* analysis
// path via a pluggable VisualAnalysisBackend (with a Vision-backed implementation on
// platforms where Vision is available). See README.md for the functional/surface split.
let package = Package(
    name: "OpenVisualIntelligence",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(name: "OpenVisualIntelligence", targets: ["OpenVisualIntelligence"]),
    ],
    targets: [
        .target(
            name: "OpenVisualIntelligence"
        ),
        .testTarget(
            name: "OpenVisualIntelligenceTests",
            dependencies: ["OpenVisualIntelligence"]
        ),
    ]
)
