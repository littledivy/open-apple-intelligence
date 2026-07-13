import Foundation

/// Global configuration entry point for the polyfill.
///
/// ```swift
/// import OpenFoundationModels
///
/// OpenFoundationModels.configure(
///     backend: OpenAICompatibleBackend(endpoint: URL(string: "http://localhost:8091/v1")!)
/// )
/// ```
///
/// If you never call `configure`, the polyfill uses `.automatic`: Apple's real
/// on-device model when the device is eligible, otherwise no backend (the model
/// reports `.unavailable(.modelNotReady)` — same shape your fallback UI already handles).
public enum OpenFoundationModels {

    /// How the polyfill picks a backend.
    public enum Strategy: Sendable {
        /// Apple on-device when eligible; otherwise `fallback` (if provided).
        case automatic(fallback: (any ModelBackend)?)
        /// Always use this backend, ignoring Apple's model even when present.
        case always(any ModelBackend)
    }

    private static let lock = NSLock()
    nonisolated(unsafe) private static var _strategy: Strategy = .automatic(fallback: nil)

    /// Replace the active strategy.
    public static func configure(strategy: Strategy) {
        lock.withLock { _strategy = strategy }
    }

    /// Convenience: always route through `backend`.
    public static func configure(backend: any ModelBackend) {
        configure(strategy: .always(backend))
    }

    /// Convenience: Apple when eligible, else `fallback`.
    public static func configure(fallback: any ModelBackend) {
        configure(strategy: .automatic(fallback: fallback))
    }

    static var strategy: Strategy {
        lock.withLock { _strategy }
    }

    /// Resolve the backend that should service a request right now, or `nil` if none
    /// is usable (drives `.unavailable`). `appleReady` reflects real-framework
    /// eligibility, computed by the caller so this stays synchronous and testable.
    static func resolvedBackend(appleReady: Bool) -> (any ModelBackend)? {
        switch strategy {
        case .always(let backend):
            return backend
        case .automatic(let fallback):
            if appleReady { return AppleOnDeviceBackend.shared }
            return fallback
        }
    }
}

// MARK: - Convenience presets

public extension OpenFoundationModels {
    /// Route to a local OpenAI-compatible server. Defaults to a llama.cpp server on
    /// port 8091 (launch with `--jinja -np 1`) — override for other setups.
    ///
    /// ```swift
    /// OpenFoundationModels.configureLocalServer()                    // llama.cpp :8091
    /// OpenFoundationModels.configureLocalServer(model: "qwen3")      // pin a model id
    /// ```
    static func configureLocalServer(
        endpoint: URL = URL(string: "http://localhost:8091/v1")!,
        model: String = "default",
        apiKey: String? = nil
    ) {
        configure(backend: OpenAICompatibleBackend(endpoint: endpoint, model: model, apiKey: apiKey))
    }

    /// Route to a local Ollama server (default port 11434).
    ///
    /// ```swift
    /// OpenFoundationModels.configureOllama(model: "qwen2.5:1.5b")
    /// ```
    static func configureOllama(
        model: String,
        host: String = "localhost",
        port: Int = 11434
    ) {
        let url = URL(string: "http://\(host):\(port)/v1")!
        configure(backend: OpenAICompatibleBackend(endpoint: url, model: model))
    }
}
