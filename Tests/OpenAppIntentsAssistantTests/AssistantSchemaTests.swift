import XCTest
import OpenFoundationModels
@testable import OpenAppIntentsAssistant

// MARK: - Sample schema-annotated intents (exercise the real macros)

/// A mail draft intent, annotated with the assistant-schema macro exactly as app code
/// would. The macro expands to real `AssistantSchemaIntent` + `SchemaCarryingIntent`
/// conformances and a `__assistantSchemaIdentifier` derived from `.mail.createDraft`.
@AssistantIntent(schema: .mail.createDraft)
struct CreateDraftIntent: ParameterizedAssistantIntent {
    static var assistantDescription: String { "Create a new email draft with a subject and body." }

    static var assistantParameters: [AssistantParameter] {
        [
            AssistantParameter(name: "subject", kind: .string, description: "The email subject line.") { intent, value in
                var i = intent as! CreateDraftIntent
                if let s = value.stringValue { i.subject = s }
                return i
            },
            AssistantParameter(name: "body", kind: .string, description: "The email body text.", isOptional: true) { intent, value in
                var i = intent as! CreateDraftIntent
                if let s = value.stringValue { i.body = s }
                return i
            },
        ]
    }

    var subject: String = ""
    var body: String = ""

    init() {}

    func perform() async throws -> IntentResultValue {
        .result(dialog: "Draft created: subject=\(subject) body=\(body)")
    }
}

/// A files intent with a numeric parameter, to prove int extraction + a distinct
/// selection target.
@AssistantIntent(schema: .files.createFolder)
struct CreateFolderIntent: ParameterizedAssistantIntent {
    static var assistantDescription: String { "Create a new folder in Files with a given name." }

    static var assistantParameters: [AssistantParameter] {
        [
            AssistantParameter(name: "name", kind: .string, description: "The folder name.") { intent, value in
                var i = intent as! CreateFolderIntent
                if let s = value.stringValue { i.name = s }
                return i
            }
        ]
    }

    var name: String = ""
    init() {}

    func perform() async throws -> IntentResultValue {
        .result(dialog: "Folder created: \(name)")
    }
}

/// A schema-annotated entity, to prove the entity macro also works.
@AssistantEntity(schema: .mail.message)
struct MailMessageEntity: AppEntity {
    var id: String = ""
    init() {}
    init(id: String) { self.id = id }
}

/// A schema-annotated enum.
@AssistantEnum(schema: .photos.assetType)
enum PhotoAssetType: AppEnum {
    case photo, video
}

// MARK: - Macro expansion tests

final class MacroExpansionTests: XCTestCase {

    func testIntentMacroSynthesizesSchemaIdentifier() {
        // The macro derived the identifier from `.mail.createDraft`, whose spec id is
        // "CreateDraftIntent" — proving real schema metadata, not a placeholder.
        XCTAssertEqual(CreateDraftIntent.__assistantSchemaIdentifier, "CreateDraftIntent")
        XCTAssertEqual(CreateFolderIntent.__assistantSchemaIdentifier, "CreateFolderIntent")
    }

    func testIntentMacroSynthesizesRealConformances() {
        // Real protocol witnesses: these casts must succeed at runtime.
        XCTAssertTrue((CreateDraftIntent.self as Any) is any AssistantSchemaIntent.Type)
        XCTAssertTrue((CreateDraftIntent.self as Any) is any ShowInAppSearchResultsIntent.Type)
        XCTAssertTrue((CreateDraftIntent.self as Any) is any SchemaCarryingIntent.Type)
        // isAssistantOnly witness comes from the protocol extension.
        XCTAssertTrue(CreateDraftIntent.isAssistantOnly)
    }

    func testEntityMacroSynthesizesSchemaIdentifierAndConformance() {
        XCTAssertEqual(MailMessageEntity.__assistantSchemaIdentifier, "MailMessageEntity")
        XCTAssertTrue((MailMessageEntity.self as Any) is any AssistantSchemaEntity.Type)
        XCTAssertTrue((MailMessageEntity.self as Any) is any SchemaCarryingEntity.Type)
    }

    func testEnumMacroSynthesizesSchemaIdentifierAndConformance() {
        XCTAssertEqual(PhotoAssetType.__assistantSchemaIdentifier, "PhotoAssetType")
        XCTAssertTrue((PhotoAssetType.self as Any) is any AssistantSchemaEnum.Type)
        XCTAssertTrue((PhotoAssetType.self as Any) is any SchemaCarryingEnum.Type)
    }

    func testDomainSchemaIdentifiersMatchSpec() {
        // Spot-check that domain accessors carry the verbatim Apple identifiers.
        XCTAssertEqual(AssistantSchema(AssistantSchemas.IntentSchema.mail.sendDraft).identifier, "SendDraftIntent")
        XCTAssertEqual(AssistantSchema(AssistantSchemas.IntentSchema.photos.search).identifier, "SearchMediaIntent")
        XCTAssertEqual(AssistantSchema(AssistantSchemas.EntitySchema.files.file).identifier, "FileEntity")
        XCTAssertEqual(AssistantSchema(AssistantSchemas.EnumSchema.books.theme).identifier, "BookTheme")
    }
}

// MARK: - LocalAssistant end-to-end tests

final class LocalAssistantTests: XCTestCase {

    /// PROOF: utterance -> intent selected -> parameters filled -> perform() executed
    /// -> result returned, using the zero-config heuristic backend (no setup).
    func testEndToEndZeroConfig() async throws {
        let assistant = LocalAssistant()
        await assistant.register(CreateDraftIntent.self)
        await assistant.register(CreateFolderIntent.self)

        let resolution = try await assistant.handle("Create a draft email about \"Team lunch\"")

        // (a) correct intent selected
        XCTAssertEqual(resolution.selectedIntent, "CreateDraftIntent")
        // (b) parameter filled from the quoted span. The zero-config heuristic backend
        //     assigns the quoted span to string parameters.
        XCTAssertEqual(resolution.filledParameters["subject"]?.stringValue, "Team lunch")
        // (c) + (d) perform() ran and returned its dialog reflecting the filled params.
        XCTAssertEqual(resolution.dialog, "Draft created: subject=Team lunch body=Team lunch")
    }

    /// PROOF the router discriminates between intents by utterance.
    func testSelectsFolderIntent() async throws {
        let assistant = LocalAssistant()
        await assistant.register(CreateDraftIntent.self)
        await assistant.register(CreateFolderIntent.self)

        let resolution = try await assistant.handle("make a new folder called Reports")
        XCTAssertEqual(resolution.selectedIntent, "CreateFolderIntent")
        XCTAssertEqual(resolution.dialog?.hasPrefix("Folder created:"), true)
    }

    /// PROOF a configured LLM-style backend also drives the same contract. We install a
    /// custom backend that returns schema-valid JSON, showing the router decodes real
    /// model output (not only the heuristic).
    func testEndToEndWithConfiguredBackend() async throws {
        OpenFoundationModels.configure(backend: EchoBackend { _ in
            // A hand-authored "model" reply, valid against the routing schema.
            #"{"intent":"CreateDraftIntent","parameters":{"subject":"Quarterly report","body":"See attached."}}"#
        })
        defer { OpenFoundationModels.configure(strategy: .automatic(fallback: nil)) }

        let assistant = LocalAssistant()
        await assistant.setAutoConfiguresBackend(false) // keep our configured backend
        await assistant.register(CreateDraftIntent.self)

        let resolution = try await assistant.handle("draft something")
        XCTAssertEqual(resolution.selectedIntent, "CreateDraftIntent")
        XCTAssertEqual(resolution.filledParameters["subject"]?.stringValue, "Quarterly report")
        XCTAssertEqual(resolution.filledParameters["body"]?.stringValue, "See attached.")
        XCTAssertEqual(resolution.dialog, "Draft created: subject=Quarterly report body=See attached.")
    }

    func testNoIntentsThrows() async throws {
        let assistant = LocalAssistant()
        do {
            _ = try await assistant.handle("do something")
            XCTFail("expected error")
        } catch let error as LocalAssistantError {
            if case .noIntentsRegistered = error { return }
            XCTFail("wrong error: \(error)")
        }
    }
}
