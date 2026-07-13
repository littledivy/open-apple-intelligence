import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

/// Implements the `@Generable` macro. Synthesizes `Generable` conformance for a
/// struct by generating:
///   - `static var generationSchema: GenerationSchema` built from stored
///     properties and their `@Guide` metadata,
///   - `init(_ content: GeneratedContent) throws` decoding each property,
///   - `var generatedContent: GeneratedContent` encoding each property,
///   - `extension <Type>: Generable {}`.
public struct GenerableMacro {}

// MARK: - Diagnostics

private enum GenerableDiagnostic: String, DiagnosticMessage {
    case notAStruct
    case noStoredProperties

    var message: String {
        switch self {
        case .notAStruct:
            return "@Generable can only be applied to a struct. Enums and classes are not supported by this polyfill."
        case .noStoredProperties:
            return "@Generable requires at least one stored property."
        }
    }

    var diagnosticID: MessageID { MessageID(domain: "OpenFoundationModelsMacros", id: rawValue) }
    var severity: DiagnosticSeverity { .error }
}

// MARK: - Property model

private struct StoredProperty {
    var name: String
    /// The written type annotation, e.g. `String`, `Int`, `[String]`.
    var type: TypeSyntax
    /// A `description:` string literal expression from `@Guide`, if any.
    var guideDescription: ExprSyntax?
    /// Positional guide expressions from `@Guide`, e.g. `.range(1...120)`.
    var guides: [ExprSyntax]
}

// MARK: - MemberMacro

extension GenerableMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            context.diagnose(Diagnostic(node: node, message: GenerableDiagnostic.notAStruct))
            return []
        }

        let typeName = structDecl.name.trimmed.text
        let properties = storedProperties(of: structDecl)

        guard !properties.isEmpty else {
            context.diagnose(Diagnostic(node: node, message: GenerableDiagnostic.noStoredProperties))
            return []
        }

        // static var generationSchema
        let schemaProps = properties.map { prop -> String in
            var args = "name: \"\(prop.name)\""
            if let desc = prop.guideDescription {
                args += ", description: \(desc.trimmedDescription)"
            }
            args += ", type: \(prop.type.trimmedDescription).self"
            if !prop.guides.isEmpty {
                let guideList = prop.guides.map { $0.trimmedDescription }.joined(separator: ", ")
                args += ", guides: [\(guideList)]"
            }
            return "GenerationSchema.Property(\(args))"
        }.joined(separator: ",\n                ")

        let schemaDescription = generableDescription(from: node)
        let schemaDescriptionArg = schemaDescription.map { ", description: \($0.trimmedDescription)" } ?? ""

        // Only the schema is a MEMBER. `init(_:)` and `generatedContent` go in the
        // extension (below) so the struct keeps its synthesized memberwise initializer.
        let generationSchema: DeclSyntax = """
            public static var generationSchema: GenerationSchema {
                GenerationSchema(
                    type: \(raw: typeName).self\(raw: schemaDescriptionArg),
                    properties: [
                        \(raw: schemaProps)
                    ]
                )
            }
            """

        return [generationSchema]
    }
}

// MARK: - ExtensionMacro

extension GenerableMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else { return [] }
        let properties = storedProperties(of: structDecl)
        guard !properties.isEmpty else { return [] }

        // init(_ content: GeneratedContent) throws — decode each property.
        let decodeLines = properties.map { prop in
            "self.\(prop.name) = try content.value(\(prop.type.trimmedDescription).self, forProperty: \"\(prop.name)\")"
        }.joined(separator: "\n        ")

        // var generatedContent — encode each property.
        let encodePairs = properties.map { "\"\($0.name)\": \($0.name)" }.joined(separator: ",\n            ")

        // Emitting init(_:) in an extension (not as a member) preserves the memberwise init.
        let ext: DeclSyntax = """
            extension \(type.trimmed): Generable {
                public init(_ content: GeneratedContent) throws {
                    \(raw: decodeLines)
                }
                public var generatedContent: GeneratedContent {
                    GeneratedContent(properties: [
                        \(raw: encodePairs)
                    ])
                }
            }
            """
        return [ext.cast(ExtensionDeclSyntax.self)]
    }
}

// MARK: - Parsing helpers

private func storedProperties(of structDecl: StructDeclSyntax) -> [StoredProperty] {
    var result: [StoredProperty] = []

    for member in structDecl.memberBlock.members {
        guard let varDecl = member.decl.as(VariableDeclSyntax.self) else { continue }

        // Skip static and class properties.
        let modifiers = varDecl.modifiers.map { $0.name.text }
        if modifiers.contains("static") || modifiers.contains("class") { continue }

        // Read @Guide attribute metadata, if present.
        let (guideDescription, guides) = parseGuide(from: varDecl.attributes)

        for binding in varDecl.bindings {
            guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self) else { continue }

            // Skip computed properties (accessor blocks with a getter/setter).
            if let accessor = binding.accessorBlock {
                switch accessor.accessors {
                case .accessors(let list):
                    // A `didSet`/`willSet` observer is still a stored property.
                    let isObserverOnly = list.allSatisfy {
                        $0.accessorSpecifier.text == "didSet" || $0.accessorSpecifier.text == "willSet"
                    }
                    if !isObserverOnly { continue }
                case .getter:
                    continue
                }
            }

            guard let typeAnnotation = binding.typeAnnotation?.type else { continue }

            result.append(
                StoredProperty(
                    name: pattern.identifier.trimmed.text,
                    type: typeAnnotation,
                    guideDescription: guideDescription,
                    guides: guides
                )
            )
        }
    }

    return result
}

/// Extract `description:` and positional guide expressions from a `@Guide`
/// attribute attached to a property, if present.
private func parseGuide(from attributes: AttributeListSyntax) -> (ExprSyntax?, [ExprSyntax]) {
    for attribute in attributes {
        guard let attr = attribute.as(AttributeSyntax.self) else { continue }
        guard attr.attributeName.trimmedDescription == "Guide" else { continue }
        guard let args = attr.arguments?.as(LabeledExprListSyntax.self) else { return (nil, []) }

        var description: ExprSyntax?
        var guides: [ExprSyntax] = []
        for arg in args {
            if arg.label?.text == "description" {
                description = arg.expression
            } else {
                guides.append(arg.expression)
            }
        }
        return (description, guides)
    }
    return (nil, [])
}

/// Extract the `description:` argument passed to `@Generable(...)`, if any.
private func generableDescription(from node: AttributeSyntax) -> ExprSyntax? {
    guard let args = node.arguments?.as(LabeledExprListSyntax.self) else { return nil }
    for arg in args where arg.label?.text == "description" {
        return arg.expression
    }
    return nil
}
