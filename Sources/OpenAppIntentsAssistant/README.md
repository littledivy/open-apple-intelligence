# OpenAppIntentsAssistant

A **source-compatibility polyfill** for Apple's AppIntents **Assistant Schemas** — the
Apple-Intelligence / Siri subset of AppIntents (`@AssistantIntent`, `@AssistantEntity`,
`@AssistantEnum`, `AssistantSchema`, `AssistantSchemas.*`) — plus a **fully functional
in-process natural-language intent router** (`LocalAssistant`) as the realistic
"AI Siri on old devices" path.

Sibling package to [`OpenFoundationModels`](../../). Import name:
`OpenAppIntentsAssistant`. Deployment floor: **iOS 16 / macOS 13**.

```swift
import OpenAppIntentsAssistant
```

---

## What this is (and isn't)

The AppIntents framework itself ships to every supported OS. Only the **assistant
schema layer** is `@available`-gated to newer OSes (iOS 18 / macOS 15). This package
mirrors that layer with the gating **stripped**, so code annotated with the assistant
schema macros **compiles on older deployment targets**.

| Capability | Status | Notes |
|---|---|---|
| Assistant-schema **types** (`AssistantSchema`, `AssistantSchemas.*` domains) | ✅ Functional | Carry the verbatim Apple schema identifiers; used by the router. |
| Assistant-schema **protocols** (`AssistantSchemaIntent/Entity/Enum`) | ✅ Functional | Real protocol witnesses. |
| `@AssistantIntent` / `@AssistantEntity` / `@AssistantEnum` **macros** | ✅ Functional | Expand to real conformances + a runtime-derived `__assistantSchemaIdentifier`. |
| **`LocalAssistant`** utterance → intent → parameters → `perform()` | ✅ Functional | The primary deliverable. Uses `OpenFoundationModels` guided generation. |
| Zero-config operation | ✅ Functional | Installs a deterministic on-device backend automatically. |
| **System Siri / Assistant routing** | ❌ Impossible | No public hook exists to register these with Apple's system Assistant. |

The one thing that genuinely **cannot** be polyfilled is routing into the OS system
Assistant surface. Everything else works in-process.

---

## 1. Source compatibility (the schema surface)

This is a self-contained module — it deliberately does **not** `import AppIntents`, so
the mirrored `AssistantSchema*` types never collide with Apple's real ones on a new OS.
It provides a minimal AppIntents base surface (`AppIntent`, `AppEntity`, `AppEnum`,
`ShowInAppSearchResultsIntent`, `LocalizedStringResource`, `TypeDisplayRepresentation`)
just large enough for the assistant-schema shape.

### Types & protocols mirrored (from `spec/AppIntents.swiftinterface`)

- `struct AssistantSchema` — carries a stable schema `identifier`.
- `enum AssistantSchemas` with marker protocols `Model` / `Intent` / `Entity` / `Enum`
  and value types `IntentSchema` / `EntitySchema` / `EnumSchema`.
- **15 domain namespaces**, each exposing a selector + member schemas with the exact
  identifiers Apple ships:
  `Assistant`, `Books`, `Browser`, `Camera`, `Files`, `Journal`, `Mail`, `Photos`,
  `Presentation`, `Reader`, `Spreadsheet`, `System`, `VisualIntelligence`,
  `Whiteboard`, `WordProcessor`.
  e.g. `.mail.createDraft` → `IntentSchema("CreateDraftIntent")`,
  `.files.file` → `EntitySchema("FileEntity")`,
  `.books.theme` → `EnumSchema("BookTheme")`.
- `protocol AssistantIntent : AppIntent`, `AssistantEntity : AppEntity`,
  `AssistantEnum : AppEnum`.
- `protocol AssistantSchemaIntent`, `AssistantSchemaEntity`, `AssistantSchemaEnum`
  (each with `static var isAssistantOnly`).

### Macros mirrored

```swift
@attached(member, names: named(__assistantSchemaIdentifier))
@attached(extension, conformances: AssistantSchemaIntent, ShowInAppSearchResultsIntent, SchemaCarryingIntent)
public macro AssistantIntent<T: AssistantSchemas.Intent>(schema: T)

@attached(member, names: named(__assistantSchemaIdentifier))
@attached(extension, conformances: AssistantSchemaEntity, SchemaCarryingEntity)
public macro AssistantEntity<T: AssistantSchemas.Entity>(schema: T)

@attached(member, names: named(__assistantSchemaIdentifier))
@attached(extension, conformances: AssistantSchemaEnum, SchemaCarryingEnum)
public macro AssistantEnum<T: AssistantSchemas.Enum>(schema: T)
```

These are **not empty pass-throughs**. Each expands to:
1. A real conformance extension (`AssistantSchemaIntent`, etc.).
2. A `static var __assistantSchemaIdentifier: String` that evaluates the schema
   argument at runtime (`AssistantSchema(<expr>).identifier`), so the recorded
   identifier is exactly the one the schema value carries — the same string the
   `LocalAssistant` registry keys off.

```swift
@AssistantIntent(schema: .mail.createDraft)
struct CreateDraftIntent: ParameterizedAssistantIntent {
    static var assistantDescription: String { "Create a new email draft." }
    static var assistantParameters: [AssistantParameter] {
        [AssistantParameter(name: "subject", kind: .string) { intent, value in
            var i = intent as! CreateDraftIntent
            if let s = value.stringValue { i.subject = s }
            return i
        }]
    }
    var subject = ""
    init() {}
    func perform() async throws -> IntentResultValue {
        .result(dialog: "Draft: \(subject)")
    }
}

// CreateDraftIntent.__assistantSchemaIdentifier == "CreateDraftIntent"
```

---

## 2. `LocalAssistant` — the functional "AI Siri on old devices" path

Given a natural-language utterance and a set of registered assistant intents,
`LocalAssistant` uses `OpenFoundationModels` guided generation to:

**(a)** select the correct intent → **(b)** fill its parameters from the utterance →
**(c)** invoke `perform()` → **(d)** return the result.

```swift
let assistant = LocalAssistant()
await assistant.register(CreateDraftIntent.self)
await assistant.register(CreateFolderIntent.self)

let result = try await assistant.handle("Create a draft email about \"Team lunch\"")
// result.selectedIntent            == "CreateDraftIntent"
// result.filledParameters["subject"]?.stringValue == "Team lunch"
// result.dialog                    == "Draft created: subject=Team lunch ..."
```

### How it works

- Builds a `DynamicGenerationSchema`: an `intent` field constrained to the registered
  identifiers (`anyOf`), plus a `parameters` object with every candidate parameter.
- Sends the utterance + an intent catalog through a `LanguageModelSession` with that
  schema (guided generation), decodes the structured reply, applies each decoded value
  to a fresh intent instance via its parameter setters, then `await`s `perform()`.

### Zero configuration (works out of the box)

On the first `handle(_:)`, if you have not configured a backend, `LocalAssistant`
installs a **`HeuristicAssistantBackend`** as an `.automatic(fallback:)` — a real,
deterministic, dependency-free on-device router that scores intents by token overlap
and extracts parameters heuristically. No LLM, no network, no setup required.

Because it registers as the *fallback*, Apple's real on-device model is still preferred
when the device is eligible.

### Plugging in a real LLM

For higher-quality selection/extraction, configure any `OpenFoundationModels` backend
(llama.cpp / OpenAI-compatible) before handling, and disable the auto-bootstrap:

```swift
OpenFoundationModels.configureLocalServer()          // llama.cpp on :8091
let assistant = LocalAssistant()
await assistant.setAutoConfiguresBackend(false)      // keep your backend
await assistant.register(CreateDraftIntent.self)
let result = try await assistant.handle("draft a note to the team")
```

Both backends satisfy the same JSON contract, so the router code path is identical.

---

## 3. What's impossible

**Routing into the system Siri / Assistant.** Apple's real macros register a type with
the on-device Assistant so "Hey Siri, …" can invoke it. There is no public API to do
that on any OS, new or old. `LocalAssistant` is *your own* assistant running against a
model you control — not a hook into Apple's. This is a hard platform limitation, not a
polyfill shortcut.

---

## Testing

```
cd Frameworks/AppIntentsAssistant && swift test
```

Offline, deterministic, no network. Covers:
- **Macro expansion** — schema identifiers derived from `.domain.member`, real
  conformances (`AssistantSchemaIntent` / `Entity` / `Enum`, `SchemaCarrying*`).
- **Domain identifiers** match the spec verbatim.
- **End-to-end zero-config** — utterance → intent selected → parameters filled →
  `perform()` executed → dialog returned.
- **End-to-end with a configured backend** — decodes real structured model output.
```
