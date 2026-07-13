import Foundation

// MARK: - @Generable

/// Conform a type to `Generable`, synthesizing its `generationSchema`,
/// `init(_ content:)`, and `generatedContent` from its stored properties.
///
/// Mirrors `FoundationModels.Generable` (the macro). The `@available`
/// attributes from Apple's declaration are intentionally stripped so this
/// polyfill can target older OS versions.
@attached(
    extension,
    conformances: Generable,
    names: named(init(_:)), named(generatedContent)
)
@attached(member, names: arbitrary)
public macro Generable(description: String? = nil) =
    #externalMacro(module: "OpenFoundationModelsMacros", type: "GenerableMacro")

// MARK: - @Guide

/// Attach generation guidance (a description and/or `GenerationGuide`s) to a
/// stored property of a `@Generable` type. Read as metadata by `@Generable`;
/// expands to nothing on its own.
@attached(peer)
public macro Guide<T>(description: String? = nil, _ guides: GenerationGuide<T>...) =
    #externalMacro(module: "OpenFoundationModelsMacros", type: "GuideMacro")
    where T: Generable

/// Attach a regex constraint to a `String` property of a `@Generable` type.
@attached(peer)
public macro Guide<RegexOutput>(description: String? = nil, _ guides: Regex<RegexOutput>) =
    #externalMacro(module: "OpenFoundationModelsMacros", type: "GuideMacro")

/// Attach a plain description to a stored property of a `@Generable` type.
@attached(peer)
public macro Guide(description: String) =
    #externalMacro(module: "OpenFoundationModelsMacros", type: "GuideMacro")
