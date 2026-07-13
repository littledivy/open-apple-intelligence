# ChatDemo

A small SwiftUI example app that demonstrates
[`OpenFoundationModels`](../..), the drop-in polyfill for Apple's
`FoundationModels` framework. It shows:

- Streaming chat (`LanguageModelSession.streamResponse(to:)`) with a live-updating
  assistant bubble.
- Swappable backends at runtime (`OpenFoundationModels.configure(backend:)`).
- Guided (structured) generation with `@Generable` / `@Guide` and
  `respond(to:generating:)`.

This is a separate, self-contained SwiftPM package — it does not modify or
depend on anything beyond the root `OpenFoundationModels` library product.

## Run

```sh
cd Examples/ChatDemo
swift run ChatDemo
```

This builds and launches the app. Xcode also works: `open Package.swift`.

## Backends

The top bar has a segmented picker:

- **Echo (offline)** — the default. Uses `EchoBackend`, a deterministic,
  network-free backend that echoes/streams the prompt back. No setup needed;
  good for confirming the UI and streaming plumbing work.
- **Local server** — routes through `OpenAICompatibleBackend` against any
  OpenAI-compatible `/v1/chat/completions` endpoint. The endpoint and model
  fields default to a local [Ollama](https://ollama.com) server:

  ```sh
  ollama serve
  ollama pull qwen2.5:1.5b
  ```

  Endpoint defaults to `http://localhost:11434/v1`, model to `qwen2.5:1.5b`.
  Both are editable text fields — point them at any other OpenAI-compatible
  server (llama.cpp, LM Studio, vLLM, OpenAI itself, etc.) by changing the
  endpoint/model and, if needed, wiring an API key in code.

  If the server isn't running, requests fail and the error is shown inline
  in the chat (and in the guided-generation tab) instead of crashing the app.

Switching backends re-configures `OpenFoundationModels` immediately and
starts a fresh `LanguageModelSession` on both tabs.

The status line next to the picker reflects
`SystemLanguageModel.default.availability` live, so you can see the same
`.available` / `.unavailable(reason)` states real `FoundationModels`-based
code would observe.

## Guided generation tab

Demonstrates typed, schema-constrained output. `Recipe` is a `@Generable`
struct:

```swift
@Generable
struct Recipe: Equatable {
    @Guide(description: "a short, appetizing dish name")
    var name: String

    @Guide(description: "the ingredients, each as a short shopping-list style line")
    var ingredients: [String]

    @Guide(description: "total time to prepare and cook, in minutes", .range(1...480))
    var minutes: Int
}
```

Typing a prompt (e.g. "a quick weeknight pasta dinner") and pressing
**Generate** calls:

```swift
let response = try await session.respond(to: prompt, generating: Recipe.self)
```

The model's JSON reply is decoded straight into a `Recipe` value (no manual
parsing) and rendered in a small recipe card. `@Guide` descriptions and the
`.range(...)` constraint on `minutes` steer the model without any bespoke
prompt-engineering in app code.

## Notes

- Only depends on `OpenFoundationModels` (the `apple-intelligence` package,
  path `../..`) — no MLX dependency, so it stays lightweight to build. MLX is
  just mentioned as one of several possible backends you could wire up
  yourself; it isn't included here.
- Targets macOS 14+, Swift tools 6.0.
