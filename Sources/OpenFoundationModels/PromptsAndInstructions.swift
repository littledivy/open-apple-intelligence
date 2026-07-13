import Foundation

// Instructions / Prompt + their representable protocols and result builders.
// Mirrors `FoundationModels.{Instructions,Prompt,...}`.
//
// NOTE: Apple's spec builders use variadic *parameter packs* (`repeat each`). Those
// mis-compile (SIGSEGV) under the current toolchain's pack-iteration codegen, so we
// implement the builders with plain variadics — the public builder syntax is identical
// (`Instructions { "a"; "b" }`), only the internal mechanism differs.

// MARK: - Instructions

/// System instructions for a session. Mirrors `FoundationModels.Instructions`.
public struct Instructions: Sendable {
    /// The concatenated instruction text. Internal; the session reads this.
    var text: String

    /// Internal string constructor used by the builders and representable conformances.
    init(text: String) { self.text = text }

    public init(_ content: some InstructionsRepresentable) {
        self = content.instructionsRepresentation
    }

    public init(@InstructionsBuilder _ content: () throws -> Instructions) rethrows {
        self = try content()
    }
}

/// A value that can stand in for `Instructions`.
public protocol InstructionsRepresentable {
    var instructionsRepresentation: Instructions { get }
}

extension Instructions: InstructionsRepresentable {
    public var instructionsRepresentation: Instructions { self }
}

extension String: InstructionsRepresentable {
    public var instructionsRepresentation: Instructions { Instructions(text: self) }
}

/// Result builder that concatenates instruction fragments (newline-joined).
@resultBuilder
public struct InstructionsBuilder {
    public static func buildBlock(_ components: Instructions...) -> Instructions {
        Instructions(text: components.map(\.text).filter { !$0.isEmpty }.joined(separator: "\n"))
    }
    @_disfavoredOverload
    public static func buildExpression(_ expression: some InstructionsRepresentable) -> Instructions {
        expression.instructionsRepresentation
    }
    public static func buildExpression(_ expression: Instructions) -> Instructions { expression }
    public static func buildArray(_ components: [Instructions]) -> Instructions {
        Instructions(text: components.map(\.text).filter { !$0.isEmpty }.joined(separator: "\n"))
    }
    public static func buildOptional(_ component: Instructions?) -> Instructions {
        component ?? Instructions(text: "")
    }
    public static func buildEither(first component: Instructions) -> Instructions { component }
    public static func buildEither(second component: Instructions) -> Instructions { component }
    public static func buildLimitedAvailability(_ component: Instructions) -> Instructions { component }
}

// MARK: - Prompt

/// A single prompt turn. Mirrors `FoundationModels.Prompt`.
public struct Prompt: Sendable {
    /// The concatenated prompt text. Internal; the session + tool rendering read this.
    var text: String

    /// Internal string constructor used by the builders and representable conformances.
    init(text: String) { self.text = text }

    public init(_ content: some PromptRepresentable) {
        self = content.promptRepresentation
    }

    public init(@PromptBuilder _ content: () throws -> Prompt) rethrows {
        self = try content()
    }
}

/// A value that can stand in for `Prompt`.
public protocol PromptRepresentable {
    var promptRepresentation: Prompt { get }
}

extension Prompt: PromptRepresentable {
    public var promptRepresentation: Prompt { self }
}

extension String: PromptRepresentable {
    public var promptRepresentation: Prompt { Prompt(text: self) }
}

/// Result builder that concatenates prompt fragments (newline-joined).
@resultBuilder
public struct PromptBuilder {
    public static func buildBlock(_ components: Prompt...) -> Prompt {
        Prompt(text: components.map(\.text).filter { !$0.isEmpty }.joined(separator: "\n"))
    }
    @_disfavoredOverload
    public static func buildExpression(_ expression: some PromptRepresentable) -> Prompt {
        expression.promptRepresentation
    }
    public static func buildExpression(_ expression: Prompt) -> Prompt { expression }
    public static func buildArray(_ components: [Prompt]) -> Prompt {
        Prompt(text: components.map(\.text).filter { !$0.isEmpty }.joined(separator: "\n"))
    }
    public static func buildOptional(_ component: Prompt?) -> Prompt {
        component ?? Prompt(text: "")
    }
    public static func buildEither(first component: Prompt) -> Prompt { component }
    public static func buildEither(second component: Prompt) -> Prompt { component }
    public static func buildLimitedAvailability(_ component: Prompt) -> Prompt { component }
}
