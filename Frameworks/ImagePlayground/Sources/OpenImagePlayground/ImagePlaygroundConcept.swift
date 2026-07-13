import CoreGraphics
import Foundation

#if canImport(PencilKit)
import PencilKit
#endif

/// A seed for image generation: a prompt, extracted text, a drawing, or an image.
/// Mirrors `ImagePlayground.ImagePlaygroundConcept`.
public struct ImagePlaygroundConcept {
    /// How this concept contributes to the generation prompt.
    enum Kind {
        case text(String)
        case extracted(text: String, title: String?)
        case image(CGImage)
        #if canImport(PencilKit)
        case drawing(PKDrawing)
        #endif
    }

    let kind: Kind

    public static func text(_ text: String) -> ImagePlaygroundConcept {
        ImagePlaygroundConcept(kind: .text(text))
    }

    public static func extracted(from text: String, title: String? = nil) -> ImagePlaygroundConcept {
        ImagePlaygroundConcept(kind: .extracted(text: text, title: title))
    }

    public static func image(_ image: CGImage) -> ImagePlaygroundConcept {
        ImagePlaygroundConcept(kind: .image(image))
    }

    public static func image(_ url: URL) -> ImagePlaygroundConcept? {
        guard let data = try? Data(contentsOf: url),
              let image = try? ImageDecoding.cgImage(from: data)
        else { return nil }
        return ImagePlaygroundConcept(kind: .image(image))
    }

    #if canImport(PencilKit)
    public static func drawing(_ drawing: PKDrawing) -> ImagePlaygroundConcept {
        ImagePlaygroundConcept(kind: .drawing(drawing))
    }
    #endif

    // Matches the spec's @usableFromInline internal overload.
    @usableFromInline
    internal static func extracted(from text: String) -> ImagePlaygroundConcept {
        ImagePlaygroundConcept(kind: .extracted(text: text, title: nil))
    }

    /// The textual portion of this concept used to build a generation prompt.
    /// Non-text concepts (drawings/images) contribute no words here; they act as
    /// visual seeds and are handled by the backend where supported.
    var promptText: String? {
        switch kind {
        case let .text(text): return text
        case let .extracted(text, title):
            if let title, !title.isEmpty { return "\(title): \(text)" }
            return text
        case .image: return nil
        #if canImport(PencilKit)
        case .drawing: return nil
        #endif
        }
    }
}
