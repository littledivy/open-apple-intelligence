import Foundation

// Nested result/error types + the streaming engine + tool helpers for
// LanguageModelSession. Mirrors `FoundationModels.LanguageModelSession.*`.
public extension LanguageModelSession {

    // MARK: Response

    /// The result of a completed request. Mirrors `LanguageModelSession.Response`.
    struct Response<Content> where Content: Generable {
        /// The generated value (a `String`, a `GeneratedContent`, or a typed `Generable`).
        public let content: Content
        /// The raw structured content the model produced.
        public let rawContent: GeneratedContent
        /// The transcript entries added by this turn.
        public let transcriptEntries: ArraySlice<Transcript.Entry>

        public init(content: Content, rawContent: GeneratedContent, transcriptEntries: ArraySlice<Transcript.Entry>) {
            self.content = content
            self.rawContent = rawContent
            self.transcriptEntries = transcriptEntries
        }
    }

    // MARK: ResponseStream

    /// An async sequence of cumulative snapshots. Mirrors
    /// `LanguageModelSession.ResponseStream`.
    struct ResponseStream<Content>: AsyncSequence where Content: Generable {
        public struct Snapshot {
            /// The partially-generated value so far.
            public var content: Content.PartiallyGenerated
            /// The raw structured content so far.
            public var rawContent: GeneratedContent
        }

        public typealias Element = Snapshot
        let stream: AsyncThrowingStream<Snapshot, Error>

        public struct AsyncIterator: AsyncIteratorProtocol {
            var base: AsyncThrowingStream<Snapshot, Error>.Iterator
            public mutating func next() async throws -> Snapshot? { try await base.next() }
        }

        public func makeAsyncIterator() -> AsyncIterator {
            AsyncIterator(base: stream.makeAsyncIterator())
        }

        /// Drain the stream and return the final, fully-decoded response.
        public func collect() async throws -> Response<Content> {
            var last: Snapshot?
            for try await snap in stream { last = snap }
            guard let last else {
                throw GenerationError.decodingFailure(.init(debugDescription: "empty response stream"))
            }
            return Response(content: try Content(last.rawContent), rawContent: last.rawContent, transcriptEntries: [])
        }
    }

    // MARK: GenerationError

    /// Errors thrown during generation. Mirrors `LanguageModelSession.GenerationError`.
    enum GenerationError: Error, LocalizedError {
        case exceededContextWindowSize(Context)
        case assetsUnavailable(Context)
        case guardrailViolation(Context)
        case unsupportedGuide(Context)
        case unsupportedLanguageOrLocale(Context)
        case decodingFailure(Context)
        case rateLimited(Context)
        case concurrentRequests(Context)
        case refusal(Refusal, Context)

        public struct Context: Sendable {
            public let debugDescription: String
            public init(debugDescription: String) { self.debugDescription = debugDescription }
        }

        public struct Refusal: Sendable {
            public let transcriptEntries: [Transcript.Entry]
            public init(transcriptEntries: [Transcript.Entry]) {
                self.transcriptEntries = transcriptEntries
            }
            private var explanationText: String {
                transcriptEntries.reversed().compactMap { entry -> String? in
                    if case .response(let r) = entry {
                        return r.segments.compactMap { if case .text(let t) = $0 { return t.content } else { return nil } }.joined()
                    }
                    return nil
                }.first ?? "The model declined to respond."
            }
            public var explanation: Response<String> {
                get async throws {
                    let raw = GeneratedContent(kind: .string(explanationText))
                    return Response(content: explanationText, rawContent: raw, transcriptEntries: [])
                }
            }
        }

        public var errorDescription: String? {
            switch self {
            case .exceededContextWindowSize(let c), .assetsUnavailable(let c), .guardrailViolation(let c),
                 .unsupportedGuide(let c), .unsupportedLanguageOrLocale(let c), .decodingFailure(let c),
                 .rateLimited(let c), .concurrentRequests(let c):
                return c.debugDescription
            case .refusal(_, let c):
                return c.debugDescription
            }
        }
    }

    // MARK: ToolCallError

    /// Wraps an error thrown while a tool was executing. Mirrors
    /// `LanguageModelSession.ToolCallError`.
    struct ToolCallError: Error, LocalizedError {
        public var tool: any Tool
        public var underlyingError: any Error
        public init(tool: any Tool, underlyingError: any Error) {
            self.tool = tool
            self.underlyingError = underlyingError
        }
        public var errorDescription: String? {
            "Tool '\(tool.name)' failed: \(underlyingError)"
        }
    }

    // MARK: Streaming engine

    internal func makeStream<Content: Generable>(
        prompt: String,
        schema: GenerationSchema?,
        includeSchemaInPrompt: Bool,
        options: GenerationOptions,
        _ type: @escaping () -> Content.Type
    ) -> ResponseStream<Content> {
        let stream = AsyncThrowingStream<ResponseStream<Content>.Snapshot, Error> { continuation in
            let task = Task {
                do {
                    let backend = try self.begin()
                    defer { self.end() }
                    self.appendPrompt(prompt, options: options, schema: schema)
                    let request = self.makeRequest(prompt: prompt, schema: schema, includeSchemaInPrompt: includeSchemaInPrompt, options: options)

                    var lastText = ""
                    for try await snapshotText in backend.stream(request) {
                        if Task.isCancelled { break }
                        lastText = snapshotText
                        if let snap = Self.snapshot(Content.self, text: snapshotText, schema: schema) {
                            continuation.yield(snap)
                        }
                    }
                    self.appendResponse(lastText)

                    // Guarantee a final, fully-decoded snapshot.
                    let raw = schema != nil
                        ? try GeneratedContent(json: extractJSON(lastText))
                        : GeneratedContent(kind: .string(lastText))
                    continuation.yield(.init(content: try Content.PartiallyGenerated(raw), rawContent: raw))
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
        return ResponseStream(stream: stream)
    }

    private static func snapshot<Content: Generable>(
        _ type: Content.Type, text: String, schema: GenerationSchema?
    ) -> ResponseStream<Content>.Snapshot? {
        let raw: GeneratedContent
        if schema != nil {
            guard let parsed = try? GeneratedContent(json: extractJSON(text)) else { return nil }
            raw = parsed
        } else {
            raw = GeneratedContent(kind: .string(text))
        }
        let content: Content.PartiallyGenerated
        do { content = try Content.PartiallyGenerated(raw) } catch { return nil }
        return ResponseStream<Content>.Snapshot(content: content, rawContent: raw)
    }
}

// MARK: - Tool erasure

extension Tool {
    /// Decode arguments from generated content, invoke the tool, return its output text.
    /// Callable on `any Tool` because the signature exposes no associated types.
    func _invokeErased(_ content: GeneratedContent) async throws -> String {
        let args = try Arguments(content)
        let output = try await call(arguments: args)
        return output.promptRepresentation.text
    }
}

// MARK: - JSON extraction

/// Pull the JSON value out of a model reply that may be fenced or wrapped in prose.
func extractJSON(_ text: String) -> String {
    var s = text.trimmingCharacters(in: .whitespacesAndNewlines)
    if let fence = s.range(of: "```") {
        let after = s[fence.upperBound...]
        // drop an optional language tag line
        let body = after.drop(while: { $0 != "\n" }).dropFirst()
        if let close = body.range(of: "```") {
            s = String(body[..<close.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    // Bracket-match the outermost object/array.
    guard let start = s.firstIndex(where: { $0 == "{" || $0 == "[" }) else { return s }
    let open = s[start], close: Character = open == "{" ? "}" : "]"
    var depth = 0, inString = false, escaped = false
    var idx = start
    while idx < s.endIndex {
        let c = s[idx]
        if escaped { escaped = false }
        else if c == "\\" { escaped = true }
        else if c == "\"" { inString.toggle() }
        else if !inString {
            if c == open { depth += 1 }
            else if c == close { depth -= 1; if depth == 0 { return String(s[start...idx]) } }
        }
        idx = s.index(after: idx)
    }
    return String(s[start...])
}
