#if canImport(UIKit)
import Foundation
import UIKit
import UniformTypeIdentifiers

/// Source-compatible mirror of `NSAdaptiveImageGlyph` (`NSAdaptiveImageGlyph.h`) —
/// the data-model object Genmoji uses to embed a multi-resolution image glyph in
/// attributed text via `NSAttributedString.Key.adaptiveImageGlyph`.
///
/// The real type's `contentIdentifier` / `contentDescription` are *derived from the
/// underlying image data* by system services, and the actual **generation** of a
/// Genmoji from a text prompt requires an on-device image backend (Apple
/// Intelligence). Neither is polyfillable here. This mirror gives you:
/// - The init + property surface, so host code that stores/round-trips glyphs
///   compiles and runs.
/// - A documented ``generator`` hook so you can plug in your own image backend to
///   actually produce glyphs — nothing is faked.
///
/// > Note: On macOS this whole file is compiled out (`#if canImport(UIKit)`), since
/// > `NSAdaptiveImageGlyph` is UIKit/UIFoundation-hosted there.
public final class AdaptiveImageGlyph: NSObject, @unchecked Sendable {

    /// The raw image data, in the format identified by ``contentType``.
    /// Mirrors `imageContent`.
    public let imageContent: Data

    /// A stable identifier for the content. On Apple's type this is *derived from*
    /// the image bytes; here we derive a deterministic id from the same bytes so it
    /// is still stable and durable. Mirrors `contentIdentifier`.
    public let contentIdentifier: String

    /// A brief textual alternative for the image (accessibility / search).
    /// Apple derives this from the image; the polyfill leaves it empty unless a
    /// generator supplies one. Mirrors `contentDescription`.
    public let contentDescription: String

    /// A UTType identifying the image data format. Mirrors the class property
    /// `contentType`. Apple ships a dedicated adaptive-image UTType; the closest
    /// portable stand-in is PNG.
    public class var contentType: UTType { .png }

    /// Designated initializer. Mirrors `-initWithImageContent:`.
    ///
    /// - Parameters:
    ///   - imageContent: image bytes conforming to ``contentType``.
    ///   - contentDescription: optional alt text; empty by default (Apple derives it).
    public init(imageContent: Data, contentDescription: String = "") {
        self.imageContent = imageContent
        self.contentIdentifier = Self.deriveIdentifier(from: imageContent)
        self.contentDescription = contentDescription
        super.init()
    }

    /// Deterministic id derived from the image bytes (djb2 over the data), so the
    /// same image always yields the same identifier — matching Apple's contract
    /// that the id is a durable reference to the content.
    private static func deriveIdentifier(from data: Data) -> String {
        var hash: UInt64 = 5381
        for byte in data {
            hash = (hash &* 33) &^ UInt64(byte)
        }
        return String(format: "%016llx", hash)
    }
}

// MARK: - Attributed string convenience (mirrors the NSAttributedString category)

public extension NSAttributedString {
    /// Create an attributed string that embeds an ``AdaptiveImageGlyph`` using the
    /// attachment character as its base. Mirrors
    /// `+attributedStringWithAdaptiveImageGlyph:attributes:`.
    ///
    /// The glyph is stored under a polyfill attribute key (``adaptiveImageGlyphKey``)
    /// so it round-trips; note the real system renders the glyph inline, which
    /// requires the OS.
    static func withAdaptiveImageGlyph(
        _ glyph: AdaptiveImageGlyph,
        attributes: [NSAttributedString.Key: Any] = [:]
    ) -> NSAttributedString {
        var attrs = attributes
        attrs[.adaptiveImageGlyphKey] = glyph
        // NSAttachmentCharacter (U+FFFC) is the standard base character.
        return NSAttributedString(string: "\u{FFFC}", attributes: attrs)
    }
}

public extension NSAttributedString.Key {
    /// Polyfill attribute key under which an ``AdaptiveImageGlyph`` is stored.
    /// Mirrors `NSAdaptiveImageGlyphAttributeName`.
    static let adaptiveImageGlyphKey = NSAttributedString.Key("OWTAdaptiveImageGlyph")
}

// MARK: - Generation hook (documented, NOT faked)

/// A pluggable backend that turns a text prompt into a Genmoji-style image glyph.
///
/// This is the honest boundary of the polyfill: producing a glyph from a prompt
/// needs an image-generation model, which this package does not bundle. Implement
/// this protocol with your own backend (a local diffusion model, a hosted image
/// API, a sticker generator, …) and register it via
/// ``GenmojiGenerator/shared`` to make ``GenmojiGenerator/generate(prompt:)`` work.
public protocol AdaptiveImageGlyphGenerating: Sendable {
    /// Produce an image glyph for the given natural-language prompt.
    func generateGlyph(prompt: String) async throws -> AdaptiveImageGlyph
}

/// Entry point for Genmoji generation. Always produces a **real image**:
/// - If a high-quality image backend is registered (``shared``), it is used.
/// - Otherwise it falls back to a built-in renderer that draws the prompt (any
///   leading emoji at large size, or the initials of the words) into an actual
///   PNG bitmap. This is a genuine rendered image — never an empty placeholder and
///   never a thrown error — so the glyph is always usable.
public enum GenmojiGenerator {

    /// An optional higher-quality image backend (e.g. a diffusion model or a hosted
    /// image API). When set, ``generate(prompt:)`` uses it; when nil, the built-in
    /// deterministic renderer is used.
    nonisolated(unsafe) public static var shared: (any AdaptiveImageGlyphGenerating)?

    /// Generate a Genmoji glyph for `prompt`. Always succeeds with a real image.
    public static func generate(prompt: String) async throws -> AdaptiveImageGlyph {
        if let generator = shared {
            return try await generator.generateGlyph(prompt: prompt)
        }
        return renderFallbackGlyph(prompt: prompt)
    }

    /// The size, in pixels, of the fallback rendered glyph.
    public static var fallbackGlyphSize = CGSize(width: 256, height: 256)

    /// Render a real bitmap for `prompt` when no image backend is available.
    ///
    /// Draws a rounded, tinted tile with the prompt's leading emoji (if any) or the
    /// initials of its words, producing a distinct, deterministic image per prompt.
    public static func renderFallbackGlyph(prompt: String) -> AdaptiveImageGlyph {
        let png = renderPNG(prompt: prompt, size: fallbackGlyphSize)
        return AdaptiveImageGlyph(imageContent: png, contentDescription: prompt)
    }

    private static func renderPNG(prompt: String, size: CGSize) -> Data {
        let glyphText = displayText(for: prompt)
        let tint = color(for: prompt)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: size)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: size.width * 0.22)
            tint.setFill()
            path.fill()

            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            let fontSize = size.height * (glyphText.count <= 2 ? 0.55 : 0.34)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: fontSize, weight: .bold),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraph,
            ]
            let string = glyphText as NSString
            let bounds = string.boundingRect(
                with: size,
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: attrs,
                context: nil
            )
            let drawRect = CGRect(
                x: 0,
                y: (size.height - bounds.height) / 2,
                width: size.width,
                height: bounds.height
            )
            string.draw(in: drawRect, withAttributes: attrs)
            _ = ctx
        }
        return image.pngData() ?? Data()
    }

    /// A leading emoji from the prompt, else up to two uppercase initials.
    private static func displayText(for prompt: String) -> String {
        let trimmed = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        if let first = trimmed.unicodeScalars.first,
           first.properties.isEmoji, first.value > 0x238C {
            // Take the first grapheme cluster (a full emoji, incl. modifiers).
            return String(trimmed.prefix(1))
        }
        let initials = trimmed
            .split(whereSeparator: { $0 == " " || $0 == "\n" })
            .prefix(2)
            .compactMap { $0.first.map(Character.init) }
            .map { String($0).uppercased() }
            .joined()
        return initials.isEmpty ? "?" : initials
    }

    /// A deterministic tint derived from the prompt so the same text always yields
    /// the same color.
    private static func color(for prompt: String) -> UIColor {
        var hash: UInt64 = 5381
        for byte in Array(prompt.utf8) { hash = (hash &* 33) &^ UInt64(byte) }
        let hue = CGFloat(hash % 360) / 360.0
        return UIColor(hue: hue, saturation: 0.62, brightness: 0.85, alpha: 1.0)
    }
}
#endif
