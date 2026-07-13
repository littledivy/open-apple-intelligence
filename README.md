# open-apple-intelligence

Drop-in polyfills for Apple Intelligence frameworks on devices Apple gates them off —
ineligible hardware, or an OS older than iOS 26 / macOS 26.

Apple ships these frameworks in the OS but disables them on ineligible devices (their
availability APIs report `.unavailable`); on older OS versions the frameworks don't exist
at all. These packages reproduce the public API and make it actually work, backed by
Apple's real model when eligible and by on-device / local engines otherwise.

## Frameworks

| Apple framework | Package | Polyfill import |
|---|---|---|
| FoundationModels | `OpenFoundationModels` | `import OpenFoundationModels` |
| Writing Tools + Genmoji (UIKit) | `OpenWritingTools` | `import OpenWritingTools` |
| ImagePlayground | `OpenImagePlayground` | `import OpenImagePlayground` |
| VisualIntelligence | `OpenVisualIntelligence` | `import OpenVisualIntelligence` |
| AppIntents assistant schemas | `OpenAppIntentsAssistant` | `import OpenAppIntentsAssistant` |

`OpenFoundationModelsMLX` adds an in-process on-device LLM backend (Apple Silicon, via MLX).

## Drop-in

Each package mirrors Apple's public API **exactly** — same type names, same signatures —
so adopting it is a one-line change per framework:

```diff
- import FoundationModels
+ import OpenFoundationModels
```

The rest of your code compiles unchanged. The polyfill types intentionally carry no
`@available` gating, so they resolve on old deployment targets where the real symbols
are absent.

## How it works

**Same names, own module.** A module named `FoundationModels` would collide with Apple's
on the current SDK, so each polyfill lives in an `Open*` module that re-declares the same
API surface. You change the import; nothing else.

**Availability means "is a backend ready".** `SystemLanguageModel.default.availability`,
`ImageCreator`, and friends report available whenever a usable engine is configured — so
existing code that branches on availability keeps working, and falls through to your
fallback path only when nothing can serve the request.

**Runtime resolution.** For each request the polyfill picks, in order:

1. Apple's real framework, when the device is eligible (best quality, private, free).
2. An on-device engine — MLX (text), Core ML Stable Diffusion (images), Vision (analysis).
3. A configured server — any OpenAI-compatible `/v1` endpoint (llama.cpp, Ollama, vLLM, cloud).
4. A deterministic local fallback, so a path never silently no-ops.

**Guided generation & tools** are real: `@Generable` / `@Guide` expand via a Swift macro
into a schema, the backend is asked for schema-constrained JSON, and the reply is decoded
into your typed value; tool calls are detected and executed in-process.

## What isn't polyfillable

A few surfaces hook into private OS services with no public entry point. These are the only
gaps, and they're documented per package — everything in userspace is real, not stubbed:

- System **Siri / Assistant** routing — `OpenAppIntentsAssistant` ships an in-process
  intent router instead.
- Writing Tools' system **inline-editing overlay** (private `UIInteraction`) — the text
  transforms and menu integration work regardless.
- VisualIntelligence's system **camera trigger** — the image-analysis API itself is real.
- `AppIntents._SystemIntentValue` (private SPI, mangled symbols).

## Status

Early (0.1). Honest coverage against Apple's real API — see `AppleIntelligence.md` for the
member-by-member breakdown:

| Framework | Coverage | Reality |
|---|--:|---|
| FoundationModels | 313/364 | **True drop-in.** Sessions, streaming, guided generation (`@Generable`), tools all work. Gaps are niche (feedback logging, adapter no-ops, ABI shims). |
| ImagePlayground | 62/66 | **Drop-in.** `ImageCreator`, `.imagePlaygroundSheet`, styles. On-device Stable Diffusion needs the `CoreMLDiffusion` trait + Xcode. |
| AppIntents assistant | 205/205 | **Compiles drop-in** (full schema surface), but system Siri routing has no public hook — runs via an in-process `LocalAssistant`, not the OS assistant. |
| Writing Tools | functional | Text engine (proofread/rewrite/summarize/…) works, but it is **not** a 1:1 mirror of the `UIWritingToolsCoordinator` / `NSAdaptiveImageGlyph` UIKit API — it's a functional analog with its own surface. |
| VisualIntelligence | 3/10 | `SemanticContentDescriptor` + on-device Vision analysis. The framework is mostly OS-side; the system camera/search path isn't polyfillable. |

**Not yet validated on a real iOS device.** Verified on macOS (SwiftPM + Xcode): local-server
and MLX text generation, one on-device Stable Diffusion image, guided decoding. The
Writing Tools / AppIntents / VisualIntelligence paths are covered by offline + unit tests
only. Treat as a starting point, not a finished product.

## Requirements

Swift 6.1+ (this is a single SwiftPM package; every framework above is a `library` product,
so one `.package(url: "https://github.com/littledivy/open-apple-intelligence")` dependency vends
them all). MLX and ImagePlayground run their Metal / Core ML pipelines under Xcode or on
device (SwiftPM's CLI doesn't compile their shaders); the other packages run anywhere.

The heavy on-device backends are gated behind SwiftPM package **traits**, so a default
build never resolves their large dependency trees. Enable them explicitly to pull in and
build those backends:

- `swift build --traits MLX` — the in-process MLX LLM backend (`mlx-swift-examples`).
- `swift build --traits CoreMLDiffusion` — the on-device Core ML Stable Diffusion image
  backend (`apple/ml-stable-diffusion`).

With the traits off, `OpenImagePlayground` still works via its OpenAI-compatible HTTP
image backend; configure one with `OpenImagePlayground.configure(backend:)`.

Per-package `README`s cover configuration and usage; `Examples/ChatDemo` is a runnable
SwiftUI app. `AppleIntelligence.md` tracks polyfill coverage against Apple's real API,
member by member.
