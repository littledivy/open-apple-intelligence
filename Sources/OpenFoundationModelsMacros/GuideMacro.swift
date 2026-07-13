import SwiftSyntax
import SwiftSyntaxMacros

/// `@Guide` is pure metadata: it is read from the attribute syntax by
/// `GenerableMacro` and produces no code of its own.
public struct GuideMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}
