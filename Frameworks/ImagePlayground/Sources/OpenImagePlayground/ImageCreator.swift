import CoreGraphics
import Foundation

/// Generates images from concepts. Mirrors `ImagePlayground.ImageCreator`.
///
/// Apple gates this behind Apple Intelligence; the polyfill drives it from the
/// configured `ImageGenerationBackend` (`OpenImagePlayground.configure(backend:)`).
public final class ImageCreator: Sendable {
    /// One produced image. Mirrors `ImageCreator.CreatedImage`.
    public struct CreatedImage {
        public let cgImage: CGImage
    }

    /// Failure cases surfaced during creation. Mirrors `ImageCreator.Error`.
    /// (`conceptsRequirePersonIdentity` is spec-gated to iOS 26 but kept here since the
    /// polyfill strips availability.)
    public enum Error: LocalizedError, CustomNSError, CaseIterable {
        case notSupported
        case unavailable
        case creationCancelled
        case faceInImageTooSmall
        case unsupportedLanguage
        case unsupportedInputImage
        case backgroundCreationForbidden
        case creationFailed
        case conceptsRequirePersonIdentity

        public static var errorDomain: String { "ImageCreator.Error" }

        public var errorUserInfo: [String: Any] {
            [NSLocalizedDescriptionKey: errorDescription ?? String(describing: self)]
        }

        public var errorDescription: String? {
            switch self {
            case .notSupported: return "Image generation is not supported on this device."
            case .unavailable: return "Image generation is currently unavailable."
            case .creationCancelled: return "Image creation was cancelled."
            case .faceInImageTooSmall: return "The face in the provided image is too small."
            case .unsupportedLanguage: return "The provided language is not supported."
            case .unsupportedInputImage: return "The provided input image is not supported."
            case .backgroundCreationForbidden: return "Image creation is not allowed in the background."
            case .creationFailed: return "Image creation failed."
            case .conceptsRequirePersonIdentity: return "The provided concepts require a person identity."
            }
        }
    }

    private let backend: ImageGenerationBackend

    /// The styles this creator can render. Mirrors the spec's stored property.
    public let availableStyles: [ImagePlaygroundStyle]

    /// Create a creator bound to the active backend. With no explicit configuration this
    /// is the real on-device `CoreMLDiffusionBackend`; otherwise it is whatever was passed
    /// to `OpenImagePlayground.configure(backend:)`.
    ///
    /// Throws `Error.unavailable` if the backend is not ready — paralleling how Apple
    /// throws when Apple Intelligence is unavailable.
    public init() async throws {
        guard let backend = OpenImagePlayground.backend else {
            throw Error.unavailable
        }
        guard await backend.isReady() else {
            throw Error.unavailable
        }
        self.backend = backend
        self.availableStyles = ImagePlaygroundStyle.all
    }

    /// Create a creator bound to an explicit backend (convenience; not in Apple's spec).
    public init(backend: ImageGenerationBackend) {
        self.backend = backend
        self.availableStyles = ImagePlaygroundStyle.all
    }

    /// Stream up to `limit` images generated for `concepts` in `style`.
    ///
    /// Spec signature adaptation: Apple declares this as
    /// `some AsyncSequence<CreatedImage, any Error>` (the typed-throws AsyncSequence form,
    /// SE-0421). That primary-associated-type spelling requires macOS 15 / iOS 18; this
    /// polyfill targets macOS 13 / iOS 16, so we return the concrete
    /// `AsyncThrowingStream<CreatedImage, any Error>` — still an `AsyncSequence` yielding
    /// `CreatedImage` and throwing, so `for try await` call sites are unchanged.
    public func images(
        for concepts: [ImagePlaygroundConcept],
        style: ImagePlaygroundStyle,
        limit: Int
    ) -> AsyncThrowingStream<CreatedImage, any Swift.Error> {
        let prompt = Self.buildPrompt(from: concepts)
        let backend = self.backend
        return AsyncThrowingStream<CreatedImage, any Swift.Error> { continuation in
            let task = Task {
                do {
                    let images = try await backend.generate(prompt: prompt, style: style, count: limit)
                    for image in images.prefix(limit) {
                        if Task.isCancelled { break }
                        continuation.yield(CreatedImage(cgImage: image))
                    }
                    continuation.finish()
                } catch is CancellationError {
                    continuation.finish(throwing: Error.creationCancelled)
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    /// Join the textual parts of the concepts into one generation prompt.
    static func buildPrompt(from concepts: [ImagePlaygroundConcept]) -> String {
        concepts.compactMap(\.promptText).joined(separator: ", ")
    }
}
