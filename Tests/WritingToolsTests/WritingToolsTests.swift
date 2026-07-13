import XCTest
import OpenFoundationModels
@testable import OpenWritingTools

/// Offline tests: drive the transform engine with a deterministic `EchoBackend`
/// so no network/model is required. The echo transform inspects the request's
/// system instruction to prove each action reaches the model with its tuned
/// prompt, and returns a per-action transformed string so assertions are meaningful.
final class WritingToolsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Register a deterministic backend *and* mark configuration done so the
        // zero-config bootstrap does not override it. Uses useDefaultBackend so the
        // .always strategy is set and the fallback path is skipped.
        WritingTools.useDefaultBackend(EchoBackend { request in
            // The instruction encodes the action; produce a distinct, obviously
            // transformed reply per task so each action is verifiable offline.
            let instr = request.messages.first(where: { $0.role == .system })?.text ?? ""
            let user = request.messages.last(where: { $0.role == .user })?.text ?? request.prompt
            let body = user.replacingOccurrences(of: "Text:\n", with: "")
            if instr.contains("Correct spelling") { return "PROOFREAD: \(body)" }
            if instr.contains("reads more clearly") { return "REWRITTEN: \(body)" }
            if instr.contains("warm, friendly") { return "Hey! \(body) 😊" }
            if instr.contains("formal, professional") { return "Dear Sir/Madam, \(body)" }
            if instr.contains("as concise as possible") { return "Concise." }
            if instr.contains("brief prose summary") { return "Summary of the text." }
            if instr.contains("key points as a Markdown") { return "- point one\n- point two" }
            if instr.contains("Markdown bulleted list") { return "- item one\n- item two" }
            if instr.contains("Markdown table") { return "| A | B |\n| - | - |\n| 1 | 2 |" }
            return body
        })
    }

    private let sample = "teh quick borwn fox jumpz over the lazy dog"

    func testEveryActionProducesTransformedOutput() async throws {
        for action in WritingToolsAction.allCases {
            let out = try await WritingTools.apply(action, to: sample)
            XCTAssertFalse(out.isEmpty, "\(action) produced empty output")
            XCTAssertNotEqual(out, sample, "\(action) did not transform the input")
        }
    }

    func testProofreadReachesProofreadInstruction() async throws {
        let out = try await WritingTools.apply(.proofread, to: sample)
        XCTAssertTrue(out.hasPrefix("PROOFREAD:"), "got: \(out)")
        XCTAssertTrue(out.contains(sample))
    }

    func testRewriteReachesRewriteInstruction() async throws {
        let out = try await WritingTools.apply(.rewrite, to: sample)
        XCTAssertTrue(out.hasPrefix("REWRITTEN:"), "got: \(out)")
    }

    func testToneActions() async throws {
        let friendly = try await WritingTools.apply(.friendly, to: sample)
        XCTAssertTrue(friendly.contains("Hey!"), "got: \(friendly)")
        let professional = try await WritingTools.apply(.professional, to: sample)
        XCTAssertTrue(professional.contains("Dear Sir/Madam"), "got: \(professional)")
    }

    func testStructuralActionsProduceMarkdown() async throws {
        let list = try await WritingTools.apply(.list, to: sample)
        XCTAssertTrue(list.contains("- item"), "got: \(list)")
        let keyPoints = try await WritingTools.apply(.keyPoints, to: sample)
        XCTAssertTrue(keyPoints.contains("- point"), "got: \(keyPoints)")
        let table = try await WritingTools.apply(.table, to: sample)
        XCTAssertTrue(table.contains("|"), "got: \(table)")
    }

    func testStreamYieldsCumulativeSnapshots() async throws {
        var snapshots: [String] = []
        for try await partial in WritingTools.stream(.rewrite, sample) {
            snapshots.append(partial)
        }
        XCTAssertFalse(snapshots.isEmpty, "stream yielded nothing")
        // EchoBackend streams word-by-word cumulatively; each snapshot should grow.
        for i in 1..<snapshots.count {
            XCTAssertGreaterThanOrEqual(snapshots[i].count, snapshots[i - 1].count)
        }
        XCTAssertEqual(snapshots.last, "REWRITTEN: \(sample)")
    }

    func testEmptyInputIsReturnedUnchanged() async throws {
        let out = try await WritingTools.apply(.proofread, to: "   ")
        XCTAssertEqual(out, "   ")
    }

    // MARK: Mirrored UIKit surface (OS-independent enums)

    func testBehaviorRawValuesMatchUIKit() {
        XCTAssertEqual(WritingToolsBehavior.none.rawValue, -1)
        XCTAssertEqual(WritingToolsBehavior.default.rawValue, 0)
        XCTAssertEqual(WritingToolsBehavior.complete.rawValue, 1)
        XCTAssertEqual(WritingToolsBehavior.limited.rawValue, 2)
    }

    func testResultOptionsBitmask() {
        XCTAssertEqual(WritingToolsResultOptions.default.rawValue, 0)
        XCTAssertEqual(WritingToolsResultOptions.plainText.rawValue, 1)
        XCTAssertEqual(WritingToolsResultOptions.richText.rawValue, 2)
        XCTAssertEqual(WritingToolsResultOptions.list.rawValue, 4)
    }
}
