import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Backend for any OpenAI-compatible `/chat/completions` endpoint: OpenAI, a local
/// llama.cpp / LM Studio / Ollama server, vLLM, etc. Supports SSE token streaming.
///
/// ```swift
/// OpenFoundationModels.configure(backend: OpenAICompatibleBackend(
///     endpoint: URL(string: "http://localhost:8091/v1")!,
///     model: "qwen3"
/// ))
/// ```
public final class OpenAICompatibleBackend: ModelBackend, @unchecked Sendable {
    public let identifier: String
    private let endpoint: URL          // base, e.g. http://host:port/v1
    private let model: String
    private let apiKey: String?
    private let session: URLSession

    public init(
        endpoint: URL,
        model: String = "default",
        apiKey: String? = nil,
        session: URLSession = .shared
    ) {
        self.endpoint = endpoint
        self.model = model
        self.apiKey = apiKey
        self.session = session
        self.identifier = "openai-compatible(\(endpoint.host ?? "?"))"
    }

    private var chatURL: URL { endpoint.appendingPathComponent("chat/completions") }

    private func makeRequest(_ body: [String: Any]) throws -> URLRequest {
        var req = URLRequest(url: chatURL)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let apiKey { req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization") }
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        return req
    }

    private func body(_ request: GenerationRequest, stream: Bool) -> [String: Any] {
        var messages: [[String: String]] = request.messages.map {
            ["role": $0.role.rawValue, "content": $0.text]
        }
        // Some servers reject an empty message list; guarantee at least the prompt.
        if messages.isEmpty { messages = [["role": "user", "content": request.prompt]] }

        var body: [String: Any] = ["model": model, "messages": messages, "stream": stream]
        if let t = request.options.temperature { body["temperature"] = t }
        if let m = request.options.maximumResponseTokens { body["max_tokens"] = m }
        switch request.options.sampling?.kind {
        case .topP(let threshold, _): body["top_p"] = threshold
        case .topK(let k, _): body["top_k"] = k
        default: break
        }
        // Guided generation: ask for JSON matching the schema. json_schema is honored by
        // OpenAI + llama.cpp; Ollama supports it too. Fall back to json_object mode.
        if let schema = request.schema,
           let schemaObj = try? JSONSerialization.jsonObject(with: Data(schema.jsonSchema.utf8)) {
            body["response_format"] = [
                "type": "json_schema",
                "json_schema": ["name": "response", "schema": schemaObj, "strict": true],
            ]
        }
        return body
    }

    public func isReady() async -> Bool {
        // Cheap reachability probe against the models list; treat any HTTP reply as ready.
        var req = URLRequest(url: endpoint.appendingPathComponent("models"))
        req.timeoutInterval = 2
        if let apiKey { req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization") }
        do {
            let (_, response) = try await session.data(for: req)
            return (response as? HTTPURLResponse) != nil
        } catch {
            return false
        }
    }

    public func generate(_ request: GenerationRequest) async throws -> String {
        let req = try makeRequest(body(request, stream: false))
        let (data, response) = try await session.data(for: req)
        try Self.checkStatus(response, data)
        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let choices = json["choices"] as? [[String: Any]],
            let message = choices.first?["message"] as? [String: Any],
            let content = message["content"] as? String
        else {
            throw GenerationBackendError.invalidResponse(String(data: data, encoding: .utf8) ?? "<binary>")
        }
        return content
    }

    public func stream(_ request: GenerationRequest) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let req = try makeRequest(body(request, stream: true))
                    let (bytes, response) = try await session.bytes(for: req)
                    try Self.checkStatus(response, nil)
                    var accumulated = ""
                    for try await line in bytes.lines {
                        guard line.hasPrefix("data:") else { continue }
                        let payload = line.dropFirst(5).trimmingCharacters(in: .whitespaces)
                        if payload == "[DONE]" { break }
                        guard
                            let d = payload.data(using: .utf8),
                            let json = try? JSONSerialization.jsonObject(with: d) as? [String: Any],
                            let choices = json["choices"] as? [[String: Any]],
                            let delta = choices.first?["delta"] as? [String: Any],
                            let piece = delta["content"] as? String
                        else { continue }
                        accumulated += piece
                        continuation.yield(accumulated)   // cumulative snapshot, matches Apple
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    private static func checkStatus(_ response: URLResponse?, _ data: Data?) throws {
        guard let http = response as? HTTPURLResponse else { return }
        guard (200..<300).contains(http.statusCode) else {
            throw GenerationBackendError.http(
                status: http.statusCode,
                body: data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            )
        }
    }
}
