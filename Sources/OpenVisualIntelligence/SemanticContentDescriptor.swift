import CoreGraphics
import CoreVideo
import Foundation

/// Polyfill of `VisualIntelligence.SemanticContentDescriptor`.
///
/// Apple's original type carries semantic labels for the pixel content the system camera
/// or on-screen semantic search surfaced, plus the backing pixel buffer for that content.
/// That surfacing is done by the OS (Visual Intelligence / Camera Control integration) and
/// cannot be replicated by an app; see the package README for the functional/surface split.
///
/// This polyfill keeps the same public shape (`labels`, `pixelBuffer`, `description`) and
/// adds a functional constructor: `init(analyzing:backend:)` runs a pluggable
/// ``VisualAnalysisBackend`` over a `CGImage` to populate `labels`.
public struct SemanticContentDescriptor: Sendable {
    /// Semantic labels describing the content (e.g. classification results).
    public let labels: [String]

    /// The pixel buffer backing this descriptor's content, if one is available.
    ///
    /// Apple's spec types this as `CVReadOnlyPixelBuffer?` (a noncopyable/nonescapable
    /// CoreVideo type gated behind the Swift `NonescapableTypes` feature, iOS 26+ only).
    /// That type has no polyfillable equivalent on older OSes, so this polyfill exposes
    /// the classic `CVPixelBuffer?` under the same property name instead.
    public var pixelBuffer: CVPixelBuffer? {
        _pixelBuffer
    }

    // `CVPixelBuffer` itself isn't `Sendable` (it's the mutable CoreVideo buffer type;
    // Apple's own `CVReadOnlyPixelBuffer` is the read-only, Sendable-safe counterpart used
    // by the real framework). Callers are expected to treat the buffer as read-only once
    // handed to a descriptor, mirroring that contract.
    private nonisolated(unsafe) let _pixelBuffer: CVPixelBuffer?

    /// Directly construct a descriptor from known labels and (optionally) a pixel buffer.
    public init(labels: [String], pixelBuffer: CVPixelBuffer? = nil) {
        self.labels = labels
        self._pixelBuffer = pixelBuffer
    }

    /// Functional constructor: runs `backend` over `image` to derive `labels`.
    ///
    /// This is the polyfill's on-device-analysis path, standing in for the semantic
    /// content the system would otherwise have surfaced.
    public init(analyzing image: CGImage, backend: some VisualAnalysisBackend, pixelBuffer: CVPixelBuffer? = nil) async throws {
        let labels = try await backend.analyze(image)
        self.init(labels: labels, pixelBuffer: pixelBuffer)
    }

    #if canImport(Vision)
    /// Functional constructor, zero-config: analyzes `image` with the real, on-device
    /// ``VisionBackend`` (`VNClassifyImageRequest` + `VNGenerateImageFeaturePrintRequest`).
    ///
    /// This is the default analysis path — no backend configuration required. Use
    /// `init(analyzing:backend:pixelBuffer:)` with `StubVisualBackend` only in unit tests
    /// where deterministic, offline output is required.
    public init(analyzing image: CGImage, pixelBuffer: CVPixelBuffer? = nil) async throws {
        try await self.init(analyzing: image, backend: VisionBackend(), pixelBuffer: pixelBuffer)
    }
    #endif
}

extension SemanticContentDescriptor: CustomStringConvertible {
    public var description: String {
        "SemanticContentDescriptor(labels: \(labels))"
    }
}
