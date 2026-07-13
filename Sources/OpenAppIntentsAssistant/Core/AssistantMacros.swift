import Foundation

// MARK: - Assistant schema attached macro declarations
//
// Spec shapes (with `@available` gating stripped):
//   @attached(memberAttribute)
//   @attached(extension, conformances: AppEntity, AssistantSchemaEntity, names: named(__assistantSchemaEntity))
//   macro AssistantEntity<T>(schema: T) where T : AssistantSchemas.Entity
//
//   @attached(memberAttribute)
//   @attached(extension, conformances: AssistantSchemaIntent, ShowInAppSearchResultsIntent, names: named(__assistantSchemaIntent))
//   macro AssistantIntent<T>(schema: T) where T : AssistantSchemas.Intent
//
//   @attached(extension, conformances: AssistantSchemaEnum, names: named(__assistantSchemaEnum))
//   macro AssistantEnum<T>(schema: T) where T : AssistantSchemas.Enum
//
// In the real framework these hook a type into the system Assistant. In the polyfill
// they expand to REAL, working conformances plus a stored `__assistantSchema*`
// property that records the schema value. That property is a genuine protocol witness
// (see `SchemaCarrying*` protocols below) which the LocalAssistant registry reads to
// discover a type's schema at runtime — no placeholders. The one thing the polyfill
// cannot do is route into the OS system Assistant (no public hook); everything else
// works in-process.

/// A type whose assistant schema is discoverable at runtime. Synthesized by the
/// `@AssistantIntent` macro.
public protocol SchemaCarryingIntent {
    static var __assistantSchemaIdentifier: String { get }
}

/// A type whose assistant schema is discoverable at runtime. Synthesized by the
/// `@AssistantEntity` macro.
public protocol SchemaCarryingEntity {
    static var __assistantSchemaIdentifier: String { get }
}

/// A type whose assistant schema is discoverable at runtime. Synthesized by the
/// `@AssistantEnum` macro.
public protocol SchemaCarryingEnum {
    static var __assistantSchemaIdentifier: String { get }
}

/// Marks an `AppIntent` as conforming to an assistant schema. Mirrors
/// `AppIntents.@AssistantIntent(schema:)`. Expands to real `AssistantSchemaIntent`,
/// `ShowInAppSearchResultsIntent`, and `SchemaCarryingIntent` conformances plus a
/// `__assistantSchemaIdentifier` recording the schema's stable identifier.
@attached(member, names: named(__assistantSchemaIdentifier))
@attached(extension, conformances: AssistantSchemaIntent, ShowInAppSearchResultsIntent, SchemaCarryingIntent)
public macro AssistantIntent<T: AssistantSchemas.Intent>(schema: T) =
    #externalMacro(module: "OpenAppIntentsAssistantMacros", type: "AssistantIntentMacro")

/// Marks an `AppEntity` as conforming to an assistant schema. Mirrors
/// `AppIntents.@AssistantEntity(schema:)`.
@attached(member, names: named(__assistantSchemaIdentifier))
@attached(extension, conformances: AssistantSchemaEntity, SchemaCarryingEntity)
public macro AssistantEntity<T: AssistantSchemas.Entity>(schema: T) =
    #externalMacro(module: "OpenAppIntentsAssistantMacros", type: "AssistantEntityMacro")

/// Marks an `AppEnum` as conforming to an assistant schema. Mirrors
/// `AppIntents.@AssistantEnum(schema:)`.
@attached(member, names: named(__assistantSchemaIdentifier))
@attached(extension, conformances: AssistantSchemaEnum, SchemaCarryingEnum)
public macro AssistantEnum<T: AssistantSchemas.Enum>(schema: T) =
    #externalMacro(module: "OpenAppIntentsAssistantMacros", type: "AssistantEnumMacro")
