import Foundation
import OpenFoundationModels

/// Source-compatible mirror of UIKit's `UIWritingToolsCoordinator`
/// (`UIWritingToolsCoordinator.h`), with Apple-Intelligence availability gating
/// stripped so code that references the coordinator, its delegate, and its nested
/// enums keeps compiling on older OSes and on macOS.
///
/// ## What is and isn't polyfillable
///
/// The real `UIWritingToolsCoordinator` is a `UIInteraction` that the system UI
/// drives: it inserts an inline-editing overlay into the responder chain, animates
/// text, and calls your delegate to fetch/replace ranges. **That system-UI
/// integration cannot be reproduced off-device** — it depends on private
/// system services and the Apple Intelligence overlay.
///
/// This type therefore provides:
/// - The **type surface** (init, delegate property, nested `State` / `TextReplacementReason`
///   / `ContextScope` enums, `Context`) so existing code compiles.
/// - A **functional bridge**, ``runWritingTools(_:on:)``, that actually performs a
///   transform against the LLM engine and delivers the replacement through the same
///   delegate `replaceRange:inContext:proposedText:` call the real coordinator uses —
///   so a host that implemented the delegate to drive real Writing Tools can be
///   exercised, tested, and even shipped on unsupported OSes.
///
/// For the pragmatic path most hosts want (run an action on a text view's
/// selection and get replacement text), see ``WritingTools/apply(_:to:options:)``
/// and the `UITextView`/`UIMenu` helpers under `#if canImport(UIKit)`.
public final class WritingToolsCoordinator {

    // MARK: Nested types (mirror UIWritingToolsCoordinator.*)

    /// Mirror of `UIWritingToolsCoordinator.State`.
    public enum State: Int, Sendable {
        case inactive
        case noninteractive
        case interactiveResting
        case interactiveStreaming
    }

    /// Mirror of `UIWritingToolsCoordinator.TextReplacementReason`.
    public enum TextReplacementReason: Int, Sendable {
        case noninteractive
        case interactive
        case animationEnded
    }

    /// Mirror of `UIWritingToolsCoordinator.TextUpdateReason`.
    public enum TextUpdateReason: Int, Sendable {
        case typing
        case undoRedo
    }

    /// Mirror of `UIWritingToolsCoordinator.ContextScope`.
    public enum ContextScope: Int, Sendable {
        case userSelection
        case visibleTextAndInputText
        case allText
    }

    /// Mirror of `UIWritingToolsCoordinator.Context` — a span of the host's text
    /// storage that Writing Tools may read and replace.
    public final class Context: @unchecked Sendable {
        /// The attributed text this context was initialized with.
        public let attributedString: NSAttributedString
        /// The range the context was initialized with.
        public let range: NSRange
        /// A stable identifier for this context.
        public let identifier: UUID
        /// The range where Writing Tools suggests replacements; may be larger than
        /// `range`. Mirrors `resolvedRange`; here it defaults to `range`.
        public var resolvedRange: NSRange

        public init(attributedString: NSAttributedString, range: NSRange) {
            self.attributedString = attributedString
            self.range = range
            self.identifier = UUID()
            self.resolvedRange = range
        }
    }

    // MARK: Stored properties (mirror UIWritingToolsCoordinator)

    /// The delegate that supplies contexts and applies replacements.
    public private(set) weak var delegate: (any WritingToolsCoordinatorDelegate)?

    /// The current activity state. Driven by ``runWritingTools(_:on:)``.
    public private(set) var state: State = .inactive

    /// The host's preferred behavior. Mirrors `preferredBehavior`.
    public var preferredBehavior: WritingToolsBehavior = .default

    /// The resolved behavior. Off-device this simply reflects `preferredBehavior`
    /// (resolving `.default`) since there is no system to consult.
    public var behavior: WritingToolsBehavior {
        preferredBehavior == .default ? .complete : preferredBehavior
    }

    /// The host's preferred result options. Mirrors `preferredResultOptions`.
    public var preferredResultOptions: WritingToolsResultOptions = .default

    /// The resolved result options. Off-device reflects `preferredResultOptions`.
    public var resultOptions: WritingToolsResultOptions { preferredResultOptions }

    /// Mirror of `UIWritingToolsCoordinator.isWritingToolsAvailable`.
    ///
    /// The polyfill's transforms are available whenever a backend is configured,
    /// which cannot be determined synchronously here, so this reports `true` to
    /// signal that the polyfilled surface is usable. Gate real UI on the OS check
    /// in your host if you need the genuine system feature.
    public static var isWritingToolsAvailable: Bool { true }

    // MARK: Init (mirror initWithDelegate:)

    /// Create a coordinator. Mirrors `-initWithDelegate:`.
    public init(delegate: (any WritingToolsCoordinatorDelegate)?) {
        self.delegate = delegate
    }

    // MARK: Control (mirror stopWritingTools)

    /// Stop any in-flight Writing Tools activity. Mirrors `-stopWritingTools`.
    public func stopWritingTools() {
        transitionState(to: .inactive)
    }

    // MARK: Functional bridge

    /// Run a Writing Tools transform through the LLM engine and deliver the result
    /// to the delegate via `writingToolsCoordinator(_:replaceRange:in:proposedText:reason:completion:)`,
    /// exactly as the real coordinator would after Apple Intelligence produced text.
    ///
    /// This is what makes the polyfilled coordinator *do* something off-device: it
    /// fetches contexts from the delegate for the requested scope, transforms each
    /// context's text, and hands back proposed replacements. The host's delegate is
    /// responsible for actually mutating its text storage (as with the real API).
    ///
    /// - Parameters:
    ///   - action: the transform to apply.
    ///   - scope: which text to operate on. Requested from the delegate.
    public func runWritingTools(
        _ action: WritingToolsAction,
        on scope: ContextScope = .userSelection
    ) async throws {
        guard let delegate else { return }
        transitionState(to: .noninteractive)
        let contexts = await delegate.writingToolsCoordinator(self, contextsFor: scope)
        transitionState(to: .interactiveStreaming)
        for context in contexts {
            let source = context.attributedString.attributedSubstring(from: clamp(context.range, to: context.attributedString.length))
            let transformed = try await WritingTools.apply(action, to: source.string)
            let proposed = NSAttributedString(string: transformed)
            await delegate.writingToolsCoordinator(
                self,
                replaceRange: context.range,
                in: context,
                proposedText: proposed,
                reason: .interactive
            )
        }
        transitionState(to: .interactiveResting)
    }

    // MARK: Private

    private func transitionState(to newState: State) {
        state = newState
        delegate?.writingToolsCoordinator(self, willChangeTo: newState)
    }

    private func clamp(_ range: NSRange, to length: Int) -> NSRange {
        let location = max(0, min(range.location, length))
        let len = max(0, min(range.length, length - location))
        return NSRange(location: location, length: len)
    }
}

/// Source-compatible mirror of `UIWritingToolsCoordinatorDelegate`
/// (`UIWritingToolsCoordinator.Delegate`), reduced to the two methods the polyfill
/// can actually drive off-device: supplying contexts and applying replacements.
///
/// The full protocol has ~15 methods for animation previews, bezier paths, and
/// decoration containers that only matter for the on-device inline-editing UI;
/// those are intentionally omitted because they are not polyfillable and requiring
/// hosts to implement them would be misleading.
public protocol WritingToolsCoordinatorDelegate: AnyObject {

    /// Supply the contexts (text spans) Writing Tools should operate on for the
    /// given scope. Mirrors
    /// `writingToolsCoordinator(_:requestsContextsFor:completion:)`.
    func writingToolsCoordinator(
        _ coordinator: WritingToolsCoordinator,
        contextsFor scope: WritingToolsCoordinator.ContextScope
    ) async -> [WritingToolsCoordinator.Context]

    /// Apply a proposed replacement to your text storage. Mirrors
    /// `writingToolsCoordinator(_:replaceRange:inContext:proposedText:reason:animationParameters:completion:)`.
    func writingToolsCoordinator(
        _ coordinator: WritingToolsCoordinator,
        replaceRange range: NSRange,
        in context: WritingToolsCoordinator.Context,
        proposedText replacementText: NSAttributedString,
        reason: WritingToolsCoordinator.TextReplacementReason
    ) async

    /// Notifies the delegate of a state change. Mirrors
    /// `writingToolsCoordinator(_:willChangeTo:completion:)`. Optional.
    func writingToolsCoordinator(
        _ coordinator: WritingToolsCoordinator,
        willChangeTo newState: WritingToolsCoordinator.State
    )
}

public extension WritingToolsCoordinatorDelegate {
    func writingToolsCoordinator(
        _ coordinator: WritingToolsCoordinator,
        willChangeTo newState: WritingToolsCoordinator.State
    ) {}
}
