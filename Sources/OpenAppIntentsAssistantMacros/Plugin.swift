import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct OpenAppIntentsAssistantMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AssistantIntentMacro.self,
        AssistantEntityMacro.self,
        AssistantEnumMacro.self,
    ]
}
