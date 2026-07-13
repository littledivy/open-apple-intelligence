import Foundation

// MARK: - Transcript

/// An ordered history of entries in an interaction with a language model.
/// Mirrors `FoundationModels.Transcript`.
public struct Transcript: Sendable, Equatable, RandomAccessCollection {
    public typealias Index = Int
    public typealias Element = Transcript.Entry
    public typealias Indices = Range<Transcript.Index>
    public typealias Iterator = IndexingIterator<Transcript>
    public typealias SubSequence = Slice<Transcript>

    private var storage: [Entry]

    public init(entries: some Sequence<Entry> = []) {
        self.storage = Array(entries)
    }

    public subscript(index: Transcript.Index) -> Transcript.Entry {
        get { storage[index] }
        set { storage[index] = newValue }
    }

    public var startIndex: Int { storage.startIndex }
    public var endIndex: Int { storage.endIndex }

    public static func == (a: Transcript, b: Transcript) -> Bool {
        a.storage == b.storage
    }

    // MARK: Entry

    /// A single entry in a transcript.
    public enum Entry: Sendable, Identifiable, Equatable {
        case instructions(Transcript.Instructions)
        case prompt(Transcript.Prompt)
        case toolCalls(Transcript.ToolCalls)
        case toolOutput(Transcript.ToolOutput)
        case response(Transcript.Response)

        public typealias ID = String

        public var id: String {
            switch self {
            case .instructions(let value): return value.id
            case .prompt(let value): return value.id
            case .toolCalls(let value): return value.id
            case .toolOutput(let value): return value.id
            case .response(let value): return value.id
            }
        }

        public static func == (a: Transcript.Entry, b: Transcript.Entry) -> Bool {
            switch (a, b) {
            case (.instructions(let l), .instructions(let r)): return l == r
            case (.prompt(let l), .prompt(let r)): return l == r
            case (.toolCalls(let l), .toolCalls(let r)): return l == r
            case (.toolOutput(let l), .toolOutput(let r)): return l == r
            case (.response(let l), .response(let r)): return l == r
            default: return false
            }
        }
    }

    // MARK: Segment

    /// A segment of content within a transcript entry.
    public enum Segment: Sendable, Identifiable, Equatable {
        case text(Transcript.TextSegment)
        case structure(Transcript.StructuredSegment)

        public typealias ID = String

        public var id: String {
            switch self {
            case .text(let value): return value.id
            case .structure(let value): return value.id
            }
        }

        public static func == (a: Transcript.Segment, b: Transcript.Segment) -> Bool {
            switch (a, b) {
            case (.text(let l), .text(let r)): return l == r
            case (.structure(let l), .structure(let r)): return l == r
            default: return false
            }
        }
    }

    // MARK: TextSegment

    /// A plain-text segment of transcript content.
    public struct TextSegment: Sendable, Identifiable, Equatable {
        public typealias ID = String

        public var id: String
        public var content: String

        public init(id: String = UUID().uuidString, content: String) {
            self.id = id
            self.content = content
        }

        public static func == (a: Transcript.TextSegment, b: Transcript.TextSegment) -> Bool {
            a.id == b.id && a.content == b.content
        }
    }

    // MARK: StructuredSegment

    /// A structured-content segment of transcript content.
    public struct StructuredSegment: Sendable, Identifiable, Equatable {
        public typealias ID = String

        public var id: String
        public var source: String
        private var _content: GeneratedContent

        public var content: GeneratedContent {
            get { _content }
            set { _content = newValue }
        }

        public init(id: String = UUID().uuidString, source: String, content: GeneratedContent) {
            self.id = id
            self.source = source
            self._content = content
        }

        public static func == (a: Transcript.StructuredSegment, b: Transcript.StructuredSegment) -> Bool {
            a.id == b.id && a.source == b.source && a._content == b._content
        }
    }

    // MARK: Instructions

    /// Instructions given to the model at the start of a transcript.
    ///
    /// Distinct from the top-level `OpenFoundationModels.Instructions` type: this
    /// is the transcript-entry representation, carrying segments and the tool
    /// definitions that were available when the instructions were issued.
    public struct Instructions: Sendable, Identifiable, Equatable {
        public typealias ID = String

        public var id: String
        public var segments: [Transcript.Segment]
        public var toolDefinitions: [Transcript.ToolDefinition]

        public init(
            id: String = UUID().uuidString,
            segments: [Transcript.Segment],
            toolDefinitions: [Transcript.ToolDefinition]
        ) {
            self.id = id
            self.segments = segments
            self.toolDefinitions = toolDefinitions
        }

        public static func == (a: Transcript.Instructions, b: Transcript.Instructions) -> Bool {
            a.id == b.id && a.segments == b.segments && a.toolDefinitions == b.toolDefinitions
        }
    }

    // MARK: ToolDefinition

    /// Describes a tool that was made available to the model.
    public struct ToolDefinition: Sendable, Equatable {
        public var name: String
        public var description: String
        public var parameters: GenerationSchema

        public init(name: String, description: String, parameters: GenerationSchema) {
            self.name = name
            self.description = description
            self.parameters = parameters
        }

        public init(tool: some Tool) {
            self.name = tool.name
            self.description = tool.description
            self.parameters = GenerationSchema(type: GeneratedContent.self, description: nil, properties: [])
        }

        public static func == (a: Transcript.ToolDefinition, b: Transcript.ToolDefinition) -> Bool {
            a.name == b.name && a.description == b.description
        }
    }

    // MARK: Prompt

    /// A prompt turn recorded in a transcript.
    ///
    /// Distinct from the top-level `OpenFoundationModels.Prompt` type: this is the
    /// transcript-entry representation, carrying segments, generation options, and
    /// an optional response format.
    public struct Prompt: Sendable, Identifiable, Equatable {
        public typealias ID = String

        public var id: String
        public var segments: [Transcript.Segment]
        public var options: GenerationOptions
        public var responseFormat: Transcript.ResponseFormat?

        public init(
            id: String = UUID().uuidString,
            segments: [Transcript.Segment],
            options: GenerationOptions = GenerationOptions(),
            responseFormat: Transcript.ResponseFormat? = nil
        ) {
            self.id = id
            self.segments = segments
            self.options = options
            self.responseFormat = responseFormat
        }

        public static func == (a: Transcript.Prompt, b: Transcript.Prompt) -> Bool {
            a.id == b.id
                && a.segments == b.segments
                && a.options == b.options
                && a.responseFormat == b.responseFormat
        }
    }

    // MARK: ResponseFormat

    /// Describes the expected structured-output format for a prompt.
    public struct ResponseFormat: Sendable, Equatable {
        private let schema: GenerationSchema
        private let _name: String

        public var name: String { _name }

        public init<Content>(type: Content.Type) where Content: Generable {
            self.schema = Content.generationSchema
            self._name = String(describing: Content.self)
        }

        public init(schema: GenerationSchema) {
            self.schema = schema
            self._name = String(describing: GenerationSchema.self)
        }

        public static func == (a: Transcript.ResponseFormat, b: Transcript.ResponseFormat) -> Bool {
            a.name == b.name
        }
    }

    // MARK: ToolCalls

    /// An ordered collection of tool calls requested by the model.
    public struct ToolCalls: Sendable, Identifiable, Equatable, RandomAccessCollection {
        public typealias Element = Transcript.ToolCall
        public typealias ID = String
        public typealias Index = Int
        public typealias Indices = Range<Int>
        public typealias Iterator = IndexingIterator<Transcript.ToolCalls>
        public typealias SubSequence = Slice<Transcript.ToolCalls>

        public var id: String
        private var storage: [ToolCall]

        public init<S>(id: String = UUID().uuidString, _ calls: S) where S: Sequence, S.Element == Transcript.ToolCall {
            self.id = id
            self.storage = Array(calls)
        }

        public subscript(position: Int) -> Transcript.ToolCall {
            storage[position]
        }

        public var startIndex: Int { storage.startIndex }
        public var endIndex: Int { storage.endIndex }

        public static func == (a: Transcript.ToolCalls, b: Transcript.ToolCalls) -> Bool {
            a.id == b.id && a.storage == b.storage
        }
    }

    // MARK: ToolCall

    /// A single tool invocation requested by the model.
    public struct ToolCall: Sendable, Identifiable, Equatable {
        public typealias ID = String

        public var id: String
        public var toolName: String
        private var _arguments: GeneratedContent

        public var arguments: GeneratedContent {
            get { _arguments }
            set { _arguments = newValue }
        }

        public init(id: String, toolName: String, arguments: GeneratedContent) {
            self.id = id
            self.toolName = toolName
            self._arguments = arguments
        }

        public static func == (a: Transcript.ToolCall, b: Transcript.ToolCall) -> Bool {
            a.id == b.id && a.toolName == b.toolName && a._arguments == b._arguments
        }
    }

    // MARK: ToolOutput

    /// The output produced by a tool call, recorded in a transcript.
    public struct ToolOutput: Sendable, Identifiable, Equatable {
        public typealias ID = String

        public var id: String
        public var toolName: String
        public var segments: [Transcript.Segment]

        public init(id: String, toolName: String, segments: [Transcript.Segment]) {
            self.id = id
            self.toolName = toolName
            self.segments = segments
        }

        public static func == (a: Transcript.ToolOutput, b: Transcript.ToolOutput) -> Bool {
            a.id == b.id && a.toolName == b.toolName && a.segments == b.segments
        }
    }

    // MARK: Response

    /// A response produced by the model, recorded in a transcript.
    public struct Response: Sendable, Identifiable, Equatable {
        public typealias ID = String

        public var id: String
        public var assetIDs: [String]
        public var segments: [Transcript.Segment]

        public init(id: String = UUID().uuidString, assetIDs: [String], segments: [Transcript.Segment]) {
            self.id = id
            self.assetIDs = assetIDs
            self.segments = segments
        }

        public static func == (a: Transcript.Response, b: Transcript.Response) -> Bool {
            a.id == b.id && a.assetIDs == b.assetIDs && a.segments == b.segments
        }
    }
}
