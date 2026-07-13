import Foundation

// MARK: - Intent parameter reflection
//
// To let the LocalAssistant fill an intent's fields from a natural-language utterance
// we need each intent to describe its parameters and accept decoded values. Apple's
// AppIntents does this with the `@Parameter` property wrapper + Mirror reflection; the
// polyfill provides a small, fully functional equivalent that intents adopt via
// `assistantParameters`.

/// The value kinds the LocalAssistant can extract and assign.
public enum AssistantParameterKind: String, Sendable, Codable {
    case string
    case int
    case double
    case bool
}

/// A description of one settable parameter on an intent, plus the closure that writes
/// a decoded value back into the intent instance. Fully functional: the setter mutates
/// the concrete intent so `perform()` sees the filled value.
public struct AssistantParameter: Sendable {
    public let name: String
    public let kind: AssistantParameterKind
    public let description: String?
    public let isOptional: Bool

    /// Applies a decoded value to `intent`. Returns the mutated intent.
    let apply: @Sendable (_ intent: any AssistantSchemaIntent, _ value: AssistantParameterValue) -> any AssistantSchemaIntent

    public init(
        name: String,
        kind: AssistantParameterKind,
        description: String? = nil,
        isOptional: Bool = false,
        apply: @escaping @Sendable (_ intent: any AssistantSchemaIntent, _ value: AssistantParameterValue) -> any AssistantSchemaIntent
    ) {
        self.name = name
        self.kind = kind
        self.description = description
        self.isOptional = isOptional
        self.apply = apply
    }
}

/// A concrete decoded parameter value handed back from the model.
public enum AssistantParameterValue: Sendable, Equatable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)

    public var stringValue: String? { if case let .string(v) = self { return v }; return nil }
    public var intValue: Int? { if case let .int(v) = self { return v }; return nil }
    public var doubleValue: Double? { if case let .double(v) = self { return v }; return nil }
    public var boolValue: Bool? { if case let .bool(v) = self { return v }; return nil }
}

// MARK: - Parameterized intent

/// An assistant intent that exposes its parameters for LocalAssistant filling.
///
/// Intents may declare `assistantParameters` directly. Adoption is optional: a
/// zero-parameter intent (e.g. a toggle) needs nothing and is still selectable and
/// invokable. Parameters use a small builder-style setter so the LocalAssistant can
/// mutate a fresh instance before calling `perform()`.
public protocol ParameterizedAssistantIntent: AssistantSchemaIntent {
    /// The parameters this intent can have filled from an utterance. Default: none.
    static var assistantParameters: [AssistantParameter] { get }

    /// A short natural-language description of what this intent does, used to help the
    /// model select it. Default: derived from the type name.
    static var assistantDescription: String { get }
}

public extension ParameterizedAssistantIntent {
    static var assistantParameters: [AssistantParameter] { [] }
    static var assistantDescription: String { "\(Self.self)" }
}
