import Foundation

// MARK: - AssistantSchema value type
//
// Spec shapes:
//   public struct AssistantSchema : Swift.Sendable {}
//   public enum AssistantSchemas {
//     @_marker public protocol Model {}
//     @_marker public protocol Intent : Model {}
//     @_marker public protocol Entity : Model {}
//     @_marker public protocol Enum   : Model {}
//     public struct IntentSchema : Intent {}
//     public struct EntitySchema : Entity {}
//     public struct EnumSchema   : Enum   {}
//   }
//   extension AssistantSchema {
//     public struct IntentSchema : AssistantSchemas.Intent { init(_ identifier: String) }
//     public struct EntitySchema : AssistantSchemas.Entity { init(_ identifier: String) }
//     public struct EnumSchema   : AssistantSchemas.Enum   { init(_ identifier: String) }
//     public init(_ schema: some AssistantSchemas.Intent/Entity/Enum)
//   }
//
// The schema identifiers (e.g. "CreateDraftIntent", "files") are the domain-qualified
// values Apple ships. We reproduce them verbatim so schema references resolve to the
// same string identifiers, which is what the LocalAssistant registry keys off.

/// A description of a schema that an intent, entity, or enum conforms to.
/// Mirrors `AppIntents.AssistantSchema`.
public struct AssistantSchema: Sendable, Equatable {
    /// The stable identifier for this schema, e.g. `"CreateDraftIntent"`.
    public let identifier: String

    public init(_ schema: some AssistantSchemas.Intent) { self.identifier = schema.schemaIdentifier }
    public init(_ schema: some AssistantSchemas.Entity) { self.identifier = schema.schemaIdentifier }
    public init(_ schema: some AssistantSchemas.Enum)   { self.identifier = schema.schemaIdentifier }

    internal init(identifier: String) { self.identifier = identifier }
}

/// Namespace for assistant schema domains. Mirrors `AppIntents.AssistantSchemas`.
public enum AssistantSchemas {
    /// Base marker for any schema model. Mirrors `AssistantSchemas.Model`.
    public protocol Model: Sendable {
        /// The stable schema identifier this value represents.
        var schemaIdentifier: String { get }
    }

    /// Marker for intent schemas. Mirrors `AssistantSchemas.Intent`.
    public protocol Intent: Model {}
    /// Marker for entity schemas. Mirrors `AssistantSchemas.Entity`.
    public protocol Entity: Model {}
    /// Marker for enum schemas. Mirrors `AssistantSchemas.Enum`.
    public protocol Enum: Model {}

    /// Concrete intent schema value. Mirrors `AssistantSchemas.IntentSchema`.
    public struct IntentSchema: Intent {
        public let schemaIdentifier: String
        public init(_ identifier: String) { self.schemaIdentifier = identifier }
    }

    /// Concrete entity schema value. Mirrors `AssistantSchemas.EntitySchema`.
    public struct EntitySchema: Entity {
        public let schemaIdentifier: String
        public init(_ identifier: String) { self.schemaIdentifier = identifier }
    }

    /// Concrete enum schema value. Mirrors `AssistantSchemas.EnumSchema`.
    public struct EnumSchema: Enum {
        public let schemaIdentifier: String
        public init(_ identifier: String) { self.schemaIdentifier = identifier }
    }
}

// MARK: - AssistantSchema nested schema types
//
// The real framework exposes both `AssistantSchemas.IntentSchema` and
// `AssistantSchema.IntentSchema`. We provide the nested aliases for source parity.
public extension AssistantSchema {
    typealias IntentSchema = AssistantSchemas.IntentSchema
    typealias EntitySchema = AssistantSchemas.EntitySchema
    typealias EnumSchema = AssistantSchemas.EnumSchema
}
