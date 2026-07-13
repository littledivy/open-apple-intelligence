import XCTest
import OpenFoundationModels
@testable import OpenWritingTools

/// Gated integration test that hits a real local OpenAI-compatible server.
/// Skipped unless `OFM_LIVE=1` is set (and a server is reachable at
/// `WritingTools.defaultLocalEndpoint`, e.g. llama.cpp on :8091 with `--jinja -np 1`).
final class LiveServerTests: XCTestCase {

    private var isLive: Bool { ProcessInfo.processInfo.environment["OFM_LIVE"] == "1" }
    private var endpoint: URL {
        URL(string: ProcessInfo.processInfo.environment["OFM_ENDPOINT"] ?? WritingTools.defaultLocalEndpoint.absoluteString)!
    }
    private var model: String { ProcessInfo.processInfo.environment["OFM_MODEL"] ?? "default" }

    func testLiveProofreadAgainstLocalServer() async throws {
        try XCTSkipUnless(isLive, "Set OFM_LIVE=1 with a local server running to enable this test.")

        // Explicitly route to the default local server (other test suites in this
        // process may already have installed a backend, so bootstrap won't re-run).
        WritingTools.useDefaultBackend(OpenAICompatibleBackend(endpoint: endpoint, model: model))
        let input = "teh cat sat on teh mat"
        let out = try await WritingTools.apply(.proofread, to: input)
        XCTAssertFalse(out.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        // A real proofread should fix the "teh" typos.
        print("[WritingTools.proofread] \(input) -> \(out)")
        XCTAssertFalse(out.lowercased().contains("teh "), "expected typo fixed, got: \(out)")
    }

    func testLiveStreaming() async throws {
        try XCTSkipUnless(isLive, "Set OFM_LIVE=1 with a local server running to enable this test.")
        WritingTools.useDefaultBackend(OpenAICompatibleBackend(endpoint: endpoint, model: model))
        var last = ""
        for try await partial in WritingTools.stream(.concise, "This is a rather long and verbose sentence that could be much shorter.") {
            last = partial
        }
        XCTAssertFalse(last.isEmpty)
    }
}
