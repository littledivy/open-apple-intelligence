#if canImport(Vision)
import CoreGraphics
import Vision

/// A real, on-device `VisualAnalysisBackend` powered by `VNClassifyImageRequest` (semantic
/// classification labels) and `VNGenerateImageFeaturePrintRequest` (a stable content
/// fingerprint, surfaced as a `feature-print:<hash>` label).
///
/// Available wherever the Vision framework is available (iOS 16+, macOS 13+ per this
/// package's deployment targets). This is the closest functional analog to Apple's
/// on-device semantic analysis that a userspace polyfill can offer, and is the **default**
/// backend `SemanticContentDescriptor.init(analyzing:)` uses when no backend is specified.
public struct VisionBackend: VisualAnalysisBackend {
    /// Maximum number of classification labels to return, highest-confidence first.
    public let maxLabels: Int

    /// Minimum confidence (0...1) a classification must have to be included.
    public let minimumConfidence: Float

    /// Whether to also run `VNGenerateImageFeaturePrintRequest` and append a
    /// `feature-print:<hash>` label derived from it, giving callers a stable fingerprint
    /// they can use to compare/dedupe content even when classification is inconclusive.
    public let includesFeaturePrint: Bool

    public init(maxLabels: Int = 10, minimumConfidence: Float = 0.1, includesFeaturePrint: Bool = true) {
        self.maxLabels = maxLabels
        self.minimumConfidence = minimumConfidence
        self.includesFeaturePrint = includesFeaturePrint
    }

    public func analyze(_ image: CGImage) async throws -> [String] {
        var labels = try await classify(image)
        if includesFeaturePrint, let featurePrintLabel = try? await featurePrint(image) {
            labels.append(featurePrintLabel)
        }
        return labels
    }

    /// Runs `VNClassifyImageRequest` and returns confidence-filtered, confidence-sorted
    /// classification identifiers.
    private func classify(_ image: CGImage) async throws -> [String] {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNClassifyImageRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let observations = (request.results as? [VNClassificationObservation]) ?? []
                let labels = observations
                    .filter { $0.confidence >= self.minimumConfidence }
                    .sorted { $0.confidence > $1.confidence }
                    .prefix(self.maxLabels)
                    .map(\.identifier)
                continuation.resume(returning: Array(labels))
            }
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    /// Runs `VNGenerateImageFeaturePrintRequest` and encodes the resulting feature print
    /// into a short, stable `feature-print:<hash>` label.
    private func featurePrint(_ image: CGImage) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNGenerateImageFeaturePrintRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let observation = (request.results as? [VNFeaturePrintObservation])?.first else {
                    continuation.resume(throwing: VisionBackendError.noFeaturePrint)
                    return
                }
                continuation.resume(returning: "feature-print:\(Self.hash(of: observation))")
            }
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    /// Deterministically hashes a feature print's raw bytes into a short hex fingerprint.
    private static func hash(of observation: VNFeaturePrintObservation) -> String {
        var hasher = Hasher()
        observation.data.withUnsafeBytes { buffer in
            hasher.combine(bytes: buffer)
        }
        let digest = UInt(bitPattern: hasher.finalize())
        return String(format: "%016x", digest)
    }
}

enum VisionBackendError: Error {
    case noFeaturePrint
}
#endif
