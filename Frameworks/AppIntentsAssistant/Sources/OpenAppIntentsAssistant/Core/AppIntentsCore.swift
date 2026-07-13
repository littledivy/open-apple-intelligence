import Foundation

// MARK: - Minimal AppIntents base surface
//
// The real `AppIntent` / `AppEntity` / `AppEnum` protocols live in Apple's AppIntents
// framework (which ships to all supported OSes). We deliberately DO NOT
// `import AppIntents` here: importing it would pull in the real `AssistantSchema*`
// types on new OSes and cause redeclaration ambiguity with the mirrored types below.
//
// Instead we provide a tiny, self-contained base surface just large enough for the
// assistant-schema polyfill and the LocalAssistant router to compile and run offline.
// If you need the full AppIntents surface, use Apple's framework directly on a
// supported OS; this polyfill targets the assistant-schema *source shape*, not the
// entire AppIntents API.

/// A localized, human-readable representation of a type. Mirrors
/// `AppIntents.TypeDisplayRepresentation` in shape (name only).
public struct TypeDisplayRepresentation: Sendable, Equatable {
    public var name: String
    public init(name: String) { self.name = name }
    public init(stringLiteral value: String) { self.name = value }
}

extension TypeDisplayRepresentation: ExpressibleByStringLiteral {}

/// Base protocol for an executable intent. Mirrors `AppIntents.AppIntent`.
///
/// The real `AppIntent` requires `static var title` plus a `perform()` returning an
/// `IntentResult`. We keep the two members app authors actually implement.
public protocol AppIntent: Sendable {
    /// A user-visible title for the intent.
    static var title: LocalizedStringResource { get }

    init()

    /// Performs the intent and returns a result value.
    @discardableResult
    func perform() async throws -> IntentResultValue
}

/// A minimal result value returned from `AppIntent.perform()`. The real AppIntents
/// framework has a rich `IntentResult` builder family; for the polyfill a dialog
/// string plus an optional opaque value is enough to drive the LocalAssistant demo.
public struct IntentResultValue: Sendable {
    public var dialog: String?
    public init(dialog: String? = nil) { self.dialog = dialog }

    /// Convenience for "no visible result".
    public static var none: IntentResultValue { IntentResultValue() }
    /// A spoken/printed reply.
    public static func result(dialog: String) -> IntentResultValue { IntentResultValue(dialog: dialog) }
}

/// Base protocol for an app entity. Mirrors `AppIntents.AppEntity`.
public protocol AppEntity: Sendable {
    static var typeDisplayRepresentation: TypeDisplayRepresentation { get }
}

/// Base protocol for an app enum. Mirrors `AppIntents.AppEnum`.
public protocol AppEnum: Sendable {}

/// Present in-app search results. Mirrors `AppIntents.ShowInAppSearchResultsIntent`.
public protocol ShowInAppSearchResultsIntent: AppIntent {}

// MARK: - LocalizedStringResource shim
//
// `LocalizedStringResource` is a Foundation type on new OSes but is `@available`-gated.
// To keep the polyfill buildable on the declared floor (macOS 13 / iOS 16) we provide
// a lightweight stand-in that is source-compatible for the string-literal usage app
// code relies on for intent titles.
public struct LocalizedStringResource: Sendable, Equatable, ExpressibleByStringLiteral, CustomStringConvertible {
    public var key: String
    public init(_ key: String) { self.key = key }
    public init(stringLiteral value: String) { self.key = value }
    public var description: String { key }
}
