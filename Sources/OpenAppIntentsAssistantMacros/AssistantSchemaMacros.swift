import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

// MARK: - Diagnostics

private enum AssistantMacroDiagnostic: String, DiagnosticMessage {
    case missingSchema

    var message: String {
        switch self {
        case .missingSchema:
            return "Assistant schema macro requires a `schema:` argument, e.g. @AssistantIntent(schema: .mail.createDraft)."
        }
    }
    var diagnosticID: MessageID { MessageID(domain: "OpenAppIntentsAssistantMacros", id: rawValue) }
    var severity: DiagnosticSeverity { .error }
}

// MARK: - Shared expansion

/// Extracts the `schema:` argument expression from the attribute, or diagnoses.
private func schemaExpression(
    from node: AttributeSyntax,
    in context: some MacroExpansionContext
) -> ExprSyntax? {
    guard case let .argumentList(args) = node.arguments,
          let schemaArg = args.first(where: { $0.label?.text == "schema" }) ?? args.first
    else {
        context.diagnose(Diagnostic(node: node, message: AssistantMacroDiagnostic.missingSchema))
        return nil
    }
    return schemaArg.expression
}

/// Synthesizes the `__assistantSchemaIdentifier` member. It evaluates the real schema
/// value at runtime (`AssistantSchema(<expr>).identifier`), so the recorded identifier
/// is exactly the one Apple's schema value carries — never a placeholder.
private func schemaIdentifierMember(for schema: ExprSyntax) -> DeclSyntax {
    """
    public static var __assistantSchemaIdentifier: String {
        AssistantSchema(\(schema)).identifier
    }
    """
}

// MARK: - @AssistantIntent

public struct AssistantIntentMacro: MemberMacro, ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let schema = schemaExpression(from: node, in: context) else { return [] }
        return [schemaIdentifierMember(for: schema)]
    }

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let ext: DeclSyntax =
            """
            extension \(type.trimmed): AssistantSchemaIntent, ShowInAppSearchResultsIntent, SchemaCarryingIntent {}
            """
        return [ext.cast(ExtensionDeclSyntax.self)]
    }
}

// MARK: - @AssistantEntity

public struct AssistantEntityMacro: MemberMacro, ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let schema = schemaExpression(from: node, in: context) else { return [] }
        return [schemaIdentifierMember(for: schema)]
    }

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let ext: DeclSyntax =
            """
            extension \(type.trimmed): AssistantSchemaEntity, SchemaCarryingEntity {}
            """
        return [ext.cast(ExtensionDeclSyntax.self)]
    }
}

// MARK: - @AssistantEnum

public struct AssistantEnumMacro: MemberMacro, ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let schema = schemaExpression(from: node, in: context) else { return [] }
        return [schemaIdentifierMember(for: schema)]
    }

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let ext: DeclSyntax =
            """
            extension \(type.trimmed): AssistantSchemaEnum, SchemaCarryingEnum {}
            """
        return [ext.cast(ExtensionDeclSyntax.self)]
    }
}
