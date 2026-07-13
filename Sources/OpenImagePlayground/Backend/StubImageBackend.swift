import CoreGraphics
import Foundation

/// Offline, deterministic backend for tests and previews. Returns `count` solid-color
/// `CGImage`s (no network), so `ImageCreator` behaviour can be asserted without a
/// real endpoint or Apple Intelligence.
public final class StubImageBackend: ImageGenerationBackend, @unchecked Sendable {
    public let identifier = "stub-image"
    private let width: Int
    private let height: Int
    private let color: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)

    public init(
        width: Int = 64,
        height: Int = 64,
        color: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) = (0.2, 0.5, 0.9, 1.0)
    ) {
        self.width = width
        self.height = height
        self.color = color
    }

    public func generate(prompt: String, style: ImagePlaygroundStyle, count: Int) async throws -> [CGImage] {
        (0..<max(1, count)).map { _ in Self.solidColorImage(width, height, color) }
    }

    static func solidColorImage(
        _ width: Int,
        _ height: Int,
        _ color: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)
    ) -> CGImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        context.setFillColor(red: color.r, green: color.g, blue: color.b, alpha: color.a)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        return context.makeImage()!
    }
}
