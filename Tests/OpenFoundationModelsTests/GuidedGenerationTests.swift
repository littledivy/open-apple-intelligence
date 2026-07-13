import XCTest
@testable import OpenFoundationModels

@Generable
struct Person: Equatable {
    @Guide(description: "the person's full name")
    var name: String
    var age: Int
}

@Generable
struct WeatherArgs: Equatable {
    var city: String
}

struct WeatherTool: Tool {
    let name = "get_weather"
    let description = "Get the current weather for a city."
    func call(arguments: WeatherArgs) async throws -> String {
        "72F and sunny in \(arguments.city)"
    }
}

final class GuidedGenerationTests: XCTestCase {

    func testMacroDerivedSchema() {
        // @Generable synthesized a schema over the stored properties.
        let json = Person.generationSchema.jsonSchema
        XCTAssertTrue(json.contains("name"))
        XCTAssertTrue(json.contains("age"))
    }

    func testGuidedTypedResponse() async throws {
        OpenFoundationModels.configure(backend: EchoBackend { _ in
            #"{"name": "Ada Lovelace", "age": 36}"#
        })
        let session = LanguageModelSession()
        let response = try await session.respond(to: "Make a person.", generating: Person.self)
        XCTAssertEqual(response.content, Person(name: "Ada Lovelace", age: 36))
    }

    func testGuidedRawSchemaResponse() async throws {
        OpenFoundationModels.configure(backend: EchoBackend { _ in
            #"{"name": "Grace", "age": 45}"#
        })
        let session = LanguageModelSession()
        let response = try await session.respond(to: "x", schema: Person.generationSchema)
        let name: String = try response.content.value(String.self, forProperty: "name")
        XCTAssertEqual(name, "Grace")
    }

    func testGuidedDecodesFencedJSON() async throws {
        OpenFoundationModels.configure(backend: EchoBackend { _ in
            "Here you go:\n```json\n{\"name\": \"Alan\", \"age\": 41}\n```"
        })
        let session = LanguageModelSession()
        let person = try await session.respond(to: "x", generating: Person.self).content
        XCTAssertEqual(person, Person(name: "Alan", age: 41))
    }

    func testToolCallingLoop() async throws {
        // First model turn requests the tool; once the tool output is in history,
        // the model answers normally.
        OpenFoundationModels.configure(backend: EchoBackend { req in
            if req.history.contains(where: { $0.role == .tool }) {
                return "The weather is 72F and sunny."
            }
            return #"{"tool_call": {"name": "get_weather", "arguments": {"city": "Paris"}}}"#
        })
        let session = LanguageModelSession(tools: [WeatherTool()])
        let response = try await session.respond(to: "What's the weather in Paris?")
        XCTAssertEqual(response.content, "The weather is 72F and sunny.")
        // Transcript should contain the tool output entry.
        let hasToolOutput = session.transcript.contains { if case .toolOutput = $0 { return true } else { return false } }
        XCTAssertTrue(hasToolOutput, "expected a toolOutput entry in the transcript")
    }
}
