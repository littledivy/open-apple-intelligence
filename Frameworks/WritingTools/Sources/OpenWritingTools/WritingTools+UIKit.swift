#if canImport(UIKit)
import Foundation
import UIKit
import OpenFoundationModels

// Practical, WORKING host helpers for the polyfilled Writing Tools. These do not
// require the on-device system UI: they run a transform on a text view's current
// selection (or its whole text) and replace it in place. This is the pragmatic
// substitute for the non-polyfillable inline-editing overlay.

@available(iOS 16.0, *)
public extension UITextView {

    /// Run a Writing Tools action on the current selection (or the whole text if
    /// nothing is selected) and replace it in place.
    ///
    /// - Parameters:
    ///   - action: the transform to run.
    ///   - options: generation options forwarded to the model.
    /// - Returns: the replacement text that was inserted.
    /// - Throws: whatever the underlying model throws.
    @discardableResult
    @MainActor
    func applyWritingToolsAction(
        _ action: WritingToolsAction,
        options: GenerationOptions = GenerationOptions()
    ) async throws -> String {
        let ns = text as NSString? ?? ""
        let full = NSRange(location: 0, length: ns.length)
        let selected = selectedRange.length > 0 ? selectedRange : full
        let source = ns.substring(with: selected)

        let replacement = try await WritingTools.apply(action, to: source, options: options)

        if let start = position(from: beginningOfDocument, offset: selected.location),
           let end = position(from: start, offset: selected.length),
           let textRange = textRange(from: start, to: end) {
            replace(textRange, withText: replacement)
        } else {
            // Fallback: replace the whole text.
            text = replacement
        }
        return replacement
    }

    /// Build a `UIMenu` of Writing Tools actions that each run on this text view's
    /// selection when chosen — a drop-in replacement for the system menu on OSes
    /// without Apple Intelligence.
    ///
    /// - Parameters:
    ///   - actions: which actions to include (defaults to all).
    ///   - onError: called on the main actor if a transform throws.
    @MainActor
    func writingToolsMenu(
        actions: [WritingToolsAction] = WritingToolsAction.allCases,
        onError: (@MainActor (Error) -> Void)? = nil
    ) -> UIMenu {
        let items: [UIAction] = actions.map { action in
            UIAction(title: action.title) { [weak self] _ in
                guard let self else { return }
                Task { @MainActor in
                    do { try await self.applyWritingToolsAction(action) }
                    catch { onError?(error) }
                }
            }
        }
        return UIMenu(title: "Writing Tools", children: items)
    }
}
#endif
