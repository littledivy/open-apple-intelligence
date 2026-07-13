import Foundation
import OpenFoundationModels
import MLXLMCommon
import MLXLLM

/// A `ModelBackend` that runs a language model **fully on-device** via Apple's MLX
/// (`mlx-swift` / `mlx-swift-examples`). No external server is required: weights are
/// downloaded from Hugging Face on first use and inference runs in-process on Apple
/// Silicon (M-series Macs, A-series iPhones/iPads).
///
/// ```swift
/// import OpenFoundationModels
/// import OpenFoundationModelsMLX
///
/// OpenFoundationModels.configure(
///     backend: MLXBackend(modelId: "mlx-community/Qwen2.5-1.5B-Instruct-4bit")
/// )
/// // then use LanguageModelSession exactly like Apple's FoundationModels
/// ```
///
/// The `ModelContainer` (model + tokenizer) is loaded lazily on first `generate` /
/// `stream` and cached for the lifetime of the backend.
public final class MLXBackend: ModelBackend, @unchecked Sendable {
    public let identifier: String

    private let modelId: String
    private let loader: ContainerLoader

    /// - Parameters:
    ///   - modelId: a Hugging Face model id in MLX format, e.g.
    ///     `"mlx-community/Qwen2.5-1.5B-Instruct-4bit"`.
    public init(modelId: String = "mlx-community/Qwen2.5-1.5B-Instruct-4bit") {
        self.modelId = modelId
        self.identifier = "mlx(\(modelId))"
        self.loader = ContainerLoader(modelId: modelId)
    }

    /// True once the model container has been loaded. This never triggers a download
    /// on its own; call `generate`/`stream` (or `prewarm`) to load the model.
    public func isReady() async -> Bool {
        await loader.isLoaded
    }

    /// Force the model to download + load now, so the first `generate` is fast. Optional.
    public func prewarm() async throws {
        _ = try await loader.container()
    }

    public func generate(_ request: GenerationRequest) async throws -> String {
        let container = try await loader.container()
        let parameters = Self.parameters(from: request.options)

        // `Chat.Message` is not Sendable, so build the input *inside* the isolated
        // `perform` closure; only the Sendable `request`/`parameters` are captured.
        return try await container.perform { context in
            let input = try await context.processor.prepare(
                input: UserInput(chat: Self.chatMessages(from: request)))
            let result: GenerateResult = MLXLMCommon.generate(
                input: input,
                context: context,
                iterator: try TokenIterator(
                    input: input, model: context.model, parameters: parameters)
            ) { _ in .more }
            return result.output
        }
    }

    public func stream(_ request: GenerationRequest) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let container = try await self.loader.container()
                    let parameters = Self.parameters(from: request.options)

                    try await container.perform { context in
                        let input = try await context.processor.prepare(
                            input: UserInput(chat: Self.chatMessages(from: request)))

                        var accumulated = ""
                        // MLXLMCommon.generate yields incremental detokenized chunks; we
                        // accumulate and emit cumulative snapshots to match how the core
                        // (and Apple's FoundationModels) stream.
                        for await item in try MLXLMCommon.generate(
                            input: input, cache: nil, parameters: parameters, context: context)
                        {
                            if Task.isCancelled { break }
                            if let chunk = item.chunk {
                                accumulated += chunk
                                continuation.yield(accumulated)
                            }
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    // MARK: - Mapping helpers

    /// Convert a `GenerationRequest` into MLX `Chat.Message`s. Uses the model's own
    /// chat template (applied downstream by `UserInputProcessor.prepare`).
    private static func chatMessages(from request: GenerationRequest) -> [Chat.Message] {
        request.messages.map { message in
            switch message.role {
            case .system: return .system(message.text)
            case .assistant: return .assistant(message.text)
            case .tool: return .tool(message.text)
            case .user: return .user(message.text)
            }
        }
    }

    /// Map core `GenerationOptions` to MLX `GenerateParameters`.
    private static func parameters(from options: GenerationOptions) -> GenerateParameters {
        var parameters = GenerateParameters()
        if let temperature = options.temperature {
            parameters.temperature = Float(temperature)
        }
        if let maxTokens = options.maximumResponseTokens {
            parameters.maxTokens = maxTokens
        }
        // Note: `GenerationOptions.SamplingMode.kind` is internal to the core package,
        // so top-p/top-k cannot be read here; temperature + maxTokens are honored.
        return parameters
    }
}

/// Serializes lazy, one-shot loading of a `ModelContainer` so concurrent first
/// requests share a single download/load.
private actor ContainerLoader {
    private let modelId: String
    private var loaded: ModelContainer?
    private var inFlight: Task<ModelContainer, Error>?

    init(modelId: String) {
        self.modelId = modelId
    }

    var isLoaded: Bool { loaded != nil }

    func container() async throws -> ModelContainer {
        if let loaded { return loaded }
        if let inFlight { return try await inFlight.value }

        let id = modelId
        let task = Task {
            try await LLMModelFactory.shared.loadContainer(
                configuration: ModelConfiguration(id: id))
        }
        inFlight = task
        do {
            let container = try await task.value
            loaded = container
            inFlight = nil
            return container
        } catch {
            inFlight = nil
            throw error
        }
    }
}
