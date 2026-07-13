import XCTest
@testable import OpenFoundationModels

/// Live smoke tests against a real OpenAI-compatible server (e.g. a local
/// llama.cpp Qwen server on port 8091, launched with `--jinja -np 1`).
///
/// These hit the network and require a running server, so they are gated
/// behind the `OFM_LIVE` environment variable and are skipped by default —
/// normal `swift test` stays offline and green.
///
/// Run with:
/// ```
/// OFM_LIVE=1 swift test --filter LiveBackendTests
/// ```
final class LiveBackendTests: XCTestCase {

    /// Endpoint + model. Override via env for other servers:
    ///   OFM_ENDPOINT=http://localhost:8091/v1  OFM_MODEL=qwen3
    private static var endpoint: String {
        ProcessInfo.processInfo.environment["OFM_ENDPOINT"] ?? "http://localhost:11434/v1"
    }
    private static var modelID: String {
        ProcessInfo.processInfo.environment["OFM_MODEL"] ?? "qwen2.5:1.5b"
    }

    // setUpWithError (not setUp) so `try XCTSkipUnless` actually skips — wrapping the
    // throw in `try?` would swallow the XCTSkip and run the tests anyway.
    override func setUpWithError() throws {
        try super.setUpWithError()
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["OFM_LIVE"] == "1",
            "Set OFM_LIVE=1 to run live backend tests against a local server."
        )
        OpenFoundationModels.configure(backend: OpenAICompatibleBackend(
            endpoint: URL(string: Self.endpoint)!,
            model: Self.modelID
        ))
    }

    func testLiveRespondNonStreaming() async throws {
        let session = LanguageModelSession(instructions: "Answer in one word.")
        let response = try await session.respond(to: "Capital of France?")
        print("[LiveBackendTests] non-streaming content: \(response.content)")
        XCTAssertFalse(response.content.isEmpty, "expected non-empty content from live server")
    }

    func testLiveStreamingIsCumulative() async throws {
        let session = LanguageModelSession()
        var snapshots: [String] = []
        for try await snapshot in session.streamResponse(to: "Count: one two three") {
            snapshots.append(snapshot.content)
        }
        XCTAssertFalse(snapshots.isEmpty, "expected at least one streamed snapshot")
        for (previous, current) in zip(snapshots, snapshots.dropFirst()) {
            XCTAssertTrue(
                current.hasPrefix(previous),
                "snapshot '\(current)' is not cumulative over previous '\(previous)'"
            )
        }
        let final = snapshots.last ?? ""
        print("[LiveBackendTests] streaming final: \(final)")
        XCTAssertFalse(final.isEmpty, "expected non-empty final streamed content")
    }

    func testLiveGuidedGeneration() async throws {
        let session = LanguageModelSession(instructions: "Extract structured data.")
        let person = try await session.respond(
            to: "A person named Ada Lovelace who is 36 years old.",
            generating: Person.self
        ).content
        print("[LiveBackendTests] guided person: \(person)")
        XCTAssertFalse(person.name.isEmpty)
        XCTAssertGreaterThan(person.age, 0)
    }

    func testLiveMultiTurnHistory() async throws {
        let session = LanguageModelSession()
        _ = try await session.respond(to: "My favorite color is blue. Acknowledge briefly.")
        _ = try await session.respond(to: "What did I say my favorite color was?")
        XCTAssertEqual(session.transcript.count, 4) // 2 user + 2 assistant
    }
}
