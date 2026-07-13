import Foundation

/// A deterministic, dependency-free backend for tests, previews, and offline demos.
/// Emits a transform of the prompt, streamed word-by-word so streaming code paths
/// exercise real incremental delivery.
public final class EchoBackend: ModelBackend, @unchecked Sendable {
    public let identifier = "echo"
    private let transform: @Sendable (GenerationRequest) -> String

    /// - Parameter transform: maps a request to the reply. Defaults to echoing the prompt.
    public init(transform: @escaping @Sendable (GenerationRequest) -> String = { $0.prompt }) {
        self.transform = transform
    }

    public func generate(_ request: GenerationRequest) async throws -> String {
        transform(request)
    }

    public func stream(_ request: GenerationRequest) -> AsyncThrowingStream<String, Error> {
        let full = transform(request)
        return AsyncThrowingStream { continuation in
            let task = Task {
                var acc = ""
                for word in full.split(separator: " ", omittingEmptySubsequences: false) {
                    if Task.isCancelled { break }
                    acc += (acc.isEmpty ? "" : " ") + word
                    continuation.yield(acc)
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
