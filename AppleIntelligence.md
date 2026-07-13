# Apple Intelligence — polyfill API checklist

Target: real iOS. Scope: only Apple-Intelligence-capability-gated APIs Apple disables on ineligible/old devices. All other SDK frameworks ship to the device and are NOT listed here.

Source: `iPhoneOS26.2.sdk` · real arm64e `.swiftinterface`. All boxes unchecked = polyfill TODO.


---

## FoundationModels

> On-device LLM (Apple Intelligence core). iOS 26+. Present on ineligible devices but SystemLanguageModel.availability == .unavailable(.deviceNotEligible). Polyfill: mirror API, route to cloud LLM or local MLX/llama.cpp; @Generable → constrained JSON decode.

Source: iPhoneOS26.2.sdk · Swift (.swiftinterface) · full framework

Types: 59 · Members: 364

### [ ] `Adapter` — 1 member

- [ ] `public var creatorDefinedMetadata: [Swift.String : Any]`

### [ ] `Array` — 6 members

- [ ] `public init(_ content: FoundationModels.GeneratedContent) throws`
- [ ] `public static var generationSchema: FoundationModels.GenerationSchema`
- [ ] `public typealias PartiallyGenerated = [Element.PartiallyGenerated]`
- [ ] `public var generatedContent: FoundationModels.GeneratedContent`
- [ ] `public var instructionsRepresentation: FoundationModels.Instructions`
- [ ] `public var promptRepresentation: FoundationModels.Prompt`

### [ ] `AssetError` — 5 members

- [ ] `case compatibleAdapterNotFound(FoundationModels.SystemLanguageModel.Adapter.AssetError.Context)`
- [ ] `case invalidAdapterName(FoundationModels.SystemLanguageModel.Adapter.AssetError.Context)`
- [ ] `case invalidAsset(FoundationModels.SystemLanguageModel.Adapter.AssetError.Context)`
- [ ] `public var errorDescription: Swift.String?`
- [ ] `public var recoverySuggestion: Swift.String?`

### [ ] `AsyncIterator` — 3 members

- [ ] `@_implements(_Concurrency.AsyncIteratorProtocol, Failure) public typealias __AsyncIteratorProtocol_Failure = any Swift.Error`
- [ ] `public mutating func next(isolation actor: isolated (any _Concurrency.Actor)? = #isolation) async throws -> FoundationModels.LanguageModelSession.ResponseStream<Content>.Snapshot?`
- [ ] `public typealias Element = FoundationModels.LanguageModelSession.ResponseStream<Content>.Snapshot`

### [ ] `Availability` — 3 members

- [ ] `case available`
- [ ] `case unavailable(FoundationModels.SystemLanguageModel.Availability.UnavailableReason)`
- [ ] `public static func == (a: FoundationModels.SystemLanguageModel.Availability, b: FoundationModels.SystemLanguageModel.Availability) -> Swift.Bool`

### [ ] `Bool` — 3 members

- [ ] `public init(_ content: FoundationModels.GeneratedContent) throws`
- [ ] `public static var generationSchema: FoundationModels.GenerationSchema`
- [ ] `public var generatedContent: FoundationModels.GeneratedContent`

### [ ] `Category` — 13 members

- [ ] `case didNotFollowInstructions`
- [ ] `case incorrect`
- [ ] `case stereotypeOrBias`
- [ ] `case suggestiveOrSexual`
- [ ] `case tooVerbose`
- [ ] `case triggeredGuardrailUnexpectedly`
- [ ] `case unhelpful`
- [ ] `case vulgarOrOffensive`
- [ ] `nonisolated public static var allCases: [FoundationModels.LanguageModelFeedback.Issue.Category]`
- [ ] `public func hash(into hasher: inout Swift.Hasher)`
- [ ] `public static func == (a: FoundationModels.LanguageModelFeedback.Issue.Category, b: FoundationModels.LanguageModelFeedback.Issue.Category) -> Swift.Bool`
- [ ] `public typealias AllCases = [FoundationModels.LanguageModelFeedback.Issue.Category]`
- [ ] `public var hashValue: Swift.Int`

### [ ] `Context` — 2 members

- [ ] `public init(debugDescription: Swift.String)`
- [ ] `public let debugDescription: Swift.String`

### [ ] `ConvertibleFromGeneratedContent` — 0 members


### [ ] `ConvertibleToGeneratedContent` — 2 members

- [ ] `public var instructionsRepresentation: FoundationModels.Instructions`
- [ ] `public var promptRepresentation: FoundationModels.Prompt`

### [ ] `Decimal` — 3 members

- [ ] `public init(_ content: FoundationModels.GeneratedContent) throws`
- [ ] `public static var generationSchema: FoundationModels.GenerationSchema`
- [ ] `public var generatedContent: FoundationModels.GeneratedContent`

### [ ] `Double` — 3 members

- [ ] `public init(_ content: FoundationModels.GeneratedContent) throws`
- [ ] `public static var generationSchema: FoundationModels.GenerationSchema`
- [ ] `public var generatedContent: FoundationModels.GeneratedContent`

### [ ] `DynamicGenerationSchema` — 6 members

- [ ] `public init(arrayOf itemSchema: FoundationModels.DynamicGenerationSchema, minimumElements: Swift.Int? = nil, maximumElements: Swift.Int? = nil)`
- [ ] `public init(name: Swift.String, description: Swift.String? = nil, anyOf choices: [FoundationModels.DynamicGenerationSchema])`
- [ ] `public init(name: Swift.String, description: Swift.String? = nil, anyOf choices: [Swift.String])`
- [ ] `public init(name: Swift.String, description: Swift.String? = nil, properties: [FoundationModels.DynamicGenerationSchema.Property])`
- [ ] `public init(referenceTo name: Swift.String)`
- [ ] `public init<Value>(type: Value.Type, guides: [FoundationModels.GenerationGuide<Value>] = []) where Value : FoundationModels.Generable`

### [ ] `Entry` — 8 members

- [ ] `case instructions(FoundationModels.Transcript.Instructions)`
- [ ] `case prompt(FoundationModels.Transcript.Prompt)`
- [ ] `case response(FoundationModels.Transcript.Response)`
- [ ] `case toolCalls(FoundationModels.Transcript.ToolCalls)`
- [ ] `case toolOutput(FoundationModels.Transcript.ToolOutput)`
- [ ] `public static func == (a: FoundationModels.Transcript.Entry, b: FoundationModels.Transcript.Entry) -> Swift.Bool`
- [ ] `public typealias ID = Swift.String`
- [ ] `public var id: Swift.String`

### [ ] `Float` — 3 members

- [ ] `public init(_ content: FoundationModels.GeneratedContent) throws`
- [ ] `public static var generationSchema: FoundationModels.GenerationSchema`
- [ ] `public var generatedContent: FoundationModels.GeneratedContent`

### [ ] `Generable` — 2 members

- [ ] `public func asPartiallyGenerated() -> Self.PartiallyGenerated`
- [ ] `public typealias PartiallyGenerated = Self`

### [ ] `GeneratedContent` — 19 members

- [ ] `public func value<Value>(_ type: Value.Type = Value.self) throws -> Value where Value : FoundationModels.ConvertibleFromGeneratedContent`
- [ ] `public func value<Value>(_ type: Value.Type = Value.self, forProperty property: Swift.String) throws -> Value where Value : FoundationModels.ConvertibleFromGeneratedContent`
- [ ] `public func value<Value>(_ type: Value?.Type = Value?.self, forProperty property: Swift.String) throws -> Value? where Value : FoundationModels.ConvertibleFromGeneratedContent`
- [ ] `public init(_ content: FoundationModels.GeneratedContent) throws`
- [ ] `public init(_ value: some ConvertibleToGeneratedContent)`
- [ ] `public init(_ value: some ConvertibleToGeneratedContent, id: FoundationModels.GenerationID)`
- [ ] `public init(json: Swift.String) throws`
- [ ] `public init(kind: FoundationModels.GeneratedContent.Kind, id: FoundationModels.GenerationID? = nil)`
- [ ] `public init(properties: Swift.KeyValuePairs<Swift.String, any FoundationModels.ConvertibleToGeneratedContent>, id: FoundationModels.GenerationID? = nil)`
- [ ] `public init<S>(elements: S, id: FoundationModels.GenerationID? = nil) where S : Swift.Sequence, S.Element == any FoundationModels.ConvertibleToGeneratedContent`
- [ ] `public init<S>(properties: S, id: FoundationModels.GenerationID? = nil, uniquingKeysWith combine: (FoundationModels.GeneratedContent, FoundationModels.GeneratedContent) throws -> some ConvertibleToGeneratedContent) rethrows where S : Swift.Sequence, S.Element == (Swift.String, any FoundationModels.ConvertibleToGeneratedContent)`
- [ ] `public static func == (a: FoundationModels.GeneratedContent, b: FoundationModels.GeneratedContent) -> Swift.Bool`
- [ ] `public static var generationSchema: FoundationModels.GenerationSchema`
- [ ] `public var debugDescription: Swift.String`
- [ ] `public var generatedContent: FoundationModels.GeneratedContent`
- [ ] `public var id: FoundationModels.GenerationID?`
- [ ] `public var isComplete: Swift.Bool`
- [ ] `public var jsonString: Swift.String`
- [ ] `public var kind: FoundationModels.GeneratedContent.Kind`

### [ ] `GenerationError` — 12 members

- [ ] `case assetsUnavailable(FoundationModels.LanguageModelSession.GenerationError.Context)`
- [ ] `case concurrentRequests(FoundationModels.LanguageModelSession.GenerationError.Context)`
- [ ] `case decodingFailure(FoundationModels.LanguageModelSession.GenerationError.Context)`
- [ ] `case exceededContextWindowSize(FoundationModels.LanguageModelSession.GenerationError.Context)`
- [ ] `case guardrailViolation(FoundationModels.LanguageModelSession.GenerationError.Context)`
- [ ] `case rateLimited(FoundationModels.LanguageModelSession.GenerationError.Context)`
- [ ] `case refusal(FoundationModels.LanguageModelSession.GenerationError.Refusal, FoundationModels.LanguageModelSession.GenerationError.Context)`
- [ ] `case unsupportedGuide(FoundationModels.LanguageModelSession.GenerationError.Context)`
- [ ] `case unsupportedLanguageOrLocale(FoundationModels.LanguageModelSession.GenerationError.Context)`
- [ ] `public var errorDescription: Swift.String?`
- [ ] `public var failureReason: Swift.String?`
- [ ] `public var recoverySuggestion: Swift.String?`

### [ ] `GenerationGuide` — 24 members

- [ ] `@_documentation(visibility: private) @_alwaysEmitIntoClient public static func count(_ range: Swift.ClosedRange<Swift.Int>) -> FoundationModels.GenerationGuide<Value>`
- [ ] `@_documentation(visibility: private) @_alwaysEmitIntoClient public static func maximumCount(_ count: Swift.Int) -> FoundationModels.GenerationGuide<Value>`
- [ ] `@_documentation(visibility: private) @_alwaysEmitIntoClient public static func minimumCount(_ count: Swift.Int) -> FoundationModels.GenerationGuide<Value>`
- [ ] `@_documentation(visibility: private) @_disfavoredOverload @_alwaysEmitIntoClient public static func count(_ count: Swift.Int) -> FoundationModels.GenerationGuide<Value>`
- [ ] `public static func anyOf(_ values: [Swift.String]) -> FoundationModels.GenerationGuide<Swift.String>`
- [ ] `public static func constant(_ value: Swift.String) -> FoundationModels.GenerationGuide<Swift.String>`
- [ ] `public static func count<Element>(_ count: Swift.Int) -> FoundationModels.GenerationGuide<[Element]> where Value == [Element]`
- [ ] `public static func count<Element>(_ range: Swift.ClosedRange<Swift.Int>) -> FoundationModels.GenerationGuide<[Element]> where Value == [Element]`
- [ ] `public static func element<Element>(_ guide: FoundationModels.GenerationGuide<Element>) -> FoundationModels.GenerationGuide<[Element]> where Value == [Element]`
- [ ] `public static func maximum(_ value: Foundation.Decimal) -> FoundationModels.GenerationGuide<Foundation.Decimal>`
- [ ] `public static func maximum(_ value: Swift.Double) -> FoundationModels.GenerationGuide<Swift.Double>`
- [ ] `public static func maximum(_ value: Swift.Float) -> FoundationModels.GenerationGuide<Swift.Float>`
- [ ] `public static func maximum(_ value: Swift.Int) -> FoundationModels.GenerationGuide<Swift.Int>`
- [ ] `public static func maximumCount<Element>(_ count: Swift.Int) -> FoundationModels.GenerationGuide<[Element]> where Value == [Element]`
- [ ] `public static func minimum(_ value: Foundation.Decimal) -> FoundationModels.GenerationGuide<Foundation.Decimal>`
- [ ] `public static func minimum(_ value: Swift.Double) -> FoundationModels.GenerationGuide<Swift.Double>`
- [ ] `public static func minimum(_ value: Swift.Float) -> FoundationModels.GenerationGuide<Swift.Float>`
- [ ] `public static func minimum(_ value: Swift.Int) -> FoundationModels.GenerationGuide<Swift.Int>`
- [ ] `public static func minimumCount<Element>(_ count: Swift.Int) -> FoundationModels.GenerationGuide<[Element]> where Value == [Element]`
- [ ] `public static func pattern<Output>(_ regex: _StringProcessing.Regex<Output>) -> FoundationModels.GenerationGuide<Swift.String>`
- [ ] `public static func range(_ range: Swift.ClosedRange<Foundation.Decimal>) -> FoundationModels.GenerationGuide<Foundation.Decimal>`
- [ ] `public static func range(_ range: Swift.ClosedRange<Swift.Double>) -> FoundationModels.GenerationGuide<Swift.Double>`
- [ ] `public static func range(_ range: Swift.ClosedRange<Swift.Float>) -> FoundationModels.GenerationGuide<Swift.Float>`
- [ ] `public static func range(_ range: Swift.ClosedRange<Swift.Int>) -> FoundationModels.GenerationGuide<Swift.Int>`

### [ ] `GenerationID` — 4 members

- [ ] `public func hash(into hasher: inout Swift.Hasher)`
- [ ] `public init()`
- [ ] `public static func == (a: FoundationModels.GenerationID, b: FoundationModels.GenerationID) -> Swift.Bool`
- [ ] `public var hashValue: Swift.Int`

### [ ] `GenerationOptions` — 5 members

- [ ] `public init(sampling: FoundationModels.GenerationOptions.SamplingMode? = nil, temperature: Swift.Double? = nil, maximumResponseTokens: Swift.Int? = nil)`
- [ ] `public static func == (a: FoundationModels.GenerationOptions, b: FoundationModels.GenerationOptions) -> Swift.Bool`
- [ ] `public var maximumResponseTokens: Swift.Int?`
- [ ] `public var sampling: FoundationModels.GenerationOptions.SamplingMode?`
- [ ] `public var temperature: Swift.Double?`

### [ ] `GenerationSchema` — 7 members

- [ ] `public func encode(to encoder: any Swift.Encoder) throws`
- [ ] `public init(from decoder: any Swift.Decoder) throws`
- [ ] `public init(root: FoundationModels.DynamicGenerationSchema, dependencies: [FoundationModels.DynamicGenerationSchema]) throws`
- [ ] `public init(type: any FoundationModels.Generable.Type, description: Swift.String? = nil, anyOf choices: [Swift.String])`
- [ ] `public init(type: any FoundationModels.Generable.Type, description: Swift.String? = nil, anyOf types: [any FoundationModels.Generable.Type])`
- [ ] `public init(type: any FoundationModels.Generable.Type, description: Swift.String? = nil, properties: [FoundationModels.GenerationSchema.Property])`
- [ ] `public var debugDescription: Swift.String`

### [ ] `Guardrails` — 2 members

- [ ] `public static let `default`: FoundationModels.SystemLanguageModel.Guardrails`
- [ ] `public static let permissiveContentTransformations: FoundationModels.SystemLanguageModel.Guardrails`

### [ ] `Instructions` — 9 members

- [ ] `public init(@FoundationModels.InstructionsBuilder _ content: () throws -> FoundationModels.Instructions) rethrows`
- [ ] `public init(_ content: some InstructionsRepresentable)`
- [ ] `public init(id: Swift.String = UUID().uuidString, segments: [FoundationModels.Transcript.Segment], toolDefinitions: [FoundationModels.Transcript.ToolDefinition])`
- [ ] `public static func == (a: FoundationModels.Transcript.Instructions, b: FoundationModels.Transcript.Instructions) -> Swift.Bool`
- [ ] `public typealias ID = Swift.String`
- [ ] `public var id: Swift.String`
- [ ] `public var instructionsRepresentation: FoundationModels.Instructions`
- [ ] `public var segments: [FoundationModels.Transcript.Segment]`
- [ ] `public var toolDefinitions: [FoundationModels.Transcript.ToolDefinition]`

### [ ] `InstructionsBuilder` — 9 members

- [ ] `@_alwaysEmitIntoClient public static func buildArray(_ instructions: [some InstructionsRepresentable]) -> FoundationModels.Instructions`
- [ ] `@_alwaysEmitIntoClient public static func buildBlock<each I>(_ components: repeat each I) -> FoundationModels.Instructions where repeat each I : FoundationModels.InstructionsRepresentable`
- [ ] `@_alwaysEmitIntoClient public static func buildEither(first component: some InstructionsRepresentable) -> FoundationModels.Instructions`
- [ ] `@_alwaysEmitIntoClient public static func buildEither(second component: some InstructionsRepresentable) -> FoundationModels.Instructions`
- [ ] `@_alwaysEmitIntoClient public static func buildExpression(_ expression: FoundationModels.Instructions) -> FoundationModels.Instructions`
- [ ] `@_alwaysEmitIntoClient public static func buildExpression<T>(_ expression: T) -> FoundationModels.Instructions`
- [ ] `@_alwaysEmitIntoClient public static func buildLimitedAvailability(_ instructions: some InstructionsRepresentable) -> FoundationModels.Instructions`
- [ ] `@_alwaysEmitIntoClient public static func buildOptional(_ instructions: FoundationModels.Instructions?) -> FoundationModels.Instructions`
- [ ] `@_disfavoredOverload @_alwaysEmitIntoClient public static func buildExpression<I>(_ expression: I) -> I where I : FoundationModels.InstructionsRepresentable`

### [ ] `InstructionsRepresentable` — 0 members


### [ ] `Int` — 3 members

- [ ] `public init(_ content: FoundationModels.GeneratedContent) throws`
- [ ] `public static var generationSchema: FoundationModels.GenerationSchema`
- [ ] `public var generatedContent: FoundationModels.GeneratedContent`

### [ ] `Issue` — 1 member

- [ ] `public init(category: FoundationModels.LanguageModelFeedback.Issue.Category, explanation: Swift.String? = nil)`

### [ ] `Kind` — 7 members

- [ ] `case array([FoundationModels.GeneratedContent])`
- [ ] `case bool(Swift.Bool)`
- [ ] `case null`
- [ ] `case number(Swift.Double)`
- [ ] `case string(Swift.String)`
- [ ] `case structure(properties: [Swift.String : FoundationModels.GeneratedContent], orderedKeys: [Swift.String])`
- [ ] `public static func == (a: FoundationModels.GeneratedContent.Kind, b: FoundationModels.GeneratedContent.Kind) -> Swift.Bool`

### [ ] `LanguageModelFeedback` — 0 members


### [ ] `LanguageModelSession` — 42 members

- [ ] `@_disfavoredOverload convenience public init(model: FoundationModels.SystemLanguageModel = .default, tools: [any FoundationModels.Tool] = [], instructions: Swift.String? = nil)`
- [ ] `@_disfavoredOverload final public func streamResponse(to prompt: Swift.String, options: FoundationModels.GenerationOptions = GenerationOptions()) -> FoundationModels.LanguageModelSession.ResponseStream<Swift.String>`
- [ ] `@_disfavoredOverload final public func streamResponse(to prompt: Swift.String, options: FoundationModels.GenerationOptions = GenerationOptions()) -> sending FoundationModels.LanguageModelSession.ResponseStream<Swift.String>`
- [ ] `@_disfavoredOverload final public func streamResponse(to prompt: Swift.String, schema: FoundationModels.GenerationSchema, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) -> FoundationModels.LanguageModelSession.ResponseStream<FoundationModels.GeneratedContent>`
- [ ] `@_disfavoredOverload final public func streamResponse(to prompt: Swift.String, schema: FoundationModels.GenerationSchema, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) -> sending FoundationModels.LanguageModelSession.ResponseStream<FoundationModels.GeneratedContent>`
- [ ] `@_disfavoredOverload final public func streamResponse<Content>(to prompt: Swift.String, generating type: Content.Type = Content.self, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) -> FoundationModels.LanguageModelSession.ResponseStream<Content> where Content : FoundationModels.Generable`
- [ ] `@_disfavoredOverload final public func streamResponse<Content>(to prompt: Swift.String, generating type: Content.Type = Content.self, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) -> sending FoundationModels.LanguageModelSession.ResponseStream<Content> where Content : FoundationModels.Generable`
- [ ] `@_disfavoredOverload nonisolated(nonsending) final public func respond(to prompt: Swift.String, options: FoundationModels.GenerationOptions = GenerationOptions()) async throws -> FoundationModels.LanguageModelSession.Response<Swift.String>`
- [ ] `@_disfavoredOverload nonisolated(nonsending) final public func respond(to prompt: Swift.String, schema: FoundationModels.GenerationSchema, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) async throws -> FoundationModels.LanguageModelSession.Response<FoundationModels.GeneratedContent>`
- [ ] `@_disfavoredOverload nonisolated(nonsending) final public func respond<Content>(to prompt: Swift.String, generating type: Content.Type = Content.self, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) async throws -> FoundationModels.LanguageModelSession.Response<Content> where Content : FoundationModels.Generable`
- [ ] `@_implements(_Concurrency.AsyncSequence, Failure) public typealias __AsyncSequence_Failure = any Swift.Error`
- [ ] `convenience public init(model: FoundationModels.SystemLanguageModel = .default, tools: [any FoundationModels.Tool] = [], @FoundationModels.InstructionsBuilder instructions: () throws -> FoundationModels.Instructions) rethrows`
- [ ] `convenience public init(model: FoundationModels.SystemLanguageModel = .default, tools: [any FoundationModels.Tool] = [], instructions: FoundationModels.Instructions? = nil)`
- [ ] `convenience public init(model: FoundationModels.SystemLanguageModel = .default, tools: [any FoundationModels.Tool] = [], transcript: FoundationModels.Transcript)`
- [ ] `final public func logFeedbackAttachment(sentiment: FoundationModels.LanguageModelFeedback.Sentiment?, issues: [FoundationModels.LanguageModelFeedback.Issue] = [], desiredOutput: FoundationModels.Transcript.Entry? = nil) -> Foundation.Data`
- [ ] `final public func logFeedbackAttachment(sentiment: FoundationModels.LanguageModelFeedback.Sentiment?, issues: [FoundationModels.LanguageModelFeedback.Issue] = [], desiredResponseContent: (any FoundationModels.ConvertibleToGeneratedContent)?) -> Foundation.Data`
- [ ] `final public func logFeedbackAttachment(sentiment: FoundationModels.LanguageModelFeedback.Sentiment?, issues: [FoundationModels.LanguageModelFeedback.Issue] = [], desiredResponseText: Swift.String?) -> Foundation.Data`
- [ ] `final public func prewarm(promptPrefix: FoundationModels.Prompt? = nil)`
- [ ] `final public func streamResponse(options: FoundationModels.GenerationOptions = GenerationOptions(), @FoundationModels.PromptBuilder prompt: () throws -> FoundationModels.Prompt) rethrows -> FoundationModels.LanguageModelSession.ResponseStream<Swift.String>`
- [ ] `final public func streamResponse(options: FoundationModels.GenerationOptions = GenerationOptions(), @FoundationModels.PromptBuilder prompt: () throws -> FoundationModels.Prompt) rethrows -> sending FoundationModels.LanguageModelSession.ResponseStream<Swift.String>`
- [ ] `final public func streamResponse(schema: FoundationModels.GenerationSchema, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions(), @FoundationModels.PromptBuilder prompt: () throws -> FoundationModels.Prompt) rethrows -> FoundationModels.LanguageModelSession.ResponseStream<FoundationModels.GeneratedContent>`
- [ ] `final public func streamResponse(schema: FoundationModels.GenerationSchema, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions(), @FoundationModels.PromptBuilder prompt: () throws -> FoundationModels.Prompt) rethrows -> sending FoundationModels.LanguageModelSession.ResponseStream<FoundationModels.GeneratedContent>`
- [ ] `final public func streamResponse(to prompt: FoundationModels.Prompt, options: FoundationModels.GenerationOptions = GenerationOptions()) -> FoundationModels.LanguageModelSession.ResponseStream<Swift.String>`
- [ ] `final public func streamResponse(to prompt: FoundationModels.Prompt, options: FoundationModels.GenerationOptions = GenerationOptions()) -> sending FoundationModels.LanguageModelSession.ResponseStream<Swift.String>`
- [ ] `final public func streamResponse(to prompt: FoundationModels.Prompt, schema: FoundationModels.GenerationSchema, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) -> FoundationModels.LanguageModelSession.ResponseStream<FoundationModels.GeneratedContent>`
- [ ] `final public func streamResponse(to prompt: FoundationModels.Prompt, schema: FoundationModels.GenerationSchema, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) -> sending FoundationModels.LanguageModelSession.ResponseStream<FoundationModels.GeneratedContent>`
- [ ] `final public func streamResponse<Content>(generating type: Content.Type = Content.self, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions(), @FoundationModels.PromptBuilder prompt: () throws -> FoundationModels.Prompt) rethrows -> FoundationModels.LanguageModelSession.ResponseStream<Content> where Content : FoundationModels.Generable`
- [ ] `final public func streamResponse<Content>(generating type: Content.Type = Content.self, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions(), @FoundationModels.PromptBuilder prompt: () throws -> FoundationModels.Prompt) rethrows -> sending FoundationModels.LanguageModelSession.ResponseStream<Content> where Content : FoundationModels.Generable`
- [ ] `final public func streamResponse<Content>(to prompt: FoundationModels.Prompt, generating type: Content.Type = Content.self, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) -> FoundationModels.LanguageModelSession.ResponseStream<Content> where Content : FoundationModels.Generable`
- [ ] `final public func streamResponse<Content>(to prompt: FoundationModels.Prompt, generating type: Content.Type = Content.self, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) -> sending FoundationModels.LanguageModelSession.ResponseStream<Content> where Content : FoundationModels.Generable`
- [ ] `final public var isResponding: Swift.Bool`
- [ ] `final public var transcript: FoundationModels.Transcript`
- [ ] `nonisolated(nonsending) final public func respond(options: FoundationModels.GenerationOptions = GenerationOptions(), @FoundationModels.PromptBuilder prompt: () throws -> FoundationModels.Prompt) async throws -> FoundationModels.LanguageModelSession.Response<Swift.String>`
- [ ] `nonisolated(nonsending) final public func respond(schema: FoundationModels.GenerationSchema, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions(), @FoundationModels.PromptBuilder prompt: () throws -> FoundationModels.Prompt) async throws -> FoundationModels.LanguageModelSession.Response<FoundationModels.GeneratedContent>`
- [ ] `nonisolated(nonsending) final public func respond(to prompt: FoundationModels.Prompt, options: FoundationModels.GenerationOptions = GenerationOptions()) async throws -> FoundationModels.LanguageModelSession.Response<Swift.String>`
- [ ] `nonisolated(nonsending) final public func respond(to prompt: FoundationModels.Prompt, schema: FoundationModels.GenerationSchema, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) async throws -> FoundationModels.LanguageModelSession.Response<FoundationModels.GeneratedContent>`
- [ ] `nonisolated(nonsending) final public func respond<Content>(generating type: Content.Type = Content.self, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions(), @FoundationModels.PromptBuilder prompt: () throws -> FoundationModels.Prompt) async throws -> FoundationModels.LanguageModelSession.Response<Content> where Content : FoundationModels.Generable`
- [ ] `nonisolated(nonsending) final public func respond<Content>(to prompt: FoundationModels.Prompt, generating type: Content.Type = Content.self, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) async throws -> FoundationModels.LanguageModelSession.Response<Content> where Content : FoundationModels.Generable`
- [ ] `nonisolated(nonsending) public func collect() async throws -> FoundationModels.LanguageModelSession.Response<Content>`
- [ ] `nonisolated(nonsending) public func collect() async throws -> sending FoundationModels.LanguageModelSession.Response<Content>`
- [ ] `public func makeAsyncIterator() -> FoundationModels.LanguageModelSession.ResponseStream<Content>.AsyncIterator`
- [ ] `public typealias Element = FoundationModels.LanguageModelSession.ResponseStream<Content>.Snapshot`

### [ ] `Never` — 3 members

- [ ] `public init(_ content: FoundationModels.GeneratedContent) throws`
- [ ] `public static var generationSchema: FoundationModels.GenerationSchema`
- [ ] `public var generatedContent: FoundationModels.GeneratedContent`

### [ ] `Optional` — 2 members

- [ ] `public typealias PartiallyGenerated = Wrapped.PartiallyGenerated`
- [ ] `public var generatedContent: FoundationModels.GeneratedContent`

### [ ] `Prompt` — 10 members

- [ ] `public init(@FoundationModels.PromptBuilder _ content: () throws -> FoundationModels.Prompt) rethrows`
- [ ] `public init(_ content: some PromptRepresentable)`
- [ ] `public init(id: Swift.String = UUID().uuidString, segments: [FoundationModels.Transcript.Segment], options: FoundationModels.GenerationOptions = GenerationOptions(), responseFormat: FoundationModels.Transcript.ResponseFormat? = nil)`
- [ ] `public static func == (a: FoundationModels.Transcript.Prompt, b: FoundationModels.Transcript.Prompt) -> Swift.Bool`
- [ ] `public typealias ID = Swift.String`
- [ ] `public var id: Swift.String`
- [ ] `public var options: FoundationModels.GenerationOptions`
- [ ] `public var promptRepresentation: FoundationModels.Prompt`
- [ ] `public var responseFormat: FoundationModels.Transcript.ResponseFormat?`
- [ ] `public var segments: [FoundationModels.Transcript.Segment]`

### [ ] `PromptBuilder` — 9 members

- [ ] `@_alwaysEmitIntoClient public static func buildArray(_ prompts: [some PromptRepresentable]) -> FoundationModels.Prompt`
- [ ] `@_alwaysEmitIntoClient public static func buildBlock<each P>(_ components: repeat each P) -> FoundationModels.Prompt where repeat each P : FoundationModels.PromptRepresentable`
- [ ] `@_alwaysEmitIntoClient public static func buildEither(first component: some PromptRepresentable) -> FoundationModels.Prompt`
- [ ] `@_alwaysEmitIntoClient public static func buildEither(second component: some PromptRepresentable) -> FoundationModels.Prompt`
- [ ] `@_alwaysEmitIntoClient public static func buildExpression(_ expression: FoundationModels.Prompt) -> FoundationModels.Prompt`
- [ ] `@_alwaysEmitIntoClient public static func buildExpression<T>(_ expression: T) -> FoundationModels.Prompt`
- [ ] `@_alwaysEmitIntoClient public static func buildLimitedAvailability(_ prompt: some PromptRepresentable) -> FoundationModels.Prompt`
- [ ] `@_alwaysEmitIntoClient public static func buildOptional(_ component: FoundationModels.Prompt?) -> FoundationModels.Prompt`
- [ ] `@_disfavoredOverload @_alwaysEmitIntoClient public static func buildExpression<P>(_ expression: P) -> P where P : FoundationModels.PromptRepresentable`

### [ ] `PromptRepresentable` — 0 members


### [ ] `Property` — 5 members

- [ ] `public init(name: Swift.String, description: Swift.String? = nil, schema: FoundationModels.DynamicGenerationSchema, isOptional: Swift.Bool = false)`
- [ ] `public init<RegexOutput>(name: Swift.String, description: Swift.String? = nil, type: Swift.String.Type, guides: [_StringProcessing.Regex<RegexOutput>] = [])`
- [ ] `public init<RegexOutput>(name: Swift.String, description: Swift.String? = nil, type: Swift.String?.Type, guides: [_StringProcessing.Regex<RegexOutput>] = [])`
- [ ] `public init<Value>(name: Swift.String, description: Swift.String? = nil, type: Value.Type, guides: [FoundationModels.GenerationGuide<Value>] = []) where Value : FoundationModels.Generable`
- [ ] `public init<Value>(name: Swift.String, description: Swift.String? = nil, type: Value?.Type, guides: [FoundationModels.GenerationGuide<Value>] = []) where Value : FoundationModels.Generable`

### [ ] `Refusal` — 3 members

- [ ] `public init(transcriptEntries: [FoundationModels.Transcript.Entry])`
- [ ] `public var explanation: FoundationModels.LanguageModelSession.Response<Swift.String>`
- [ ] `public var explanationStream: FoundationModels.LanguageModelSession.ResponseStream<Swift.String>`

### [ ] `Response` — 9 members

- [ ] `public init(id: Swift.String = UUID().uuidString, assetIDs: [Swift.String], segments: [FoundationModels.Transcript.Segment])`
- [ ] `public let content: Content`
- [ ] `public let rawContent: FoundationModels.GeneratedContent`
- [ ] `public let transcriptEntries: Swift.ArraySlice<FoundationModels.Transcript.Entry>`
- [ ] `public static func == (a: FoundationModels.Transcript.Response, b: FoundationModels.Transcript.Response) -> Swift.Bool`
- [ ] `public typealias ID = Swift.String`
- [ ] `public var assetIDs: [Swift.String]`
- [ ] `public var id: Swift.String`
- [ ] `public var segments: [FoundationModels.Transcript.Segment]`

### [ ] `ResponseFormat` — 4 members

- [ ] `public init(schema: FoundationModels.GenerationSchema)`
- [ ] `public init<Content>(type: Content.Type) where Content : FoundationModels.Generable`
- [ ] `public static func == (a: FoundationModels.Transcript.ResponseFormat, b: FoundationModels.Transcript.ResponseFormat) -> Swift.Bool`
- [ ] `public var name: Swift.String`

### [ ] `ResponseStream` — 0 members


### [ ] `SamplingMode` — 4 members

- [ ] `public static func == (a: FoundationModels.GenerationOptions.SamplingMode, b: FoundationModels.GenerationOptions.SamplingMode) -> Swift.Bool`
- [ ] `public static func random(probabilityThreshold: Swift.Double, seed: Swift.UInt64? = nil) -> FoundationModels.GenerationOptions.SamplingMode`
- [ ] `public static func random(top k: Swift.Int, seed: Swift.UInt64? = nil) -> FoundationModels.GenerationOptions.SamplingMode`
- [ ] `public static var greedy: FoundationModels.GenerationOptions.SamplingMode`

### [ ] `SchemaError` — 6 members

- [ ] `case duplicateProperty(schema: Swift.String, property: Swift.String, context: FoundationModels.GenerationSchema.SchemaError.Context)`
- [ ] `case duplicateType(schema: Swift.String?, type: Swift.String, context: FoundationModels.GenerationSchema.SchemaError.Context)`
- [ ] `case emptyTypeChoices(schema: Swift.String, context: FoundationModels.GenerationSchema.SchemaError.Context)`
- [ ] `case undefinedReferences(schema: Swift.String?, references: [Swift.String], context: FoundationModels.GenerationSchema.SchemaError.Context)`
- [ ] `public var errorDescription: Swift.String?`
- [ ] `public var recoverySuggestion: Swift.String?`

### [ ] `Segment` — 5 members

- [ ] `case structure(FoundationModels.Transcript.StructuredSegment)`
- [ ] `case text(FoundationModels.Transcript.TextSegment)`
- [ ] `public static func == (a: FoundationModels.Transcript.Segment, b: FoundationModels.Transcript.Segment) -> Swift.Bool`
- [ ] `public typealias ID = Swift.String`
- [ ] `public var id: Swift.String`

### [ ] `Sentiment` — 8 members

- [ ] `case negative`
- [ ] `case neutral`
- [ ] `case positive`
- [ ] `nonisolated public static var allCases: [FoundationModels.LanguageModelFeedback.Sentiment]`
- [ ] `public func hash(into hasher: inout Swift.Hasher)`
- [ ] `public static func == (a: FoundationModels.LanguageModelFeedback.Sentiment, b: FoundationModels.LanguageModelFeedback.Sentiment) -> Swift.Bool`
- [ ] `public typealias AllCases = [FoundationModels.LanguageModelFeedback.Sentiment]`
- [ ] `public var hashValue: Swift.Int`

### [ ] `Snapshot` — 2 members

- [ ] `public var content: Content.PartiallyGenerated`
- [ ] `public var rawContent: FoundationModels.GeneratedContent`

### [ ] `String` — 5 members

- [ ] `public init(_ content: FoundationModels.GeneratedContent) throws`
- [ ] `public static var generationSchema: FoundationModels.GenerationSchema`
- [ ] `public var generatedContent: FoundationModels.GeneratedContent`
- [ ] `public var instructionsRepresentation: FoundationModels.Instructions`
- [ ] `public var promptRepresentation: FoundationModels.Prompt`

### [ ] `StructuredSegment` — 6 members

- [ ] `public init(id: Swift.String = UUID().uuidString, source: Swift.String, content: FoundationModels.GeneratedContent)`
- [ ] `public static func == (a: FoundationModels.Transcript.StructuredSegment, b: FoundationModels.Transcript.StructuredSegment) -> Swift.Bool`
- [ ] `public typealias ID = Swift.String`
- [ ] `public var content: FoundationModels.GeneratedContent`
- [ ] `public var id: Swift.String`
- [ ] `public var source: Swift.String`

### [ ] `SystemLanguageModel` — 13 members

- [ ] `convenience public init(adapter: FoundationModels.SystemLanguageModel.Adapter, guardrails: FoundationModels.SystemLanguageModel.Guardrails = .default)`
- [ ] `convenience public init(useCase: FoundationModels.SystemLanguageModel.UseCase = .general, guardrails: FoundationModels.SystemLanguageModel.Guardrails = Guardrails.default)`
- [ ] `final public func supportsLocale(_ locale: Foundation.Locale = Locale.current) -> Swift.Bool`
- [ ] `final public var availability: FoundationModels.SystemLanguageModel.Availability`
- [ ] `final public var isAvailable: Swift.Bool`
- [ ] `final public var supportedLanguages: Swift.Set<Foundation.Locale.Language>`
- [ ] `public func compile() async throws`
- [ ] `public init(fileURL: Foundation.URL) throws`
- [ ] `public init(name: Swift.String) throws`
- [ ] `public static func compatibleAdapterIdentifiers(name: Swift.String) -> [Swift.String]`
- [ ] `public static func isCompatible(_ assetPack: BackgroundAssets.AssetPack) -> Swift.Bool`
- [ ] `public static func removeObsoleteAdapters() throws`
- [ ] `public static let `default`: FoundationModels.SystemLanguageModel`

### [ ] `TextSegment` — 5 members

- [ ] `public init(id: Swift.String = UUID().uuidString, content: Swift.String)`
- [ ] `public static func == (a: FoundationModels.Transcript.TextSegment, b: FoundationModels.Transcript.TextSegment) -> Swift.Bool`
- [ ] `public typealias ID = Swift.String`
- [ ] `public var content: Swift.String`
- [ ] `public var id: Swift.String`

### [ ] `Tool` — 3 members

- [ ] `public var includesSchemaInInstructions: Swift.Bool`
- [ ] `public var name: Swift.String`
- [ ] `public var parameters: FoundationModels.GenerationSchema`

### [ ] `ToolCall` — 6 members

- [ ] `public init(id: Swift.String, toolName: Swift.String, arguments: FoundationModels.GeneratedContent)`
- [ ] `public static func == (a: FoundationModels.Transcript.ToolCall, b: FoundationModels.Transcript.ToolCall) -> Swift.Bool`
- [ ] `public typealias ID = Swift.String`
- [ ] `public var arguments: FoundationModels.GeneratedContent`
- [ ] `public var id: Swift.String`
- [ ] `public var toolName: Swift.String`

### [ ] `ToolCallError` — 4 members

- [ ] `public init(tool: any FoundationModels.Tool, underlyingError: any Swift.Error)`
- [ ] `public var errorDescription: Swift.String?`
- [ ] `public var tool: any FoundationModels.Tool`
- [ ] `public var underlyingError: any Swift.Error`

### [ ] `ToolCalls` — 12 members

- [ ] `public init<S>(id: Swift.String = UUID().uuidString, _ calls: S) where S : Swift.Sequence, S.Element == FoundationModels.Transcript.ToolCall`
- [ ] `public static func == (a: FoundationModels.Transcript.ToolCalls, b: FoundationModels.Transcript.ToolCalls) -> Swift.Bool`
- [ ] `public subscript(position: Swift.Int) -> FoundationModels.Transcript.ToolCall`
- [ ] `public typealias Element = FoundationModels.Transcript.ToolCall`
- [ ] `public typealias ID = Swift.String`
- [ ] `public typealias Index = Swift.Int`
- [ ] `public typealias Indices = Swift.Range<Swift.Int>`
- [ ] `public typealias Iterator = Swift.IndexingIterator<FoundationModels.Transcript.ToolCalls>`
- [ ] `public typealias SubSequence = Swift.Slice<FoundationModels.Transcript.ToolCalls>`
- [ ] `public var endIndex: Swift.Int`
- [ ] `public var id: Swift.String`
- [ ] `public var startIndex: Swift.Int`

### [ ] `ToolDefinition` — 5 members

- [ ] `public init(name: Swift.String, description: Swift.String, parameters: FoundationModels.GenerationSchema)`
- [ ] `public init(tool: some Tool)`
- [ ] `public static func == (a: FoundationModels.Transcript.ToolDefinition, b: FoundationModels.Transcript.ToolDefinition) -> Swift.Bool`
- [ ] `public var description: Swift.String`
- [ ] `public var name: Swift.String`

### [ ] `ToolOutput` — 6 members

- [ ] `public init(id: Swift.String, toolName: Swift.String, segments: [FoundationModels.Transcript.Segment])`
- [ ] `public static func == (a: FoundationModels.Transcript.ToolOutput, b: FoundationModels.Transcript.ToolOutput) -> Swift.Bool`
- [ ] `public typealias ID = Swift.String`
- [ ] `public var id: Swift.String`
- [ ] `public var segments: [FoundationModels.Transcript.Segment]`
- [ ] `public var toolName: Swift.String`

### [ ] `Transcript` — 13 members

- [ ] `public func encode(to encoder: any Swift.Encoder) throws`
- [ ] `public init(entries: some Sequence<Entry> = [])`
- [ ] `public init(from decoder: any Swift.Decoder) throws`
- [ ] `public static func == (a: FoundationModels.Transcript, b: FoundationModels.Transcript) -> Swift.Bool`
- [ ] `public subscript(index: FoundationModels.Transcript.Index) -> FoundationModels.Transcript.Entry`
- [ ] `public typealias Element = FoundationModels.Transcript.Entry`
- [ ] `public typealias Index = Swift.Int`
- [ ] `public typealias Indices = Swift.Range<FoundationModels.Transcript.Index>`
- [ ] `public typealias Iterator = Swift.IndexingIterator<FoundationModels.Transcript>`
- [ ] `public typealias SubSequence = Swift.Slice<FoundationModels.Transcript>`
- [ ] `public var description: Swift.String`
- [ ] `public var endIndex: Swift.Int`
- [ ] `public var startIndex: Swift.Int`

### [ ] `UnavailableReason` — 6 members

- [ ] `case appleIntelligenceNotEnabled`
- [ ] `case deviceNotEligible`
- [ ] `case modelNotReady`
- [ ] `public func hash(into hasher: inout Swift.Hasher)`
- [ ] `public static func == (a: FoundationModels.SystemLanguageModel.Availability.UnavailableReason, b: FoundationModels.SystemLanguageModel.Availability.UnavailableReason) -> Swift.Bool`
- [ ] `public var hashValue: Swift.Int`

### [ ] `UseCase` — 3 members

- [ ] `public static func == (a: FoundationModels.SystemLanguageModel.UseCase, b: FoundationModels.SystemLanguageModel.UseCase) -> Swift.Bool`
- [ ] `public static let contentTagging: FoundationModels.SystemLanguageModel.UseCase`
- [ ] `public static let general: FoundationModels.SystemLanguageModel.UseCase`


---

## ImagePlayground

> Image generation + Genmoji. iOS 18.2+. AI-gated. Polyfill: diffusion backend (cloud or CoreML SD).

Source: iPhoneOS26.2.sdk · Swift (.swiftinterface) · full framework

Types: 11 · Members: 66

### [ ] `CreatedImage` — 1 member

- [ ] `public let cgImage: CoreGraphics.CGImage`

### [ ] `Delegate` — 0 members


### [ ] `EnvironmentValues` — 4 members

- [ ] `public var imagePlaygroundAllowedGenerationStyles: [ImagePlayground.ImagePlaygroundStyle]`
- [ ] `public var imagePlaygroundPersonalizationPolicy: ImagePlayground.ImagePlaygroundPersonalizationPolicy`
- [ ] `public var imagePlaygroundSelectedGenerationStyle: ImagePlayground.ImagePlaygroundStyle`
- [ ] `public var supportsImagePlayground: Swift.Bool`

### [ ] `Error` — 16 members

- [ ] `case backgroundCreationForbidden`
- [ ] `case conceptsRequirePersonIdentity`
- [ ] `case creationCancelled`
- [ ] `case creationFailed`
- [ ] `case faceInImageTooSmall`
- [ ] `case notSupported`
- [ ] `case unavailable`
- [ ] `case unsupportedInputImage`
- [ ] `case unsupportedLanguage`
- [ ] `public func hash(into hasher: inout Swift.Hasher)`
- [ ] `public static func == (a: ImagePlayground.ImageCreator.Error, b: ImagePlayground.ImageCreator.Error) -> Swift.Bool`
- [ ] `public static var allCases: [ImagePlayground.ImageCreator.Error]`
- [ ] `public static var errorDomain: Swift.String`
- [ ] `public typealias AllCases = [ImagePlayground.ImageCreator.Error]`
- [ ] `public var errorUserInfo: [Swift.String : Any]`
- [ ] `public var hashValue: Swift.Int`

### [ ] `ImageCreator` — 3 members

- [ ] `final public func images(for concepts: [ImagePlayground.ImagePlaygroundConcept], style: ImagePlayground.ImagePlaygroundStyle, limit: Swift.Int) -> some _Concurrency.AsyncSequence<ImagePlayground.ImageCreator.CreatedImage, any Swift.Error>`
- [ ] `final public let availableStyles: [ImagePlayground.ImagePlaygroundStyle]`
- [ ] `public init() async throws`

### [ ] `ImagePlaygroundConcept` — 5 members

- [ ] `public static func drawing(_ drawing: PencilKit.PKDrawing) -> ImagePlayground.ImagePlaygroundConcept`
- [ ] `public static func extracted(from text: Swift.String, title: Swift.String? = nil) -> ImagePlayground.ImagePlaygroundConcept`
- [ ] `public static func image(_ image: CoreGraphics.CGImage) -> ImagePlayground.ImagePlaygroundConcept`
- [ ] `public static func image(_ url: Foundation.URL) -> ImagePlayground.ImagePlaygroundConcept?`
- [ ] `public static func text(_ text: Swift.String) -> ImagePlayground.ImagePlaygroundConcept`

### [ ] `ImagePlaygroundPersonalizationPolicy` — 6 members

- [ ] `case automatic`
- [ ] `case disabled`
- [ ] `case enabled`
- [ ] `public init?(rawValue: Swift.Int)`
- [ ] `public typealias RawValue = Swift.Int`
- [ ] `public var rawValue: Swift.Int`

### [ ] `ImagePlaygroundStyle` — 12 members

- [ ] `public func encode(to encoder: any Swift.Encoder) throws`
- [ ] `public func hash(into hasher: inout Swift.Hasher)`
- [ ] `public init(from decoder: any Swift.Decoder) throws`
- [ ] `public let id: Swift.String`
- [ ] `public static func == (a: ImagePlayground.ImagePlaygroundStyle, b: ImagePlayground.ImagePlaygroundStyle) -> Swift.Bool`
- [ ] `public static let animation: ImagePlayground.ImagePlaygroundStyle`
- [ ] `public static let externalProvider: ImagePlayground.ImagePlaygroundStyle`
- [ ] `public static let illustration: ImagePlayground.ImagePlaygroundStyle`
- [ ] `public static let sketch: ImagePlayground.ImagePlaygroundStyle`
- [ ] `public static var all: [ImagePlayground.ImagePlaygroundStyle]`
- [ ] `public typealias ID = Swift.String`
- [ ] `public var hashValue: Swift.Int`

### [ ] `ImagePlaygroundViewController` — 13 members

- [ ] `@_Concurrency.MainActor @preconcurrency @objc convenience dynamic public init()`
- [ ] `@_Concurrency.MainActor @preconcurrency @objc override dynamic public func viewDidDisappear(_ animated: Swift.Bool)`
- [ ] `@_Concurrency.MainActor @preconcurrency @objc override dynamic public func viewDidLoad()`
- [ ] `@_Concurrency.MainActor @preconcurrency @objc override dynamic public var isModalInPresentation: Swift.Bool`
- [ ] `@_Concurrency.MainActor @preconcurrency @objc override dynamic public var modalPresentationStyle: UIKit.UIModalPresentationStyle`
- [ ] `@_Concurrency.MainActor @preconcurrency @objc override dynamic public var preferredContentSize: CoreFoundation.CGSize`
- [ ] `@_Concurrency.MainActor @preconcurrency @objc override dynamic public var supportedInterfaceOrientations: UIKit.UIInterfaceOrientationMask`
- [ ] `@_Concurrency.MainActor @preconcurrency public var allowedGenerationStyles: [ImagePlayground.ImagePlaygroundStyle]`
- [ ] `@_Concurrency.MainActor @preconcurrency public var concepts: [ImagePlayground.ImagePlaygroundConcept]`
- [ ] `@_Concurrency.MainActor @preconcurrency public var personalizationPolicy: ImagePlayground.ImagePlaygroundPersonalizationPolicy`
- [ ] `@_Concurrency.MainActor @preconcurrency public var selectedGenerationStyle: ImagePlayground.ImagePlaygroundStyle`
- [ ] `@objc @_Concurrency.MainActor @preconcurrency public var sourceImage: UIKit.UIImage?`
- [ ] `@objc @_Concurrency.MainActor @preconcurrency weak public var delegate: (any ImagePlayground.ImagePlaygroundViewController.Delegate)?`

### [ ] `View` — 6 members

- [ ] `@_Concurrency.MainActor @preconcurrency public func imagePlaygroundSheet(isPresented: SwiftUICore.Binding<Swift.Bool>, concept: Swift.String, sourceImage: SwiftUICore.Image? = nil, onCompletion: @escaping (_ url: Foundation.URL) -> Swift.Void, onCancellation: (() -> Swift.Void)? = nil) -> some SwiftUICore.View`
- [ ] `@_Concurrency.MainActor @preconcurrency public func imagePlaygroundSheet(isPresented: SwiftUICore.Binding<Swift.Bool>, concept: Swift.String, sourceImageURL: Foundation.URL, onCompletion: @escaping (_ url: Foundation.URL) -> Swift.Void, onCancellation: (() -> Swift.Void)? = nil) -> some SwiftUICore.View`
- [ ] `@_Concurrency.MainActor @preconcurrency public func imagePlaygroundSheet(isPresented: SwiftUICore.Binding<Swift.Bool>, concepts: [ImagePlayground.ImagePlaygroundConcept] = [], sourceImage: SwiftUICore.Image? = nil, onCompletion: @escaping (Foundation.URL) -> Swift.Void, onCancellation: (() -> Swift.Void)? = nil) -> some SwiftUICore.View`
- [ ] `@_Concurrency.MainActor @preconcurrency public func imagePlaygroundSheet(isPresented: SwiftUICore.Binding<Swift.Bool>, concepts: [ImagePlayground.ImagePlaygroundConcept] = [], sourceImageURL: Foundation.URL, onCompletion: @escaping (_ url: Foundation.URL) -> Swift.Void, onCancellation: (() -> Swift.Void)? = nil) -> some SwiftUICore.View`
- [ ] `nonisolated public func imagePlaygroundGenerationStyle(_ style: ImagePlayground.ImagePlaygroundStyle, in allowedStyles: [ImagePlayground.ImagePlaygroundStyle] = ImagePlaygroundStyle.all) -> some SwiftUICore.View`
- [ ] `nonisolated public func imagePlaygroundPersonalizationPolicy(_ policy: ImagePlayground.ImagePlaygroundPersonalizationPolicy = .automatic) -> some SwiftUICore.View`

### [ ] `var` — 0 members



---

## VisualIntelligence

> Camera/onscreen semantic search. iOS 26+. AI-gated. Polyfill: VisionKit DataScanner + vision model.

Source: iPhoneOS26.2.sdk · Swift (.swiftinterface) · full framework

Types: 1 · Members: 10

### [ ] `SemanticContentDescriptor` — 10 members

- [ ] `public let labels: [Swift.String]`
- [ ] `public static var defaultResolverSpecification: some AppIntents.ResolverSpecification`
- [ ] `public static var persistentIdentifier: Swift.String`
- [ ] `public static var typeDisplayRepresentation: AppIntents.TypeDisplayRepresentation`
- [ ] `public typealias Specification = @_opaqueReturnTypeOf("$s18VisualIntelligence25SemanticContentDescriptorV28defaultResolverSpecificationQrvpZ", 0) __`
- [ ] `public typealias UnwrappedType = VisualIntelligence.SemanticContentDescriptor`
- [ ] `public typealias ValueType = VisualIntelligence.SemanticContentDescriptor`
- [ ] `public var description: Swift.String`
- [ ] `public var displayRepresentation: AppIntents.DisplayRepresentation`
- [ ] `public var pixelBuffer: CoreVideo.CVReadOnlyPixelBuffer?`


---

## UIKit (AI subset)

> Writing Tools + Genmoji adaptive glyphs — AI-gated subset of UIKit (UIKit itself ships). Polyfill: custom UIMenu → LLM backend; glyphs as NSTextAttachment.

Source: iPhoneOS26.2.sdk · Swift (.swiftinterface) · filtered subset `WritingTools|AdaptiveImageGlyph|WritingToolsCoordinator|WritingToolsResult|WritingToolsBehavior`

Types: 4 · Members: 36

### [ ] `AdaptiveImageGlyphAttribute` — 9 members

- [ ] `public static func decode(from decoder: any Swift.Decoder) throws -> Foundation.AttributedString.AdaptiveImageGlyph`
- [ ] `public static func encode(_ value: Foundation.AttributedString.AdaptiveImageGlyph, to encoder: any Swift.Encoder) throws`
- [ ] `public static func objectiveCValue(for value: Foundation.AttributedString.AdaptiveImageGlyph) throws -> NSAdaptiveImageGlyph`
- [ ] `public static func value(for object: NSAdaptiveImageGlyph) throws -> Foundation.AttributedString.AdaptiveImageGlyph`
- [ ] `public static let name: Swift.String`
- [ ] `public static var inheritedByAddedText: Swift.Bool`
- [ ] `public static var runBoundaries: Foundation.AttributedString.AttributeRunBoundaries?`
- [ ] `public typealias ObjectiveCValue = NSAdaptiveImageGlyph`
- [ ] `public typealias Value = Foundation.AttributedString.AdaptiveImageGlyph`

### [ ] `AttributedString` — 1 member

- [ ] `public init(_ nsAdaptiveImageGlyph: NSAdaptiveImageGlyph)`

### [ ] `NSAdaptiveImageGlyph` — 1 member

- [ ] `convenience public init(_ adaptiveImageGlypth: Foundation.AttributedString.AdaptiveImageGlyph)`

### [ ] `UIKitAttributes` — 25 members

- [ ] `public let accessibility: Foundation.AttributeScopes.AccessibilityAttributes`
- [ ] `public let adaptiveImageGlyph: Foundation.AttributeScopes.UIKitAttributes.AdaptiveImageGlyphAttribute`
- [ ] `public let attachment: Foundation.AttributeScopes.UIKitAttributes.AttachmentAttribute`
- [ ] `public let backgroundColor: Foundation.AttributeScopes.UIKitAttributes.BackgroundColorAttribute`
- [ ] `public let baselineOffset: Foundation.AttributeScopes.UIKitAttributes.BaselineOffsetAttribute`
- [ ] `public let expansion: Foundation.AttributeScopes.UIKitAttributes.ExpansionAttribute`
- [ ] `public let font: Foundation.AttributeScopes.UIKitAttributes.FontAttribute`
- [ ] `public let foregroundColor: Foundation.AttributeScopes.UIKitAttributes.ForegroundColorAttribute`
- [ ] `public let foundation: Foundation.AttributeScopes.FoundationAttributes`
- [ ] `public let kern: Foundation.AttributeScopes.UIKitAttributes.KernAttribute`
- [ ] `public let ligature: Foundation.AttributeScopes.UIKitAttributes.LigatureAttribute`
- [ ] `public let obliqueness: Foundation.AttributeScopes.UIKitAttributes.ObliquenessAttribute`
- [ ] `public let paragraphStyle: Foundation.AttributeScopes.UIKitAttributes.ParagraphStyleAttribute`
- [ ] `public let shadow: Foundation.AttributeScopes.UIKitAttributes.ShadowAttribute`
- [ ] `public let strikethroughColor: Foundation.AttributeScopes.UIKitAttributes.StrikethroughColorAttribute`
- [ ] `public let strikethroughStyle: Foundation.AttributeScopes.UIKitAttributes.StrikethroughStyleAttribute`
- [ ] `public let strokeColor: Foundation.AttributeScopes.UIKitAttributes.StrokeColorAttribute`
- [ ] `public let strokeWidth: Foundation.AttributeScopes.UIKitAttributes.StrokeWidthAttribute`
- [ ] `public let textEffect: Foundation.AttributeScopes.UIKitAttributes.TextEffectAttribute`
- [ ] `public let textItemTag: Foundation.AttributeScopes.UIKitAttributes.TextItemTagAttribute`
- [ ] `public let tracking: Foundation.AttributeScopes.UIKitAttributes.TrackingAttribute`
- [ ] `public let underlineColor: Foundation.AttributeScopes.UIKitAttributes.UnderlineColorAttribute`
- [ ] `public let underlineStyle: Foundation.AttributeScopes.UIKitAttributes.UnderlineStyleAttribute`
- [ ] `public typealias DecodingConfiguration = Foundation.AttributeScopeCodableConfiguration`
- [ ] `public typealias EncodingConfiguration = Foundation.AttributeScopeCodableConfiguration`


---

## AppIntents (AI subset)

> Assistant schemas (AI Siri) — AI-gated subset of AppIntents (AppIntents itself ships). Polyfill: intent-router LLM.

Source: iPhoneOS26.2.sdk · Swift (.swiftinterface) · filtered subset `AssistantSchema|AssistantIntent|AssistantEntity|AssistantEnum`

Types: 8 · Members: 205

### [ ] `AssistantEntity` — 0 members


### [ ] `AssistantEnum` — 0 members


### [ ] `AssistantIntent` — 0 members


### [ ] `AssistantSchema` — 3 members

- [ ] `public init(_ schema: some AssistantSchemas.Entity)`
- [ ] `public init(_ schema: some AssistantSchemas.Enum)`
- [ ] `public init(_ schema: some AssistantSchemas.Intent)`

### [ ] `AssistantSchemaEntity` — 2 members

- [ ] `public static var isAssistantOnly: Swift.Bool`
- [ ] `public static var typeDisplayRepresentation: AppIntents.TypeDisplayRepresentation`

### [ ] `AssistantSchemaEnum` — 2 members

- [ ] `public static var isAssistantOnly: Swift.Bool`
- [ ] `public static var typeDisplayRepresentation: AppIntents.TypeDisplayRepresentation`

### [ ] `AssistantSchemaIntent` — 2 members

- [ ] `public static var isAssistantOnly: Swift.Bool`
- [ ] `public static var title: Foundation.LocalizedStringResource`

### [ ] `AssistantSchemas` — 196 members

- [ ] `@_alwaysEmitIntoClient public static var assistant: some AppIntents.AssistantSchemas.AssistantIntent`
- [ ] `@_alwaysEmitIntoClient public static var books: some AppIntents.AssistantSchemas.BooksEntity`
- [ ] `@_alwaysEmitIntoClient public static var books: some AppIntents.AssistantSchemas.BooksEnum`
- [ ] `@_alwaysEmitIntoClient public static var books: some AppIntents.AssistantSchemas.BooksIntent`
- [ ] `@_alwaysEmitIntoClient public static var browser: some AppIntents.AssistantSchemas.BrowserEntity`
- [ ] `@_alwaysEmitIntoClient public static var browser: some AppIntents.AssistantSchemas.BrowserEnum`
- [ ] `@_alwaysEmitIntoClient public static var camera: some AppIntents.AssistantSchemas.CameraEnum`
- [ ] `@_alwaysEmitIntoClient public static var camera: some AppIntents.AssistantSchemas.CameraIntent`
- [ ] `@_alwaysEmitIntoClient public static var files: some AppIntents.AssistantSchemas.FilesEntity`
- [ ] `@_alwaysEmitIntoClient public static var files: some AppIntents.AssistantSchemas.FilesIntent`
- [ ] `@_alwaysEmitIntoClient public static var journal: some AppIntents.AssistantSchemas.JournalEntity`
- [ ] `@_alwaysEmitIntoClient public static var journal: some AppIntents.AssistantSchemas.JournalIntent`
- [ ] `@_alwaysEmitIntoClient public static var mail: some AppIntents.AssistantSchemas.MailEntity`
- [ ] `@_alwaysEmitIntoClient public static var mail: some AppIntents.AssistantSchemas.MailIntent`
- [ ] `@_alwaysEmitIntoClient public static var photos: some AppIntents.AssistantSchemas.PhotosEntity`
- [ ] `@_alwaysEmitIntoClient public static var photos: some AppIntents.AssistantSchemas.PhotosEnum`
- [ ] `@_alwaysEmitIntoClient public static var photos: some AppIntents.AssistantSchemas.PhotosIntent`
- [ ] `@_alwaysEmitIntoClient public static var presentation: some AppIntents.AssistantSchemas.PresentationEntity`
- [ ] `@_alwaysEmitIntoClient public static var presentation: some AppIntents.AssistantSchemas.PresentationIntent`
- [ ] `@_alwaysEmitIntoClient public static var reader: some AppIntents.AssistantSchemas.ReaderEntity`
- [ ] `@_alwaysEmitIntoClient public static var reader: some AppIntents.AssistantSchemas.ReaderEnum`
- [ ] `@_alwaysEmitIntoClient public static var reader: some AppIntents.AssistantSchemas.ReaderIntent`
- [ ] `@_alwaysEmitIntoClient public static var spreadsheet: some AppIntents.AssistantSchemas.SpreadsheetEntity`
- [ ] `@_alwaysEmitIntoClient public static var spreadsheet: some AppIntents.AssistantSchemas.SpreadsheetIntent`
- [ ] `@_alwaysEmitIntoClient public static var system: some AppIntents.AssistantSchemas.SystemIntent`
- [ ] `@_alwaysEmitIntoClient public static var visualIntelligence: some AppIntents.AssistantSchemas.VisualIntelligenceIntent`
- [ ] `@_alwaysEmitIntoClient public static var whiteboard: some AppIntents.AssistantSchemas.WhiteboardEntity`
- [ ] `@_alwaysEmitIntoClient public static var whiteboard: some AppIntents.AssistantSchemas.WhiteboardEnum`
- [ ] `@_alwaysEmitIntoClient public static var whiteboard: some AppIntents.AssistantSchemas.WhiteboardIntent`
- [ ] `@_alwaysEmitIntoClient public static var wordProcessor: some AppIntents.AssistantSchemas.WordProcessorEntity`
- [ ] `@_alwaysEmitIntoClient public static var wordProcessor: some AppIntents.AssistantSchemas.WordProcessorIntent`
- [ ] `@_alwaysEmitIntoClient public var account: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var activate: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addAssetsToAlbum: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addAudioToPage: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addAudioToSheet: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addAudioToSlide: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addCommentToSheet: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addCommentToSlide: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addImageToPage: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addImageToSheet: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addImageToSlide: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addTextBoxToPage: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addTextBoxToSheet: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addTextBoxToSlide: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addVideoToPage: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addVideoToSheet: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addVideoToSlide: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addWebVideoToPage: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addWebVideoToSheet: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addWebVideoToSlide: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var album: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var albumType: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var archiveMail: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var asset: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var assetType: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var audiobook: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var board: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var book: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var bookmark: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var bookmarkTab: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var bookmarkURL: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var captureDevice: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var captureDuration: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var captureMode: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var cleanupPhoto: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var clearHistory: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var clearHistoryTimeFrame: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var closeTabs: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var closeWindows: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var color: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var contentType: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var copyEdits: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var create: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var createAlbum: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var createAssets: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var createAudioEntry: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var createBoard: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var createDraft: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var createEntry: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var createFolder: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var createItem: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var createPage: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var createSheet: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var createSlide: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var createTab: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var createWindow: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var crop: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var delete: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var deleteAlbum: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var deleteAssets: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var deleteBoard: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var deleteBookmarks: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var deleteDraft: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var deleteEntry: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var deleteFiles: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var deleteItem: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var deleteMail: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var deletePages: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var deleteSheet: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var deleteSlide: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var document: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var documentKind: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var draft: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var duplicateAssets: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var enhanceDocuments: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var entry: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var file: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var filterType: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var findOnPage: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var font: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var fontSize: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var forwardMail: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var insertPages: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var item: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var itemType: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var mailbox: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var message: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var moveFiles: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var navigatePage: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var navigationDirection: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var open: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var openAlbum: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var openAsset: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var openBoard: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var openBook: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var openBookmark: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var openDocument: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var openFile: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var openInCaptureMode: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var openPage: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var openSheet: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var openSlide: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var openURLInTab: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var page: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var pageNavigationSetting: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var pasteEdits: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var playAudiobook: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var postToSharedAlbum: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var recognizedPerson: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var relativeCharacterSpacingChange: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var relativeFontChange: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var relativeLineSpacingChange: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var relativeWordSpacingChange: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var removeAssetsFromAlbum: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var renameFile: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var replyMail: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var resizeDocuments: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var rotateDocuments: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var rotatePages: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var rotationDirection: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var saveDraft: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var search: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var searchDocuments: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var semanticContentSearch: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var sendDraft: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var setDepth: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var setDevice: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var setExposure: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var setFilter: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var setRotation: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var setSaturation: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var setSlideTitle: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var setWarmth: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var settings: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var sheet: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var slide: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var startCapture: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var startPlayback: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var stopCapture: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var stopPlayback: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var straighten: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var switchDevice: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var switchTab: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var tab: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var template: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var theme: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var toggleDepth: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var toggleSuggestedEdits: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var update: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var updateAlbum: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var updateAsset: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var updateBoard: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var updateCharacterSpacing: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var updateDraft: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var updateEntry: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var updateFontSize: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var updateItem: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var updateLineSpacing: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var updateMail: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var updateRecognizedPerson: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var updateSettings: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var updateSheet: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var updateWordSpacing: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var window: some AppIntents.AssistantSchemas.Entity`
- [ ] `public static var browser: some AppIntents.AssistantSchemas.BrowserIntent`

| Framework | Types | Members |
|---|--:|--:|
| FoundationModels | 59 | 364 |
| ImagePlayground | 11 | 66 |
| VisualIntelligence | 1 | 10 |
| UIKit (AI subset) | 4 | 36 |
| AppIntents (AI subset) | 8 | 205 |
| **TOTAL** | **83** | **681** |


---

## FoundationModels

> On-device LLM (Apple Intelligence core). iOS 26+. Present on ineligible devices but SystemLanguageModel.availability == .unavailable(.deviceNotEligible). Polyfill: mirror API, route to cloud LLM or local MLX/llama.cpp; @Generable → constrained JSON decode.

Source: iPhoneOS26.2.sdk · Swift (.swiftinterface) · full framework

Types: 59 · Members: 364

### [ ] `Adapter` — 1 member

- [ ] `public var creatorDefinedMetadata: [Swift.String : Any]`

### [ ] `Array` — 6 members

- [ ] `public init(_ content: FoundationModels.GeneratedContent) throws`
- [ ] `public static var generationSchema: FoundationModels.GenerationSchema`
- [ ] `public typealias PartiallyGenerated = [Element.PartiallyGenerated]`
- [ ] `public var generatedContent: FoundationModels.GeneratedContent`
- [ ] `public var instructionsRepresentation: FoundationModels.Instructions`
- [ ] `public var promptRepresentation: FoundationModels.Prompt`

### [ ] `AssetError` — 5 members

- [ ] `case compatibleAdapterNotFound(FoundationModels.SystemLanguageModel.Adapter.AssetError.Context)`
- [ ] `case invalidAdapterName(FoundationModels.SystemLanguageModel.Adapter.AssetError.Context)`
- [ ] `case invalidAsset(FoundationModels.SystemLanguageModel.Adapter.AssetError.Context)`
- [ ] `public var errorDescription: Swift.String?`
- [ ] `public var recoverySuggestion: Swift.String?`

### [ ] `AsyncIterator` — 3 members

- [ ] `@_implements(_Concurrency.AsyncIteratorProtocol, Failure) public typealias __AsyncIteratorProtocol_Failure = any Swift.Error`
- [ ] `public mutating func next(isolation actor: isolated (any _Concurrency.Actor)? = #isolation) async throws -> FoundationModels.LanguageModelSession.ResponseStream<Content>.Snapshot?`
- [ ] `public typealias Element = FoundationModels.LanguageModelSession.ResponseStream<Content>.Snapshot`

### [ ] `Availability` — 3 members

- [ ] `case available`
- [ ] `case unavailable(FoundationModels.SystemLanguageModel.Availability.UnavailableReason)`
- [ ] `public static func == (a: FoundationModels.SystemLanguageModel.Availability, b: FoundationModels.SystemLanguageModel.Availability) -> Swift.Bool`

### [ ] `Bool` — 3 members

- [ ] `public init(_ content: FoundationModels.GeneratedContent) throws`
- [ ] `public static var generationSchema: FoundationModels.GenerationSchema`
- [ ] `public var generatedContent: FoundationModels.GeneratedContent`

### [ ] `Category` — 13 members

- [ ] `case didNotFollowInstructions`
- [ ] `case incorrect`
- [ ] `case stereotypeOrBias`
- [ ] `case suggestiveOrSexual`
- [ ] `case tooVerbose`
- [ ] `case triggeredGuardrailUnexpectedly`
- [ ] `case unhelpful`
- [ ] `case vulgarOrOffensive`
- [ ] `nonisolated public static var allCases: [FoundationModels.LanguageModelFeedback.Issue.Category]`
- [ ] `public func hash(into hasher: inout Swift.Hasher)`
- [ ] `public static func == (a: FoundationModels.LanguageModelFeedback.Issue.Category, b: FoundationModels.LanguageModelFeedback.Issue.Category) -> Swift.Bool`
- [ ] `public typealias AllCases = [FoundationModels.LanguageModelFeedback.Issue.Category]`
- [ ] `public var hashValue: Swift.Int`

### [ ] `Context` — 2 members

- [ ] `public init(debugDescription: Swift.String)`
- [ ] `public let debugDescription: Swift.String`

### [ ] `ConvertibleFromGeneratedContent` — 0 members


### [ ] `ConvertibleToGeneratedContent` — 2 members

- [ ] `public var instructionsRepresentation: FoundationModels.Instructions`
- [ ] `public var promptRepresentation: FoundationModels.Prompt`

### [ ] `Decimal` — 3 members

- [ ] `public init(_ content: FoundationModels.GeneratedContent) throws`
- [ ] `public static var generationSchema: FoundationModels.GenerationSchema`
- [ ] `public var generatedContent: FoundationModels.GeneratedContent`

### [ ] `Double` — 3 members

- [ ] `public init(_ content: FoundationModels.GeneratedContent) throws`
- [ ] `public static var generationSchema: FoundationModels.GenerationSchema`
- [ ] `public var generatedContent: FoundationModels.GeneratedContent`

### [ ] `DynamicGenerationSchema` — 6 members

- [ ] `public init(arrayOf itemSchema: FoundationModels.DynamicGenerationSchema, minimumElements: Swift.Int? = nil, maximumElements: Swift.Int? = nil)`
- [ ] `public init(name: Swift.String, description: Swift.String? = nil, anyOf choices: [FoundationModels.DynamicGenerationSchema])`
- [ ] `public init(name: Swift.String, description: Swift.String? = nil, anyOf choices: [Swift.String])`
- [ ] `public init(name: Swift.String, description: Swift.String? = nil, properties: [FoundationModels.DynamicGenerationSchema.Property])`
- [ ] `public init(referenceTo name: Swift.String)`
- [ ] `public init<Value>(type: Value.Type, guides: [FoundationModels.GenerationGuide<Value>] = []) where Value : FoundationModels.Generable`

### [ ] `Entry` — 8 members

- [ ] `case instructions(FoundationModels.Transcript.Instructions)`
- [ ] `case prompt(FoundationModels.Transcript.Prompt)`
- [ ] `case response(FoundationModels.Transcript.Response)`
- [ ] `case toolCalls(FoundationModels.Transcript.ToolCalls)`
- [ ] `case toolOutput(FoundationModels.Transcript.ToolOutput)`
- [ ] `public static func == (a: FoundationModels.Transcript.Entry, b: FoundationModels.Transcript.Entry) -> Swift.Bool`
- [ ] `public typealias ID = Swift.String`
- [ ] `public var id: Swift.String`

### [ ] `Float` — 3 members

- [ ] `public init(_ content: FoundationModels.GeneratedContent) throws`
- [ ] `public static var generationSchema: FoundationModels.GenerationSchema`
- [ ] `public var generatedContent: FoundationModels.GeneratedContent`

### [ ] `Generable` — 2 members

- [ ] `public func asPartiallyGenerated() -> Self.PartiallyGenerated`
- [ ] `public typealias PartiallyGenerated = Self`

### [ ] `GeneratedContent` — 19 members

- [ ] `public func value<Value>(_ type: Value.Type = Value.self) throws -> Value where Value : FoundationModels.ConvertibleFromGeneratedContent`
- [ ] `public func value<Value>(_ type: Value.Type = Value.self, forProperty property: Swift.String) throws -> Value where Value : FoundationModels.ConvertibleFromGeneratedContent`
- [ ] `public func value<Value>(_ type: Value?.Type = Value?.self, forProperty property: Swift.String) throws -> Value? where Value : FoundationModels.ConvertibleFromGeneratedContent`
- [ ] `public init(_ content: FoundationModels.GeneratedContent) throws`
- [ ] `public init(_ value: some ConvertibleToGeneratedContent)`
- [ ] `public init(_ value: some ConvertibleToGeneratedContent, id: FoundationModels.GenerationID)`
- [ ] `public init(json: Swift.String) throws`
- [ ] `public init(kind: FoundationModels.GeneratedContent.Kind, id: FoundationModels.GenerationID? = nil)`
- [ ] `public init(properties: Swift.KeyValuePairs<Swift.String, any FoundationModels.ConvertibleToGeneratedContent>, id: FoundationModels.GenerationID? = nil)`
- [ ] `public init<S>(elements: S, id: FoundationModels.GenerationID? = nil) where S : Swift.Sequence, S.Element == any FoundationModels.ConvertibleToGeneratedContent`
- [ ] `public init<S>(properties: S, id: FoundationModels.GenerationID? = nil, uniquingKeysWith combine: (FoundationModels.GeneratedContent, FoundationModels.GeneratedContent) throws -> some ConvertibleToGeneratedContent) rethrows where S : Swift.Sequence, S.Element == (Swift.String, any FoundationModels.ConvertibleToGeneratedContent)`
- [ ] `public static func == (a: FoundationModels.GeneratedContent, b: FoundationModels.GeneratedContent) -> Swift.Bool`
- [ ] `public static var generationSchema: FoundationModels.GenerationSchema`
- [ ] `public var debugDescription: Swift.String`
- [ ] `public var generatedContent: FoundationModels.GeneratedContent`
- [ ] `public var id: FoundationModels.GenerationID?`
- [ ] `public var isComplete: Swift.Bool`
- [ ] `public var jsonString: Swift.String`
- [ ] `public var kind: FoundationModels.GeneratedContent.Kind`

### [ ] `GenerationError` — 12 members

- [ ] `case assetsUnavailable(FoundationModels.LanguageModelSession.GenerationError.Context)`
- [ ] `case concurrentRequests(FoundationModels.LanguageModelSession.GenerationError.Context)`
- [ ] `case decodingFailure(FoundationModels.LanguageModelSession.GenerationError.Context)`
- [ ] `case exceededContextWindowSize(FoundationModels.LanguageModelSession.GenerationError.Context)`
- [ ] `case guardrailViolation(FoundationModels.LanguageModelSession.GenerationError.Context)`
- [ ] `case rateLimited(FoundationModels.LanguageModelSession.GenerationError.Context)`
- [ ] `case refusal(FoundationModels.LanguageModelSession.GenerationError.Refusal, FoundationModels.LanguageModelSession.GenerationError.Context)`
- [ ] `case unsupportedGuide(FoundationModels.LanguageModelSession.GenerationError.Context)`
- [ ] `case unsupportedLanguageOrLocale(FoundationModels.LanguageModelSession.GenerationError.Context)`
- [ ] `public var errorDescription: Swift.String?`
- [ ] `public var failureReason: Swift.String?`
- [ ] `public var recoverySuggestion: Swift.String?`

### [ ] `GenerationGuide` — 24 members

- [ ] `@_documentation(visibility: private) @_alwaysEmitIntoClient public static func count(_ range: Swift.ClosedRange<Swift.Int>) -> FoundationModels.GenerationGuide<Value>`
- [ ] `@_documentation(visibility: private) @_alwaysEmitIntoClient public static func maximumCount(_ count: Swift.Int) -> FoundationModels.GenerationGuide<Value>`
- [ ] `@_documentation(visibility: private) @_alwaysEmitIntoClient public static func minimumCount(_ count: Swift.Int) -> FoundationModels.GenerationGuide<Value>`
- [ ] `@_documentation(visibility: private) @_disfavoredOverload @_alwaysEmitIntoClient public static func count(_ count: Swift.Int) -> FoundationModels.GenerationGuide<Value>`
- [ ] `public static func anyOf(_ values: [Swift.String]) -> FoundationModels.GenerationGuide<Swift.String>`
- [ ] `public static func constant(_ value: Swift.String) -> FoundationModels.GenerationGuide<Swift.String>`
- [ ] `public static func count<Element>(_ count: Swift.Int) -> FoundationModels.GenerationGuide<[Element]> where Value == [Element]`
- [ ] `public static func count<Element>(_ range: Swift.ClosedRange<Swift.Int>) -> FoundationModels.GenerationGuide<[Element]> where Value == [Element]`
- [ ] `public static func element<Element>(_ guide: FoundationModels.GenerationGuide<Element>) -> FoundationModels.GenerationGuide<[Element]> where Value == [Element]`
- [ ] `public static func maximum(_ value: Foundation.Decimal) -> FoundationModels.GenerationGuide<Foundation.Decimal>`
- [ ] `public static func maximum(_ value: Swift.Double) -> FoundationModels.GenerationGuide<Swift.Double>`
- [ ] `public static func maximum(_ value: Swift.Float) -> FoundationModels.GenerationGuide<Swift.Float>`
- [ ] `public static func maximum(_ value: Swift.Int) -> FoundationModels.GenerationGuide<Swift.Int>`
- [ ] `public static func maximumCount<Element>(_ count: Swift.Int) -> FoundationModels.GenerationGuide<[Element]> where Value == [Element]`
- [ ] `public static func minimum(_ value: Foundation.Decimal) -> FoundationModels.GenerationGuide<Foundation.Decimal>`
- [ ] `public static func minimum(_ value: Swift.Double) -> FoundationModels.GenerationGuide<Swift.Double>`
- [ ] `public static func minimum(_ value: Swift.Float) -> FoundationModels.GenerationGuide<Swift.Float>`
- [ ] `public static func minimum(_ value: Swift.Int) -> FoundationModels.GenerationGuide<Swift.Int>`
- [ ] `public static func minimumCount<Element>(_ count: Swift.Int) -> FoundationModels.GenerationGuide<[Element]> where Value == [Element]`
- [ ] `public static func pattern<Output>(_ regex: _StringProcessing.Regex<Output>) -> FoundationModels.GenerationGuide<Swift.String>`
- [ ] `public static func range(_ range: Swift.ClosedRange<Foundation.Decimal>) -> FoundationModels.GenerationGuide<Foundation.Decimal>`
- [ ] `public static func range(_ range: Swift.ClosedRange<Swift.Double>) -> FoundationModels.GenerationGuide<Swift.Double>`
- [ ] `public static func range(_ range: Swift.ClosedRange<Swift.Float>) -> FoundationModels.GenerationGuide<Swift.Float>`
- [ ] `public static func range(_ range: Swift.ClosedRange<Swift.Int>) -> FoundationModels.GenerationGuide<Swift.Int>`

### [ ] `GenerationID` — 4 members

- [ ] `public func hash(into hasher: inout Swift.Hasher)`
- [ ] `public init()`
- [ ] `public static func == (a: FoundationModels.GenerationID, b: FoundationModels.GenerationID) -> Swift.Bool`
- [ ] `public var hashValue: Swift.Int`

### [ ] `GenerationOptions` — 5 members

- [ ] `public init(sampling: FoundationModels.GenerationOptions.SamplingMode? = nil, temperature: Swift.Double? = nil, maximumResponseTokens: Swift.Int? = nil)`
- [ ] `public static func == (a: FoundationModels.GenerationOptions, b: FoundationModels.GenerationOptions) -> Swift.Bool`
- [ ] `public var maximumResponseTokens: Swift.Int?`
- [ ] `public var sampling: FoundationModels.GenerationOptions.SamplingMode?`
- [ ] `public var temperature: Swift.Double?`

### [ ] `GenerationSchema` — 7 members

- [ ] `public func encode(to encoder: any Swift.Encoder) throws`
- [ ] `public init(from decoder: any Swift.Decoder) throws`
- [ ] `public init(root: FoundationModels.DynamicGenerationSchema, dependencies: [FoundationModels.DynamicGenerationSchema]) throws`
- [ ] `public init(type: any FoundationModels.Generable.Type, description: Swift.String? = nil, anyOf choices: [Swift.String])`
- [ ] `public init(type: any FoundationModels.Generable.Type, description: Swift.String? = nil, anyOf types: [any FoundationModels.Generable.Type])`
- [ ] `public init(type: any FoundationModels.Generable.Type, description: Swift.String? = nil, properties: [FoundationModels.GenerationSchema.Property])`
- [ ] `public var debugDescription: Swift.String`

### [ ] `Guardrails` — 2 members

- [ ] `public static let `default`: FoundationModels.SystemLanguageModel.Guardrails`
- [ ] `public static let permissiveContentTransformations: FoundationModels.SystemLanguageModel.Guardrails`

### [ ] `Instructions` — 9 members

- [ ] `public init(@FoundationModels.InstructionsBuilder _ content: () throws -> FoundationModels.Instructions) rethrows`
- [ ] `public init(_ content: some InstructionsRepresentable)`
- [ ] `public init(id: Swift.String = UUID().uuidString, segments: [FoundationModels.Transcript.Segment], toolDefinitions: [FoundationModels.Transcript.ToolDefinition])`
- [ ] `public static func == (a: FoundationModels.Transcript.Instructions, b: FoundationModels.Transcript.Instructions) -> Swift.Bool`
- [ ] `public typealias ID = Swift.String`
- [ ] `public var id: Swift.String`
- [ ] `public var instructionsRepresentation: FoundationModels.Instructions`
- [ ] `public var segments: [FoundationModels.Transcript.Segment]`
- [ ] `public var toolDefinitions: [FoundationModels.Transcript.ToolDefinition]`

### [ ] `InstructionsBuilder` — 9 members

- [ ] `@_alwaysEmitIntoClient public static func buildArray(_ instructions: [some InstructionsRepresentable]) -> FoundationModels.Instructions`
- [ ] `@_alwaysEmitIntoClient public static func buildBlock<each I>(_ components: repeat each I) -> FoundationModels.Instructions where repeat each I : FoundationModels.InstructionsRepresentable`
- [ ] `@_alwaysEmitIntoClient public static func buildEither(first component: some InstructionsRepresentable) -> FoundationModels.Instructions`
- [ ] `@_alwaysEmitIntoClient public static func buildEither(second component: some InstructionsRepresentable) -> FoundationModels.Instructions`
- [ ] `@_alwaysEmitIntoClient public static func buildExpression(_ expression: FoundationModels.Instructions) -> FoundationModels.Instructions`
- [ ] `@_alwaysEmitIntoClient public static func buildExpression<T>(_ expression: T) -> FoundationModels.Instructions`
- [ ] `@_alwaysEmitIntoClient public static func buildLimitedAvailability(_ instructions: some InstructionsRepresentable) -> FoundationModels.Instructions`
- [ ] `@_alwaysEmitIntoClient public static func buildOptional(_ instructions: FoundationModels.Instructions?) -> FoundationModels.Instructions`
- [ ] `@_disfavoredOverload @_alwaysEmitIntoClient public static func buildExpression<I>(_ expression: I) -> I where I : FoundationModels.InstructionsRepresentable`

### [ ] `InstructionsRepresentable` — 0 members


### [ ] `Int` — 3 members

- [ ] `public init(_ content: FoundationModels.GeneratedContent) throws`
- [ ] `public static var generationSchema: FoundationModels.GenerationSchema`
- [ ] `public var generatedContent: FoundationModels.GeneratedContent`

### [ ] `Issue` — 1 member

- [ ] `public init(category: FoundationModels.LanguageModelFeedback.Issue.Category, explanation: Swift.String? = nil)`

### [ ] `Kind` — 7 members

- [ ] `case array([FoundationModels.GeneratedContent])`
- [ ] `case bool(Swift.Bool)`
- [ ] `case null`
- [ ] `case number(Swift.Double)`
- [ ] `case string(Swift.String)`
- [ ] `case structure(properties: [Swift.String : FoundationModels.GeneratedContent], orderedKeys: [Swift.String])`
- [ ] `public static func == (a: FoundationModels.GeneratedContent.Kind, b: FoundationModels.GeneratedContent.Kind) -> Swift.Bool`

### [ ] `LanguageModelFeedback` — 0 members


### [ ] `LanguageModelSession` — 42 members

- [ ] `@_disfavoredOverload convenience public init(model: FoundationModels.SystemLanguageModel = .default, tools: [any FoundationModels.Tool] = [], instructions: Swift.String? = nil)`
- [ ] `@_disfavoredOverload final public func streamResponse(to prompt: Swift.String, options: FoundationModels.GenerationOptions = GenerationOptions()) -> FoundationModels.LanguageModelSession.ResponseStream<Swift.String>`
- [ ] `@_disfavoredOverload final public func streamResponse(to prompt: Swift.String, options: FoundationModels.GenerationOptions = GenerationOptions()) -> sending FoundationModels.LanguageModelSession.ResponseStream<Swift.String>`
- [ ] `@_disfavoredOverload final public func streamResponse(to prompt: Swift.String, schema: FoundationModels.GenerationSchema, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) -> FoundationModels.LanguageModelSession.ResponseStream<FoundationModels.GeneratedContent>`
- [ ] `@_disfavoredOverload final public func streamResponse(to prompt: Swift.String, schema: FoundationModels.GenerationSchema, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) -> sending FoundationModels.LanguageModelSession.ResponseStream<FoundationModels.GeneratedContent>`
- [ ] `@_disfavoredOverload final public func streamResponse<Content>(to prompt: Swift.String, generating type: Content.Type = Content.self, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) -> FoundationModels.LanguageModelSession.ResponseStream<Content> where Content : FoundationModels.Generable`
- [ ] `@_disfavoredOverload final public func streamResponse<Content>(to prompt: Swift.String, generating type: Content.Type = Content.self, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) -> sending FoundationModels.LanguageModelSession.ResponseStream<Content> where Content : FoundationModels.Generable`
- [ ] `@_disfavoredOverload nonisolated(nonsending) final public func respond(to prompt: Swift.String, options: FoundationModels.GenerationOptions = GenerationOptions()) async throws -> FoundationModels.LanguageModelSession.Response<Swift.String>`
- [ ] `@_disfavoredOverload nonisolated(nonsending) final public func respond(to prompt: Swift.String, schema: FoundationModels.GenerationSchema, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) async throws -> FoundationModels.LanguageModelSession.Response<FoundationModels.GeneratedContent>`
- [ ] `@_disfavoredOverload nonisolated(nonsending) final public func respond<Content>(to prompt: Swift.String, generating type: Content.Type = Content.self, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) async throws -> FoundationModels.LanguageModelSession.Response<Content> where Content : FoundationModels.Generable`
- [ ] `@_implements(_Concurrency.AsyncSequence, Failure) public typealias __AsyncSequence_Failure = any Swift.Error`
- [ ] `convenience public init(model: FoundationModels.SystemLanguageModel = .default, tools: [any FoundationModels.Tool] = [], @FoundationModels.InstructionsBuilder instructions: () throws -> FoundationModels.Instructions) rethrows`
- [ ] `convenience public init(model: FoundationModels.SystemLanguageModel = .default, tools: [any FoundationModels.Tool] = [], instructions: FoundationModels.Instructions? = nil)`
- [ ] `convenience public init(model: FoundationModels.SystemLanguageModel = .default, tools: [any FoundationModels.Tool] = [], transcript: FoundationModels.Transcript)`
- [ ] `final public func logFeedbackAttachment(sentiment: FoundationModels.LanguageModelFeedback.Sentiment?, issues: [FoundationModels.LanguageModelFeedback.Issue] = [], desiredOutput: FoundationModels.Transcript.Entry? = nil) -> Foundation.Data`
- [ ] `final public func logFeedbackAttachment(sentiment: FoundationModels.LanguageModelFeedback.Sentiment?, issues: [FoundationModels.LanguageModelFeedback.Issue] = [], desiredResponseContent: (any FoundationModels.ConvertibleToGeneratedContent)?) -> Foundation.Data`
- [ ] `final public func logFeedbackAttachment(sentiment: FoundationModels.LanguageModelFeedback.Sentiment?, issues: [FoundationModels.LanguageModelFeedback.Issue] = [], desiredResponseText: Swift.String?) -> Foundation.Data`
- [ ] `final public func prewarm(promptPrefix: FoundationModels.Prompt? = nil)`
- [ ] `final public func streamResponse(options: FoundationModels.GenerationOptions = GenerationOptions(), @FoundationModels.PromptBuilder prompt: () throws -> FoundationModels.Prompt) rethrows -> FoundationModels.LanguageModelSession.ResponseStream<Swift.String>`
- [ ] `final public func streamResponse(options: FoundationModels.GenerationOptions = GenerationOptions(), @FoundationModels.PromptBuilder prompt: () throws -> FoundationModels.Prompt) rethrows -> sending FoundationModels.LanguageModelSession.ResponseStream<Swift.String>`
- [ ] `final public func streamResponse(schema: FoundationModels.GenerationSchema, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions(), @FoundationModels.PromptBuilder prompt: () throws -> FoundationModels.Prompt) rethrows -> FoundationModels.LanguageModelSession.ResponseStream<FoundationModels.GeneratedContent>`
- [ ] `final public func streamResponse(schema: FoundationModels.GenerationSchema, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions(), @FoundationModels.PromptBuilder prompt: () throws -> FoundationModels.Prompt) rethrows -> sending FoundationModels.LanguageModelSession.ResponseStream<FoundationModels.GeneratedContent>`
- [ ] `final public func streamResponse(to prompt: FoundationModels.Prompt, options: FoundationModels.GenerationOptions = GenerationOptions()) -> FoundationModels.LanguageModelSession.ResponseStream<Swift.String>`
- [ ] `final public func streamResponse(to prompt: FoundationModels.Prompt, options: FoundationModels.GenerationOptions = GenerationOptions()) -> sending FoundationModels.LanguageModelSession.ResponseStream<Swift.String>`
- [ ] `final public func streamResponse(to prompt: FoundationModels.Prompt, schema: FoundationModels.GenerationSchema, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) -> FoundationModels.LanguageModelSession.ResponseStream<FoundationModels.GeneratedContent>`
- [ ] `final public func streamResponse(to prompt: FoundationModels.Prompt, schema: FoundationModels.GenerationSchema, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) -> sending FoundationModels.LanguageModelSession.ResponseStream<FoundationModels.GeneratedContent>`
- [ ] `final public func streamResponse<Content>(generating type: Content.Type = Content.self, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions(), @FoundationModels.PromptBuilder prompt: () throws -> FoundationModels.Prompt) rethrows -> FoundationModels.LanguageModelSession.ResponseStream<Content> where Content : FoundationModels.Generable`
- [ ] `final public func streamResponse<Content>(generating type: Content.Type = Content.self, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions(), @FoundationModels.PromptBuilder prompt: () throws -> FoundationModels.Prompt) rethrows -> sending FoundationModels.LanguageModelSession.ResponseStream<Content> where Content : FoundationModels.Generable`
- [ ] `final public func streamResponse<Content>(to prompt: FoundationModels.Prompt, generating type: Content.Type = Content.self, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) -> FoundationModels.LanguageModelSession.ResponseStream<Content> where Content : FoundationModels.Generable`
- [ ] `final public func streamResponse<Content>(to prompt: FoundationModels.Prompt, generating type: Content.Type = Content.self, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) -> sending FoundationModels.LanguageModelSession.ResponseStream<Content> where Content : FoundationModels.Generable`
- [ ] `final public var isResponding: Swift.Bool`
- [ ] `final public var transcript: FoundationModels.Transcript`
- [ ] `nonisolated(nonsending) final public func respond(options: FoundationModels.GenerationOptions = GenerationOptions(), @FoundationModels.PromptBuilder prompt: () throws -> FoundationModels.Prompt) async throws -> FoundationModels.LanguageModelSession.Response<Swift.String>`
- [ ] `nonisolated(nonsending) final public func respond(schema: FoundationModels.GenerationSchema, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions(), @FoundationModels.PromptBuilder prompt: () throws -> FoundationModels.Prompt) async throws -> FoundationModels.LanguageModelSession.Response<FoundationModels.GeneratedContent>`
- [ ] `nonisolated(nonsending) final public func respond(to prompt: FoundationModels.Prompt, options: FoundationModels.GenerationOptions = GenerationOptions()) async throws -> FoundationModels.LanguageModelSession.Response<Swift.String>`
- [ ] `nonisolated(nonsending) final public func respond(to prompt: FoundationModels.Prompt, schema: FoundationModels.GenerationSchema, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) async throws -> FoundationModels.LanguageModelSession.Response<FoundationModels.GeneratedContent>`
- [ ] `nonisolated(nonsending) final public func respond<Content>(generating type: Content.Type = Content.self, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions(), @FoundationModels.PromptBuilder prompt: () throws -> FoundationModels.Prompt) async throws -> FoundationModels.LanguageModelSession.Response<Content> where Content : FoundationModels.Generable`
- [ ] `nonisolated(nonsending) final public func respond<Content>(to prompt: FoundationModels.Prompt, generating type: Content.Type = Content.self, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) async throws -> FoundationModels.LanguageModelSession.Response<Content> where Content : FoundationModels.Generable`
- [ ] `nonisolated(nonsending) public func collect() async throws -> FoundationModels.LanguageModelSession.Response<Content>`
- [ ] `nonisolated(nonsending) public func collect() async throws -> sending FoundationModels.LanguageModelSession.Response<Content>`
- [ ] `public func makeAsyncIterator() -> FoundationModels.LanguageModelSession.ResponseStream<Content>.AsyncIterator`
- [ ] `public typealias Element = FoundationModels.LanguageModelSession.ResponseStream<Content>.Snapshot`

### [ ] `Never` — 3 members

- [ ] `public init(_ content: FoundationModels.GeneratedContent) throws`
- [ ] `public static var generationSchema: FoundationModels.GenerationSchema`
- [ ] `public var generatedContent: FoundationModels.GeneratedContent`

### [ ] `Optional` — 2 members

- [ ] `public typealias PartiallyGenerated = Wrapped.PartiallyGenerated`
- [ ] `public var generatedContent: FoundationModels.GeneratedContent`

### [ ] `Prompt` — 10 members

- [ ] `public init(@FoundationModels.PromptBuilder _ content: () throws -> FoundationModels.Prompt) rethrows`
- [ ] `public init(_ content: some PromptRepresentable)`
- [ ] `public init(id: Swift.String = UUID().uuidString, segments: [FoundationModels.Transcript.Segment], options: FoundationModels.GenerationOptions = GenerationOptions(), responseFormat: FoundationModels.Transcript.ResponseFormat? = nil)`
- [ ] `public static func == (a: FoundationModels.Transcript.Prompt, b: FoundationModels.Transcript.Prompt) -> Swift.Bool`
- [ ] `public typealias ID = Swift.String`
- [ ] `public var id: Swift.String`
- [ ] `public var options: FoundationModels.GenerationOptions`
- [ ] `public var promptRepresentation: FoundationModels.Prompt`
- [ ] `public var responseFormat: FoundationModels.Transcript.ResponseFormat?`
- [ ] `public var segments: [FoundationModels.Transcript.Segment]`

### [ ] `PromptBuilder` — 9 members

- [ ] `@_alwaysEmitIntoClient public static func buildArray(_ prompts: [some PromptRepresentable]) -> FoundationModels.Prompt`
- [ ] `@_alwaysEmitIntoClient public static func buildBlock<each P>(_ components: repeat each P) -> FoundationModels.Prompt where repeat each P : FoundationModels.PromptRepresentable`
- [ ] `@_alwaysEmitIntoClient public static func buildEither(first component: some PromptRepresentable) -> FoundationModels.Prompt`
- [ ] `@_alwaysEmitIntoClient public static func buildEither(second component: some PromptRepresentable) -> FoundationModels.Prompt`
- [ ] `@_alwaysEmitIntoClient public static func buildExpression(_ expression: FoundationModels.Prompt) -> FoundationModels.Prompt`
- [ ] `@_alwaysEmitIntoClient public static func buildExpression<T>(_ expression: T) -> FoundationModels.Prompt`
- [ ] `@_alwaysEmitIntoClient public static func buildLimitedAvailability(_ prompt: some PromptRepresentable) -> FoundationModels.Prompt`
- [ ] `@_alwaysEmitIntoClient public static func buildOptional(_ component: FoundationModels.Prompt?) -> FoundationModels.Prompt`
- [ ] `@_disfavoredOverload @_alwaysEmitIntoClient public static func buildExpression<P>(_ expression: P) -> P where P : FoundationModels.PromptRepresentable`

### [ ] `PromptRepresentable` — 0 members


### [ ] `Property` — 5 members

- [ ] `public init(name: Swift.String, description: Swift.String? = nil, schema: FoundationModels.DynamicGenerationSchema, isOptional: Swift.Bool = false)`
- [ ] `public init<RegexOutput>(name: Swift.String, description: Swift.String? = nil, type: Swift.String.Type, guides: [_StringProcessing.Regex<RegexOutput>] = [])`
- [ ] `public init<RegexOutput>(name: Swift.String, description: Swift.String? = nil, type: Swift.String?.Type, guides: [_StringProcessing.Regex<RegexOutput>] = [])`
- [ ] `public init<Value>(name: Swift.String, description: Swift.String? = nil, type: Value.Type, guides: [FoundationModels.GenerationGuide<Value>] = []) where Value : FoundationModels.Generable`
- [ ] `public init<Value>(name: Swift.String, description: Swift.String? = nil, type: Value?.Type, guides: [FoundationModels.GenerationGuide<Value>] = []) where Value : FoundationModels.Generable`

### [ ] `Refusal` — 3 members

- [ ] `public init(transcriptEntries: [FoundationModels.Transcript.Entry])`
- [ ] `public var explanation: FoundationModels.LanguageModelSession.Response<Swift.String>`
- [ ] `public var explanationStream: FoundationModels.LanguageModelSession.ResponseStream<Swift.String>`

### [ ] `Response` — 9 members

- [ ] `public init(id: Swift.String = UUID().uuidString, assetIDs: [Swift.String], segments: [FoundationModels.Transcript.Segment])`
- [ ] `public let content: Content`
- [ ] `public let rawContent: FoundationModels.GeneratedContent`
- [ ] `public let transcriptEntries: Swift.ArraySlice<FoundationModels.Transcript.Entry>`
- [ ] `public static func == (a: FoundationModels.Transcript.Response, b: FoundationModels.Transcript.Response) -> Swift.Bool`
- [ ] `public typealias ID = Swift.String`
- [ ] `public var assetIDs: [Swift.String]`
- [ ] `public var id: Swift.String`
- [ ] `public var segments: [FoundationModels.Transcript.Segment]`

### [ ] `ResponseFormat` — 4 members

- [ ] `public init(schema: FoundationModels.GenerationSchema)`
- [ ] `public init<Content>(type: Content.Type) where Content : FoundationModels.Generable`
- [ ] `public static func == (a: FoundationModels.Transcript.ResponseFormat, b: FoundationModels.Transcript.ResponseFormat) -> Swift.Bool`
- [ ] `public var name: Swift.String`

### [ ] `ResponseStream` — 0 members


### [ ] `SamplingMode` — 4 members

- [ ] `public static func == (a: FoundationModels.GenerationOptions.SamplingMode, b: FoundationModels.GenerationOptions.SamplingMode) -> Swift.Bool`
- [ ] `public static func random(probabilityThreshold: Swift.Double, seed: Swift.UInt64? = nil) -> FoundationModels.GenerationOptions.SamplingMode`
- [ ] `public static func random(top k: Swift.Int, seed: Swift.UInt64? = nil) -> FoundationModels.GenerationOptions.SamplingMode`
- [ ] `public static var greedy: FoundationModels.GenerationOptions.SamplingMode`

### [ ] `SchemaError` — 6 members

- [ ] `case duplicateProperty(schema: Swift.String, property: Swift.String, context: FoundationModels.GenerationSchema.SchemaError.Context)`
- [ ] `case duplicateType(schema: Swift.String?, type: Swift.String, context: FoundationModels.GenerationSchema.SchemaError.Context)`
- [ ] `case emptyTypeChoices(schema: Swift.String, context: FoundationModels.GenerationSchema.SchemaError.Context)`
- [ ] `case undefinedReferences(schema: Swift.String?, references: [Swift.String], context: FoundationModels.GenerationSchema.SchemaError.Context)`
- [ ] `public var errorDescription: Swift.String?`
- [ ] `public var recoverySuggestion: Swift.String?`

### [ ] `Segment` — 5 members

- [ ] `case structure(FoundationModels.Transcript.StructuredSegment)`
- [ ] `case text(FoundationModels.Transcript.TextSegment)`
- [ ] `public static func == (a: FoundationModels.Transcript.Segment, b: FoundationModels.Transcript.Segment) -> Swift.Bool`
- [ ] `public typealias ID = Swift.String`
- [ ] `public var id: Swift.String`

### [ ] `Sentiment` — 8 members

- [ ] `case negative`
- [ ] `case neutral`
- [ ] `case positive`
- [ ] `nonisolated public static var allCases: [FoundationModels.LanguageModelFeedback.Sentiment]`
- [ ] `public func hash(into hasher: inout Swift.Hasher)`
- [ ] `public static func == (a: FoundationModels.LanguageModelFeedback.Sentiment, b: FoundationModels.LanguageModelFeedback.Sentiment) -> Swift.Bool`
- [ ] `public typealias AllCases = [FoundationModels.LanguageModelFeedback.Sentiment]`
- [ ] `public var hashValue: Swift.Int`

### [ ] `Snapshot` — 2 members

- [ ] `public var content: Content.PartiallyGenerated`
- [ ] `public var rawContent: FoundationModels.GeneratedContent`

### [ ] `String` — 5 members

- [ ] `public init(_ content: FoundationModels.GeneratedContent) throws`
- [ ] `public static var generationSchema: FoundationModels.GenerationSchema`
- [ ] `public var generatedContent: FoundationModels.GeneratedContent`
- [ ] `public var instructionsRepresentation: FoundationModels.Instructions`
- [ ] `public var promptRepresentation: FoundationModels.Prompt`

### [ ] `StructuredSegment` — 6 members

- [ ] `public init(id: Swift.String = UUID().uuidString, source: Swift.String, content: FoundationModels.GeneratedContent)`
- [ ] `public static func == (a: FoundationModels.Transcript.StructuredSegment, b: FoundationModels.Transcript.StructuredSegment) -> Swift.Bool`
- [ ] `public typealias ID = Swift.String`
- [ ] `public var content: FoundationModels.GeneratedContent`
- [ ] `public var id: Swift.String`
- [ ] `public var source: Swift.String`

### [ ] `SystemLanguageModel` — 13 members

- [ ] `convenience public init(adapter: FoundationModels.SystemLanguageModel.Adapter, guardrails: FoundationModels.SystemLanguageModel.Guardrails = .default)`
- [ ] `convenience public init(useCase: FoundationModels.SystemLanguageModel.UseCase = .general, guardrails: FoundationModels.SystemLanguageModel.Guardrails = Guardrails.default)`
- [ ] `final public func supportsLocale(_ locale: Foundation.Locale = Locale.current) -> Swift.Bool`
- [ ] `final public var availability: FoundationModels.SystemLanguageModel.Availability`
- [ ] `final public var isAvailable: Swift.Bool`
- [ ] `final public var supportedLanguages: Swift.Set<Foundation.Locale.Language>`
- [ ] `public func compile() async throws`
- [ ] `public init(fileURL: Foundation.URL) throws`
- [ ] `public init(name: Swift.String) throws`
- [ ] `public static func compatibleAdapterIdentifiers(name: Swift.String) -> [Swift.String]`
- [ ] `public static func isCompatible(_ assetPack: BackgroundAssets.AssetPack) -> Swift.Bool`
- [ ] `public static func removeObsoleteAdapters() throws`
- [ ] `public static let `default`: FoundationModels.SystemLanguageModel`

### [ ] `TextSegment` — 5 members

- [ ] `public init(id: Swift.String = UUID().uuidString, content: Swift.String)`
- [ ] `public static func == (a: FoundationModels.Transcript.TextSegment, b: FoundationModels.Transcript.TextSegment) -> Swift.Bool`
- [ ] `public typealias ID = Swift.String`
- [ ] `public var content: Swift.String`
- [ ] `public var id: Swift.String`

### [ ] `Tool` — 3 members

- [ ] `public var includesSchemaInInstructions: Swift.Bool`
- [ ] `public var name: Swift.String`
- [ ] `public var parameters: FoundationModels.GenerationSchema`

### [ ] `ToolCall` — 6 members

- [ ] `public init(id: Swift.String, toolName: Swift.String, arguments: FoundationModels.GeneratedContent)`
- [ ] `public static func == (a: FoundationModels.Transcript.ToolCall, b: FoundationModels.Transcript.ToolCall) -> Swift.Bool`
- [ ] `public typealias ID = Swift.String`
- [ ] `public var arguments: FoundationModels.GeneratedContent`
- [ ] `public var id: Swift.String`
- [ ] `public var toolName: Swift.String`

### [ ] `ToolCallError` — 4 members

- [ ] `public init(tool: any FoundationModels.Tool, underlyingError: any Swift.Error)`
- [ ] `public var errorDescription: Swift.String?`
- [ ] `public var tool: any FoundationModels.Tool`
- [ ] `public var underlyingError: any Swift.Error`

### [ ] `ToolCalls` — 12 members

- [ ] `public init<S>(id: Swift.String = UUID().uuidString, _ calls: S) where S : Swift.Sequence, S.Element == FoundationModels.Transcript.ToolCall`
- [ ] `public static func == (a: FoundationModels.Transcript.ToolCalls, b: FoundationModels.Transcript.ToolCalls) -> Swift.Bool`
- [ ] `public subscript(position: Swift.Int) -> FoundationModels.Transcript.ToolCall`
- [ ] `public typealias Element = FoundationModels.Transcript.ToolCall`
- [ ] `public typealias ID = Swift.String`
- [ ] `public typealias Index = Swift.Int`
- [ ] `public typealias Indices = Swift.Range<Swift.Int>`
- [ ] `public typealias Iterator = Swift.IndexingIterator<FoundationModels.Transcript.ToolCalls>`
- [ ] `public typealias SubSequence = Swift.Slice<FoundationModels.Transcript.ToolCalls>`
- [ ] `public var endIndex: Swift.Int`
- [ ] `public var id: Swift.String`
- [ ] `public var startIndex: Swift.Int`

### [ ] `ToolDefinition` — 5 members

- [ ] `public init(name: Swift.String, description: Swift.String, parameters: FoundationModels.GenerationSchema)`
- [ ] `public init(tool: some Tool)`
- [ ] `public static func == (a: FoundationModels.Transcript.ToolDefinition, b: FoundationModels.Transcript.ToolDefinition) -> Swift.Bool`
- [ ] `public var description: Swift.String`
- [ ] `public var name: Swift.String`

### [ ] `ToolOutput` — 6 members

- [ ] `public init(id: Swift.String, toolName: Swift.String, segments: [FoundationModels.Transcript.Segment])`
- [ ] `public static func == (a: FoundationModels.Transcript.ToolOutput, b: FoundationModels.Transcript.ToolOutput) -> Swift.Bool`
- [ ] `public typealias ID = Swift.String`
- [ ] `public var id: Swift.String`
- [ ] `public var segments: [FoundationModels.Transcript.Segment]`
- [ ] `public var toolName: Swift.String`

### [ ] `Transcript` — 13 members

- [ ] `public func encode(to encoder: any Swift.Encoder) throws`
- [ ] `public init(entries: some Sequence<Entry> = [])`
- [ ] `public init(from decoder: any Swift.Decoder) throws`
- [ ] `public static func == (a: FoundationModels.Transcript, b: FoundationModels.Transcript) -> Swift.Bool`
- [ ] `public subscript(index: FoundationModels.Transcript.Index) -> FoundationModels.Transcript.Entry`
- [ ] `public typealias Element = FoundationModels.Transcript.Entry`
- [ ] `public typealias Index = Swift.Int`
- [ ] `public typealias Indices = Swift.Range<FoundationModels.Transcript.Index>`
- [ ] `public typealias Iterator = Swift.IndexingIterator<FoundationModels.Transcript>`
- [ ] `public typealias SubSequence = Swift.Slice<FoundationModels.Transcript>`
- [ ] `public var description: Swift.String`
- [ ] `public var endIndex: Swift.Int`
- [ ] `public var startIndex: Swift.Int`

### [ ] `UnavailableReason` — 6 members

- [ ] `case appleIntelligenceNotEnabled`
- [ ] `case deviceNotEligible`
- [ ] `case modelNotReady`
- [ ] `public func hash(into hasher: inout Swift.Hasher)`
- [ ] `public static func == (a: FoundationModels.SystemLanguageModel.Availability.UnavailableReason, b: FoundationModels.SystemLanguageModel.Availability.UnavailableReason) -> Swift.Bool`
- [ ] `public var hashValue: Swift.Int`

### [ ] `UseCase` — 3 members

- [ ] `public static func == (a: FoundationModels.SystemLanguageModel.UseCase, b: FoundationModels.SystemLanguageModel.UseCase) -> Swift.Bool`
- [ ] `public static let contentTagging: FoundationModels.SystemLanguageModel.UseCase`
- [ ] `public static let general: FoundationModels.SystemLanguageModel.UseCase`


---

## ImagePlayground

> Image generation + Genmoji. iOS 18.2+. AI-gated. Polyfill: diffusion backend (cloud or CoreML SD).

Source: iPhoneOS26.2.sdk · Swift (.swiftinterface) · full framework

Types: 11 · Members: 66

### [ ] `CreatedImage` — 1 member

- [ ] `public let cgImage: CoreGraphics.CGImage`

### [ ] `Delegate` — 0 members


### [ ] `EnvironmentValues` — 4 members

- [ ] `public var imagePlaygroundAllowedGenerationStyles: [ImagePlayground.ImagePlaygroundStyle]`
- [ ] `public var imagePlaygroundPersonalizationPolicy: ImagePlayground.ImagePlaygroundPersonalizationPolicy`
- [ ] `public var imagePlaygroundSelectedGenerationStyle: ImagePlayground.ImagePlaygroundStyle`
- [ ] `public var supportsImagePlayground: Swift.Bool`

### [ ] `Error` — 16 members

- [ ] `case backgroundCreationForbidden`
- [ ] `case conceptsRequirePersonIdentity`
- [ ] `case creationCancelled`
- [ ] `case creationFailed`
- [ ] `case faceInImageTooSmall`
- [ ] `case notSupported`
- [ ] `case unavailable`
- [ ] `case unsupportedInputImage`
- [ ] `case unsupportedLanguage`
- [ ] `public func hash(into hasher: inout Swift.Hasher)`
- [ ] `public static func == (a: ImagePlayground.ImageCreator.Error, b: ImagePlayground.ImageCreator.Error) -> Swift.Bool`
- [ ] `public static var allCases: [ImagePlayground.ImageCreator.Error]`
- [ ] `public static var errorDomain: Swift.String`
- [ ] `public typealias AllCases = [ImagePlayground.ImageCreator.Error]`
- [ ] `public var errorUserInfo: [Swift.String : Any]`
- [ ] `public var hashValue: Swift.Int`

### [ ] `ImageCreator` — 3 members

- [ ] `final public func images(for concepts: [ImagePlayground.ImagePlaygroundConcept], style: ImagePlayground.ImagePlaygroundStyle, limit: Swift.Int) -> some _Concurrency.AsyncSequence<ImagePlayground.ImageCreator.CreatedImage, any Swift.Error>`
- [ ] `final public let availableStyles: [ImagePlayground.ImagePlaygroundStyle]`
- [ ] `public init() async throws`

### [ ] `ImagePlaygroundConcept` — 5 members

- [ ] `public static func drawing(_ drawing: PencilKit.PKDrawing) -> ImagePlayground.ImagePlaygroundConcept`
- [ ] `public static func extracted(from text: Swift.String, title: Swift.String? = nil) -> ImagePlayground.ImagePlaygroundConcept`
- [ ] `public static func image(_ image: CoreGraphics.CGImage) -> ImagePlayground.ImagePlaygroundConcept`
- [ ] `public static func image(_ url: Foundation.URL) -> ImagePlayground.ImagePlaygroundConcept?`
- [ ] `public static func text(_ text: Swift.String) -> ImagePlayground.ImagePlaygroundConcept`

### [ ] `ImagePlaygroundPersonalizationPolicy` — 6 members

- [ ] `case automatic`
- [ ] `case disabled`
- [ ] `case enabled`
- [ ] `public init?(rawValue: Swift.Int)`
- [ ] `public typealias RawValue = Swift.Int`
- [ ] `public var rawValue: Swift.Int`

### [ ] `ImagePlaygroundStyle` — 12 members

- [ ] `public func encode(to encoder: any Swift.Encoder) throws`
- [ ] `public func hash(into hasher: inout Swift.Hasher)`
- [ ] `public init(from decoder: any Swift.Decoder) throws`
- [ ] `public let id: Swift.String`
- [ ] `public static func == (a: ImagePlayground.ImagePlaygroundStyle, b: ImagePlayground.ImagePlaygroundStyle) -> Swift.Bool`
- [ ] `public static let animation: ImagePlayground.ImagePlaygroundStyle`
- [ ] `public static let externalProvider: ImagePlayground.ImagePlaygroundStyle`
- [ ] `public static let illustration: ImagePlayground.ImagePlaygroundStyle`
- [ ] `public static let sketch: ImagePlayground.ImagePlaygroundStyle`
- [ ] `public static var all: [ImagePlayground.ImagePlaygroundStyle]`
- [ ] `public typealias ID = Swift.String`
- [ ] `public var hashValue: Swift.Int`

### [ ] `ImagePlaygroundViewController` — 13 members

- [ ] `@_Concurrency.MainActor @preconcurrency @objc convenience dynamic public init()`
- [ ] `@_Concurrency.MainActor @preconcurrency @objc override dynamic public func viewDidDisappear(_ animated: Swift.Bool)`
- [ ] `@_Concurrency.MainActor @preconcurrency @objc override dynamic public func viewDidLoad()`
- [ ] `@_Concurrency.MainActor @preconcurrency @objc override dynamic public var isModalInPresentation: Swift.Bool`
- [ ] `@_Concurrency.MainActor @preconcurrency @objc override dynamic public var modalPresentationStyle: UIKit.UIModalPresentationStyle`
- [ ] `@_Concurrency.MainActor @preconcurrency @objc override dynamic public var preferredContentSize: CoreFoundation.CGSize`
- [ ] `@_Concurrency.MainActor @preconcurrency @objc override dynamic public var supportedInterfaceOrientations: UIKit.UIInterfaceOrientationMask`
- [ ] `@_Concurrency.MainActor @preconcurrency public var allowedGenerationStyles: [ImagePlayground.ImagePlaygroundStyle]`
- [ ] `@_Concurrency.MainActor @preconcurrency public var concepts: [ImagePlayground.ImagePlaygroundConcept]`
- [ ] `@_Concurrency.MainActor @preconcurrency public var personalizationPolicy: ImagePlayground.ImagePlaygroundPersonalizationPolicy`
- [ ] `@_Concurrency.MainActor @preconcurrency public var selectedGenerationStyle: ImagePlayground.ImagePlaygroundStyle`
- [ ] `@objc @_Concurrency.MainActor @preconcurrency public var sourceImage: UIKit.UIImage?`
- [ ] `@objc @_Concurrency.MainActor @preconcurrency weak public var delegate: (any ImagePlayground.ImagePlaygroundViewController.Delegate)?`

### [ ] `View` — 6 members

- [ ] `@_Concurrency.MainActor @preconcurrency public func imagePlaygroundSheet(isPresented: SwiftUICore.Binding<Swift.Bool>, concept: Swift.String, sourceImage: SwiftUICore.Image? = nil, onCompletion: @escaping (_ url: Foundation.URL) -> Swift.Void, onCancellation: (() -> Swift.Void)? = nil) -> some SwiftUICore.View`
- [ ] `@_Concurrency.MainActor @preconcurrency public func imagePlaygroundSheet(isPresented: SwiftUICore.Binding<Swift.Bool>, concept: Swift.String, sourceImageURL: Foundation.URL, onCompletion: @escaping (_ url: Foundation.URL) -> Swift.Void, onCancellation: (() -> Swift.Void)? = nil) -> some SwiftUICore.View`
- [ ] `@_Concurrency.MainActor @preconcurrency public func imagePlaygroundSheet(isPresented: SwiftUICore.Binding<Swift.Bool>, concepts: [ImagePlayground.ImagePlaygroundConcept] = [], sourceImage: SwiftUICore.Image? = nil, onCompletion: @escaping (Foundation.URL) -> Swift.Void, onCancellation: (() -> Swift.Void)? = nil) -> some SwiftUICore.View`
- [ ] `@_Concurrency.MainActor @preconcurrency public func imagePlaygroundSheet(isPresented: SwiftUICore.Binding<Swift.Bool>, concepts: [ImagePlayground.ImagePlaygroundConcept] = [], sourceImageURL: Foundation.URL, onCompletion: @escaping (_ url: Foundation.URL) -> Swift.Void, onCancellation: (() -> Swift.Void)? = nil) -> some SwiftUICore.View`
- [ ] `nonisolated public func imagePlaygroundGenerationStyle(_ style: ImagePlayground.ImagePlaygroundStyle, in allowedStyles: [ImagePlayground.ImagePlaygroundStyle] = ImagePlaygroundStyle.all) -> some SwiftUICore.View`
- [ ] `nonisolated public func imagePlaygroundPersonalizationPolicy(_ policy: ImagePlayground.ImagePlaygroundPersonalizationPolicy = .automatic) -> some SwiftUICore.View`

### [ ] `var` — 0 members



---

## VisualIntelligence

> Camera/onscreen semantic search. iOS 26+. AI-gated. Polyfill: VisionKit DataScanner + vision model.

Source: iPhoneOS26.2.sdk · Swift (.swiftinterface) · full framework

Types: 1 · Members: 10

### [ ] `SemanticContentDescriptor` — 10 members

- [ ] `public let labels: [Swift.String]`
- [ ] `public static var defaultResolverSpecification: some AppIntents.ResolverSpecification`
- [ ] `public static var persistentIdentifier: Swift.String`
- [ ] `public static var typeDisplayRepresentation: AppIntents.TypeDisplayRepresentation`
- [ ] `public typealias Specification = @_opaqueReturnTypeOf("$s18VisualIntelligence25SemanticContentDescriptorV28defaultResolverSpecificationQrvpZ", 0) __`
- [ ] `public typealias UnwrappedType = VisualIntelligence.SemanticContentDescriptor`
- [ ] `public typealias ValueType = VisualIntelligence.SemanticContentDescriptor`
- [ ] `public var description: Swift.String`
- [ ] `public var displayRepresentation: AppIntents.DisplayRepresentation`
- [ ] `public var pixelBuffer: CoreVideo.CVReadOnlyPixelBuffer?`


---

## UIKit (AI subset)

> Writing Tools + Genmoji adaptive glyphs — AI-gated subset of UIKit (UIKit itself ships). Polyfill: custom UIMenu → LLM backend; glyphs as NSTextAttachment.

Source: iPhoneOS26.2.sdk · Swift (.swiftinterface) · filtered subset `WritingTools|AdaptiveImageGlyph|WritingToolsCoordinator|WritingToolsResult|WritingToolsBehavior`

Types: 4 · Members: 36

### [ ] `AdaptiveImageGlyphAttribute` — 9 members

- [ ] `public static func decode(from decoder: any Swift.Decoder) throws -> Foundation.AttributedString.AdaptiveImageGlyph`
- [ ] `public static func encode(_ value: Foundation.AttributedString.AdaptiveImageGlyph, to encoder: any Swift.Encoder) throws`
- [ ] `public static func objectiveCValue(for value: Foundation.AttributedString.AdaptiveImageGlyph) throws -> NSAdaptiveImageGlyph`
- [ ] `public static func value(for object: NSAdaptiveImageGlyph) throws -> Foundation.AttributedString.AdaptiveImageGlyph`
- [ ] `public static let name: Swift.String`
- [ ] `public static var inheritedByAddedText: Swift.Bool`
- [ ] `public static var runBoundaries: Foundation.AttributedString.AttributeRunBoundaries?`
- [ ] `public typealias ObjectiveCValue = NSAdaptiveImageGlyph`
- [ ] `public typealias Value = Foundation.AttributedString.AdaptiveImageGlyph`

### [ ] `AttributedString` — 1 member

- [ ] `public init(_ nsAdaptiveImageGlyph: NSAdaptiveImageGlyph)`

### [ ] `NSAdaptiveImageGlyph` — 1 member

- [ ] `convenience public init(_ adaptiveImageGlypth: Foundation.AttributedString.AdaptiveImageGlyph)`

### [ ] `UIKitAttributes` — 25 members

- [ ] `public let accessibility: Foundation.AttributeScopes.AccessibilityAttributes`
- [ ] `public let adaptiveImageGlyph: Foundation.AttributeScopes.UIKitAttributes.AdaptiveImageGlyphAttribute`
- [ ] `public let attachment: Foundation.AttributeScopes.UIKitAttributes.AttachmentAttribute`
- [ ] `public let backgroundColor: Foundation.AttributeScopes.UIKitAttributes.BackgroundColorAttribute`
- [ ] `public let baselineOffset: Foundation.AttributeScopes.UIKitAttributes.BaselineOffsetAttribute`
- [ ] `public let expansion: Foundation.AttributeScopes.UIKitAttributes.ExpansionAttribute`
- [ ] `public let font: Foundation.AttributeScopes.UIKitAttributes.FontAttribute`
- [ ] `public let foregroundColor: Foundation.AttributeScopes.UIKitAttributes.ForegroundColorAttribute`
- [ ] `public let foundation: Foundation.AttributeScopes.FoundationAttributes`
- [ ] `public let kern: Foundation.AttributeScopes.UIKitAttributes.KernAttribute`
- [ ] `public let ligature: Foundation.AttributeScopes.UIKitAttributes.LigatureAttribute`
- [ ] `public let obliqueness: Foundation.AttributeScopes.UIKitAttributes.ObliquenessAttribute`
- [ ] `public let paragraphStyle: Foundation.AttributeScopes.UIKitAttributes.ParagraphStyleAttribute`
- [ ] `public let shadow: Foundation.AttributeScopes.UIKitAttributes.ShadowAttribute`
- [ ] `public let strikethroughColor: Foundation.AttributeScopes.UIKitAttributes.StrikethroughColorAttribute`
- [ ] `public let strikethroughStyle: Foundation.AttributeScopes.UIKitAttributes.StrikethroughStyleAttribute`
- [ ] `public let strokeColor: Foundation.AttributeScopes.UIKitAttributes.StrokeColorAttribute`
- [ ] `public let strokeWidth: Foundation.AttributeScopes.UIKitAttributes.StrokeWidthAttribute`
- [ ] `public let textEffect: Foundation.AttributeScopes.UIKitAttributes.TextEffectAttribute`
- [ ] `public let textItemTag: Foundation.AttributeScopes.UIKitAttributes.TextItemTagAttribute`
- [ ] `public let tracking: Foundation.AttributeScopes.UIKitAttributes.TrackingAttribute`
- [ ] `public let underlineColor: Foundation.AttributeScopes.UIKitAttributes.UnderlineColorAttribute`
- [ ] `public let underlineStyle: Foundation.AttributeScopes.UIKitAttributes.UnderlineStyleAttribute`
- [ ] `public typealias DecodingConfiguration = Foundation.AttributeScopeCodableConfiguration`
- [ ] `public typealias EncodingConfiguration = Foundation.AttributeScopeCodableConfiguration`


---

## AppIntents (AI subset)

> Assistant schemas (AI Siri) — AI-gated subset of AppIntents (AppIntents itself ships). Polyfill: intent-router LLM.

Source: iPhoneOS26.2.sdk · Swift (.swiftinterface) · filtered subset `AssistantSchema|AssistantIntent|AssistantEntity|AssistantEnum`

Types: 8 · Members: 205

### [ ] `AssistantEntity` — 0 members


### [ ] `AssistantEnum` — 0 members


### [ ] `AssistantIntent` — 0 members


### [ ] `AssistantSchema` — 3 members

- [ ] `public init(_ schema: some AssistantSchemas.Entity)`
- [ ] `public init(_ schema: some AssistantSchemas.Enum)`
- [ ] `public init(_ schema: some AssistantSchemas.Intent)`

### [ ] `AssistantSchemaEntity` — 2 members

- [ ] `public static var isAssistantOnly: Swift.Bool`
- [ ] `public static var typeDisplayRepresentation: AppIntents.TypeDisplayRepresentation`

### [ ] `AssistantSchemaEnum` — 2 members

- [ ] `public static var isAssistantOnly: Swift.Bool`
- [ ] `public static var typeDisplayRepresentation: AppIntents.TypeDisplayRepresentation`

### [ ] `AssistantSchemaIntent` — 2 members

- [ ] `public static var isAssistantOnly: Swift.Bool`
- [ ] `public static var title: Foundation.LocalizedStringResource`

### [ ] `AssistantSchemas` — 196 members

- [ ] `@_alwaysEmitIntoClient public static var assistant: some AppIntents.AssistantSchemas.AssistantIntent`
- [ ] `@_alwaysEmitIntoClient public static var books: some AppIntents.AssistantSchemas.BooksEntity`
- [ ] `@_alwaysEmitIntoClient public static var books: some AppIntents.AssistantSchemas.BooksEnum`
- [ ] `@_alwaysEmitIntoClient public static var books: some AppIntents.AssistantSchemas.BooksIntent`
- [ ] `@_alwaysEmitIntoClient public static var browser: some AppIntents.AssistantSchemas.BrowserEntity`
- [ ] `@_alwaysEmitIntoClient public static var browser: some AppIntents.AssistantSchemas.BrowserEnum`
- [ ] `@_alwaysEmitIntoClient public static var camera: some AppIntents.AssistantSchemas.CameraEnum`
- [ ] `@_alwaysEmitIntoClient public static var camera: some AppIntents.AssistantSchemas.CameraIntent`
- [ ] `@_alwaysEmitIntoClient public static var files: some AppIntents.AssistantSchemas.FilesEntity`
- [ ] `@_alwaysEmitIntoClient public static var files: some AppIntents.AssistantSchemas.FilesIntent`
- [ ] `@_alwaysEmitIntoClient public static var journal: some AppIntents.AssistantSchemas.JournalEntity`
- [ ] `@_alwaysEmitIntoClient public static var journal: some AppIntents.AssistantSchemas.JournalIntent`
- [ ] `@_alwaysEmitIntoClient public static var mail: some AppIntents.AssistantSchemas.MailEntity`
- [ ] `@_alwaysEmitIntoClient public static var mail: some AppIntents.AssistantSchemas.MailIntent`
- [ ] `@_alwaysEmitIntoClient public static var photos: some AppIntents.AssistantSchemas.PhotosEntity`
- [ ] `@_alwaysEmitIntoClient public static var photos: some AppIntents.AssistantSchemas.PhotosEnum`
- [ ] `@_alwaysEmitIntoClient public static var photos: some AppIntents.AssistantSchemas.PhotosIntent`
- [ ] `@_alwaysEmitIntoClient public static var presentation: some AppIntents.AssistantSchemas.PresentationEntity`
- [ ] `@_alwaysEmitIntoClient public static var presentation: some AppIntents.AssistantSchemas.PresentationIntent`
- [ ] `@_alwaysEmitIntoClient public static var reader: some AppIntents.AssistantSchemas.ReaderEntity`
- [ ] `@_alwaysEmitIntoClient public static var reader: some AppIntents.AssistantSchemas.ReaderEnum`
- [ ] `@_alwaysEmitIntoClient public static var reader: some AppIntents.AssistantSchemas.ReaderIntent`
- [ ] `@_alwaysEmitIntoClient public static var spreadsheet: some AppIntents.AssistantSchemas.SpreadsheetEntity`
- [ ] `@_alwaysEmitIntoClient public static var spreadsheet: some AppIntents.AssistantSchemas.SpreadsheetIntent`
- [ ] `@_alwaysEmitIntoClient public static var system: some AppIntents.AssistantSchemas.SystemIntent`
- [ ] `@_alwaysEmitIntoClient public static var visualIntelligence: some AppIntents.AssistantSchemas.VisualIntelligenceIntent`
- [ ] `@_alwaysEmitIntoClient public static var whiteboard: some AppIntents.AssistantSchemas.WhiteboardEntity`
- [ ] `@_alwaysEmitIntoClient public static var whiteboard: some AppIntents.AssistantSchemas.WhiteboardEnum`
- [ ] `@_alwaysEmitIntoClient public static var whiteboard: some AppIntents.AssistantSchemas.WhiteboardIntent`
- [ ] `@_alwaysEmitIntoClient public static var wordProcessor: some AppIntents.AssistantSchemas.WordProcessorEntity`
- [ ] `@_alwaysEmitIntoClient public static var wordProcessor: some AppIntents.AssistantSchemas.WordProcessorIntent`
- [ ] `@_alwaysEmitIntoClient public var account: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var activate: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addAssetsToAlbum: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addAudioToPage: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addAudioToSheet: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addAudioToSlide: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addCommentToSheet: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addCommentToSlide: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addImageToPage: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addImageToSheet: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addImageToSlide: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addTextBoxToPage: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addTextBoxToSheet: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addTextBoxToSlide: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addVideoToPage: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addVideoToSheet: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addVideoToSlide: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addWebVideoToPage: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addWebVideoToSheet: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var addWebVideoToSlide: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var album: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var albumType: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var archiveMail: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var asset: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var assetType: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var audiobook: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var board: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var book: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var bookmark: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var bookmarkTab: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var bookmarkURL: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var captureDevice: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var captureDuration: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var captureMode: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var cleanupPhoto: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var clearHistory: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var clearHistoryTimeFrame: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var closeTabs: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var closeWindows: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var color: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var contentType: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var copyEdits: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var create: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var createAlbum: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var createAssets: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var createAudioEntry: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var createBoard: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var createDraft: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var createEntry: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var createFolder: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var createItem: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var createPage: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var createSheet: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var createSlide: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var createTab: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var createWindow: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var crop: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var delete: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var deleteAlbum: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var deleteAssets: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var deleteBoard: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var deleteBookmarks: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var deleteDraft: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var deleteEntry: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var deleteFiles: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var deleteItem: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var deleteMail: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var deletePages: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var deleteSheet: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var deleteSlide: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var document: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var documentKind: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var draft: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var duplicateAssets: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var enhanceDocuments: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var entry: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var file: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var filterType: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var findOnPage: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var font: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var fontSize: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var forwardMail: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var insertPages: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var item: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var itemType: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var mailbox: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var message: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var moveFiles: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var navigatePage: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var navigationDirection: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var open: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var openAlbum: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var openAsset: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var openBoard: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var openBook: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var openBookmark: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var openDocument: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var openFile: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var openInCaptureMode: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var openPage: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var openSheet: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var openSlide: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var openURLInTab: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var page: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var pageNavigationSetting: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var pasteEdits: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var playAudiobook: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var postToSharedAlbum: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var recognizedPerson: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var relativeCharacterSpacingChange: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var relativeFontChange: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var relativeLineSpacingChange: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var relativeWordSpacingChange: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var removeAssetsFromAlbum: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var renameFile: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var replyMail: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var resizeDocuments: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var rotateDocuments: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var rotatePages: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var rotationDirection: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var saveDraft: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var search: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var searchDocuments: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var semanticContentSearch: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var sendDraft: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var setDepth: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var setDevice: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var setExposure: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var setFilter: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var setRotation: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var setSaturation: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var setSlideTitle: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var setWarmth: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var settings: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var sheet: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var slide: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var startCapture: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var startPlayback: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var stopCapture: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var stopPlayback: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var straighten: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var switchDevice: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var switchTab: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var tab: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var template: some AppIntents.AssistantSchemas.Entity`
- [ ] `@_alwaysEmitIntoClient public var theme: some AppIntents.AssistantSchemas.Enum`
- [ ] `@_alwaysEmitIntoClient public var toggleDepth: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var toggleSuggestedEdits: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var update: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var updateAlbum: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var updateAsset: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var updateBoard: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var updateCharacterSpacing: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var updateDraft: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var updateEntry: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var updateFontSize: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var updateItem: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var updateLineSpacing: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var updateMail: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var updateRecognizedPerson: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var updateSettings: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var updateSheet: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var updateWordSpacing: some AppIntents.AssistantSchemas.Intent`
- [ ] `@_alwaysEmitIntoClient public var window: some AppIntents.AssistantSchemas.Entity`
- [ ] `public static var browser: some AppIntents.AssistantSchemas.BrowserIntent`
