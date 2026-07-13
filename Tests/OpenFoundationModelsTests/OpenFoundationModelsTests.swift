import XCTest
@testable import OpenFoundationModels

final class OpenFoundationModelsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Deterministic backend for all tests.
        OpenFoundationModels.configure(backend: EchoBackend { req in
            "reply to: \(req.prompt)"
        })
    }

    func testAvailabilityReflectsConfiguredBackend() {
        XCTAssertTrue(SystemLanguageModel.default.isAvailable)
        XCTAssertEqual(SystemLanguageModel.default.availability, .available)
    }

    func testUnavailableWhenNoBackend() {
        OpenFoundationModels.configure(strategy: .automatic(fallback: nil))
        // No Apple model on this test host ⇒ unavailable.
        if case .unavailable = SystemLanguageModel.default.availability {
            // ok
        } else {
            XCTFail("expected unavailable with no backend + ineligible host")
        }
    }

    func testRespond() async throws {
        let session = LanguageModelSession(instructions: "be terse")
        let response = try await session.respond(to: "hello")
        XCTAssertEqual(response.content, "reply to: hello")
    }

    func testStreamingIsCumulative() async throws {
        OpenFoundationModels.configure(backend: EchoBackend { _ in "one two three" })
        let session = LanguageModelSession()
        var snapshots: [String] = []
        for try await snap in session.streamResponse(to: "x") {
            snapshots.append(snap.content)
        }
        // EchoBackend streams word-by-word cumulatively; engine appends a final snapshot.
        XCTAssertEqual(snapshots.last, "one two three")
        for (prev, cur) in zip(snapshots, snapshots.dropFirst()) {
            XCTAssertTrue(cur.hasPrefix(prev))
        }
    }

    func testMultiTurnHistory() async throws {
        let session = LanguageModelSession()
        _ = try await session.respond(to: "first")
        _ = try await session.respond(to: "second")
        XCTAssertEqual(session.transcript.count, 4) // 2 prompt + 2 response entries
        if case .prompt = session.transcript.first { } else { XCTFail("first entry should be a prompt") }
    }

    func testStreamCollect() async throws {
        OpenFoundationModels.configure(backend: EchoBackend { _ in "final text" })
        let session = LanguageModelSession()
        let response = try await session.streamResponse(to: "x").collect()
        XCTAssertEqual(response.content, "final text")
    }

    func testInstructionsBuilder() {
        let i = Instructions {
            "line one"
            "line two"
        }
        XCTAssertEqual(i.text, "line one\nline two")
    }

    func testStringLiteralInstructions() async throws {
        let session = LanguageModelSession(instructions: "system prompt")
        let r = try await session.respond(to: "hi")
        XCTAssertEqual(r.content, "reply to: hi")
    }

}
