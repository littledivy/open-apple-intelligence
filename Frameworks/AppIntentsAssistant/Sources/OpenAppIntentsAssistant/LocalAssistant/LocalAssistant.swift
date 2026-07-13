import Foundation
import OpenFoundationModels

// MARK: - LocalAssistant
//
// The realistic "AI Siri on old devices" path. Given a natural-language utterance and
// a set of registered assistant intents, LocalAssistant uses OpenFoundationModels
// guided generation to:
//   (a) SELECT the correct intent,
//   (b) FILL its parameters from the utterance,
//   (c) INVOKE `perform()`,
//   (d) RETURN the result.
//
// This is fully functional and in-process. It is NOT the system Siri surface — there
// is no public hook to route these into Apple's Assistant. LocalAssistant is your own
// assistant, running against whatever OpenFoundationModels backend is configured.
//
// ZERO CONFIG: if no OpenFoundationModels backend has been configured, LocalAssistant
// installs a deterministic on-device `HeuristicAssistantBackend` (see that file) the
// first time it runs, so `handle(_:)` works out of the box with no setup. Configure a
// real LLM backend (llama.cpp / OpenAI-compatible) via `OpenFoundationModels.configure`
// for higher-quality selection and extraction.

/// A registration record for one intent the assistant can route to.
public struct RegisteredIntent: Sendable {
    /// The schema identifier (from the `@AssistantIntent(schema:)` macro), e.g.
    /// `"CreateDraftIntent"`. Used as the intent's selection id.
    public let schemaIdentifier: String
    /// A natural-language description used to help the model choose this intent.
    public let description: String
    /// The parameters that can be filled from the utterance.
    public let parameters: [AssistantParameter]
    /// Constructs a fresh, empty intent instance to fill and perform.
    let makeInstance: @Sendable () -> any AssistantSchemaIntent

    init(
        schemaIdentifier: String,
        description: String,
        parameters: [AssistantParameter],
        makeInstance: @escaping @Sendable () -> any AssistantSchemaIntent
    ) {
        self.schemaIdentifier = schemaIdentifier
        self.description = description
        self.parameters = parameters
        self.makeInstance = makeInstance
    }
}

/// The outcome of handling an utterance.
public struct AssistantResolution: Sendable {
    /// The schema identifier of the intent that was selected and run.
    public let selectedIntent: String
    /// The parameter values that were extracted and applied.
    public let filledParameters: [String: AssistantParameterValue]
    /// The dialog returned by the intent's `perform()`, if any.
    public let dialog: String?
}

public enum LocalAssistantError: Error, CustomStringConvertible {
    case noIntentsRegistered
    case couldNotSelectIntent(raw: String)
    case unknownIntentSelected(id: String)

    public var description: String {
        switch self {
        case .noIntentsRegistered:
            return "No intents are registered with the LocalAssistant."
        case .couldNotSelectIntent(let raw):
            return "The model reply did not name a known intent. Raw reply: \(raw)"
        case .unknownIntentSelected(let id):
            return "The model selected intent '\(id)', which is not registered."
        }
    }
}

/// An in-process natural-language router over registered assistant intents.
public actor LocalAssistant {
    private var intents: [String: RegisteredIntent] = [:]
    private let instructions: String

    /// When `true` (default), the first `handle(_:)` installs the deterministic
    /// on-device `HeuristicAssistantBackend` as the OpenFoundationModels backend so the
    /// assistant works with zero configuration. Set to `false` if you have already
    /// called `OpenFoundationModels.configure(...)` with your own LLM backend and do
    /// not want it replaced.
    public var autoConfiguresBackend: Bool = true

    public init(
        instructions: String = "You are an on-device assistant that maps a user request to exactly one app intent and its parameters."
    ) {
        self.instructions = instructions
    }

    /// Enables or disables the zero-config backend bootstrap (see `autoConfiguresBackend`).
    public func setAutoConfiguresBackend(_ enabled: Bool) {
        autoConfiguresBackend = enabled
    }

    // MARK: Registration

    /// Registers a `ParameterizedAssistantIntent` type. Its schema identifier is read
    /// from the `@AssistantIntent` macro-synthesized witness, its parameters and
    /// description from the protocol. Fully functional — the registered factory builds
    /// real instances that `handle(_:)` fills and performs.
    public func register<I>(_ type: I.Type) where I: ParameterizedAssistantIntent, I: SchemaCarryingIntent {
        let record = RegisteredIntent(
            schemaIdentifier: I.__assistantSchemaIdentifier,
            description: I.assistantDescription,
            parameters: I.assistantParameters,
            makeInstance: { I() }
        )
        intents[record.schemaIdentifier] = record
    }

    /// Registers a plain (zero-parameter) intent type carrying a schema, e.g. a toggle.
    public func register<I>(plain type: I.Type) where I: AssistantSchemaIntent, I: SchemaCarryingIntent {
        let record = RegisteredIntent(
            schemaIdentifier: I.__assistantSchemaIdentifier,
            description: "\(I.self)",
            parameters: [],
            makeInstance: { I() }
        )
        intents[record.schemaIdentifier] = record
    }

    public var registeredIntentIdentifiers: [String] { intents.keys.sorted() }

    // MARK: Handling

    /// Routes an utterance: selects an intent, fills parameters, invokes `perform()`,
    /// returns the resolution. This is the primary end-to-end path.
    @discardableResult
    public func handle(_ utterance: String) async throws -> AssistantResolution {
        guard !intents.isEmpty else { throw LocalAssistantError.noIntentsRegistered }

        if autoConfiguresBackend {
            LocalAssistant.installDefaultBackendOnce()
        }

        let ordered = intents.values.sorted { $0.schemaIdentifier < $1.schemaIdentifier }
        let schema = try Self.buildSchema(for: ordered)
        let prompt = Self.buildPrompt(utterance: utterance, intents: ordered)

        let session = LanguageModelSession(instructions: instructions)
        let response = try await session.respond(to: prompt, schema: schema, includeSchemaInPrompt: true)
        let content = response.content

        // (a) Which intent?
        let selectedId = try content.value(String.self, forProperty: "intent")
        guard let chosen = intents[selectedId] else {
            // Tolerate case/spacing drift from a real LLM: match case-insensitively.
            if let match = ordered.first(where: { $0.schemaIdentifier.caseInsensitiveCompare(selectedId) == .orderedSame }) {
                return try await Self.fill(match, from: content)
            }
            throw LocalAssistantError.unknownIntentSelected(id: selectedId)
        }

        // (b) Fill + (c) perform + (d) return.
        return try await Self.fill(chosen, from: content)
    }

    // MARK: Internal machinery

    private static func fill(
        _ record: RegisteredIntent,
        from content: GeneratedContent
    ) async throws -> AssistantResolution {
        var instance = record.makeInstance()
        var filled: [String: AssistantParameterValue] = [:]

        for param in record.parameters {
            guard let value = try decodeParameter(param, from: content) else { continue }
            instance = param.apply(instance, value)
            filled[param.name] = value
        }

        let result = try await instance.perform()
        return AssistantResolution(
            selectedIntent: record.schemaIdentifier,
            filledParameters: filled,
            dialog: result.dialog
        )
    }

    /// Decodes one parameter from the model's structured reply. Parameters are grouped
    /// under a `parameters` object keyed by intent-qualified names to avoid collisions.
    private static func decodeParameter(
        _ param: AssistantParameter,
        from content: GeneratedContent
    ) throws -> AssistantParameterValue? {
        let params: GeneratedContent
        do {
            params = try content.value(GeneratedContent.self, forProperty: "parameters")
        } catch {
            return nil
        }
        switch param.kind {
        case .string:
            guard let v: String = try? params.value(String.self, forProperty: param.name), !v.isEmpty else { return nil }
            return .string(v)
        case .int:
            guard let v: Int = try? params.value(Int.self, forProperty: param.name) else { return nil }
            return .int(v)
        case .double:
            guard let v: Double = try? params.value(Double.self, forProperty: param.name) else { return nil }
            return .double(v)
        case .bool:
            guard let v: Bool = try? params.value(Bool.self, forProperty: param.name) else { return nil }
            return .bool(v)
        }
    }

    /// Builds a dynamic generation schema: `intent` chosen from the registered ids,
    /// plus a `parameters` object with every candidate parameter (all optional).
    static func buildSchema(for intents: [RegisteredIntent]) throws -> GenerationSchema {
        let intentChoice = DynamicGenerationSchema(
            name: "intent",
            description: "The identifier of the single best-matching intent.",
            anyOf: intents.map(\.schemaIdentifier)
        )

        var seen = Set<String>()
        var paramProps: [DynamicGenerationSchema.Property] = []
        for intent in intents {
            for param in intent.parameters where !seen.contains(param.name) {
                seen.insert(param.name)
                paramProps.append(
                    DynamicGenerationSchema.Property(
                        name: param.name,
                        description: param.description,
                        schema: primitiveSchema(for: param.kind),
                        isOptional: true
                    )
                )
            }
        }
        let parameters = DynamicGenerationSchema(
            name: "parameters",
            description: "Values extracted from the utterance for the selected intent. Leave irrelevant fields absent.",
            properties: paramProps
        )

        let root = DynamicGenerationSchema(
            name: "AssistantRouting",
            description: "Chosen intent and its extracted parameters.",
            properties: [
                DynamicGenerationSchema.Property(name: "intent", description: "The selected intent identifier.", schema: intentChoice),
                DynamicGenerationSchema.Property(name: "parameters", description: "Extracted parameter values.", schema: parameters, isOptional: true),
            ]
        )
        return try GenerationSchema(root: root, dependencies: [])
    }

    private static func primitiveSchema(for kind: AssistantParameterKind) -> DynamicGenerationSchema {
        switch kind {
        case .string: return DynamicGenerationSchema(type: String.self)
        case .int:    return DynamicGenerationSchema(type: Int.self)
        case .double: return DynamicGenerationSchema(type: Double.self)
        case .bool:   return DynamicGenerationSchema(type: Bool.self)
        }
    }

    /// Builds the human-readable prompt. Also emits machine-readable markers that the
    /// zero-config `HeuristicAssistantBackend` parses; a real LLM ignores them and
    /// reads the natural-language catalog.
    static func buildPrompt(utterance: String, intents: [RegisteredIntent]) -> String {
        var lines: [String] = []
        lines.append("User request: \"\(utterance)\"")
        lines.append("")
        lines.append("Available intents:")
        for intent in intents {
            let params = intent.parameters.map { "\($0.name):\($0.kind.rawValue)" }.joined(separator: ", ")
            lines.append("- \(intent.schemaIdentifier): \(intent.description)" + (params.isEmpty ? "" : " [params: \(params)]"))
        }
        lines.append("")
        lines.append("Choose the single best intent and extract its parameters from the request.")
        // Machine markers for the zero-config heuristic backend.
        lines.append(HeuristicAssistantBackend.encodeCatalog(utterance: utterance, intents: intents))
        return lines.joined(separator: "\n")
    }

    // MARK: Zero-config backend bootstrap

    nonisolated(unsafe) private static var didConfigure = false
    private static let configureLock = NSLock()

    /// Installs the deterministic on-device backend as an automatic fallback the first
    /// time the assistant runs. Uses `.automatic(fallback:)`, so Apple's real
    /// on-device model is still preferred when the device is eligible; the heuristic
    /// backend only services requests when no Apple model and no app backend exist.
    /// Idempotent, and only ever runs when `autoConfiguresBackend` is left enabled.
    static func installDefaultBackendOnce() {
        configureLock.lock(); defer { configureLock.unlock() }
        guard !didConfigure else { return }
        didConfigure = true
        OpenFoundationModels.configure(fallback: HeuristicAssistantBackend())
    }
}
