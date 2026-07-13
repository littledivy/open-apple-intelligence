import Foundation

// MARK: - Bool

extension Bool: Generable {
    public static var generationSchema: GenerationSchema {
        GenerationSchema(primitive: .boolean, description: nil)
    }

    public init(_ content: GeneratedContent) throws {
        guard case let .bool(value) = content.kind else {
            throw GenerationSchema.SchemaError.typeMismatch(expected: "Bool", content: content)
        }
        self = value
    }

    public var generatedContent: GeneratedContent {
        GeneratedContent(kind: .bool(self))
    }
}

// MARK: - String

extension String: Generable {
    public static var generationSchema: GenerationSchema {
        GenerationSchema(primitive: .string, description: nil)
    }

    public init(_ content: GeneratedContent) throws {
        guard case let .string(value) = content.kind else {
            throw GenerationSchema.SchemaError.typeMismatch(expected: "String", content: content)
        }
        self = value
    }

    public var generatedContent: GeneratedContent {
        GeneratedContent(kind: .string(self))
    }
}

// MARK: - Int

extension Int: Generable {
    public static var generationSchema: GenerationSchema {
        GenerationSchema(primitive: .integer, description: nil)
    }

    public init(_ content: GeneratedContent) throws {
        guard case let .number(value) = content.kind else {
            throw GenerationSchema.SchemaError.typeMismatch(expected: "Int", content: content)
        }
        self = Int(value)
    }

    public var generatedContent: GeneratedContent {
        GeneratedContent(kind: .number(Double(self)))
    }
}

// MARK: - Float

extension Float: Generable {
    public static var generationSchema: GenerationSchema {
        GenerationSchema(primitive: .number, description: nil)
    }

    public init(_ content: GeneratedContent) throws {
        guard case let .number(value) = content.kind else {
            throw GenerationSchema.SchemaError.typeMismatch(expected: "Float", content: content)
        }
        self = Float(value)
    }

    public var generatedContent: GeneratedContent {
        GeneratedContent(kind: .number(Double(self)))
    }
}

// MARK: - Double

extension Double: Generable {
    public static var generationSchema: GenerationSchema {
        GenerationSchema(primitive: .number, description: nil)
    }

    public init(_ content: GeneratedContent) throws {
        guard case let .number(value) = content.kind else {
            throw GenerationSchema.SchemaError.typeMismatch(expected: "Double", content: content)
        }
        self = value
    }

    public var generatedContent: GeneratedContent {
        GeneratedContent(kind: .number(self))
    }
}

// MARK: - Decimal

extension Decimal: Generable {
    public static var generationSchema: GenerationSchema {
        GenerationSchema(primitive: .number, description: nil)
    }

    public init(_ content: GeneratedContent) throws {
        guard case let .number(value) = content.kind else {
            throw GenerationSchema.SchemaError.typeMismatch(expected: "Decimal", content: content)
        }
        self = Decimal(value)
    }

    public var generatedContent: GeneratedContent {
        GeneratedContent(kind: .number((self as NSDecimalNumber).doubleValue))
    }
}

// MARK: - Array

extension Array: InstructionsRepresentable where Element: ConvertibleToGeneratedContent {}
extension Array: PromptRepresentable where Element: ConvertibleToGeneratedContent {}

extension Array: ConvertibleToGeneratedContent where Element: ConvertibleToGeneratedContent {
    public var generatedContent: GeneratedContent {
        GeneratedContent(kind: .array(map { $0.generatedContent }))
    }
}

extension Array: ConvertibleFromGeneratedContent where Element: ConvertibleFromGeneratedContent {
    public init(_ content: GeneratedContent) throws {
        guard case let .array(items) = content.kind else {
            throw GenerationSchema.SchemaError.typeMismatch(expected: "Array", content: content)
        }
        self = try items.map { try Element($0) }
    }
}

extension Array: Generable where Element: Generable {
    public typealias PartiallyGenerated = [Element.PartiallyGenerated]

    public static var generationSchema: GenerationSchema {
        GenerationSchema(arrayOf: Element.generationSchema, description: nil)
    }
}

// MARK: - Optional

extension Optional: InstructionsRepresentable where Wrapped: ConvertibleToGeneratedContent {}
extension Optional: PromptRepresentable where Wrapped: ConvertibleToGeneratedContent {}

extension Optional: ConvertibleToGeneratedContent where Wrapped: ConvertibleToGeneratedContent {
    public var generatedContent: GeneratedContent {
        switch self {
        case .none:
            return GeneratedContent(kind: .null)
        case let .some(value):
            return value.generatedContent
        }
    }
}

// MARK: - Never

extension Never: Generable {
    public static var generationSchema: GenerationSchema {
        GenerationSchema(primitive: .null, description: nil)
    }

    public init(_ content: GeneratedContent) throws {
        throw GenerationSchema.SchemaError.typeMismatch(expected: "Never", content: content)
    }

    public var generatedContent: GeneratedContent {
        // `Never` has no instances, so this is unreachable.
        switch self {}
    }
}
