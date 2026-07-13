import Foundation

/// The universal serialization currency for guided generation. Mirrors
/// `FoundationModels.GeneratedContent`.
///
/// A `GeneratedContent` wraps a `Kind` (null / bool / number / string / array /
/// structure) and can round-trip to and from JSON. Every `Generable` type is
/// convertible to and from this representation.
public struct GeneratedContent: Sendable, Equatable, Generable, CustomDebugStringConvertible {

    // MARK: Kind

    /// The concrete shape of a piece of generated content.
    public enum Kind: Equatable, Sendable {
        case null
        case bool(Bool)
        case number(Double)
        case string(String)
        case array([GeneratedContent])
        case structure(properties: [String: GeneratedContent], orderedKeys: [String])
    }

    // MARK: Stored properties

    /// The wrapped value.
    public var kind: Kind

    /// An optional identity, used to correlate partial-generation snapshots.
    public var id: GenerationID?

    /// Whether this content represents a fully-generated (non-partial) value.
    /// Partial snapshots created during streaming set this to `false`.
    private var complete: Bool

    // MARK: Designated init

    public init(kind: Kind, id: GenerationID? = nil) {
        self.kind = kind
        self.id = id
        self.complete = true
    }

    private init(kind: Kind, id: GenerationID?, isComplete: Bool) {
        self.kind = kind
        self.id = id
        self.complete = isComplete
    }

    // MARK: Convenience inits

    /// Wraps any convertible value.
    public init(_ value: some ConvertibleToGeneratedContent) {
        self = value.generatedContent
    }

    /// Wraps any convertible value, assigning it an identity.
    public init(_ value: some ConvertibleToGeneratedContent, id: GenerationID) {
        var content = value.generatedContent
        content.id = id
        self = content
    }

    /// Builds a structure from ordered key/value pairs.
    public init(
        properties: KeyValuePairs<String, any ConvertibleToGeneratedContent>,
        id: GenerationID? = nil
    ) {
        var dict: [String: GeneratedContent] = [:]
        var order: [String] = []
        for (key, value) in properties {
            dict[key] = value.generatedContent
            order.append(key)
        }
        self.init(kind: .structure(properties: dict, orderedKeys: order), id: id)
    }

    /// Builds a structure from a sequence of key/value pairs, resolving
    /// duplicate keys with the supplied combining closure.
    public init<S>(
        properties: S,
        id: GenerationID? = nil,
        uniquingKeysWith combine: (GeneratedContent, GeneratedContent) throws -> some ConvertibleToGeneratedContent
    ) rethrows where S: Sequence, S.Element == (String, any ConvertibleToGeneratedContent) {
        var dict: [String: GeneratedContent] = [:]
        var order: [String] = []
        for (key, value) in properties {
            let incoming = value.generatedContent
            if let existing = dict[key] {
                dict[key] = try combine(existing, incoming).generatedContent
            } else {
                dict[key] = incoming
                order.append(key)
            }
        }
        self.init(kind: .structure(properties: dict, orderedKeys: order), id: id)
    }

    /// Builds an array from a sequence of convertible elements.
    public init<S>(
        elements: S,
        id: GenerationID? = nil
    ) where S: Sequence, S.Element == any ConvertibleToGeneratedContent {
        let items = elements.map { $0.generatedContent }
        self.init(kind: .array(items), id: id)
    }

    /// Parses a JSON string into generated content.
    public init(json: String) throws {
        guard let data = json.data(using: .utf8) else {
            throw GenerationSchema.SchemaError.decodingFailure("Invalid UTF-8 in JSON string.")
        }
        let object = try JSONSerialization.jsonObject(
            with: data,
            options: [.fragmentsAllowed]
        )
        self.init(kind: GeneratedContent.kind(fromJSONObject: object))
    }

    // MARK: Generable conformance

    /// Passthrough required by `ConvertibleFromGeneratedContent`.
    public init(_ content: GeneratedContent) throws {
        self = content
    }

    public var generatedContent: GeneratedContent { self }

    public static var generationSchema: GenerationSchema {
        GenerationSchema(anyType: "GeneratedContent", description: nil)
    }

    // MARK: JSON serialization

    /// Serializes this content to a JSON string.
    public var jsonString: String {
        let object = GeneratedContent.jsonObject(from: kind)
        if JSONSerialization.isValidJSONObject(object) {
            if let data = try? JSONSerialization.data(
                withJSONObject: object,
                options: [.sortedKeys]
            ), let string = String(data: data, encoding: .utf8) {
                return string
            }
        }
        // Fragment (scalar) values are not valid top-level JSON objects for
        // JSONSerialization; encode them directly.
        return GeneratedContent.fragmentString(from: kind)
    }

    // MARK: Value accessors

    /// Decodes the content as the requested type.
    public func value<Value>(
        _ type: Value.Type = Value.self
    ) throws -> Value where Value: ConvertibleFromGeneratedContent {
        try Value(self)
    }

    /// Decodes a named property of a structure as the requested type.
    public func value<Value>(
        _ type: Value.Type = Value.self,
        forProperty property: String
    ) throws -> Value where Value: ConvertibleFromGeneratedContent {
        guard case let .structure(properties, _) = kind else {
            throw GenerationSchema.SchemaError.decodingFailure(
                "Expected a structure to read property '\(property)'."
            )
        }
        guard let child = properties[property] else {
            throw GenerationSchema.SchemaError.decodingFailure(
                "Missing property '\(property)'."
            )
        }
        return try Value(child)
    }

    /// Decodes an optional named property; returns `nil` when absent or null.
    public func value<Value>(
        _ type: Value?.Type = Value?.self,
        forProperty property: String
    ) throws -> Value? where Value: ConvertibleFromGeneratedContent {
        guard case let .structure(properties, _) = kind else {
            throw GenerationSchema.SchemaError.decodingFailure(
                "Expected a structure to read property '\(property)'."
            )
        }
        guard let child = properties[property] else { return nil }
        if case .null = child.kind { return nil }
        return try Value(child)
    }

    // MARK: Misc

    public var isComplete: Bool { complete }

    public var debugDescription: String {
        "GeneratedContent(\(jsonString))"
    }

    public static func == (a: GeneratedContent, b: GeneratedContent) -> Bool {
        a.kind == b.kind
    }

    // MARK: - Internal helpers

    /// Creates a partial (streaming) snapshot with `isComplete == false`.
    static func partial(kind: Kind, id: GenerationID? = nil) -> GeneratedContent {
        GeneratedContent(kind: kind, id: id, isComplete: false)
    }

    private static func kind(fromJSONObject object: Any) -> Kind {
        switch object {
        case is NSNull:
            return .null
        case let number as NSNumber:
            // Distinguish Bool from numeric NSNumber.
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return .bool(number.boolValue)
            }
            return .number(number.doubleValue)
        case let string as String:
            return .string(string)
        case let array as [Any]:
            return .array(array.map { GeneratedContent(kind: kind(fromJSONObject: $0)) })
        case let dictionary as [String: Any]:
            var props: [String: GeneratedContent] = [:]
            var order: [String] = []
            for (key, value) in dictionary {
                props[key] = GeneratedContent(kind: kind(fromJSONObject: value))
                order.append(key)
            }
            return .structure(properties: props, orderedKeys: order.sorted())
        default:
            return .null
        }
    }

    private static func jsonObject(from kind: Kind) -> Any {
        switch kind {
        case .null:
            return NSNull()
        case let .bool(value):
            return value
        case let .number(value):
            return value
        case let .string(value):
            return value
        case let .array(items):
            return items.map { jsonObject(from: $0.kind) }
        case let .structure(properties, orderedKeys):
            var dict: [String: Any] = [:]
            let keys = orderedKeys.isEmpty ? Array(properties.keys) : orderedKeys
            for key in keys {
                if let value = properties[key] {
                    dict[key] = jsonObject(from: value.kind)
                }
            }
            return dict
        }
    }

    private static func fragmentString(from kind: Kind) -> String {
        switch kind {
        case .null:
            return "null"
        case let .bool(value):
            return value ? "true" : "false"
        case let .number(value):
            if value == value.rounded(), abs(value) < 1e15 {
                return String(Int64(value))
            }
            return String(value)
        case let .string(value):
            let escaped = value
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\"", with: "\\\"")
                .replacingOccurrences(of: "\n", with: "\\n")
                .replacingOccurrences(of: "\r", with: "\\r")
                .replacingOccurrences(of: "\t", with: "\\t")
            return "\"\(escaped)\""
        case .array, .structure:
            // Should have been handled by JSONSerialization above.
            return "null"
        }
    }
}
