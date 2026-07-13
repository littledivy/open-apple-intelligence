import Foundation

// MARK: - ConvertibleFromGeneratedContent

/// A type that can be initialized from `GeneratedContent`.
/// Mirrors `FoundationModels.ConvertibleFromGeneratedContent`.
public protocol ConvertibleFromGeneratedContent: SendableMetatype {
    /// Creates an instance from generated content, throwing if the content
    /// does not match the expected shape.
    init(_ content: GeneratedContent) throws
}

// MARK: - ConvertibleToGeneratedContent

/// A type that can produce `GeneratedContent`. Because it refines the
/// representable protocols, any convertible value can also stand in for
/// `Instructions` or `Prompt`.
/// Mirrors `FoundationModels.ConvertibleToGeneratedContent`.
public protocol ConvertibleToGeneratedContent: InstructionsRepresentable, PromptRepresentable {
    /// The generated content that represents this value.
    var generatedContent: GeneratedContent { get }
}

extension ConvertibleToGeneratedContent {
    /// Default representation: serialize the value's generated content to text.
    public var instructionsRepresentation: Instructions {
        Instructions(generatedContent.jsonString)
    }

    /// Default representation: serialize the value's generated content to text.
    public var promptRepresentation: Prompt {
        Prompt(generatedContent.jsonString)
    }
}

// MARK: - Generable

/// A type that a language model can generate in a structured, guided way.
/// Mirrors `FoundationModels.Generable`.
public protocol Generable: ConvertibleFromGeneratedContent, ConvertibleToGeneratedContent {
    /// The type produced for in-progress (streaming) generation. Defaults to `Self`.
    associatedtype PartiallyGenerated: ConvertibleFromGeneratedContent = Self

    /// The schema describing how this type should be generated.
    static var generationSchema: GenerationSchema { get }
}

extension Generable {
    /// The default `PartiallyGenerated` type is the type itself.
    public typealias PartiallyGenerated = Self
}

extension Generable {
    /// Produces a partially generated representation of the value.
    ///
    /// The default implementation round-trips through `GeneratedContent`, which
    /// is correct when `PartiallyGenerated == Self` and for any type whose
    /// partial representation is initializable from the same content.
    public func asPartiallyGenerated() -> Self.PartiallyGenerated {
        // Safe: for the default `PartiallyGenerated = Self`, and for conforming
        // types whose partial form is constructible from the same content.
        // swiftlint:disable:next force_try
        try! Self.PartiallyGenerated(generatedContent)
    }
}
