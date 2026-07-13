import Foundation

/// A tool the model may call. Mirrors `FoundationModels.Tool`.
///
/// `Arguments` is decoded from the model's structured output; `Output` is fed back
/// into the transcript. Conform `Arguments` to `Generable` (e.g. an `@Generable`
/// struct) so `parameters` is derived automatically.
public protocol Tool<Arguments, Output>: Sendable {
    associatedtype Arguments: ConvertibleFromGeneratedContent
    associatedtype Output: PromptRepresentable

    /// Stable identifier the model uses to select the tool.
    var name: String { get }
    /// Natural-language description of what the tool does.
    var description: String { get }
    /// Schema describing `Arguments`.
    var parameters: GenerationSchema { get }
    /// Whether the tool's schema is injected into the session instructions.
    var includesSchemaInInstructions: Bool { get }

    func call(arguments: Arguments) async throws -> Output
}

public extension Tool {
    var name: String { String(describing: Self.self) }
    var includesSchemaInInstructions: Bool { true }
}

public extension Tool where Arguments: Generable {
    var parameters: GenerationSchema { Arguments.generationSchema }
}
