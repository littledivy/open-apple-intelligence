import CoreGraphics
import Foundation
import ImageIO

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Decode encoded image bytes (PNG/JPEG/…) into a `CGImage` using ImageIO — available
/// on every Apple platform, no UIKit/AppKit required.
enum ImageDecoding {
    static func cgImage(from data: Data) throws -> CGImage {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else {
            throw ImageGenerationBackendError.decodingFailed("ImageIO could not decode \(data.count) bytes")
        }
        return image
    }

    static func cgImage(fromBase64 base64: String) throws -> CGImage {
        guard let data = Data(base64Encoded: base64, options: .ignoreUnknownCharacters) else {
            throw ImageGenerationBackendError.decodingFailed("invalid base64")
        }
        return try cgImage(from: data)
    }
}
