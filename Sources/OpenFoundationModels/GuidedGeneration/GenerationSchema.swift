import Foundation

/// A description of how a `Generable` type should be generated, convertible to
/// a JSON-Schema string for constrained decoding. Mirrors
/// `FoundationModels.GenerationSchema`.
public struct GenerationSchema: Sendable, Codable, CustomDebugStringConvertible {

    // MARK: - Internal representation

    /// The primitive JSON-Schema types this schema can describe.
    enum Primitive: String, Sendable, Codable {
        case string, integer, number, boolean, null, object, array
    }

    /// Internal node describing the schema tree. Accessible within the module so
    /// backends can emit constrained-decoding grammars.
    indirect enum Node: Sendable {
        case primitive(Primitive)
        /// An object schema with ordered named properties.
        case object(properties: [PropertyNode])
        /// An array schema wrapping an item schema.
        case array(item: Node)
        /// A string enumeration (`anyOf` over string literals).
        case stringEnum([String])
        /// A union over sub-schemas.
        case anyOf([Node])
    }

    /// A single property inside an object schema.
    struct PropertyNode: Sendable {
        var name: String
        var description: String?
        var node: Node
        var isOptional: Bool
        var constraints: [GuideConstraint]
    }

    /// The type name this schema describes (used in debug output).
    let typeName: String?
    /// An optional human description of the type.
    let schemaDescription: String?
    /// The root schema node.
    let node: Node

    // MARK: - Public Property

    /// Describes a single property of an object schema. Mirrors
    /// `FoundationModels.GenerationSchema.Property`.
    public struct Property: Sendable {
        let node: PropertyNode

        public init<Value>(
            name: String,
            description: String? = nil,
            type: Value.Type,
            guides: [GenerationGuide<Value>] = []
        ) where Value: Generable {
            self.node = PropertyNode(
                name: name,
                description: description,
                node: Value.generationSchema.node,
                isOptional: false,
                constraints: guides.map(\.constraint)
            )
        }

        public init<Value>(
            name: String,
            description: String? = nil,
            type: Value?.Type,
            guides: [GenerationGuide<Value>] = []
        ) where Value: Generable {
            self.node = PropertyNode(
                name: name,
                description: description,
                node: Value.generationSchema.node,
                isOptional: true,
                constraints: guides.map(\.constraint)
            )
        }

        public init<RegexOutput>(
            name: String,
            description: String? = nil,
            type: String.Type,
            guides: [Regex<RegexOutput>] = []
        ) {
            self.node = PropertyNode(
                name: name,
                description: description,
                node: .primitive(.string),
                isOptional: false,
                constraints: guides.map { .pattern(String(describing: $0)) }
            )
        }

        public init<RegexOutput>(
            name: String,
            description: String? = nil,
            type: String?.Type,
            guides: [Regex<RegexOutput>] = []
        ) {
            self.node = PropertyNode(
                name: name,
                description: description,
                node: .primitive(.string),
                isOptional: true,
                constraints: guides.map { .pattern(String(describing: $0)) }
            )
        }
    }

    // MARK: - Public inits

    public init(
        type: any Generable.Type,
        description: String? = nil,
        properties: [GenerationSchema.Property]
    ) {
        self.typeName = String(describing: type)
        self.schemaDescription = description
        self.node = .object(properties: properties.map(\.node))
    }

    public init(
        type: any Generable.Type,
        description: String? = nil,
        anyOf choices: [String]
    ) {
        self.typeName = String(describing: type)
        self.schemaDescription = description
        self.node = .stringEnum(choices)
    }

    public init(
        type: any Generable.Type,
        description: String? = nil,
        anyOf types: [any Generable.Type]
    ) {
        self.typeName = String(describing: type)
        self.schemaDescription = description
        self.node = .anyOf(types.map { $0.generationSchema.node })
    }

    public init(
        root: DynamicGenerationSchema,
        dependencies: [DynamicGenerationSchema]
    ) throws {
        var registry: [String: DynamicGenerationSchema] = [:]
        for dependency in dependencies {
            if registry[dependency.name] != nil {
                throw SchemaError.duplicateType(
                    schema: root.name,
                    type: dependency.name,
                    context: SchemaError.Context(
                        debugDescription: "Duplicate schema named '\(dependency.name)'."
                    )
                )
            }
            registry[dependency.name] = dependency
        }
        var missing: [String] = []
        let resolved = GenerationSchema.resolve(root, registry: registry, missing: &missing)
        if !missing.isEmpty {
            throw SchemaError.undefinedReferences(
                schema: root.name,
                references: missing,
                context: SchemaError.Context(
                    debugDescription: "Unresolved references: \(missing.joined(separator: ", "))."
                )
            )
        }
        self.typeName = root.name
        self.schemaDescription = root.schemaDescription
        self.node = resolved
    }

    // MARK: - Internal inits (used by stdlib conformances)

    init(primitive: Primitive, description: String?) {
        self.typeName = nil
        self.schemaDescription = description
        self.node = .primitive(primitive)
    }

    init(arrayOf item: GenerationSchema, description: String?) {
        self.typeName = nil
        self.schemaDescription = description
        self.node = .array(item: item.node)
    }

    init(anyType typeName: String, description: String?) {
        self.typeName = typeName
        self.schemaDescription = description
        self.node = .primitive(.object)
    }

    // MARK: - JSON Schema emission

    /// The JSON-Schema representation of this schema, for constrained decoding.
    var jsonSchema: String {
        let object = GenerationSchema.jsonSchemaObject(for: node, description: schemaDescription)
        guard JSONSerialization.isValidJSONObject(object),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.sortedKeys, .prettyPrinted]),
              let string = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return string
    }

    public var debugDescription: String {
        jsonSchema
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case schema
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let json = try container.decode(String.self, forKey: .schema)
        let content = try GeneratedContent(json: json)
        self = GenerationSchema.schema(fromContent: content)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(jsonSchema, forKey: .schema)
    }

    // MARK: - SchemaError

    public enum SchemaError: Error, LocalizedError {
        public struct Context: Sendable {
            public let debugDescription: String
            public init(debugDescription: String) {
                self.debugDescription = debugDescription
            }
        }

        case duplicateType(schema: String?, type: String, context: Context)
        case duplicateProperty(schema: String, property: String, context: Context)
        case emptyTypeChoices(schema: String, context: Context)
        case undefinedReferences(schema: String?, references: [String], context: Context)

        // Internal decoding-time failures (not part of the spec's public cases,
        // but used to surface conversion errors through the same error type).
        case typeMismatch(expected: String, content: GeneratedContent)
        case decodingFailure(String)

        public var errorDescription: String? {
            switch self {
            case let .duplicateType(_, type, context):
                return "Duplicate type '\(type)'. \(context.debugDescription)"
            case let .duplicateProperty(schema, property, context):
                return "Duplicate property '\(property)' in '\(schema)'. \(context.debugDescription)"
            case let .emptyTypeChoices(schema, context):
                return "Empty type choices for '\(schema)'. \(context.debugDescription)"
            case let .undefinedReferences(_, references, context):
                return "Undefined references \(references). \(context.debugDescription)"
            case let .typeMismatch(expected, content):
                return "Expected \(expected) but found \(content.kind)."
            case let .decodingFailure(message):
                return message
            }
        }

        public var recoverySuggestion: String? {
            switch self {
            case .duplicateType:
                return "Ensure each type in the schema has a unique name."
            case .duplicateProperty:
                return "Ensure each property name is unique within its type."
            case .emptyTypeChoices:
                return "Provide at least one choice for the anyOf schema."
            case .undefinedReferences:
                return "Define all referenced schemas as dependencies."
            case .typeMismatch, .decodingFailure:
                return "Verify the generated content matches the expected schema."
            }
        }
    }

    // MARK: - Private helpers

    private static func resolve(
        _ dynamic: DynamicGenerationSchema,
        registry: [String: DynamicGenerationSchema],
        missing: inout [String]
    ) -> Node {
        switch dynamic.representation {
        case let .object(properties):
            let nodes = properties.map { property in
                PropertyNode(
                    name: property.name,
                    description: property.description,
                    node: resolve(property.schema, registry: registry, missing: &missing),
                    isOptional: property.isOptional,
                    constraints: []
                )
            }
            return .object(properties: nodes)
        case let .anyOfSchemas(choices):
            return .anyOf(choices.map { resolve($0, registry: registry, missing: &missing) })
        case let .anyOfStrings(choices):
            return .stringEnum(choices)
        case let .array(item, _, _):
            return .array(item: resolve(item, registry: registry, missing: &missing))
        case let .generable(node, _):
            return node
        case let .reference(name):
            if let target = registry[name] {
                return resolve(target, registry: registry, missing: &missing)
            }
            missing.append(name)
            return .primitive(.object)
        }
    }

    private static func jsonSchemaObject(for node: Node, description: String?) -> [String: Any] {
        var object: [String: Any] = [:]
        if let description { object["description"] = description }
        switch node {
        case let .primitive(primitive):
            object["type"] = primitive.rawValue
        case let .object(properties):
            object["type"] = "object"
            var props: [String: Any] = [:]
            var required: [String] = []
            for property in properties {
                var child = jsonSchemaObject(for: property.node, description: property.description)
                applyConstraints(property.constraints, to: &child)
                props[property.name] = child
                if !property.isOptional { required.append(property.name) }
            }
            object["properties"] = props
            if !required.isEmpty { object["required"] = required }
        case let .array(item):
            object["type"] = "array"
            object["items"] = jsonSchemaObject(for: item, description: nil)
        case let .stringEnum(choices):
            object["type"] = "string"
            object["enum"] = choices
        case let .anyOf(nodes):
            object["anyOf"] = nodes.map { jsonSchemaObject(for: $0, description: nil) }
        }
        return object
    }

    private static func applyConstraints(_ constraints: [GuideConstraint], to object: inout [String: Any]) {
        for constraint in constraints {
            switch constraint {
            case let .constant(value):
                object["const"] = value
            case let .anyOf(values):
                object["enum"] = values
            case let .pattern(pattern):
                object["pattern"] = pattern
            case let .minimum(value):
                object["minimum"] = value
            case let .maximum(value):
                object["maximum"] = value
            case let .range(range):
                object["minimum"] = range.lowerBound
                object["maximum"] = range.upperBound
            case let .minimumCount(count):
                object["minItems"] = count
            case let .maximumCount(count):
                object["maxItems"] = count
            case let .countRange(range):
                object["minItems"] = range.lowerBound
                object["maxItems"] = range.upperBound
            case let .count(count):
                object["minItems"] = count
                object["maxItems"] = count
            case let .element(inner):
                if var items = object["items"] as? [String: Any] {
                    applyConstraints([inner], to: &items)
                    object["items"] = items
                }
            }
        }
    }

    /// Reconstructs a schema node from decoded JSON-Schema content (best effort).
    private static func schema(fromContent content: GeneratedContent) -> GenerationSchema {
        let node = schemaNode(fromContent: content)
        return GenerationSchema(node: node)
    }

    private init(node: Node) {
        self.typeName = nil
        self.schemaDescription = nil
        self.node = node
    }

    private static func schemaNode(fromContent content: GeneratedContent) -> Node {
        guard case let .structure(properties, _) = content.kind else {
            return .primitive(.object)
        }
        if let type = properties["type"], case let .string(typeName) = type.kind {
            switch typeName {
            case "object":
                var propertyNodes: [PropertyNode] = []
                if let props = properties["properties"], case let .structure(childProps, order) = props.kind {
                    let keys = order.isEmpty ? Array(childProps.keys) : order
                    var required: Set<String> = []
                    if let req = properties["required"], case let .array(items) = req.kind {
                        for item in items {
                            if case let .string(name) = item.kind { required.insert(name) }
                        }
                    }
                    for key in keys {
                        if let child = childProps[key] {
                            propertyNodes.append(PropertyNode(
                                name: key,
                                description: nil,
                                node: schemaNode(fromContent: child),
                                isOptional: !required.contains(key),
                                constraints: []
                            ))
                        }
                    }
                }
                return .object(properties: propertyNodes)
            case "array":
                if let items = properties["items"] {
                    return .array(item: schemaNode(fromContent: items))
                }
                return .array(item: .primitive(.object))
            case "string":
                if let enumValues = properties["enum"], case let .array(items) = enumValues.kind {
                    let choices = items.compactMap { item -> String? in
                        if case let .string(value) = item.kind { return value }
                        return nil
                    }
                    return .stringEnum(choices)
                }
                return .primitive(.string)
            case "integer":
                return .primitive(.integer)
            case "number":
                return .primitive(.number)
            case "boolean":
                return .primitive(.boolean)
            case "null":
                return .primitive(.null)
            default:
                return .primitive(.object)
            }
        }
        return .primitive(.object)
    }
}
