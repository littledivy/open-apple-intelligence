#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import Foundation
import AppKit
import OpenFoundationModels

// Practical, WORKING host helper for AppKit (macOS). Mirrors the UIKit
// `UITextView` extension: run a Writing Tools action on an `NSTextView`'s current
// selection (or its whole text) and replace it in place. Fully functional — this
// is the macOS substitute for the non-polyfillable on-device inline-editing UI.

public extension NSTextView {

    /// Run a Writing Tools action on the current selection (or the whole text if
    /// nothing is selected) and replace it in place.
    ///
    /// - Returns: the replacement text that was inserted.
    @discardableResult
    @MainActor
    func applyWritingToolsAction(
        _ action: WritingToolsAction,
        options: GenerationOptions = GenerationOptions()
    ) async throws -> String {
        let ns = string as NSString
        let full = NSRange(location: 0, length: ns.length)
        let selected = selectedRange().length > 0 ? selectedRange() : full
        let source = ns.substring(with: selected)

        let replacement = try await WritingTools.apply(action, to: source, options: options)

        if shouldChangeText(in: selected, replacementString: replacement) {
            replaceCharacters(in: selected, with: replacement)
            didChangeText()
        } else {
            // Fallback for non-editable/uncontrolled cases.
            textStorage?.replaceCharacters(in: selected, with: replacement)
        }
        return replacement
    }

    /// Build an `NSMenu` of Writing Tools actions that each run on this text view's
    /// selection when chosen — a drop-in replacement for the system menu on macOS.
    @MainActor
    func writingToolsMenu(
        actions: [WritingToolsAction] = WritingToolsAction.allCases,
        onError: (@MainActor (Error) -> Void)? = nil
    ) -> NSMenu {
        let menu = NSMenu(title: "Writing Tools")
        for action in actions {
            let item = WritingToolsMenuItem(title: action.title, action: #selector(WritingToolsMenuItem.run), keyEquivalent: "")
            item.target = item
            item.action = #selector(WritingToolsMenuItem.run)
            item.configure(textView: self, wtAction: action, onError: onError)
            menu.addItem(item)
        }
        return menu
    }
}

/// A menu item that captures the text view + action so selecting it runs the
/// transform. (AppKit menu items need an Objective-C selector target.)
private final class WritingToolsMenuItem: NSMenuItem {
    private weak var textView: NSTextView?
    private var wtAction: WritingToolsAction = .proofread
    private var onError: (@MainActor (Error) -> Void)?

    func configure(
        textView: NSTextView,
        wtAction: WritingToolsAction,
        onError: (@MainActor (Error) -> Void)?
    ) {
        self.textView = textView
        self.wtAction = wtAction
        self.onError = onError
    }

    @MainActor @objc func run() {
        guard let textView else { return }
        let action = wtAction
        let onError = onError
        Task { @MainActor in
            do { try await textView.applyWritingToolsAction(action) }
            catch { onError?(error) }
        }
    }
}
#endif
