import Foundation

/// A pluggable text-generation engine behind the polyfill.
///
/// Implement `generate(_:)` at minimum. `stream(_:)` has a default that emits the
/// full result as one chunk; override it for true token streaming.
public protocol ModelBackend: Sendable {
    /// Human-readable id for diagnostics.
    var identifier: String { get }

    /// Whether this backend is currently usable (model loaded / endpoint reachable /
    /// hardware eligible). Drives `SystemLanguageModel.availability`.
    func isReady() async -> Bool

    /// Produce a full completion for the request.
    func generate(_ request: GenerationRequest) async throws -> String

    /// Stream partial *cumulative* snapshots of the completion.
    func stream(_ request: GenerationRequest) -> AsyncThrowingStream<String, Error>
}

public extension ModelBackend {
    var identifier: String { String(describing: type(of: self)) }

    func isReady() async -> Bool { true }

    // Default streaming: run the blocking generate, emit once. Concrete network/local
    // backends override this to forward real incremental tokens.
    func stream(_ request: GenerationRequest) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let text = try await generate(request)
                    continuation.yield(text)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}

/// One role-tagged message in a request. Mirrors chat-style transcripts.
public struct GenerationMessage: Sendable, Equatable {
    public enum Role: String, Sendable, Equatable {
        case system, user, assistant, tool
    }
    public var role: Role
    public var text: String
    public init(role: Role, text: String) {
        self.role = role
        self.text = text
    }
}

/// Everything a backend needs to produce a completion: the resolved instructions,
/// prior turns, the new prompt, and sampling options.
public struct GenerationRequest: Sendable {
    /// System instructions, if any.
    public var instructions: String?
    /// Prior conversation turns (excludes the new prompt).
    public var history: [GenerationMessage]
    /// The new user prompt for this turn.
    public var prompt: String
    /// Sampling / length controls.
    public var options: GenerationOptions
    /// When set, the backend must return JSON conforming to this schema
    /// (guided generation). `nil` ⇒ free-form text.
    public var schema: GenerationSchema?

    public init(
        instructions: String? = nil,
        history: [GenerationMessage] = [],
        prompt: String,
        options: GenerationOptions = GenerationOptions(),
        schema: GenerationSchema? = nil
    ) {
        self.instructions = instructions
        self.history = history
        self.prompt = prompt
        self.options = options
        self.schema = schema
    }

    /// Flatten to a plain message list (instructions first, then history, then prompt).
    public var messages: [GenerationMessage] {
        var out: [GenerationMessage] = []
        if let instructions, !instructions.isEmpty {
            out.append(.init(role: .system, text: instructions))
        }
        out.append(contentsOf: history)
        out.append(.init(role: .user, text: prompt))
        return out
    }
}
