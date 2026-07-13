# Apple Intelligence — polyfill API checklist

Target: real iOS. Scope: only Apple-Intelligence-capability-gated APIs Apple disables on ineligible/old devices. All other SDK frameworks ship to the device and are NOT listed here.

Source: `iPhoneOS26.2.sdk` · real arm64e `.swiftinterface`. All boxes unchecked = polyfill TODO.


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

### [x] `Array` — 6 members

- [x] `public init(_ content: FoundationModels.GeneratedContent) throws`
- [x] `public static var generationSchema: FoundationModels.GenerationSchema`
- [x] `public typealias PartiallyGenerated = [Element.PartiallyGenerated]`
- [x] `public var generatedContent: FoundationModels.GeneratedContent`
- [x] `public var instructionsRepresentation: FoundationModels.Instructions`
- [x] `public var promptRepresentation: FoundationModels.Prompt`

### [x] `AssetError` — 5 members

- [x] `case compatibleAdapterNotFound(FoundationModels.SystemLanguageModel.Adapter.AssetError.Context)`
- [x] `case invalidAdapterName(FoundationModels.SystemLanguageModel.Adapter.AssetError.Context)`
- [x] `case invalidAsset(FoundationModels.SystemLanguageModel.Adapter.AssetError.Context)`
- [x] `public var errorDescription: Swift.String?`
- [x] `public var recoverySuggestion: Swift.String?`

### [ ] `AsyncIterator` — 3 members

- [ ] `@_implements(_Concurrency.AsyncIteratorProtocol, Failure) public typealias __AsyncIteratorProtocol_Failure = any Swift.Error`
- [ ] `public mutating func next(isolation actor: isolated (any _Concurrency.Actor)? = #isolation) async throws -> FoundationModels.LanguageModelSession.ResponseStream<Content>.Snapshot?`
- [ ] `public typealias Element = FoundationModels.LanguageModelSession.ResponseStream<Content>.Snapshot`

### [x] `Availability` — 3 members

- [x] `case available`
- [x] `case unavailable(FoundationModels.SystemLanguageModel.Availability.UnavailableReason)`
- [x] `public static func == (a: FoundationModels.SystemLanguageModel.Availability, b: FoundationModels.SystemLanguageModel.Availability) -> Swift.Bool`

### [x] `Bool` — 3 members

- [x] `public init(_ content: FoundationModels.GeneratedContent) throws`
- [x] `public static var generationSchema: FoundationModels.GenerationSchema`
- [x] `public var generatedContent: FoundationModels.GeneratedContent`

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

### [x] `Context` — 2 members

- [x] `public init(debugDescription: Swift.String)`
- [x] `public let debugDescription: Swift.String`

### [x] `ConvertibleFromGeneratedContent` — 0 members


### [x] `ConvertibleToGeneratedContent` — 2 members

- [x] `public var instructionsRepresentation: FoundationModels.Instructions`
- [x] `public var promptRepresentation: FoundationModels.Prompt`

### [x] `Decimal` — 3 members

- [x] `public init(_ content: FoundationModels.GeneratedContent) throws`
- [x] `public static var generationSchema: FoundationModels.GenerationSchema`
- [x] `public var generatedContent: FoundationModels.GeneratedContent`

### [x] `Double` — 3 members

- [x] `public init(_ content: FoundationModels.GeneratedContent) throws`
- [x] `public static var generationSchema: FoundationModels.GenerationSchema`
- [x] `public var generatedContent: FoundationModels.GeneratedContent`

### [x] `DynamicGenerationSchema` — 6 members

- [x] `public init(arrayOf itemSchema: FoundationModels.DynamicGenerationSchema, minimumElements: Swift.Int? = nil, maximumElements: Swift.Int? = nil)`
- [x] `public init(name: Swift.String, description: Swift.String? = nil, anyOf choices: [FoundationModels.DynamicGenerationSchema])`
- [x] `public init(name: Swift.String, description: Swift.String? = nil, anyOf choices: [Swift.String])`
- [x] `public init(name: Swift.String, description: Swift.String? = nil, properties: [FoundationModels.DynamicGenerationSchema.Property])`
- [x] `public init(referenceTo name: Swift.String)`
- [x] `public init<Value>(type: Value.Type, guides: [FoundationModels.GenerationGuide<Value>] = []) where Value : FoundationModels.Generable`

### [x] `Entry` — 8 members

- [x] `case instructions(FoundationModels.Transcript.Instructions)`
- [x] `case prompt(FoundationModels.Transcript.Prompt)`
- [x] `case response(FoundationModels.Transcript.Response)`
- [x] `case toolCalls(FoundationModels.Transcript.ToolCalls)`
- [x] `case toolOutput(FoundationModels.Transcript.ToolOutput)`
- [x] `public static func == (a: FoundationModels.Transcript.Entry, b: FoundationModels.Transcript.Entry) -> Swift.Bool`
- [x] `public typealias ID = Swift.String`
- [x] `public var id: Swift.String`

### [x] `Float` — 3 members

- [x] `public init(_ content: FoundationModels.GeneratedContent) throws`
- [x] `public static var generationSchema: FoundationModels.GenerationSchema`
- [x] `public var generatedContent: FoundationModels.GeneratedContent`

### [x] `Generable` — 2 members

- [x] `public func asPartiallyGenerated() -> Self.PartiallyGenerated`
- [x] `public typealias PartiallyGenerated = Self`

### [x] `GeneratedContent` — 19 members

- [x] `public func value<Value>(_ type: Value.Type = Value.self) throws -> Value where Value : FoundationModels.ConvertibleFromGeneratedContent`
- [x] `public func value<Value>(_ type: Value.Type = Value.self, forProperty property: Swift.String) throws -> Value where Value : FoundationModels.ConvertibleFromGeneratedContent`
- [x] `public func value<Value>(_ type: Value?.Type = Value?.self, forProperty property: Swift.String) throws -> Value? where Value : FoundationModels.ConvertibleFromGeneratedContent`
- [x] `public init(_ content: FoundationModels.GeneratedContent) throws`
- [x] `public init(_ value: some ConvertibleToGeneratedContent)`
- [x] `public init(_ value: some ConvertibleToGeneratedContent, id: FoundationModels.GenerationID)`
- [x] `public init(json: Swift.String) throws`
- [x] `public init(kind: FoundationModels.GeneratedContent.Kind, id: FoundationModels.GenerationID? = nil)`
- [x] `public init(properties: Swift.KeyValuePairs<Swift.String, any FoundationModels.ConvertibleToGeneratedContent>, id: FoundationModels.GenerationID? = nil)`
- [x] `public init<S>(elements: S, id: FoundationModels.GenerationID? = nil) where S : Swift.Sequence, S.Element == any FoundationModels.ConvertibleToGeneratedContent`
- [x] `public init<S>(properties: S, id: FoundationModels.GenerationID? = nil, uniquingKeysWith combine: (FoundationModels.GeneratedContent, FoundationModels.GeneratedContent) throws -> some ConvertibleToGeneratedContent) rethrows where S : Swift.Sequence, S.Element == (Swift.String, any FoundationModels.ConvertibleToGeneratedContent)`
- [x] `public static func == (a: FoundationModels.GeneratedContent, b: FoundationModels.GeneratedContent) -> Swift.Bool`
- [x] `public static var generationSchema: FoundationModels.GenerationSchema`
- [x] `public var debugDescription: Swift.String`
- [x] `public var generatedContent: FoundationModels.GeneratedContent`
- [x] `public var id: FoundationModels.GenerationID?`
- [x] `public var isComplete: Swift.Bool`
- [x] `public var jsonString: Swift.String`
- [x] `public var kind: FoundationModels.GeneratedContent.Kind`

### [ ] `GenerationError` — 12 members

- [x] `case assetsUnavailable(FoundationModels.LanguageModelSession.GenerationError.Context)`
- [x] `case concurrentRequests(FoundationModels.LanguageModelSession.GenerationError.Context)`
- [x] `case decodingFailure(FoundationModels.LanguageModelSession.GenerationError.Context)`
- [x] `case exceededContextWindowSize(FoundationModels.LanguageModelSession.GenerationError.Context)`
- [x] `case guardrailViolation(FoundationModels.LanguageModelSession.GenerationError.Context)`
- [x] `case rateLimited(FoundationModels.LanguageModelSession.GenerationError.Context)`
- [x] `case refusal(FoundationModels.LanguageModelSession.GenerationError.Refusal, FoundationModels.LanguageModelSession.GenerationError.Context)`
- [x] `case unsupportedGuide(FoundationModels.LanguageModelSession.GenerationError.Context)`
- [x] `case unsupportedLanguageOrLocale(FoundationModels.LanguageModelSession.GenerationError.Context)`
- [x] `public var errorDescription: Swift.String?`
- [ ] `public var failureReason: Swift.String?`
- [ ] `public var recoverySuggestion: Swift.String?`

### [ ] `GenerationGuide` — 24 members

- [ ] `@_documentation(visibility: private) @_alwaysEmitIntoClient public static func count(_ range: Swift.ClosedRange<Swift.Int>) -> FoundationModels.GenerationGuide<Value>`
- [ ] `@_documentation(visibility: private) @_alwaysEmitIntoClient public static func maximumCount(_ count: Swift.Int) -> FoundationModels.GenerationGuide<Value>`
- [ ] `@_documentation(visibility: private) @_alwaysEmitIntoClient public static func minimumCount(_ count: Swift.Int) -> FoundationModels.GenerationGuide<Value>`
- [ ] `@_documentation(visibility: private) @_disfavoredOverload @_alwaysEmitIntoClient public static func count(_ count: Swift.Int) -> FoundationModels.GenerationGuide<Value>`
- [x] `public static func anyOf(_ values: [Swift.String]) -> FoundationModels.GenerationGuide<Swift.String>`
- [x] `public static func constant(_ value: Swift.String) -> FoundationModels.GenerationGuide<Swift.String>`
- [x] `public static func count<Element>(_ count: Swift.Int) -> FoundationModels.GenerationGuide<[Element]> where Value == [Element]`
- [x] `public static func count<Element>(_ range: Swift.ClosedRange<Swift.Int>) -> FoundationModels.GenerationGuide<[Element]> where Value == [Element]`
- [x] `public static func element<Element>(_ guide: FoundationModels.GenerationGuide<Element>) -> FoundationModels.GenerationGuide<[Element]> where Value == [Element]`
- [x] `public static func maximum(_ value: Foundation.Decimal) -> FoundationModels.GenerationGuide<Foundation.Decimal>`
- [x] `public static func maximum(_ value: Swift.Double) -> FoundationModels.GenerationGuide<Swift.Double>`
- [x] `public static func maximum(_ value: Swift.Float) -> FoundationModels.GenerationGuide<Swift.Float>`
- [x] `public static func maximum(_ value: Swift.Int) -> FoundationModels.GenerationGuide<Swift.Int>`
- [x] `public static func maximumCount<Element>(_ count: Swift.Int) -> FoundationModels.GenerationGuide<[Element]> where Value == [Element]`
- [x] `public static func minimum(_ value: Foundation.Decimal) -> FoundationModels.GenerationGuide<Foundation.Decimal>`
- [x] `public static func minimum(_ value: Swift.Double) -> FoundationModels.GenerationGuide<Swift.Double>`
- [x] `public static func minimum(_ value: Swift.Float) -> FoundationModels.GenerationGuide<Swift.Float>`
- [x] `public static func minimum(_ value: Swift.Int) -> FoundationModels.GenerationGuide<Swift.Int>`
- [x] `public static func minimumCount<Element>(_ count: Swift.Int) -> FoundationModels.GenerationGuide<[Element]> where Value == [Element]`
- [ ] `public static func pattern<Output>(_ regex: _StringProcessing.Regex<Output>) -> FoundationModels.GenerationGuide<Swift.String>`
- [x] `public static func range(_ range: Swift.ClosedRange<Foundation.Decimal>) -> FoundationModels.GenerationGuide<Foundation.Decimal>`
- [x] `public static func range(_ range: Swift.ClosedRange<Swift.Double>) -> FoundationModels.GenerationGuide<Swift.Double>`
- [x] `public static func range(_ range: Swift.ClosedRange<Swift.Float>) -> FoundationModels.GenerationGuide<Swift.Float>`
- [x] `public static func range(_ range: Swift.ClosedRange<Swift.Int>) -> FoundationModels.GenerationGuide<Swift.Int>`

### [x] `GenerationID` — 4 members

- [x] `public func hash(into hasher: inout Swift.Hasher)`
- [x] `public init()`
- [x] `public static func == (a: FoundationModels.GenerationID, b: FoundationModels.GenerationID) -> Swift.Bool`
- [x] `public var hashValue: Swift.Int`

### [x] `GenerationOptions` — 5 members

- [x] `public init(sampling: FoundationModels.GenerationOptions.SamplingMode? = nil, temperature: Swift.Double? = nil, maximumResponseTokens: Swift.Int? = nil)`
- [x] `public static func == (a: FoundationModels.GenerationOptions, b: FoundationModels.GenerationOptions) -> Swift.Bool`
- [x] `public var maximumResponseTokens: Swift.Int?`
- [x] `public var sampling: FoundationModels.GenerationOptions.SamplingMode?`
- [x] `public var temperature: Swift.Double?`

### [x] `GenerationSchema` — 7 members

- [x] `public func encode(to encoder: any Swift.Encoder) throws`
- [x] `public init(from decoder: any Swift.Decoder) throws`
- [x] `public init(root: FoundationModels.DynamicGenerationSchema, dependencies: [FoundationModels.DynamicGenerationSchema]) throws`
- [x] `public init(type: any FoundationModels.Generable.Type, description: Swift.String? = nil, anyOf choices: [Swift.String])`
- [x] `public init(type: any FoundationModels.Generable.Type, description: Swift.String? = nil, anyOf types: [any FoundationModels.Generable.Type])`
- [x] `public init(type: any FoundationModels.Generable.Type, description: Swift.String? = nil, properties: [FoundationModels.GenerationSchema.Property])`
- [x] `public var debugDescription: Swift.String`

### [x] `Guardrails` — 2 members

- [x] `public static let `default`: FoundationModels.SystemLanguageModel.Guardrails`
- [x] `public static let permissiveContentTransformations: FoundationModels.SystemLanguageModel.Guardrails`

### [x] `Instructions` — 9 members

- [x] `public init(@FoundationModels.InstructionsBuilder _ content: () throws -> FoundationModels.Instructions) rethrows`
- [x] `public init(_ content: some InstructionsRepresentable)`
- [x] `public init(id: Swift.String = UUID().uuidString, segments: [FoundationModels.Transcript.Segment], toolDefinitions: [FoundationModels.Transcript.ToolDefinition])`
- [x] `public static func == (a: FoundationModels.Transcript.Instructions, b: FoundationModels.Transcript.Instructions) -> Swift.Bool`
- [x] `public typealias ID = Swift.String`
- [x] `public var id: Swift.String`
- [x] `public var instructionsRepresentation: FoundationModels.Instructions`
- [x] `public var segments: [FoundationModels.Transcript.Segment]`
- [x] `public var toolDefinitions: [FoundationModels.Transcript.ToolDefinition]`

### [ ] `InstructionsBuilder` — 9 members

- [x] `@_alwaysEmitIntoClient public static func buildArray(_ instructions: [some InstructionsRepresentable]) -> FoundationModels.Instructions`
- [x] `@_alwaysEmitIntoClient public static func buildBlock<each I>(_ components: repeat each I) -> FoundationModels.Instructions where repeat each I : FoundationModels.InstructionsRepresentable`
- [x] `@_alwaysEmitIntoClient public static func buildEither(first component: some InstructionsRepresentable) -> FoundationModels.Instructions`
- [x] `@_alwaysEmitIntoClient public static func buildEither(second component: some InstructionsRepresentable) -> FoundationModels.Instructions`
- [x] `@_alwaysEmitIntoClient public static func buildExpression(_ expression: FoundationModels.Instructions) -> FoundationModels.Instructions`
- [ ] `@_alwaysEmitIntoClient public static func buildExpression<T>(_ expression: T) -> FoundationModels.Instructions`
- [x] `@_alwaysEmitIntoClient public static func buildLimitedAvailability(_ instructions: some InstructionsRepresentable) -> FoundationModels.Instructions`
- [x] `@_alwaysEmitIntoClient public static func buildOptional(_ instructions: FoundationModels.Instructions?) -> FoundationModels.Instructions`
- [ ] `@_disfavoredOverload @_alwaysEmitIntoClient public static func buildExpression<I>(_ expression: I) -> I where I : FoundationModels.InstructionsRepresentable`

### [x] `InstructionsRepresentable` — 0 members


### [x] `Int` — 3 members

- [x] `public init(_ content: FoundationModels.GeneratedContent) throws`
- [x] `public static var generationSchema: FoundationModels.GenerationSchema`
- [x] `public var generatedContent: FoundationModels.GeneratedContent`

### [ ] `Issue` — 1 member

- [ ] `public init(category: FoundationModels.LanguageModelFeedback.Issue.Category, explanation: Swift.String? = nil)`

### [x] `Kind` — 7 members

- [x] `case array([FoundationModels.GeneratedContent])`
- [x] `case bool(Swift.Bool)`
- [x] `case null`
- [x] `case number(Swift.Double)`
- [x] `case string(Swift.String)`
- [x] `case structure(properties: [Swift.String : FoundationModels.GeneratedContent], orderedKeys: [Swift.String])`
- [x] `public static func == (a: FoundationModels.GeneratedContent.Kind, b: FoundationModels.GeneratedContent.Kind) -> Swift.Bool`

### [ ] `LanguageModelFeedback` — 0 members


### [ ] `LanguageModelSession` — 42 members

- [x] `@_disfavoredOverload convenience public init(model: FoundationModels.SystemLanguageModel = .default, tools: [any FoundationModels.Tool] = [], instructions: Swift.String? = nil)`
- [x] `@_disfavoredOverload final public func streamResponse(to prompt: Swift.String, options: FoundationModels.GenerationOptions = GenerationOptions()) -> FoundationModels.LanguageModelSession.ResponseStream<Swift.String>`
- [x] `@_disfavoredOverload final public func streamResponse(to prompt: Swift.String, options: FoundationModels.GenerationOptions = GenerationOptions()) -> sending FoundationModels.LanguageModelSession.ResponseStream<Swift.String>`
- [x] `@_disfavoredOverload final public func streamResponse(to prompt: Swift.String, schema: FoundationModels.GenerationSchema, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) -> FoundationModels.LanguageModelSession.ResponseStream<FoundationModels.GeneratedContent>`
- [x] `@_disfavoredOverload final public func streamResponse(to prompt: Swift.String, schema: FoundationModels.GenerationSchema, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) -> sending FoundationModels.LanguageModelSession.ResponseStream<FoundationModels.GeneratedContent>`
- [x] `@_disfavoredOverload final public func streamResponse<Content>(to prompt: Swift.String, generating type: Content.Type = Content.self, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) -> FoundationModels.LanguageModelSession.ResponseStream<Content> where Content : FoundationModels.Generable`
- [x] `@_disfavoredOverload final public func streamResponse<Content>(to prompt: Swift.String, generating type: Content.Type = Content.self, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) -> sending FoundationModels.LanguageModelSession.ResponseStream<Content> where Content : FoundationModels.Generable`
- [x] `@_disfavoredOverload nonisolated(nonsending) final public func respond(to prompt: Swift.String, options: FoundationModels.GenerationOptions = GenerationOptions()) async throws -> FoundationModels.LanguageModelSession.Response<Swift.String>`
- [x] `@_disfavoredOverload nonisolated(nonsending) final public func respond(to prompt: Swift.String, schema: FoundationModels.GenerationSchema, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) async throws -> FoundationModels.LanguageModelSession.Response<FoundationModels.GeneratedContent>`
- [x] `@_disfavoredOverload nonisolated(nonsending) final public func respond<Content>(to prompt: Swift.String, generating type: Content.Type = Content.self, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) async throws -> FoundationModels.LanguageModelSession.Response<Content> where Content : FoundationModels.Generable`
- [ ] `@_implements(_Concurrency.AsyncSequence, Failure) public typealias __AsyncSequence_Failure = any Swift.Error`
- [x] `convenience public init(model: FoundationModels.SystemLanguageModel = .default, tools: [any FoundationModels.Tool] = [], @FoundationModels.InstructionsBuilder instructions: () throws -> FoundationModels.Instructions) rethrows`
- [x] `convenience public init(model: FoundationModels.SystemLanguageModel = .default, tools: [any FoundationModels.Tool] = [], instructions: FoundationModels.Instructions? = nil)`
- [x] `convenience public init(model: FoundationModels.SystemLanguageModel = .default, tools: [any FoundationModels.Tool] = [], transcript: FoundationModels.Transcript)`
- [ ] `final public func logFeedbackAttachment(sentiment: FoundationModels.LanguageModelFeedback.Sentiment?, issues: [FoundationModels.LanguageModelFeedback.Issue] = [], desiredOutput: FoundationModels.Transcript.Entry? = nil) -> Foundation.Data`
- [ ] `final public func logFeedbackAttachment(sentiment: FoundationModels.LanguageModelFeedback.Sentiment?, issues: [FoundationModels.LanguageModelFeedback.Issue] = [], desiredResponseContent: (any FoundationModels.ConvertibleToGeneratedContent)?) -> Foundation.Data`
- [ ] `final public func logFeedbackAttachment(sentiment: FoundationModels.LanguageModelFeedback.Sentiment?, issues: [FoundationModels.LanguageModelFeedback.Issue] = [], desiredResponseText: Swift.String?) -> Foundation.Data`
- [ ] `final public func prewarm(promptPrefix: FoundationModels.Prompt? = nil)`
- [x] `final public func streamResponse(options: FoundationModels.GenerationOptions = GenerationOptions(), @FoundationModels.PromptBuilder prompt: () throws -> FoundationModels.Prompt) rethrows -> FoundationModels.LanguageModelSession.ResponseStream<Swift.String>`
- [x] `final public func streamResponse(options: FoundationModels.GenerationOptions = GenerationOptions(), @FoundationModels.PromptBuilder prompt: () throws -> FoundationModels.Prompt) rethrows -> sending FoundationModels.LanguageModelSession.ResponseStream<Swift.String>`
- [x] `final public func streamResponse(schema: FoundationModels.GenerationSchema, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions(), @FoundationModels.PromptBuilder prompt: () throws -> FoundationModels.Prompt) rethrows -> FoundationModels.LanguageModelSession.ResponseStream<FoundationModels.GeneratedContent>`
- [x] `final public func streamResponse(schema: FoundationModels.GenerationSchema, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions(), @FoundationModels.PromptBuilder prompt: () throws -> FoundationModels.Prompt) rethrows -> sending FoundationModels.LanguageModelSession.ResponseStream<FoundationModels.GeneratedContent>`
- [x] `final public func streamResponse(to prompt: FoundationModels.Prompt, options: FoundationModels.GenerationOptions = GenerationOptions()) -> FoundationModels.LanguageModelSession.ResponseStream<Swift.String>`
- [x] `final public func streamResponse(to prompt: FoundationModels.Prompt, options: FoundationModels.GenerationOptions = GenerationOptions()) -> sending FoundationModels.LanguageModelSession.ResponseStream<Swift.String>`
- [x] `final public func streamResponse(to prompt: FoundationModels.Prompt, schema: FoundationModels.GenerationSchema, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) -> FoundationModels.LanguageModelSession.ResponseStream<FoundationModels.GeneratedContent>`
- [x] `final public func streamResponse(to prompt: FoundationModels.Prompt, schema: FoundationModels.GenerationSchema, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) -> sending FoundationModels.LanguageModelSession.ResponseStream<FoundationModels.GeneratedContent>`
- [x] `final public func streamResponse<Content>(generating type: Content.Type = Content.self, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions(), @FoundationModels.PromptBuilder prompt: () throws -> FoundationModels.Prompt) rethrows -> FoundationModels.LanguageModelSession.ResponseStream<Content> where Content : FoundationModels.Generable`
- [x] `final public func streamResponse<Content>(generating type: Content.Type = Content.self, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions(), @FoundationModels.PromptBuilder prompt: () throws -> FoundationModels.Prompt) rethrows -> sending FoundationModels.LanguageModelSession.ResponseStream<Content> where Content : FoundationModels.Generable`
- [x] `final public func streamResponse<Content>(to prompt: FoundationModels.Prompt, generating type: Content.Type = Content.self, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) -> FoundationModels.LanguageModelSession.ResponseStream<Content> where Content : FoundationModels.Generable`
- [x] `final public func streamResponse<Content>(to prompt: FoundationModels.Prompt, generating type: Content.Type = Content.self, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) -> sending FoundationModels.LanguageModelSession.ResponseStream<Content> where Content : FoundationModels.Generable`
- [x] `final public var isResponding: Swift.Bool`
- [x] `final public var transcript: FoundationModels.Transcript`
- [x] `nonisolated(nonsending) final public func respond(options: FoundationModels.GenerationOptions = GenerationOptions(), @FoundationModels.PromptBuilder prompt: () throws -> FoundationModels.Prompt) async throws -> FoundationModels.LanguageModelSession.Response<Swift.String>`
- [x] `nonisolated(nonsending) final public func respond(schema: FoundationModels.GenerationSchema, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions(), @FoundationModels.PromptBuilder prompt: () throws -> FoundationModels.Prompt) async throws -> FoundationModels.LanguageModelSession.Response<FoundationModels.GeneratedContent>`
- [x] `nonisolated(nonsending) final public func respond(to prompt: FoundationModels.Prompt, options: FoundationModels.GenerationOptions = GenerationOptions()) async throws -> FoundationModels.LanguageModelSession.Response<Swift.String>`
- [x] `nonisolated(nonsending) final public func respond(to prompt: FoundationModels.Prompt, schema: FoundationModels.GenerationSchema, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) async throws -> FoundationModels.LanguageModelSession.Response<FoundationModels.GeneratedContent>`
- [x] `nonisolated(nonsending) final public func respond<Content>(generating type: Content.Type = Content.self, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions(), @FoundationModels.PromptBuilder prompt: () throws -> FoundationModels.Prompt) async throws -> FoundationModels.LanguageModelSession.Response<Content> where Content : FoundationModels.Generable`
- [x] `nonisolated(nonsending) final public func respond<Content>(to prompt: FoundationModels.Prompt, generating type: Content.Type = Content.self, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) async throws -> FoundationModels.LanguageModelSession.Response<Content> where Content : FoundationModels.Generable`
- [x] `nonisolated(nonsending) public func collect() async throws -> FoundationModels.LanguageModelSession.Response<Content>`
- [x] `nonisolated(nonsending) public func collect() async throws -> sending FoundationModels.LanguageModelSession.Response<Content>`
- [x] `public func makeAsyncIterator() -> FoundationModels.LanguageModelSession.ResponseStream<Content>.AsyncIterator`
- [x] `public typealias Element = FoundationModels.LanguageModelSession.ResponseStream<Content>.Snapshot`

### [x] `Never` — 3 members

- [x] `public init(_ content: FoundationModels.GeneratedContent) throws`
- [x] `public static var generationSchema: FoundationModels.GenerationSchema`
- [x] `public var generatedContent: FoundationModels.GeneratedContent`

### [ ] `Optional` — 2 members

- [ ] `public typealias PartiallyGenerated = Wrapped.PartiallyGenerated`
- [x] `public var generatedContent: FoundationModels.GeneratedContent`

### [x] `Prompt` — 10 members

- [x] `public init(@FoundationModels.PromptBuilder _ content: () throws -> FoundationModels.Prompt) rethrows`
- [x] `public init(_ content: some PromptRepresentable)`
- [x] `public init(id: Swift.String = UUID().uuidString, segments: [FoundationModels.Transcript.Segment], options: FoundationModels.GenerationOptions = GenerationOptions(), responseFormat: FoundationModels.Transcript.ResponseFormat? = nil)`
- [x] `public static func == (a: FoundationModels.Transcript.Prompt, b: FoundationModels.Transcript.Prompt) -> Swift.Bool`
- [x] `public typealias ID = Swift.String`
- [x] `public var id: Swift.String`
- [x] `public var options: FoundationModels.GenerationOptions`
- [x] `public var promptRepresentation: FoundationModels.Prompt`
- [x] `public var responseFormat: FoundationModels.Transcript.ResponseFormat?`
- [x] `public var segments: [FoundationModels.Transcript.Segment]`

### [ ] `PromptBuilder` — 9 members

- [x] `@_alwaysEmitIntoClient public static func buildArray(_ prompts: [some PromptRepresentable]) -> FoundationModels.Prompt`
- [x] `@_alwaysEmitIntoClient public static func buildBlock<each P>(_ components: repeat each P) -> FoundationModels.Prompt where repeat each P : FoundationModels.PromptRepresentable`
- [x] `@_alwaysEmitIntoClient public static func buildEither(first component: some PromptRepresentable) -> FoundationModels.Prompt`
- [x] `@_alwaysEmitIntoClient public static func buildEither(second component: some PromptRepresentable) -> FoundationModels.Prompt`
- [x] `@_alwaysEmitIntoClient public static func buildExpression(_ expression: FoundationModels.Prompt) -> FoundationModels.Prompt`
- [ ] `@_alwaysEmitIntoClient public static func buildExpression<T>(_ expression: T) -> FoundationModels.Prompt`
- [x] `@_alwaysEmitIntoClient public static func buildLimitedAvailability(_ prompt: some PromptRepresentable) -> FoundationModels.Prompt`
- [x] `@_alwaysEmitIntoClient public static func buildOptional(_ component: FoundationModels.Prompt?) -> FoundationModels.Prompt`
- [ ] `@_disfavoredOverload @_alwaysEmitIntoClient public static func buildExpression<P>(_ expression: P) -> P where P : FoundationModels.PromptRepresentable`

### [x] `PromptRepresentable` — 0 members


### [x] `Property` — 5 members

- [x] `public init(name: Swift.String, description: Swift.String? = nil, schema: FoundationModels.DynamicGenerationSchema, isOptional: Swift.Bool = false)`
- [x] `public init<RegexOutput>(name: Swift.String, description: Swift.String? = nil, type: Swift.String.Type, guides: [_StringProcessing.Regex<RegexOutput>] = [])`
- [x] `public init<RegexOutput>(name: Swift.String, description: Swift.String? = nil, type: Swift.String?.Type, guides: [_StringProcessing.Regex<RegexOutput>] = [])`
- [x] `public init<Value>(name: Swift.String, description: Swift.String? = nil, type: Value.Type, guides: [FoundationModels.GenerationGuide<Value>] = []) where Value : FoundationModels.Generable`
- [x] `public init<Value>(name: Swift.String, description: Swift.String? = nil, type: Value?.Type, guides: [FoundationModels.GenerationGuide<Value>] = []) where Value : FoundationModels.Generable`

### [ ] `Refusal` — 3 members

- [x] `public init(transcriptEntries: [FoundationModels.Transcript.Entry])`
- [x] `public var explanation: FoundationModels.LanguageModelSession.Response<Swift.String>`
- [ ] `public var explanationStream: FoundationModels.LanguageModelSession.ResponseStream<Swift.String>`

### [x] `Response` — 9 members

- [x] `public init(id: Swift.String = UUID().uuidString, assetIDs: [Swift.String], segments: [FoundationModels.Transcript.Segment])`
- [x] `public let content: Content`
- [x] `public let rawContent: FoundationModels.GeneratedContent`
- [x] `public let transcriptEntries: Swift.ArraySlice<FoundationModels.Transcript.Entry>`
- [x] `public static func == (a: FoundationModels.Transcript.Response, b: FoundationModels.Transcript.Response) -> Swift.Bool`
- [x] `public typealias ID = Swift.String`
- [x] `public var assetIDs: [Swift.String]`
- [x] `public var id: Swift.String`
- [x] `public var segments: [FoundationModels.Transcript.Segment]`

### [x] `ResponseFormat` — 4 members

- [x] `public init(schema: FoundationModels.GenerationSchema)`
- [x] `public init<Content>(type: Content.Type) where Content : FoundationModels.Generable`
- [x] `public static func == (a: FoundationModels.Transcript.ResponseFormat, b: FoundationModels.Transcript.ResponseFormat) -> Swift.Bool`
- [x] `public var name: Swift.String`

### [x] `ResponseStream` — 0 members


### [x] `SamplingMode` — 4 members

- [x] `public static func == (a: FoundationModels.GenerationOptions.SamplingMode, b: FoundationModels.GenerationOptions.SamplingMode) -> Swift.Bool`
- [x] `public static func random(probabilityThreshold: Swift.Double, seed: Swift.UInt64? = nil) -> FoundationModels.GenerationOptions.SamplingMode`
- [x] `public static func random(top k: Swift.Int, seed: Swift.UInt64? = nil) -> FoundationModels.GenerationOptions.SamplingMode`
- [x] `public static var greedy: FoundationModels.GenerationOptions.SamplingMode`

### [x] `SchemaError` — 6 members

- [x] `case duplicateProperty(schema: Swift.String, property: Swift.String, context: FoundationModels.GenerationSchema.SchemaError.Context)`
- [x] `case duplicateType(schema: Swift.String?, type: Swift.String, context: FoundationModels.GenerationSchema.SchemaError.Context)`
- [x] `case emptyTypeChoices(schema: Swift.String, context: FoundationModels.GenerationSchema.SchemaError.Context)`
- [x] `case undefinedReferences(schema: Swift.String?, references: [Swift.String], context: FoundationModels.GenerationSchema.SchemaError.Context)`
- [x] `public var errorDescription: Swift.String?`
- [x] `public var recoverySuggestion: Swift.String?`

### [x] `Segment` — 5 members

- [x] `case structure(FoundationModels.Transcript.StructuredSegment)`
- [x] `case text(FoundationModels.Transcript.TextSegment)`
- [x] `public static func == (a: FoundationModels.Transcript.Segment, b: FoundationModels.Transcript.Segment) -> Swift.Bool`
- [x] `public typealias ID = Swift.String`
- [x] `public var id: Swift.String`

### [ ] `Sentiment` — 8 members

- [ ] `case negative`
- [ ] `case neutral`
- [ ] `case positive`
- [ ] `nonisolated public static var allCases: [FoundationModels.LanguageModelFeedback.Sentiment]`
- [ ] `public func hash(into hasher: inout Swift.Hasher)`
- [ ] `public static func == (a: FoundationModels.LanguageModelFeedback.Sentiment, b: FoundationModels.LanguageModelFeedback.Sentiment) -> Swift.Bool`
- [ ] `public typealias AllCases = [FoundationModels.LanguageModelFeedback.Sentiment]`
- [ ] `public var hashValue: Swift.Int`

### [x] `Snapshot` — 2 members

- [x] `public var content: Content.PartiallyGenerated`
- [x] `public var rawContent: FoundationModels.GeneratedContent`

### [x] `String` — 5 members

- [x] `public init(_ content: FoundationModels.GeneratedContent) throws`
- [x] `public static var generationSchema: FoundationModels.GenerationSchema`
- [x] `public var generatedContent: FoundationModels.GeneratedContent`
- [x] `public var instructionsRepresentation: FoundationModels.Instructions`
- [x] `public var promptRepresentation: FoundationModels.Prompt`

### [x] `StructuredSegment` — 6 members

- [x] `public init(id: Swift.String = UUID().uuidString, source: Swift.String, content: FoundationModels.GeneratedContent)`
- [x] `public static func == (a: FoundationModels.Transcript.StructuredSegment, b: FoundationModels.Transcript.StructuredSegment) -> Swift.Bool`
- [x] `public typealias ID = Swift.String`
- [x] `public var content: FoundationModels.GeneratedContent`
- [x] `public var id: Swift.String`
- [x] `public var source: Swift.String`

### [ ] `SystemLanguageModel` — 13 members

- [x] `convenience public init(adapter: FoundationModels.SystemLanguageModel.Adapter, guardrails: FoundationModels.SystemLanguageModel.Guardrails = .default)`
- [x] `convenience public init(useCase: FoundationModels.SystemLanguageModel.UseCase = .general, guardrails: FoundationModels.SystemLanguageModel.Guardrails = Guardrails.default)`
- [x] `final public func supportsLocale(_ locale: Foundation.Locale = Locale.current) -> Swift.Bool`
- [x] `final public var availability: FoundationModels.SystemLanguageModel.Availability`
- [x] `final public var isAvailable: Swift.Bool`
- [x] `final public var supportedLanguages: Swift.Set<Foundation.Locale.Language>`
- [ ] `public func compile() async throws`
- [x] `public init(fileURL: Foundation.URL) throws`
- [x] `public init(name: Swift.String) throws`
- [ ] `public static func compatibleAdapterIdentifiers(name: Swift.String) -> [Swift.String]`
- [ ] `public static func isCompatible(_ assetPack: BackgroundAssets.AssetPack) -> Swift.Bool`
- [ ] `public static func removeObsoleteAdapters() throws`
- [x] `public static let `default`: FoundationModels.SystemLanguageModel`

### [x] `TextSegment` — 5 members

- [x] `public init(id: Swift.String = UUID().uuidString, content: Swift.String)`
- [x] `public static func == (a: FoundationModels.Transcript.TextSegment, b: FoundationModels.Transcript.TextSegment) -> Swift.Bool`
- [x] `public typealias ID = Swift.String`
- [x] `public var content: Swift.String`
- [x] `public var id: Swift.String`

### [x] `Tool` — 3 members

- [x] `public var includesSchemaInInstructions: Swift.Bool`
- [x] `public var name: Swift.String`
- [x] `public var parameters: FoundationModels.GenerationSchema`

### [x] `ToolCall` — 6 members

- [x] `public init(id: Swift.String, toolName: Swift.String, arguments: FoundationModels.GeneratedContent)`
- [x] `public static func == (a: FoundationModels.Transcript.ToolCall, b: FoundationModels.Transcript.ToolCall) -> Swift.Bool`
- [x] `public typealias ID = Swift.String`
- [x] `public var arguments: FoundationModels.GeneratedContent`
- [x] `public var id: Swift.String`
- [x] `public var toolName: Swift.String`

### [x] `ToolCallError` — 4 members

- [x] `public init(tool: any FoundationModels.Tool, underlyingError: any Swift.Error)`
- [x] `public var errorDescription: Swift.String?`
- [x] `public var tool: any FoundationModels.Tool`
- [x] `public var underlyingError: any Swift.Error`

### [x] `ToolCalls` — 12 members

- [x] `public init<S>(id: Swift.String = UUID().uuidString, _ calls: S) where S : Swift.Sequence, S.Element == FoundationModels.Transcript.ToolCall`
- [x] `public static func == (a: FoundationModels.Transcript.ToolCalls, b: FoundationModels.Transcript.ToolCalls) -> Swift.Bool`
- [x] `public subscript(position: Swift.Int) -> FoundationModels.Transcript.ToolCall`
- [x] `public typealias Element = FoundationModels.Transcript.ToolCall`
- [x] `public typealias ID = Swift.String`
- [x] `public typealias Index = Swift.Int`
- [x] `public typealias Indices = Swift.Range<Swift.Int>`
- [x] `public typealias Iterator = Swift.IndexingIterator<FoundationModels.Transcript.ToolCalls>`
- [x] `public typealias SubSequence = Swift.Slice<FoundationModels.Transcript.ToolCalls>`
- [x] `public var endIndex: Swift.Int`
- [x] `public var id: Swift.String`
- [x] `public var startIndex: Swift.Int`

### [x] `ToolDefinition` — 5 members

- [x] `public init(name: Swift.String, description: Swift.String, parameters: FoundationModels.GenerationSchema)`
- [x] `public init(tool: some Tool)`
- [x] `public static func == (a: FoundationModels.Transcript.ToolDefinition, b: FoundationModels.Transcript.ToolDefinition) -> Swift.Bool`
- [x] `public var description: Swift.String`
- [x] `public var name: Swift.String`

### [x] `ToolOutput` — 6 members

- [x] `public init(id: Swift.String, toolName: Swift.String, segments: [FoundationModels.Transcript.Segment])`
- [x] `public static func == (a: FoundationModels.Transcript.ToolOutput, b: FoundationModels.Transcript.ToolOutput) -> Swift.Bool`
- [x] `public typealias ID = Swift.String`
- [x] `public var id: Swift.String`
- [x] `public var segments: [FoundationModels.Transcript.Segment]`
- [x] `public var toolName: Swift.String`

### [ ] `Transcript` — 13 members

- [ ] `public func encode(to encoder: any Swift.Encoder) throws`
- [x] `public init(entries: some Sequence<Entry> = [])`
- [ ] `public init(from decoder: any Swift.Decoder) throws`
- [x] `public static func == (a: FoundationModels.Transcript, b: FoundationModels.Transcript) -> Swift.Bool`
- [x] `public subscript(index: FoundationModels.Transcript.Index) -> FoundationModels.Transcript.Entry`
- [x] `public typealias Element = FoundationModels.Transcript.Entry`
- [x] `public typealias Index = Swift.Int`
- [x] `public typealias Indices = Swift.Range<FoundationModels.Transcript.Index>`
- [x] `public typealias Iterator = Swift.IndexingIterator<FoundationModels.Transcript>`
- [x] `public typealias SubSequence = Swift.Slice<FoundationModels.Transcript>`
- [ ] `public var description: Swift.String`
- [x] `public var endIndex: Swift.Int`
- [x] `public var startIndex: Swift.Int`

### [x] `UnavailableReason` — 6 members

- [x] `case appleIntelligenceNotEnabled`
- [x] `case deviceNotEligible`
- [x] `case modelNotReady`
- [x] `public func hash(into hasher: inout Swift.Hasher)`
- [x] `public static func == (a: FoundationModels.SystemLanguageModel.Availability.UnavailableReason, b: FoundationModels.SystemLanguageModel.Availability.UnavailableReason) -> Swift.Bool`
- [x] `public var hashValue: Swift.Int`

### [x] `UseCase` — 3 members

- [x] `public static func == (a: FoundationModels.SystemLanguageModel.UseCase, b: FoundationModels.SystemLanguageModel.UseCase) -> Swift.Bool`
- [x] `public static let contentTagging: FoundationModels.SystemLanguageModel.UseCase`
- [x] `public static let general: FoundationModels.SystemLanguageModel.UseCase`


---
## ImagePlayground

> Image generation + Genmoji. iOS 18.2+. AI-gated. Polyfill: diffusion backend (cloud or CoreML SD).

Source: iPhoneOS26.2.sdk · Swift (.swiftinterface) · full framework

Types: 11 · Members: 66

### [x] `CreatedImage` — 1 member

- [x] `public let cgImage: CoreGraphics.CGImage`

### [ ] `Delegate` — 0 members


### [x] `EnvironmentValues` — 4 members

- [x] `public var imagePlaygroundAllowedGenerationStyles: [ImagePlayground.ImagePlaygroundStyle]`
- [x] `public var imagePlaygroundPersonalizationPolicy: ImagePlayground.ImagePlaygroundPersonalizationPolicy`
- [x] `public var imagePlaygroundSelectedGenerationStyle: ImagePlayground.ImagePlaygroundStyle`
- [x] `public var supportsImagePlayground: Swift.Bool`

### [x] `Error` — 16 members

- [x] `case backgroundCreationForbidden`
- [x] `case conceptsRequirePersonIdentity`
- [x] `case creationCancelled`
- [x] `case creationFailed`
- [x] `case faceInImageTooSmall`
- [x] `case notSupported`
- [x] `case unavailable`
- [x] `case unsupportedInputImage`
- [x] `case unsupportedLanguage`
- [x] `public func hash(into hasher: inout Swift.Hasher)`
- [x] `public static func == (a: ImagePlayground.ImageCreator.Error, b: ImagePlayground.ImageCreator.Error) -> Swift.Bool`
- [x] `public static var allCases: [ImagePlayground.ImageCreator.Error]`
- [x] `public static var errorDomain: Swift.String`
- [x] `public typealias AllCases = [ImagePlayground.ImageCreator.Error]`
- [x] `public var errorUserInfo: [Swift.String : Any]`
- [x] `public var hashValue: Swift.Int`

### [x] `ImageCreator` — 3 members

- [x] `final public func images(for concepts: [ImagePlayground.ImagePlaygroundConcept], style: ImagePlayground.ImagePlaygroundStyle, limit: Swift.Int) -> some _Concurrency.AsyncSequence<ImagePlayground.ImageCreator.CreatedImage, any Swift.Error>`
- [x] `final public let availableStyles: [ImagePlayground.ImagePlaygroundStyle]`
- [x] `public init() async throws`

### [x] `ImagePlaygroundConcept` — 5 members

- [x] `public static func drawing(_ drawing: PencilKit.PKDrawing) -> ImagePlayground.ImagePlaygroundConcept`
- [x] `public static func extracted(from text: Swift.String, title: Swift.String? = nil) -> ImagePlayground.ImagePlaygroundConcept`
- [x] `public static func image(_ image: CoreGraphics.CGImage) -> ImagePlayground.ImagePlaygroundConcept`
- [x] `public static func image(_ url: Foundation.URL) -> ImagePlayground.ImagePlaygroundConcept?`
- [x] `public static func text(_ text: Swift.String) -> ImagePlayground.ImagePlaygroundConcept`

### [x] `ImagePlaygroundPersonalizationPolicy` — 6 members

- [x] `case automatic`
- [x] `case disabled`
- [x] `case enabled`
- [x] `public init?(rawValue: Swift.Int)`
- [x] `public typealias RawValue = Swift.Int`
- [x] `public var rawValue: Swift.Int`

### [x] `ImagePlaygroundStyle` — 12 members

- [x] `public func encode(to encoder: any Swift.Encoder) throws`
- [x] `public func hash(into hasher: inout Swift.Hasher)`
- [x] `public init(from decoder: any Swift.Decoder) throws`
- [x] `public let id: Swift.String`
- [x] `public static func == (a: ImagePlayground.ImagePlaygroundStyle, b: ImagePlayground.ImagePlaygroundStyle) -> Swift.Bool`
- [x] `public static let animation: ImagePlayground.ImagePlaygroundStyle`
- [x] `public static let externalProvider: ImagePlayground.ImagePlaygroundStyle`
- [x] `public static let illustration: ImagePlayground.ImagePlaygroundStyle`
- [x] `public static let sketch: ImagePlayground.ImagePlaygroundStyle`
- [x] `public static var all: [ImagePlayground.ImagePlaygroundStyle]`
- [x] `public typealias ID = Swift.String`
- [x] `public var hashValue: Swift.Int`

### [ ] `ImagePlaygroundViewController` — 13 members

- [x] `@_Concurrency.MainActor @preconcurrency @objc convenience dynamic public init()`
- [x] `@_Concurrency.MainActor @preconcurrency @objc override dynamic public func viewDidDisappear(_ animated: Swift.Bool)`
- [x] `@_Concurrency.MainActor @preconcurrency @objc override dynamic public func viewDidLoad()`
- [ ] `@_Concurrency.MainActor @preconcurrency @objc override dynamic public var isModalInPresentation: Swift.Bool`
- [ ] `@_Concurrency.MainActor @preconcurrency @objc override dynamic public var modalPresentationStyle: UIKit.UIModalPresentationStyle`
- [ ] `@_Concurrency.MainActor @preconcurrency @objc override dynamic public var preferredContentSize: CoreFoundation.CGSize`
- [ ] `@_Concurrency.MainActor @preconcurrency @objc override dynamic public var supportedInterfaceOrientations: UIKit.UIInterfaceOrientationMask`
- [x] `@_Concurrency.MainActor @preconcurrency public var allowedGenerationStyles: [ImagePlayground.ImagePlaygroundStyle]`
- [x] `@_Concurrency.MainActor @preconcurrency public var concepts: [ImagePlayground.ImagePlaygroundConcept]`
- [x] `@_Concurrency.MainActor @preconcurrency public var personalizationPolicy: ImagePlayground.ImagePlaygroundPersonalizationPolicy`
- [x] `@_Concurrency.MainActor @preconcurrency public var selectedGenerationStyle: ImagePlayground.ImagePlaygroundStyle`
- [x] `@objc @_Concurrency.MainActor @preconcurrency public var sourceImage: UIKit.UIImage?`
- [x] `@objc @_Concurrency.MainActor @preconcurrency weak public var delegate: (any ImagePlayground.ImagePlaygroundViewController.Delegate)?`

### [x] `View` — 6 members

- [x] `@_Concurrency.MainActor @preconcurrency public func imagePlaygroundSheet(isPresented: SwiftUICore.Binding<Swift.Bool>, concept: Swift.String, sourceImage: SwiftUICore.Image? = nil, onCompletion: @escaping (_ url: Foundation.URL) -> Swift.Void, onCancellation: (() -> Swift.Void)? = nil) -> some SwiftUICore.View`
- [x] `@_Concurrency.MainActor @preconcurrency public func imagePlaygroundSheet(isPresented: SwiftUICore.Binding<Swift.Bool>, concept: Swift.String, sourceImageURL: Foundation.URL, onCompletion: @escaping (_ url: Foundation.URL) -> Swift.Void, onCancellation: (() -> Swift.Void)? = nil) -> some SwiftUICore.View`
- [x] `@_Concurrency.MainActor @preconcurrency public func imagePlaygroundSheet(isPresented: SwiftUICore.Binding<Swift.Bool>, concepts: [ImagePlayground.ImagePlaygroundConcept] = [], sourceImage: SwiftUICore.Image? = nil, onCompletion: @escaping (Foundation.URL) -> Swift.Void, onCancellation: (() -> Swift.Void)? = nil) -> some SwiftUICore.View`
- [x] `@_Concurrency.MainActor @preconcurrency public func imagePlaygroundSheet(isPresented: SwiftUICore.Binding<Swift.Bool>, concepts: [ImagePlayground.ImagePlaygroundConcept] = [], sourceImageURL: Foundation.URL, onCompletion: @escaping (_ url: Foundation.URL) -> Swift.Void, onCancellation: (() -> Swift.Void)? = nil) -> some SwiftUICore.View`
- [x] `nonisolated public func imagePlaygroundGenerationStyle(_ style: ImagePlayground.ImagePlaygroundStyle, in allowedStyles: [ImagePlayground.ImagePlaygroundStyle] = ImagePlaygroundStyle.all) -> some SwiftUICore.View`
- [x] `nonisolated public func imagePlaygroundPersonalizationPolicy(_ policy: ImagePlayground.ImagePlaygroundPersonalizationPolicy = .automatic) -> some SwiftUICore.View`

### [ ] `var` — 0 members



---
## VisualIntelligence

> Camera/onscreen semantic search. iOS 26+. AI-gated. Polyfill: VisionKit DataScanner + vision model.

Source: iPhoneOS26.2.sdk · Swift (.swiftinterface) · full framework

Types: 1 · Members: 10

### [ ] `SemanticContentDescriptor` — 10 members

- [x] `public let labels: [Swift.String]`
- [ ] `public static var defaultResolverSpecification: some AppIntents.ResolverSpecification`
- [ ] `public static var persistentIdentifier: Swift.String`
- [ ] `public static var typeDisplayRepresentation: AppIntents.TypeDisplayRepresentation`
- [ ] `public typealias Specification = @_opaqueReturnTypeOf("$s18VisualIntelligence25SemanticContentDescriptorV28defaultResolverSpecificationQrvpZ", 0) __`
- [ ] `public typealias UnwrappedType = VisualIntelligence.SemanticContentDescriptor`
- [ ] `public typealias ValueType = VisualIntelligence.SemanticContentDescriptor`
- [x] `public var description: Swift.String`
- [ ] `public var displayRepresentation: AppIntents.DisplayRepresentation`
- [x] `public var pixelBuffer: CoreVideo.CVReadOnlyPixelBuffer?`


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

### [x] `AssistantEntity` — 0 members


### [x] `AssistantEnum` — 0 members


### [x] `AssistantIntent` — 0 members


### [x] `AssistantSchema` — 3 members

- [x] `public init(_ schema: some AssistantSchemas.Entity)`
- [x] `public init(_ schema: some AssistantSchemas.Enum)`
- [x] `public init(_ schema: some AssistantSchemas.Intent)`

### [x] `AssistantSchemaEntity` — 2 members

- [x] `public static var isAssistantOnly: Swift.Bool`
- [x] `public static var typeDisplayRepresentation: AppIntents.TypeDisplayRepresentation`

### [x] `AssistantSchemaEnum` — 2 members

- [x] `public static var isAssistantOnly: Swift.Bool`
- [x] `public static var typeDisplayRepresentation: AppIntents.TypeDisplayRepresentation`

### [x] `AssistantSchemaIntent` — 2 members

- [x] `public static var isAssistantOnly: Swift.Bool`
- [x] `public static var title: Foundation.LocalizedStringResource`

### [x] `AssistantSchemas` — 196 members

- [x] `@_alwaysEmitIntoClient public static var assistant: some AppIntents.AssistantSchemas.AssistantIntent`
- [x] `@_alwaysEmitIntoClient public static var books: some AppIntents.AssistantSchemas.BooksEntity`
- [x] `@_alwaysEmitIntoClient public static var books: some AppIntents.AssistantSchemas.BooksEnum`
- [x] `@_alwaysEmitIntoClient public static var books: some AppIntents.AssistantSchemas.BooksIntent`
- [x] `@_alwaysEmitIntoClient public static var browser: some AppIntents.AssistantSchemas.BrowserEntity`
- [x] `@_alwaysEmitIntoClient public static var browser: some AppIntents.AssistantSchemas.BrowserEnum`
- [x] `@_alwaysEmitIntoClient public static var camera: some AppIntents.AssistantSchemas.CameraEnum`
- [x] `@_alwaysEmitIntoClient public static var camera: some AppIntents.AssistantSchemas.CameraIntent`
- [x] `@_alwaysEmitIntoClient public static var files: some AppIntents.AssistantSchemas.FilesEntity`
- [x] `@_alwaysEmitIntoClient public static var files: some AppIntents.AssistantSchemas.FilesIntent`
- [x] `@_alwaysEmitIntoClient public static var journal: some AppIntents.AssistantSchemas.JournalEntity`
- [x] `@_alwaysEmitIntoClient public static var journal: some AppIntents.AssistantSchemas.JournalIntent`
- [x] `@_alwaysEmitIntoClient public static var mail: some AppIntents.AssistantSchemas.MailEntity`
- [x] `@_alwaysEmitIntoClient public static var mail: some AppIntents.AssistantSchemas.MailIntent`
- [x] `@_alwaysEmitIntoClient public static var photos: some AppIntents.AssistantSchemas.PhotosEntity`
- [x] `@_alwaysEmitIntoClient public static var photos: some AppIntents.AssistantSchemas.PhotosEnum`
- [x] `@_alwaysEmitIntoClient public static var photos: some AppIntents.AssistantSchemas.PhotosIntent`
- [x] `@_alwaysEmitIntoClient public static var presentation: some AppIntents.AssistantSchemas.PresentationEntity`
- [x] `@_alwaysEmitIntoClient public static var presentation: some AppIntents.AssistantSchemas.PresentationIntent`
- [x] `@_alwaysEmitIntoClient public static var reader: some AppIntents.AssistantSchemas.ReaderEntity`
- [x] `@_alwaysEmitIntoClient public static var reader: some AppIntents.AssistantSchemas.ReaderEnum`
- [x] `@_alwaysEmitIntoClient public static var reader: some AppIntents.AssistantSchemas.ReaderIntent`
- [x] `@_alwaysEmitIntoClient public static var spreadsheet: some AppIntents.AssistantSchemas.SpreadsheetEntity`
- [x] `@_alwaysEmitIntoClient public static var spreadsheet: some AppIntents.AssistantSchemas.SpreadsheetIntent`
- [x] `@_alwaysEmitIntoClient public static var system: some AppIntents.AssistantSchemas.SystemIntent`
- [x] `@_alwaysEmitIntoClient public static var visualIntelligence: some AppIntents.AssistantSchemas.VisualIntelligenceIntent`
- [x] `@_alwaysEmitIntoClient public static var whiteboard: some AppIntents.AssistantSchemas.WhiteboardEntity`
- [x] `@_alwaysEmitIntoClient public static var whiteboard: some AppIntents.AssistantSchemas.WhiteboardEnum`
- [x] `@_alwaysEmitIntoClient public static var whiteboard: some AppIntents.AssistantSchemas.WhiteboardIntent`
- [x] `@_alwaysEmitIntoClient public static var wordProcessor: some AppIntents.AssistantSchemas.WordProcessorEntity`
- [x] `@_alwaysEmitIntoClient public static var wordProcessor: some AppIntents.AssistantSchemas.WordProcessorIntent`
- [x] `@_alwaysEmitIntoClient public var account: some AppIntents.AssistantSchemas.Entity`
- [x] `@_alwaysEmitIntoClient public var activate: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var addAssetsToAlbum: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var addAudioToPage: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var addAudioToSheet: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var addAudioToSlide: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var addCommentToSheet: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var addCommentToSlide: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var addImageToPage: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var addImageToSheet: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var addImageToSlide: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var addTextBoxToPage: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var addTextBoxToSheet: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var addTextBoxToSlide: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var addVideoToPage: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var addVideoToSheet: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var addVideoToSlide: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var addWebVideoToPage: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var addWebVideoToSheet: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var addWebVideoToSlide: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var album: some AppIntents.AssistantSchemas.Entity`
- [x] `@_alwaysEmitIntoClient public var albumType: some AppIntents.AssistantSchemas.Enum`
- [x] `@_alwaysEmitIntoClient public var archiveMail: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var asset: some AppIntents.AssistantSchemas.Entity`
- [x] `@_alwaysEmitIntoClient public var assetType: some AppIntents.AssistantSchemas.Enum`
- [x] `@_alwaysEmitIntoClient public var audiobook: some AppIntents.AssistantSchemas.Entity`
- [x] `@_alwaysEmitIntoClient public var board: some AppIntents.AssistantSchemas.Entity`
- [x] `@_alwaysEmitIntoClient public var book: some AppIntents.AssistantSchemas.Entity`
- [x] `@_alwaysEmitIntoClient public var bookmark: some AppIntents.AssistantSchemas.Entity`
- [x] `@_alwaysEmitIntoClient public var bookmarkTab: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var bookmarkURL: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var captureDevice: some AppIntents.AssistantSchemas.Enum`
- [x] `@_alwaysEmitIntoClient public var captureDuration: some AppIntents.AssistantSchemas.Enum`
- [x] `@_alwaysEmitIntoClient public var captureMode: some AppIntents.AssistantSchemas.Enum`
- [x] `@_alwaysEmitIntoClient public var cleanupPhoto: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var clearHistory: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var clearHistoryTimeFrame: some AppIntents.AssistantSchemas.Enum`
- [x] `@_alwaysEmitIntoClient public var closeTabs: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var closeWindows: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var color: some AppIntents.AssistantSchemas.Enum`
- [x] `@_alwaysEmitIntoClient public var contentType: some AppIntents.AssistantSchemas.Enum`
- [x] `@_alwaysEmitIntoClient public var copyEdits: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var create: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var createAlbum: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var createAssets: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var createAudioEntry: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var createBoard: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var createDraft: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var createEntry: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var createFolder: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var createItem: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var createPage: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var createSheet: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var createSlide: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var createTab: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var createWindow: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var crop: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var delete: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var deleteAlbum: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var deleteAssets: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var deleteBoard: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var deleteBookmarks: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var deleteDraft: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var deleteEntry: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var deleteFiles: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var deleteItem: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var deleteMail: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var deletePages: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var deleteSheet: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var deleteSlide: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var document: some AppIntents.AssistantSchemas.Entity`
- [x] `@_alwaysEmitIntoClient public var documentKind: some AppIntents.AssistantSchemas.Enum`
- [x] `@_alwaysEmitIntoClient public var draft: some AppIntents.AssistantSchemas.Entity`
- [x] `@_alwaysEmitIntoClient public var duplicateAssets: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var enhanceDocuments: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var entry: some AppIntents.AssistantSchemas.Entity`
- [x] `@_alwaysEmitIntoClient public var file: some AppIntents.AssistantSchemas.Entity`
- [x] `@_alwaysEmitIntoClient public var filterType: some AppIntents.AssistantSchemas.Enum`
- [x] `@_alwaysEmitIntoClient public var findOnPage: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var font: some AppIntents.AssistantSchemas.Enum`
- [x] `@_alwaysEmitIntoClient public var fontSize: some AppIntents.AssistantSchemas.Enum`
- [x] `@_alwaysEmitIntoClient public var forwardMail: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var insertPages: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var item: some AppIntents.AssistantSchemas.Entity`
- [x] `@_alwaysEmitIntoClient public var itemType: some AppIntents.AssistantSchemas.Enum`
- [x] `@_alwaysEmitIntoClient public var mailbox: some AppIntents.AssistantSchemas.Entity`
- [x] `@_alwaysEmitIntoClient public var message: some AppIntents.AssistantSchemas.Entity`
- [x] `@_alwaysEmitIntoClient public var moveFiles: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var navigatePage: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var navigationDirection: some AppIntents.AssistantSchemas.Enum`
- [x] `@_alwaysEmitIntoClient public var open: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var openAlbum: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var openAsset: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var openBoard: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var openBook: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var openBookmark: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var openDocument: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var openFile: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var openInCaptureMode: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var openPage: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var openSheet: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var openSlide: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var openURLInTab: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var page: some AppIntents.AssistantSchemas.Entity`
- [x] `@_alwaysEmitIntoClient public var pageNavigationSetting: some AppIntents.AssistantSchemas.Enum`
- [x] `@_alwaysEmitIntoClient public var pasteEdits: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var playAudiobook: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var postToSharedAlbum: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var recognizedPerson: some AppIntents.AssistantSchemas.Entity`
- [x] `@_alwaysEmitIntoClient public var relativeCharacterSpacingChange: some AppIntents.AssistantSchemas.Enum`
- [x] `@_alwaysEmitIntoClient public var relativeFontChange: some AppIntents.AssistantSchemas.Enum`
- [x] `@_alwaysEmitIntoClient public var relativeLineSpacingChange: some AppIntents.AssistantSchemas.Enum`
- [x] `@_alwaysEmitIntoClient public var relativeWordSpacingChange: some AppIntents.AssistantSchemas.Enum`
- [x] `@_alwaysEmitIntoClient public var removeAssetsFromAlbum: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var renameFile: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var replyMail: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var resizeDocuments: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var rotateDocuments: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var rotatePages: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var rotationDirection: some AppIntents.AssistantSchemas.Enum`
- [x] `@_alwaysEmitIntoClient public var saveDraft: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var search: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var searchDocuments: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var semanticContentSearch: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var sendDraft: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var setDepth: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var setDevice: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var setExposure: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var setFilter: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var setRotation: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var setSaturation: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var setSlideTitle: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var setWarmth: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var settings: some AppIntents.AssistantSchemas.Entity`
- [x] `@_alwaysEmitIntoClient public var sheet: some AppIntents.AssistantSchemas.Entity`
- [x] `@_alwaysEmitIntoClient public var slide: some AppIntents.AssistantSchemas.Entity`
- [x] `@_alwaysEmitIntoClient public var startCapture: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var startPlayback: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var stopCapture: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var stopPlayback: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var straighten: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var switchDevice: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var switchTab: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var tab: some AppIntents.AssistantSchemas.Entity`
- [x] `@_alwaysEmitIntoClient public var template: some AppIntents.AssistantSchemas.Entity`
- [x] `@_alwaysEmitIntoClient public var theme: some AppIntents.AssistantSchemas.Enum`
- [x] `@_alwaysEmitIntoClient public var toggleDepth: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var toggleSuggestedEdits: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var update: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var updateAlbum: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var updateAsset: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var updateBoard: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var updateCharacterSpacing: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var updateDraft: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var updateEntry: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var updateFontSize: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var updateItem: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var updateLineSpacing: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var updateMail: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var updateRecognizedPerson: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var updateSettings: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var updateSheet: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var updateWordSpacing: some AppIntents.AssistantSchemas.Intent`
- [x] `@_alwaysEmitIntoClient public var window: some AppIntents.AssistantSchemas.Entity`
- [x] `public static var browser: some AppIntents.AssistantSchemas.BrowserIntent`
