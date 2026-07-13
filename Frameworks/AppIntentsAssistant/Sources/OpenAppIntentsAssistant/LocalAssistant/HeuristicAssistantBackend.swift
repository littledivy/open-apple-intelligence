import Foundation
import OpenFoundationModels

// MARK: - HeuristicAssistantBackend
//
// The zero-config, dependency-free, fully deterministic backend that makes
// `LocalAssistant.handle(_:)` work out of the box on any device with no LLM and no
// network. It is a real intent router, not a stub: it scores each registered intent
// against the utterance by token overlap (intent id + description + parameter names),
// picks the best, extracts parameter values heuristically, and returns JSON that
// satisfies the requested `GenerationSchema`.
//
// A configured LLM backend (llama.cpp / OpenAI-compatible via
// `OpenFoundationModels.configure`) replaces this and does the same job with better
// language understanding. Both produce the same structured contract.

public final class HeuristicAssistantBackend: ModelBackend, @unchecked Sendable {
    public let identifier = "assistant-heuristic"

    public init() {}

    public func generate(_ request: GenerationRequest) async throws -> String {
        guard let catalog = Self.decodeCatalog(from: request.prompt) else {
            // No routing catalog present ⇒ not a LocalAssistant request. Echo so we
            // never crash a caller that reused the fallback for plain text.
            return request.prompt
        }
        let (chosen, params) = Self.route(catalog: catalog)
        return Self.encodeReply(intent: chosen.id, parameters: params)
    }

    public func stream(_ request: GenerationRequest) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let full = try await self.generate(request)
                    continuation.yield(full)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    // MARK: Catalog encoding (shared with LocalAssistant.buildPrompt)

    struct CatalogIntent: Codable {
        let id: String
        let description: String
        /// name -> kind rawValue
        let parameters: [ParamSpec]
    }
    struct ParamSpec: Codable {
        let name: String
        let kind: String
    }
    struct Catalog: Codable {
        let utterance: String
        let intents: [CatalogIntent]
    }

    private static let marker = "<<ASSISTANT_CATALOG>>"

    static func encodeCatalog(utterance: String, intents: [RegisteredIntent]) -> String {
        let catalog = Catalog(
            utterance: utterance,
            intents: intents.map { intent in
                CatalogIntent(
                    id: intent.schemaIdentifier,
                    description: intent.description,
                    parameters: intent.parameters.map { ParamSpec(name: $0.name, kind: $0.kind.rawValue) }
                )
            }
        )
        let data = (try? JSONEncoder().encode(catalog)) ?? Data()
        return marker + (String(data: data, encoding: .utf8) ?? "")
    }

    static func decodeCatalog(from prompt: String) -> Catalog? {
        guard let range = prompt.range(of: marker) else { return nil }
        let jsonStart = range.upperBound
        // The catalog marker is emitted last in the prompt; everything after it is JSON.
        let json = String(prompt[jsonStart...]).trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(Catalog.self, from: data)
    }

    // MARK: Routing

    private static func tokens(_ s: String) -> [String] {
        s.lowercased()
            .replacingOccurrences(of: "intent", with: " ")
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            // split CamelCase-derived words further by inserting boundaries
            .flatMap { splitCamel($0) }
            .filter { $0.count > 2 }
    }

    private static func splitCamel(_ s: String) -> [String] {
        var words: [String] = []
        var current = ""
        for ch in s {
            if ch.isUppercase, !current.isEmpty {
                words.append(current); current = String(ch)
            } else {
                current.append(ch)
            }
        }
        if !current.isEmpty { words.append(current) }
        return words.map { $0.lowercased() }
    }

    /// Scores each intent by token overlap with the utterance and returns the best.
    static func route(catalog: Catalog) -> (CatalogIntent, [String: AssistantParameterValue]) {
        let uTokens = Set(tokens(catalog.utterance))
        var best = catalog.intents[0]
        var bestScore = -1
        for intent in catalog.intents {
            let idTokens = Set(tokens(intent.id))
            let descTokens = Set(tokens(intent.description))
            let paramTokens = Set(intent.parameters.flatMap { tokens($0.name) })
            let score =
                uTokens.intersection(idTokens).count * 3 +
                uTokens.intersection(descTokens).count * 2 +
                uTokens.intersection(paramTokens).count
            if score > bestScore {
                bestScore = score
                best = intent
            }
        }
        let params = extractParameters(for: best, utterance: catalog.utterance)
        return (best, params)
    }

    /// Heuristic parameter extraction. String params get the utterance (or a quoted
    /// span if present); numeric params get the first number; bool params get true
    /// when a negation is absent. Good enough for a deterministic offline demo.
    private static func extractParameters(
        for intent: CatalogIntent,
        utterance: String
    ) -> [String: AssistantParameterValue] {
        var out: [String: AssistantParameterValue] = [:]
        let quoted = firstQuotedSpan(in: utterance)
        let firstNumber = firstNumber(in: utterance)
        for param in intent.parameters {
            switch param.kind {
            case "string":
                out[param.name] = .string(quoted ?? utterance)
            case "int":
                if let n = firstNumber { out[param.name] = .int(Int(n)) }
            case "double":
                if let n = firstNumber { out[param.name] = .double(n) }
            case "bool":
                let negated = utterance.lowercased().contains(" no ") || utterance.lowercased().contains("don't") || utterance.lowercased().contains("dont")
                out[param.name] = .bool(!negated)
            default:
                break
            }
        }
        return out
    }

    private static func firstQuotedSpan(in s: String) -> String? {
        // Match text within straight or smart double quotes.
        for (open, close) in [("\"", "\""), ("“", "”"), ("'", "'")] {
            if let o = s.range(of: open) {
                let after = s[o.upperBound...]
                if let c = after.range(of: close) {
                    let span = String(after[..<c.lowerBound])
                    if !span.isEmpty { return span }
                }
            }
        }
        return nil
    }

    private static func firstNumber(in s: String) -> Double? {
        // First contiguous run of digits (with optional decimal point).
        let runs = s.unicodeScalars.split(whereSeparator: { !CharacterSet(charactersIn: "0123456789.").contains($0) })
        for run in runs {
            if let d = Double(String(String.UnicodeScalarView(run))) { return d }
        }
        return nil
    }

    // MARK: Reply encoding (JSON conforming to the routing schema)

    static func encodeReply(intent: String, parameters: [String: AssistantParameterValue]) -> String {
        var params: [String: Any] = [:]
        for (k, v) in parameters {
            switch v {
            case .string(let s): params[k] = s
            case .int(let i): params[k] = i
            case .double(let d): params[k] = d
            case .bool(let b): params[k] = b
            }
        }
        let obj: [String: Any] = ["intent": intent, "parameters": params]
        let data = (try? JSONSerialization.data(withJSONObject: obj)) ?? Data()
        return String(data: data, encoding: .utf8) ?? "{\"intent\":\"\(intent)\"}"
    }
}
