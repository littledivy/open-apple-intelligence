import Foundation

/// Global configuration namespace for the polyfill.
///
/// With ZERO configuration, `ImageCreator` and the SwiftUI sheet generate REAL images
/// on-device through `CoreMLDiffusionBackend` (Apple's Core ML Stable Diffusion) — no
/// server, no API key, no Apple Intelligence. Call `configure(backend:)` only to swap
/// in an alternative (e.g. the OpenAI-compatible HTTP backend, or a test stub).
///
/// ```swift
/// // Default: nothing to do — real on-device diffusion.
/// let creator = try await ImageCreator()
///
/// // Or opt into an alternative backend:
/// OpenImagePlayground.configure(backend: OpenAIImageBackend(...))  // remote HTTP
/// OpenImagePlayground.configure(backend: StubImageBackend())       // tests only
/// ```
public enum OpenImagePlayground {
    private static let lock = NSLock()
    nonisolated(unsafe) private static var _backend: ImageGenerationBackend?
    nonisolated(unsafe) private static var _explicitlyConfigured = false

    /// Install the backend used for all image generation, overriding the on-device default.
    public static func configure(backend: ImageGenerationBackend) {
        lock.lock(); defer { lock.unlock() }
        _backend = backend
        _explicitlyConfigured = true
    }

    /// The backend used for generation.
    ///
    /// When the `CoreMLDiffusion` package trait is enabled, this falls back to the real
    /// on-device `CoreMLDiffusionBackend` if nothing was explicitly configured, so the
    /// polyfill works out of the box with zero config. When the trait is off (the default),
    /// the on-device pipeline is compiled out, so there is no built-in fallback — callers
    /// must install a backend via `configure(backend:)` (e.g. the OpenAI-compatible HTTP
    /// backend), and `ImageCreator()` reports `.unavailable` until they do.
    public static var backend: ImageGenerationBackend? {
        lock.lock(); defer { lock.unlock() }
        if let _backend { return _backend }
        #if CoreMLDiffusion
        let fallback = CoreMLDiffusionBackend()
        _backend = fallback
        return fallback
        #else
        return nil
        #endif
    }

    /// Whether a caller explicitly installed a backend (vs. the on-device default).
    public static var isExplicitlyConfigured: Bool {
        lock.lock(); defer { lock.unlock() }
        return _explicitlyConfigured
    }

    /// Reset to the default (on-device) state (primarily for tests).
    public static func reset() {
        lock.lock(); defer { lock.unlock() }
        _backend = nil
        _explicitlyConfigured = false
    }
}
