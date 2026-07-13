import XCTest
import OpenFoundationModels
@testable import OpenFoundationModelsMLX

/// Live smoke tests that download a real model from Hugging Face and run
/// **actual on-device inference** via MLX on Apple Silicon.
///
/// These download ~300MB of weights on first run and use Metal, so they are
/// gated behind the `MLX_LIVE` environment variable and are skipped by
/// default — normal `swift test` stays offline and green.
///
/// These exercise `MLXBackend` directly via `GenerationRequest` rather than
/// going through `LanguageModelSession.respond(to: String)` / `Prompt`: the
/// latter currently crashes (stack overflow) due to infinite recursion in
/// `Prompt.promptRepresentation` <-> `PromptBuilder.buildBlock` in the core
/// `OpenFoundationModels` package (reproduced independently of MLX; out of
/// scope to fix here since it lives outside Integrations/MLX). Calling the
/// `ModelBackend` protocol directly with a hand-built `GenerationRequest`
/// avoids that path entirely and still proves real MLX load + inference.
///
/// Run with:
/// ```
/// MLX_LIVE=1 swift test --filter MLXLiveTests
/// ```
final class MLXLiveTests: XCTestCase {

    /// Smallest/fastest MLX-community instruct model, for quick smoke testing.
    private static let modelId = "mlx-community/Qwen2.5-0.5B-Instruct-4bit"

    // setUpWithError (not setUp) so `try XCTSkipUnless` actually skips — wrapping the
    // throw in `try?` would swallow the XCTSkip and run the tests anyway.
    override func setUpWithError() throws {
        try super.setUpWithError()
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["MLX_LIVE"] == "1",
            "Set MLX_LIVE=1 to run live MLX backend tests (downloads a real model and runs on-device inference)."
        )
    }

    func testLiveRespondNonStreaming() async throws {
        let backend = MLXBackend(modelId: Self.modelId)
        let request = GenerationRequest(prompt: "What is the capital of France? Answer in one word.")
        let content = try await backend.generate(request)
        print("[MLXLiveTests] non-streaming content: \(content)")
        XCTAssertFalse(content.isEmpty, "expected non-empty content from on-device MLX model")
    }

    func testLiveStreamingIsCumulative() async throws {
        let backend = MLXBackend(modelId: Self.modelId)
        let request = GenerationRequest(prompt: "Count from one to five.")
        var snapshots: [String] = []
        for try await snapshot in backend.stream(request) {
            snapshots.append(snapshot)
        }
        XCTAssertFalse(snapshots.isEmpty, "expected at least one streamed snapshot")
        for (previous, current) in zip(snapshots, snapshots.dropFirst()) {
            XCTAssertTrue(
                current.hasPrefix(previous),
                "snapshot '\(current)' is not cumulative over previous '\(previous)'"
            )
        }
        let final = snapshots.last ?? ""
        print("[MLXLiveTests] streaming final: \(final)")
        XCTAssertFalse(final.isEmpty, "expected non-empty final streamed content")
    }
}
