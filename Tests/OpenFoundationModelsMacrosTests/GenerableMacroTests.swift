import XCTest
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import OpenFoundationModelsMacros

nonisolated(unsafe) private let testMacros: [String: Macro.Type] = [
    "Generable": GenerableMacro.self,
    "Guide": GuideMacro.self,
]

final class GenerableMacroTests: XCTestCase {

    func testStructExpansion() {
        assertMacroExpansion(
            """
            @Generable
            struct Person {
                @Guide(description: "full name")
                var name: String
                @Guide(.range(1...120))
                var age: Int
                var pets: [String]
            }
            """,
            expandedSource: """
            struct Person {
                var name: String
                var age: Int
                var pets: [String]

                public static var generationSchema: GenerationSchema {
                    GenerationSchema(
                        type: Person.self,
                        properties: [
                            GenerationSchema.Property(name: "name", description: "full name", type: String.self),
                                GenerationSchema.Property(name: "age", type: Int.self, guides: [.range(1 ... 120)]),
                                GenerationSchema.Property(name: "pets", type: [String].self)
                        ]
                    )
                }
            }

            extension Person: Generable {
                public init(_ content: GeneratedContent) throws {
                    self.name = try content.value(String.self, forProperty: "name")
                    self.age = try content.value(Int.self, forProperty: "age")
                    self.pets = try content.value([String].self, forProperty: "pets")
                }
                public var generatedContent: GeneratedContent {
                    GeneratedContent(properties: [
                        "name": name,
                        "age": age,
                        "pets": pets
                    ])
                }
            }
            """,
            macros: testMacros
        )
    }

    func testEnumEmitsDiagnostic() {
        assertMacroExpansion(
            """
            @Generable
            enum Color {
                case red
                case blue
            }
            """,
            expandedSource: """
            enum Color {
                case red
                case blue
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@Generable can only be applied to a struct. Enums and classes are not supported by this polyfill.",
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
    }
}
