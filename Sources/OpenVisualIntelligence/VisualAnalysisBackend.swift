import CoreGraphics

/// Pluggable image analysis used by ``SemanticContentDescriptor/init(analyzing:backend:pixelBuffer:)``
/// to derive semantic labels for an image, standing in for the on-device semantic content
/// analysis Apple's real VisualIntelligence framework performs as part of system camera /
/// on-screen semantic search integration.
public protocol VisualAnalysisBackend: Sendable {
    /// Analyze `image` and return semantic labels (e.g. classification results), most
    /// confident first.
    func analyze(_ image: CGImage) async throws -> [String]
}

/// A deterministic, offline `VisualAnalysisBackend` for tests and previews.
///
/// Always returns the labels it was configured with, regardless of the image passed in.
public struct StubVisualBackend: VisualAnalysisBackend {
    private let labels: [String]

    public init(labels: [String] = ["stub"]) {
        self.labels = labels
    }

    public func analyze(_ image: CGImage) async throws -> [String] {
        labels
    }
}
