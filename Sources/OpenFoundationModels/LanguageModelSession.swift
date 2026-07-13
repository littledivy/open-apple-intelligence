import Foundation

/// A stateful conversation with the model. Mirrors
/// `FoundationModels.LanguageModelSession`.
///
/// Each `respond`/`streamResponse` appends the prompt and completion to the session
/// `transcript`, so follow-up turns carry context. Guided generation (`generating:` /
/// `schema:`) decodes the model's JSON into typed `Generable` values. Tools passed at
/// init are offered to the model and invoked when it requests them.
public final class LanguageModelSession: @unchecked Sendable {

    private let model: SystemLanguageModel
    private let tools: [any Tool]
    private let baseInstructions: Instructions?

    private let lock = NSLock()
    private var _entries: [Transcript.Entry] = []
    private var _messages: [GenerationMessage] = []
    private var _isResponding = false

    /// The full transcript of this session.
    public var transcript: Transcript {
        lock.withLock { Transcript(entries: _entries) }
    }

    /// Whether a response is currently being produced.
    public var isResponding: Bool {
        lock.withLock { _isResponding }
    }

    // MARK: Init

    public init(
        model: SystemLanguageModel = .default,
        tools: [any Tool] = [],
        instructions: Instructions? = nil
    ) {
        self.model = model
        self.tools = tools
        self.baseInstructions = instructions
        if let instructions {
            _entries.append(.instructions(.init(
                segments: [.text(.init(content: instructions.text))],
                toolDefinitions: tools.map { Transcript.ToolDefinition(tool: $0) }
            )))
        }
    }

    @_disfavoredOverload
    public convenience init(
        model: SystemLanguageModel = .default,
        tools: [any Tool] = [],
        instructions: String? = nil
    ) {
        self.init(model: model, tools: tools, instructions: instructions.map { Instructions($0) })
    }

    public convenience init(
        model: SystemLanguageModel = .default,
        tools: [any Tool] = [],
        @InstructionsBuilder instructions: () throws -> Instructions
    ) rethrows {
        self.init(model: model, tools: tools, instructions: try instructions())
    }

    public convenience init(
        model: SystemLanguageModel = .default,
        tools: [any Tool] = [],
        transcript: Transcript
    ) {
        self.init(model: model, tools: tools, instructions: Optional<Instructions>.none)
        lock.withLock {
            _entries = Array(transcript)
            _messages = Self.messages(from: transcript)
        }
    }

    // MARK: respond → Response<String>

    @discardableResult
    public func respond(
        to prompt: String,
        options: GenerationOptions = GenerationOptions()
    ) async throws -> Response<String> {
        try await respond(to: Prompt(prompt), options: options)
    }

    @discardableResult
    public func respond(
        to prompt: Prompt,
        options: GenerationOptions = GenerationOptions()
    ) async throws -> Response<String> {
        let (raw, entries) = try await run(prompt: prompt.text, schema: nil, includeSchemaInPrompt: false, options: options)
        return Response(content: try String(raw), rawContent: raw, transcriptEntries: entries)
    }

    @discardableResult
    public func respond(
        options: GenerationOptions = GenerationOptions(),
        @PromptBuilder prompt: () throws -> Prompt
    ) async throws -> Response<String> {
        try await respond(to: try prompt(), options: options)
    }

    // MARK: respond → Response<GeneratedContent> (raw schema)

    @discardableResult
    public func respond(
        to prompt: Prompt,
        schema: GenerationSchema,
        includeSchemaInPrompt: Bool = true,
        options: GenerationOptions = GenerationOptions()
    ) async throws -> Response<GeneratedContent> {
        let (raw, entries) = try await run(prompt: prompt.text, schema: schema, includeSchemaInPrompt: includeSchemaInPrompt, options: options)
        return Response(content: raw, rawContent: raw, transcriptEntries: entries)
    }

    @discardableResult
    public func respond(
        to prompt: String,
        schema: GenerationSchema,
        includeSchemaInPrompt: Bool = true,
        options: GenerationOptions = GenerationOptions()
    ) async throws -> Response<GeneratedContent> {
        try await respond(to: Prompt(prompt), schema: schema, includeSchemaInPrompt: includeSchemaInPrompt, options: options)
    }

    @discardableResult
    public func respond(
        schema: GenerationSchema,
        includeSchemaInPrompt: Bool = true,
        options: GenerationOptions = GenerationOptions(),
        @PromptBuilder prompt: () throws -> Prompt
    ) async throws -> Response<GeneratedContent> {
        try await respond(to: try prompt(), schema: schema, includeSchemaInPrompt: includeSchemaInPrompt, options: options)
    }

    // MARK: respond → Response<Content> (guided, typed)

    @discardableResult
    public func respond<Content: Generable>(
        to prompt: Prompt,
        generating type: Content.Type = Content.self,
        includeSchemaInPrompt: Bool = true,
        options: GenerationOptions = GenerationOptions()
    ) async throws -> Response<Content> {
        let (raw, entries) = try await run(prompt: prompt.text, schema: type.generationSchema, includeSchemaInPrompt: includeSchemaInPrompt, options: options)
        return Response(content: try Content(raw), rawContent: raw, transcriptEntries: entries)
    }

    @discardableResult
    public func respond<Content: Generable>(
        to prompt: String,
        generating type: Content.Type = Content.self,
        includeSchemaInPrompt: Bool = true,
        options: GenerationOptions = GenerationOptions()
    ) async throws -> Response<Content> {
        try await respond(to: Prompt(prompt), generating: type, includeSchemaInPrompt: includeSchemaInPrompt, options: options)
    }

    @discardableResult
    public func respond<Content: Generable>(
        generating type: Content.Type = Content.self,
        includeSchemaInPrompt: Bool = true,
        options: GenerationOptions = GenerationOptions(),
        @PromptBuilder prompt: () throws -> Prompt
    ) async throws -> Response<Content> {
        try await respond(to: try prompt(), generating: type, includeSchemaInPrompt: includeSchemaInPrompt, options: options)
    }

    // MARK: streamResponse → ResponseStream<String>

    public func streamResponse(
        to prompt: String,
        options: GenerationOptions = GenerationOptions()
    ) -> ResponseStream<String> {
        streamResponse(to: Prompt(prompt), options: options)
    }

    public func streamResponse(
        to prompt: Prompt,
        options: GenerationOptions = GenerationOptions()
    ) -> ResponseStream<String> {
        makeStream(prompt: prompt.text, schema: nil, includeSchemaInPrompt: false, options: options) { String.self }
    }

    public func streamResponse(
        options: GenerationOptions = GenerationOptions(),
        @PromptBuilder prompt: () throws -> Prompt
    ) rethrows -> ResponseStream<String> {
        streamResponse(to: try prompt(), options: options)
    }

    // MARK: streamResponse → ResponseStream<GeneratedContent>

    public func streamResponse(
        to prompt: Prompt,
        schema: GenerationSchema,
        includeSchemaInPrompt: Bool = true,
        options: GenerationOptions = GenerationOptions()
    ) -> ResponseStream<GeneratedContent> {
        makeStream(prompt: prompt.text, schema: schema, includeSchemaInPrompt: includeSchemaInPrompt, options: options) { GeneratedContent.self }
    }

    public func streamResponse(
        to prompt: String,
        schema: GenerationSchema,
        includeSchemaInPrompt: Bool = true,
        options: GenerationOptions = GenerationOptions()
    ) -> ResponseStream<GeneratedContent> {
        streamResponse(to: Prompt(prompt), schema: schema, includeSchemaInPrompt: includeSchemaInPrompt, options: options)
    }

    // MARK: streamResponse → ResponseStream<Content> (guided, typed)

    public func streamResponse<Content: Generable>(
        to prompt: Prompt,
        generating type: Content.Type = Content.self,
        includeSchemaInPrompt: Bool = true,
        options: GenerationOptions = GenerationOptions()
    ) -> ResponseStream<Content> {
        makeStream(prompt: prompt.text, schema: type.generationSchema, includeSchemaInPrompt: includeSchemaInPrompt, options: options) { type }
    }

    public func streamResponse<Content: Generable>(
        to prompt: String,
        generating type: Content.Type = Content.self,
        includeSchemaInPrompt: Bool = true,
        options: GenerationOptions = GenerationOptions()
    ) -> ResponseStream<Content> {
        streamResponse(to: Prompt(prompt), generating: type, includeSchemaInPrompt: includeSchemaInPrompt, options: options)
    }

    public func streamResponse<Content: Generable>(
        generating type: Content.Type = Content.self,
        includeSchemaInPrompt: Bool = true,
        options: GenerationOptions = GenerationOptions(),
        @PromptBuilder prompt: () throws -> Prompt
    ) rethrows -> ResponseStream<Content> {
        streamResponse(to: try prompt(), generating: type, includeSchemaInPrompt: includeSchemaInPrompt, options: options)
    }

    /// Best-effort warm-up. No-op for network backends; a hook for local ones.
    public func prewarm(promptPrefix: Prompt? = nil) {}

    // MARK: - Engine

    // Runs one turn, including the tool-calling loop, and records transcript entries.
    // Returns the final raw content plus the slice of entries added this turn.
    private func run(
        prompt: String,
        schema: GenerationSchema?,
        includeSchemaInPrompt: Bool,
        options: GenerationOptions
    ) async throws -> (GeneratedContent, ArraySlice<Transcript.Entry>) {
        let backend = try begin()
        defer { end() }

        let startIndex = lock.withLock { _entries.count }
        appendPrompt(prompt, options: options, schema: schema)

        var text = try await callModel(backend: backend, currentPrompt: prompt, schema: schema, includeSchemaInPrompt: includeSchemaInPrompt, options: options)

        // Tool-calling loop.
        var iterations = 0
        while iterations < 8, let call = detectToolCall(text) {
            iterations += 1
            let output = try await invokeTool(named: call.name, arguments: call.arguments)
            appendToolOutput(name: call.name, output: output)
            // Ask the model to continue now that it has the tool result.
            text = try await callModel(backend: backend, currentPrompt: nil, schema: schema, includeSchemaInPrompt: includeSchemaInPrompt, options: options)
        }

        let raw: GeneratedContent
        if schema != nil {
            do { raw = try GeneratedContent(json: extractJSON(text)) }
            catch { throw GenerationError.decodingFailure(.init(debugDescription: "Model output was not valid JSON for the requested schema: \(error)")) }
        } else {
            raw = GeneratedContent(kind: .string(text))
        }
        appendResponse(text)
        let slice = lock.withLock { _entries[startIndex..<_entries.count] }
        return (raw, slice)
    }

    private func callModel(
        backend: any ModelBackend,
        currentPrompt: String?,
        schema: GenerationSchema?,
        includeSchemaInPrompt: Bool,
        options: GenerationOptions
    ) async throws -> String {
        let request = makeRequest(prompt: currentPrompt ?? "", schema: schema, includeSchemaInPrompt: includeSchemaInPrompt, options: options)
        return try await backend.generate(request)
    }

    internal func makeRequest(
        prompt: String,
        schema: GenerationSchema?,
        includeSchemaInPrompt: Bool,
        options: GenerationOptions
    ) -> GenerationRequest {
        let (system, history) = lock.withLock { (systemText(schema: schema, includeSchemaInPrompt: includeSchemaInPrompt), _messages) }
        return GenerationRequest(
            instructions: system,
            history: history,
            prompt: prompt,
            options: options,
            schema: schema
        )
    }

    // Instructions + tool preamble + optional schema text.
    private func systemText(schema: GenerationSchema?, includeSchemaInPrompt: Bool) -> String {
        var parts: [String] = []
        if let baseInstructions, !baseInstructions.text.isEmpty { parts.append(baseInstructions.text) }
        if !tools.isEmpty {
            let list = tools.map { t in
                "- \(t.name): \(t.description)\n  arguments schema: \(t.parameters.jsonSchema)"
            }.joined(separator: "\n")
            parts.append("""
            You may call tools. Available tools:
            \(list)
            To call a tool, reply with ONLY a JSON object of the form \
            {"tool_call": {"name": "<tool>", "arguments": { ... }}}. \
            After you receive the tool result, answer the user normally.
            """)
        }
        if let schema, includeSchemaInPrompt {
            parts.append("Respond with ONLY a JSON value matching this schema:\n\(schema.jsonSchema)")
        }
        return parts.joined(separator: "\n\n")
    }

    // MARK: Tool calling

    private struct DetectedToolCall { let name: String; let arguments: GeneratedContent }

    private func detectToolCall(_ text: String) -> DetectedToolCall? {
        guard let data = extractJSON(text).data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let call = obj["tool_call"] as? [String: Any],
              let name = call["name"] as? String else { return nil }
        let argsAny = call["arguments"] ?? [String: Any]()
        let argsJSON = (try? JSONSerialization.data(withJSONObject: argsAny)).flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
        let content = (try? GeneratedContent(json: argsJSON)) ?? GeneratedContent(kind: .structure(properties: [:], orderedKeys: []))
        return DetectedToolCall(name: name, arguments: content)
    }

    private func invokeTool(named name: String, arguments: GeneratedContent) async throws -> String {
        guard let tool = tools.first(where: { $0.name == name }) else {
            throw GenerationError.decodingFailure(.init(debugDescription: "Model called unknown tool '\(name)'."))
        }
        do {
            return try await tool._invokeErased(arguments)
        } catch {
            throw ToolCallError(tool: tool, underlyingError: error)
        }
    }

    // MARK: Transcript / message bookkeeping

    internal func appendPrompt(_ text: String, options: GenerationOptions, schema: GenerationSchema?) {
        lock.withLock {
            _entries.append(.prompt(.init(segments: [.text(.init(content: text))], options: options)))
            _messages.append(.init(role: .user, text: text))
        }
    }

    internal func appendResponse(_ text: String) {
        lock.withLock {
            _entries.append(.response(.init(assetIDs: [], segments: [.text(.init(content: text))])))
            _messages.append(.init(role: .assistant, text: text))
        }
    }

    private func appendToolOutput(name: String, output: String) {
        lock.withLock {
            _entries.append(.toolOutput(.init(id: UUID().uuidString, toolName: name, segments: [.text(.init(content: output))])))
            _messages.append(.init(role: .tool, text: "Tool \(name) returned: \(output)"))
        }
    }

    internal func begin() throws -> any ModelBackend {
        try lock.withLock {
            if _isResponding {
                throw GenerationError.concurrentRequests(.init(debugDescription: "A response is already in progress on this session."))
            }
            guard let backend = OpenFoundationModels.resolvedBackend(appleReady: AppleOnDeviceBackend.isEligible) else {
                throw GenerationBackendError.noBackendConfigured
            }
            _isResponding = true
            return backend
        }
    }

    internal func end() { lock.withLock { _isResponding = false } }

    private static func messages(from transcript: Transcript) -> [GenerationMessage] {
        transcript.compactMap { entry in
            switch entry {
            case .instructions(let i): return .init(role: .system, text: Self.joinText(i.segments))
            case .prompt(let p): return .init(role: .user, text: Self.joinText(p.segments))
            case .response(let r): return .init(role: .assistant, text: Self.joinText(r.segments))
            case .toolOutput(let o): return .init(role: .tool, text: Self.joinText(o.segments))
            case .toolCalls: return nil
            }
        }
    }

    private static func joinText(_ segments: [Transcript.Segment]) -> String {
        segments.map { seg in
            switch seg {
            case .text(let t): return t.content
            case .structure(let s): return s.content.jsonString
            }
        }.joined(separator: "\n")
    }
}
