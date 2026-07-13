import Foundation

/// A runtime-constructed schema, built without a compile-time `Generable` type.
/// Mirrors `FoundationModels.DynamicGenerationSchema`.
///
/// Dynamic schemas can reference one another by name; a `GenerationSchema` is
/// produced by resolving a root against its dependencies.
public struct DynamicGenerationSchema: Sendable {

    /// The internal shape of a dynamic schema. Consumed by `GenerationSchema`
    /// when resolving references into a concrete schema tree.
    indirect enum Representation: Sendable {
        case object(properties: [Property])
        case anyOfSchemas([DynamicGenerationSchema])
        case anyOfStrings([String])
        case array(item: DynamicGenerationSchema, minimum: Int?, maximum: Int?)
        case generable(node: GenerationSchema.Node, guides: [GuideConstraint])
        case reference(name: String)
    }

    let name: String
    let schemaDescription: String?
    let representation: Representation

    // MARK: - Public inits

    public init(name: String, description: String? = nil, properties: [DynamicGenerationSchema.Property]) {
        self.name = name
        self.schemaDescription = description
        self.representation = .object(properties: properties)
    }

    public init(name: String, description: String? = nil, anyOf choices: [DynamicGenerationSchema]) {
        self.name = name
        self.schemaDescription = description
        self.representation = .anyOfSchemas(choices)
    }

    public init(name: String, description: String? = nil, anyOf choices: [String]) {
        self.name = name
        self.schemaDescription = description
        self.representation = .anyOfStrings(choices)
    }

    public init(arrayOf itemSchema: DynamicGenerationSchema, minimumElements: Int? = nil, maximumElements: Int? = nil) {
        self.name = "Array"
        self.schemaDescription = nil
        self.representation = .array(item: itemSchema, minimum: minimumElements, maximum: maximumElements)
    }

    public init<Value>(type: Value.Type, guides: [GenerationGuide<Value>] = []) where Value: Generable {
        self.name = String(describing: type)
        self.schemaDescription = nil
        self.representation = .generable(
            node: Value.generationSchema.node,
            guides: guides.map(\.constraint)
        )
    }

    public init(referenceTo name: String) {
        self.name = name
        self.schemaDescription = nil
        self.representation = .reference(name: name)
    }

    // MARK: - Property

    /// A single property within a dynamic object schema. Mirrors
    /// `FoundationModels.DynamicGenerationSchema.Property`.
    public struct Property: Sendable {
        let name: String
        let description: String?
        let schema: DynamicGenerationSchema
        let isOptional: Bool

        public init(
            name: String,
            description: String? = nil,
            schema: DynamicGenerationSchema,
            isOptional: Bool = false
        ) {
            self.name = name
            self.description = description
            self.schema = schema
            self.isOptional = isOptional
        }
    }
}
