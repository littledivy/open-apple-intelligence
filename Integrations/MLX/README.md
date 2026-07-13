# OpenFoundationModelsMLX

**True on-device inference** for [OpenFoundationModels](../..) via Apple's
[MLX](https://github.com/ml-explore/mlx-swift) — no external server, no HTTP.
Weights are downloaded from Hugging Face on first use and the model runs
**in-process on Apple Silicon** (M-series Macs, A-series iPhones/iPads).

This is a **separate, sibling package** on purpose: MLX pulls in heavy native
dependencies (`mlx-swift`, `swift-transformers`, …). Keeping it out of the core
`OpenFoundationModels` package leaves the core dependency-light (swift-syntax
only) and buildable on Linux.

## Requirements

- macOS 14+, iOS 16+, or visionOS 1+ **on Apple Silicon** (MLX has no CPU/Linux fallback).

## Usage

```swift
import OpenFoundationModels
import OpenFoundationModelsMLX

OpenFoundationModels.configure(backend: MLXBackend(modelId: "mlx-community/Qwen2.5-1.5B-Instruct-4bit"))
// then use LanguageModelSession exactly like Apple's FoundationModels
```

The first `generate`/`stream` downloads the weights (~1 GB for a 1.5B-4bit model)
and loads them; subsequent calls reuse the in-memory model. Optionally call
`try await backend.prewarm()` to pay that cost up front.

Any MLX-format model id from the [`mlx-community`](https://huggingface.co/mlx-community)
org works, e.g. `mlx-community/Llama-3.2-3B-Instruct-4bit`,
`mlx-community/Qwen3-4B-4bit`.

## Notes

- `temperature` and `maximumResponseTokens` from `GenerationOptions` are honored.
- Streaming yields **cumulative** snapshots (each value is the full text so far),
  matching the core package and Apple's `FoundationModels`.
- Cancellation is honored: cancelling the stream's `Task` stops generation.

## Add as a dependency

```swift
.package(path: "path/to/apple-intelligence/Integrations/MLX"),
// target dependency:
.product(name: "OpenFoundationModelsMLX", package: "OpenFoundationModelsMLX"),
```
