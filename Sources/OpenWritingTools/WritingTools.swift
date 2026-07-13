import Foundation
import OpenFoundationModels

/// The functional core of the polyfill: run Apple-Writing-Tools-style text
/// transforms anywhere, backed by the `OpenFoundationModels` LLM engine.
///
/// Configure a backend once (via the core polyfill), then apply an action:
///
/// ```swift
/// import OpenFoundationModels
/// import OpenWritingTools
///
/// OpenFoundationModels.configureLocalServer()               // or any ModelBackend
///
/// let fixed = try await WritingTools.apply(.proofread, to: draft)
///
/// for try await partial in WritingTools.stream(.rewrite, draft) {
///     view.text = partial                                   // cumulative snapshots
/// }
/// ```
///
/// This is the polyfillable, genuinely useful half of Writing Tools. The system-UI
/// half (the inline editing overlay wired into the responder chain) lives in
/// ``WritingToolsCoordinator`` and cannot be reproduced off-device — see its docs.
public enum WritingTools {

    // MARK: Zero-config bootstrap

    private static let bootstrapLock = NSLock()
    nonisolated(unsafe) private static var didBootstrap = false
    nonisolated(unsafe) private static var didUserConfigure = false

    /// The default endpoint used when the host never configures a backend: a local
    /// OpenAI-compatible server (llama.cpp on `:8091`, launch with `--jinja -np 1`).
    /// Override with ``useDefaultBackend(_:)`` or by calling
    /// `OpenFoundationModels.configure(...)` yourself before the first transform.
    public static let defaultLocalEndpoint = URL(string: "http://localhost:8091/v1")!

    nonisolated(unsafe) private static var defaultBackendFactory: @Sendable () -> any ModelBackend = {
        OpenAICompatibleBackend(endpoint: defaultLocalEndpoint, model: "default")
    }

    /// Explicitly set the backend the engine should use, and mark configuration as
    /// done so the zero-config fallback is skipped. Equivalent to calling
    /// `OpenFoundationModels.configure(backend:)` but also records intent so a later
    /// implicit bootstrap won't override it.
    public static func useDefaultBackend(_ backend: any ModelBackend) {
        bootstrapLock.withLock {
            didUserConfigure = true
            didBootstrap = true
        }
        OpenFoundationModels.configure(backend: backend)
    }

    /// Ensure *some* backend is available so transforms never silently no-op.
    ///
    /// If the host already called `OpenFoundationModels.configure(...)` (via
    /// ``useDefaultBackend(_:)``) this does nothing. Otherwise, on the first call it
    /// installs a sensible default: Apple's on-device model when eligible, falling
    /// back to a local OpenAI-compatible server (see ``defaultLocalEndpoint``). This
    /// runs automatically before every ``apply(_:to:options:)`` / ``stream(_:_:options:)``.
    public static func bootstrapIfNeeded() {
        bootstrapLock.withLock {
            guard !didBootstrap else { return }
            didBootstrap = true
            guard !didUserConfigure else { return }
            OpenFoundationModels.configure(fallback: defaultBackendFactory())
        }
    }

    /// Apply a Writing Tools action to `text` and return the transformed result.
    ///
    /// - Parameters:
    ///   - action: which transform to run (proofread, rewrite, tone change, …).
    ///   - text: the input text.
    ///   - options: generation options forwarded to the model.
    /// - Returns: the transformed text.
    /// - Throws: whatever the underlying `LanguageModelSession` throws (e.g.
    ///   `.unavailable` when no backend is configured / eligible).
    public static func apply(
        _ action: WritingToolsAction,
        to text: String,
        options: GenerationOptions = GenerationOptions()
    ) async throws -> String {
        bootstrapIfNeeded()
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return text }
        let session = LanguageModelSession(instructions: action.instruction)
        let response = try await session.respond(to: action.prompt(for: text), options: options)
        return response.content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Stream a Writing Tools action, yielding cumulative snapshots of the
    /// transformed text as the model produces it (mirrors the "streaming rewrite"
    /// behaviour of the real feature).
    ///
    /// Each yielded value is the full text generated *so far*, not a delta.
    ///
    /// - Parameters:
    ///   - action: which transform to run.
    ///   - text: the input text.
    ///   - options: generation options forwarded to the model.
    public static func stream(
        _ action: WritingToolsAction,
        _ text: String,
        options: GenerationOptions = GenerationOptions()
    ) -> AsyncThrowingStream<String, Error> {
        bootstrapIfNeeded()
        return AsyncThrowingStream { continuation in
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                continuation.yield(text)
                continuation.finish()
                return
            }
            let task = Task {
                do {
                    let session = LanguageModelSession(instructions: action.instruction)
                    let responseStream = session.streamResponse(to: action.prompt(for: text), options: options)
                    for try await snapshot in responseStream {
                        // For `String`, `PartiallyGenerated == String`, so the
                        // snapshot content is the cumulative text so far.
                        continuation.yield(snapshot.content)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
