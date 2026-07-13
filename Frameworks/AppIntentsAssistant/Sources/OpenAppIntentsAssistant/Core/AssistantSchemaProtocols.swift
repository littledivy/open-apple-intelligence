import Foundation

// MARK: - Assistant schema marker protocols
//
// Mirrors the assistant-schema protocol hierarchy from Apple's AppIntents
// `.swiftinterface`, with all `@available` gating stripped so it compiles on the
// package's deployment floor.
//
// Spec shapes (AppIntents.swiftinterface):
//   public protocol AssistantIntent : AppIntents.AppIntent {}
//   public protocol AssistantEntity : AppIntents.AppEntity {}
//   public protocol AssistantEnum  : AppIntents.AppEnum {}
//   public protocol AssistantSchemaIntent : AppIntents.AssistantIntent { static var isAssistantOnly: Bool { get } }
//   public protocol AssistantSchemaEntity : AppIntents.AssistantEntity { static var isAssistantOnly: Bool { get } }
//   public protocol AssistantSchemaEnum   : AppIntents.AssistantEnum   { static var isAssistantOnly: Bool { get } }

/// An intent that conforms to an assistant schema. Mirrors `AppIntents.AssistantIntent`.
public protocol AssistantIntent: AppIntent {}

/// An entity that conforms to an assistant schema. Mirrors `AppIntents.AssistantEntity`.
public protocol AssistantEntity: AppEntity {}

/// An enum that conforms to an assistant schema. Mirrors `AppIntents.AssistantEnum`.
public protocol AssistantEnum: AppEnum {}

/// A schema-conforming intent. The `@AssistantIntent(schema:)` macro synthesizes
/// conformance to this. Mirrors `AppIntents.AssistantSchemaIntent`.
public protocol AssistantSchemaIntent: AssistantIntent, ShowInAppSearchResultsIntent {
    static var isAssistantOnly: Bool { get }
}

public extension AssistantSchemaIntent {
    static var isAssistantOnly: Bool { true }
    /// The real framework derives `title` from the schema; the polyfill defaults it
    /// to the type name so schema-annotated intents need not declare a title.
    static var title: LocalizedStringResource { LocalizedStringResource("\(Self.self)") }
}

/// A schema-conforming entity. The `@AssistantEntity(schema:)` macro synthesizes
/// conformance to this. Mirrors `AppIntents.AssistantSchemaEntity`.
public protocol AssistantSchemaEntity: AssistantEntity {
    static var isAssistantOnly: Bool { get }
}

public extension AssistantSchemaEntity {
    static var isAssistantOnly: Bool { false }
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "\(Self.self)")
    }
}

/// A schema-conforming enum. The `@AssistantEnum(schema:)` macro synthesizes
/// conformance to this. Mirrors `AppIntents.AssistantSchemaEnum`.
public protocol AssistantSchemaEnum: AssistantEnum {
    static var isAssistantOnly: Bool { get }
}

public extension AssistantSchemaEnum {
    static var isAssistantOnly: Bool { false }
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "\(Self.self)")
    }
}
