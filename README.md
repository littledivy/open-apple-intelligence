# OpenFoundationModels

Drop-in polyfill for Apple's **FoundationModels** on devices where Apple gates off
Apple Intelligence (ineligible hardware, or OS older than iOS 26 / macOS 26).

Same type names as Apple's framework, so adopting it is a one-line change:

```diff
- import FoundationModels
+ import OpenFoundationModels
```

Everything else in your code — `SystemLanguageModel`, `LanguageModelSession`,
`respond(to:)`, `streamResponse(to:)`, `GenerationOptions`, `Instructions`,
`Prompt` — compiles unchanged.

## How it resolves a model

- **Eligible device** (real FoundationModels present + available) → delegates to Apple's
  on-device model. Best quality, zero cost, private.
- **Everywhere else** → routes to a backend you configure.

```swift
import OpenFoundationModels

// Local llama.cpp / LM Studio / Ollama / vLLM, or OpenAI, or any /v1 endpoint:
OpenFoundationModels.configure(backend: OpenAICompatibleBackend(
    endpoint: URL(string: "http://localhost:8091/v1")!,
    model: "qwen3"
))

// Apple when eligible, this backend otherwise:
OpenFoundationModels.configure(fallback: OpenAICompatibleBackend(endpoint: ...))
```

If you never configure a backend, `SystemLanguageModel.default.availability` reports
`.unavailable(.modelNotReady)` on ineligible devices — the same shape your existing
fallback UI already handles.

## Usage (identical to Apple's API)

```swift
let model = SystemLanguageModel.default
guard model.isAvailable else { /* your fallback */ return }

let session = LanguageModelSession(instructions: "You are terse.")

// One-shot
let reply = try await session.respond(to: "Summarize WWDC in a line.")
print(reply.content)

// Streaming (cumulative snapshots)
for try await snapshot in session.streamResponse(to: "Write a haiku.") {
    render(snapshot)   // full text so far
}
```

## Guided generation (`@Generable`)

Same as Apple's API — define a `@Generable` type and ask the model to produce it:

```swift
@Generable
struct Person {
    @Guide(description: "the person's full name")
    var name: String
    @Guide(.range(0...130))
    var age: Int
}

let person = try await session.respond(
    to: "A person named Ada Lovelace who is 36.",
    generating: Person.self
).content        // → Person(name: "Ada Lovelace", age: 36)
```

The macro synthesizes the `GenerationSchema`; the backend is asked for schema-constrained
JSON (`response_format`), and the reply is decoded into your type. Works with fenced/prose-
wrapped JSON too.

## Tool calling

Pass tools at init; the session offers them to the model and invokes them when requested:

```swift
struct WeatherTool: Tool {
    let name = "get_weather"
    let description = "Get the current weather for a city."
    func call(arguments: WeatherArgs) async throws -> String { … }   // WeatherArgs is @Generable
}

let session = LanguageModelSession(tools: [WeatherTool()])
let reply = try await session.respond(to: "Weather in Paris?")   // tool runs, result folded in
```

## Backends

| Backend | Use |
|---|---|
| `AppleOnDeviceBackend` | Real FoundationModels; auto-selected when eligible. |
| `MLXBackend` | **On-device**, in-process (Apple Silicon) via MLX — no server. `import OpenFoundationModelsMLX` (see `Integrations/MLX/`). |
| `OpenAICompatibleBackend` | Any `/chat/completions` server (OpenAI, llama.cpp, Ollama, vLLM, LM Studio). SSE streaming + schema-constrained JSON. |
| `EchoBackend` | Deterministic, offline — tests, SwiftUI previews, demos. |

Custom backend = conform to `ModelBackend` (`generate(_:)` required; override
`stream(_:)` for real token streaming; read `request.schema` for guided generation).

### On-device, no server (truly drop-in)

```swift
import OpenFoundationModels
import OpenFoundationModelsMLX

OpenFoundationModels.configure(backend: MLXBackend(
    modelId: "mlx-community/Qwen2.5-1.5B-Instruct-4bit"
))
// LanguageModelSession now runs a local model in-process on Apple Silicon.
```

> **Build with Xcode for MLX.** mlx-swift's Metal shaders are only compiled by
> Xcode/`xcodebuild`, not plain `swift build`/`swift run` from the CLI. Verified
> on-device: `mlx-community/Qwen2.5-0.5B-Instruct-4bit` → "Paris", with cumulative
> streaming. The core package and the OpenAI-compatible/Echo backends have no such
> restriction and run fine from the CLI.

## Status

**Phase 1 & 2 — done and tested:** availability, sessions, multi-turn transcript
(`Transcript`), `respond`/`streamResponse` (all String/Prompt/builder/`generating:`/`schema:`
overloads), typed `Response<Content: Generable>` + `ResponseStream.Snapshot`,
`GenerationOptions`, `Instructions`/`Prompt` builders, **guided generation** (`@Generable`/
`@Guide`/`GenerationSchema` + constrained decoding), **tool calling**, Apple delegation,
on-device MLX + OpenAI-compatible + echo backends. Verified end-to-end against a local
Ollama/llama.cpp server (text, streaming, multi-turn, guided).

**Known gaps:** streaming partial `Generable` snapshots are best-effort (final snapshot is
fully decoded; intermediates yield when parseable); the tool loop runs on non-streaming
turns; `SystemLanguageModel.Adapter.isCompatible(_:)` (BackgroundAssets) is not bridged.

See `AppleIntelligence.md` for the full gated-API checklist this tracks against.
