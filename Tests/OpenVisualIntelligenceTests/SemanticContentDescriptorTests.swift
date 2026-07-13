import CoreGraphics
import CoreVideo
import XCTest
@testable import OpenVisualIntelligence

final class SemanticContentDescriptorTests: XCTestCase {
    func testDirectConstruction() {
        let descriptor = SemanticContentDescriptor(labels: ["dog", "animal"])
        XCTAssertEqual(descriptor.labels, ["dog", "animal"])
        XCTAssertNil(descriptor.pixelBuffer)
        XCTAssertEqual(descriptor.description, "SemanticContentDescriptor(labels: [\"dog\", \"animal\"])")
    }

    func testAnalyzingWithStubBackendRoundTrips() async throws {
        let image = try Self.makeSolidColorImage(width: 4, height: 4)
        let backend = StubVisualBackend(labels: ["cat", "pet"])

        let descriptor = try await SemanticContentDescriptor(analyzing: image, backend: backend)

        XCTAssertEqual(descriptor.labels, ["cat", "pet"])
    }

    #if canImport(Vision)
    /// Exercises the zero-config default path: `init(analyzing:)` with no explicit
    /// backend must go through the real `VisionBackend` (`VNClassifyImageRequest` +
    /// `VNGenerateImageFeaturePrintRequest`), not a stub. Vision's classifier can
    /// legitimately return nothing for a synthetic solid-color test image in a sandboxed
    /// CI environment, so we don't hard-fail on empty classification labels — but the
    /// feature-print label is deterministic Vision output and must always be present,
    /// proving the real on-device code path executed.
    func testDefaultAnalysisUsesRealVisionBackend() async throws {
        let image = try Self.makeSolidColorImage(width: 32, height: 32)

        let descriptor = try await SemanticContentDescriptor(analyzing: image)

        let hasFeaturePrint = descriptor.labels.contains { $0.hasPrefix("feature-print:") }
        XCTAssertTrue(
            hasFeaturePrint,
            "expected a feature-print label from the real VisionBackend default, got \(descriptor.labels)"
        )

        if descriptor.labels.count <= 1 {
            // Only the feature-print label came back — plausible for a featureless
            // synthetic image in a constrained sandbox. Vision classification itself
            // is not guaranteed to find anything meaningful in a flat color swatch.
            throw XCTSkip("VNClassifyImageRequest returned no labels for the synthetic test image; feature-print path still verified real Vision execution")
        }
    }
    #endif

    func testAnalyzingPreservesSuppliedPixelBuffer() async throws {
        let image = try Self.makeSolidColorImage(width: 2, height: 2)
        let pixelBuffer = try Self.makePixelBuffer(width: 2, height: 2)

        let descriptor = try await SemanticContentDescriptor(
            analyzing: image,
            backend: StubVisualBackend(labels: ["x"]),
            pixelBuffer: pixelBuffer
        )

        XCTAssertNotNil(descriptor.pixelBuffer)
    }

    // MARK: - Helpers

    private static func makeSolidColorImage(width: Int, height: Int) throws -> CGImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw TestError.setupFailed
        }
        context.setFillColor(CGColor(red: 1, green: 0, blue: 0, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        guard let image = context.makeImage() else {
            throw TestError.setupFailed
        }
        return image
    }

    private static func makePixelBuffer(width: Int, height: Int) throws -> CVPixelBuffer {
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            nil,
            &pixelBuffer
        )
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            throw TestError.setupFailed
        }
        return buffer
    }

    private enum TestError: Error {
        case setupFailed
    }
}
