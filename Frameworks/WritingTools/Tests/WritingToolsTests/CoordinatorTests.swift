import XCTest
import Foundation
import OpenFoundationModels
@testable import OpenWritingTools

/// Proves the mirrored `WritingToolsCoordinator` actually transforms text
/// in-process via its delegate callbacks (not a compile-only shell).
final class CoordinatorTests: XCTestCase {

    override func setUp() {
        super.setUp()
        WritingTools.useDefaultBackend(EchoBackend { req in
            let body = (req.messages.last?.text ?? req.prompt).replacingOccurrences(of: "Text:\n", with: "")
            return "REWRITTEN: \(body)"
        })
    }

    /// A minimal host that stores text and applies the coordinator's replacements —
    /// exactly what a real UITextView-backed delegate would do.
    final class FakeHost: WritingToolsCoordinatorDelegate {
        var storage: NSMutableAttributedString
        var stateChanges: [WritingToolsCoordinator.State] = []
        init(_ text: String) { storage = NSMutableAttributedString(string: text) }

        func writingToolsCoordinator(
            _ coordinator: WritingToolsCoordinator,
            contextsFor scope: WritingToolsCoordinator.ContextScope
        ) async -> [WritingToolsCoordinator.Context] {
            let range = NSRange(location: 0, length: storage.length)
            return [WritingToolsCoordinator.Context(attributedString: storage, range: range)]
        }

        func writingToolsCoordinator(
            _ coordinator: WritingToolsCoordinator,
            replaceRange range: NSRange,
            in context: WritingToolsCoordinator.Context,
            proposedText replacementText: NSAttributedString,
            reason: WritingToolsCoordinator.TextReplacementReason
        ) async {
            storage.replaceCharacters(in: range, with: replacementText)
        }

        func writingToolsCoordinator(
            _ coordinator: WritingToolsCoordinator,
            willChangeTo newState: WritingToolsCoordinator.State
        ) {
            stateChanges.append(newState)
        }
    }

    func testCoordinatorTransformsTextThroughDelegate() async throws {
        let host = FakeHost("some rough draft")
        let coordinator = WritingToolsCoordinator(delegate: host)
        XCTAssertEqual(coordinator.state, .inactive)

        try await coordinator.runWritingTools(.rewrite, on: .allText)

        XCTAssertEqual(host.storage.string, "REWRITTEN: some rough draft")
        XCTAssertEqual(coordinator.state, .interactiveResting)
        XCTAssertTrue(host.stateChanges.contains(.interactiveStreaming))
    }

    func testCoordinatorMirrorsUIKitConstants() {
        XCTAssertTrue(WritingToolsCoordinator.isWritingToolsAvailable)
        let c = WritingToolsCoordinator(delegate: nil)
        c.preferredBehavior = .default
        XCTAssertEqual(c.behavior, .complete) // default resolves off-device
        c.stopWritingTools()
        XCTAssertEqual(c.state, .inactive)
    }
}
