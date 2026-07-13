import CoreGraphics
import Foundation

/// A pluggable image-generation engine behind the polyfill.
///
/// Apple gates ImagePlayground behind Apple Intelligence; here we substitute any
/// backend that can turn a prompt + style into images. Implement `generate` and,
/// optionally, `isReady` for an availability probe.
///
/// ```swift
/// OpenImagePlayground.configure(backend: OpenAIImageBackend(
///     endpoint: URL(string: "https://api.openai.com/v1")!,
///     model: "gpt-image-1",
///     apiKey: ProcessInfo.processInfo.environment["OPENAI_API_KEY"]
/// ))
/// ```
public protocol ImageGenerationBackend: Sendable {
    /// Human-readable id for diagnostics.
    var identifier: String { get }

    /// Whether this backend is currently usable (endpoint reachable / key present).
    /// Drives `ImageCreator` availability.
    func isReady() async -> Bool

    /// Produce up to `count` images for `prompt` rendered in `style`.
    func generate(prompt: String, style: ImagePlaygroundStyle, count: Int) async throws -> [CGImage]
}

public extension ImageGenerationBackend {
    var identifier: String { String(describing: type(of: self)) }

    func isReady() async -> Bool { true }
}

/// Errors surfaced by concrete network backends. `ImageCreator` maps these onto the
/// spec's `ImageCreator.Error` cases where possible.
public enum ImageGenerationBackendError: Error, Sendable, CustomStringConvertible {
    case http(status: Int, body: String)
    case invalidResponse(String)
    case decodingFailed(String)
    case notConfigured

    public var description: String {
        switch self {
        case let .http(status, body): return "HTTP \(status): \(body)"
        case let .invalidResponse(body): return "Invalid response: \(body)"
        case let .decodingFailed(reason): return "Failed to decode image: \(reason)"
        case .notConfigured: return "No image backend configured; call OpenImagePlayground.configure(backend:)"
        }
    }
}
