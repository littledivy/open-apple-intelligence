# OpenImagePlayground

A drop-in polyfill for Apple's **ImagePlayground** framework (image generation +
Genmoji-style creation) that runs on **old OSes** — no Apple Intelligence required.

Swap `import ImagePlayground` → `import OpenImagePlayground`; the public API names and
signatures match Apple's, so the rest of your code is unchanged.

The real value is a **fully functional, on-device image generation pipeline**: by
default, with **zero configuration**, `ImageCreator` generates real images via Apple's
Core ML [Stable Diffusion](https://github.com/apple/ml-stable-diffusion) — no server, no
API key. You can also plug in an OpenAI-compatible HTTP backend, or a deterministic stub
for tests.

## Platforms

- macOS 13+, iOS 16+ (on-device diffusion needs macOS 13.1 / iOS 16.2 on Apple Silicon /
  a device with the Neural Engine).

## Installation

```swift
.package(path: "Frameworks/ImagePlayground"),
// or by URL once published
.product(name: "OpenImagePlayground", package: "OpenImagePlayground"),
```

## Usage

### Default — real on-device generation, zero config

```swift
import OpenImagePlayground

let creator = try await ImageCreator()   // uses CoreMLDiffusionBackend by default
for try await created in creator.images(
    for: [.text("a red bicycle by the sea")],
    style: .illustration,
    limit: 4
) {
    let cgImage = created.cgImage         // real denoised image
}
```

On first use the converted Core ML Stable Diffusion model (~1.5 GB) is lazily downloaded
from Hugging Face, cached under Application Support, loaded into a `StableDiffusionPipeline`,
and driven through actual UNet denoising steps + VAE decoding to produce images.

> Core ML + the Neural Engine/GPU require a real device or simulator. A command-line
> `swift build` compiles this path but cannot exercise the ANE — run under Xcode / on
> device to actually generate (the same constraint as this repo's MLX text backend).

### Alternative — OpenAI-compatible HTTP backend

```swift
OpenImagePlayground.configure(backend: OpenAIImageBackend(
    endpoint: URL(string: "https://api.openai.com/v1")!,
    model: "gpt-image-1",
    apiKey: ProcessInfo.processInfo.environment["OPENAI_API_KEY"]
))
```

POSTs to `/v1/images/generations` and decodes both `b64_json` and `url` responses into
`CGImage`. `HTTPImageBackend` is an alias for the same type.

### SwiftUI sheet

```swift
struct ContentView: View {
    @State private var showing = false
    @State private var url: URL?
    var body: some View {
        Button("Create") { showing = true }
            .imagePlaygroundSheet(
                isPresented: $showing,
                concept: "a friendly robot waving",
                onCompletion: { url = $0 }        // temporary-file URL of the PNG
            )
    }
}
```

All four spec overloads of `.imagePlaygroundSheet(...)` are provided, plus
`.imagePlaygroundGenerationStyle(_:in:)` and `.imagePlaygroundPersonalizationPolicy(_:)`.
The sheet really invokes the backend and returns a real generated image.

### UIKit

```swift
let vc = ImagePlaygroundViewController()
vc.concepts = [.text("a watercolor mountain")]
vc.selectedGenerationStyle = .sketch
vc.delegate = self   // ImagePlaygroundViewController.Delegate
present(vc, animated: true)
```

## Custom backends

Conform to `ImageGenerationBackend`:

```swift
public protocol ImageGenerationBackend: Sendable {
    var identifier: String { get }
    func isReady() async -> Bool
    func generate(prompt: String, style: ImagePlaygroundStyle, count: Int) async throws -> [CGImage]
}
```

## Testing

Offline, deterministic tests use `StubImageBackend` (a solid-color `CGImage` mock — used
**only** in tests, never as the shipping default):

```bash
swift test        # offline tests, no network / no model download
```

A gated live test hits a real endpoint:

```bash
IMG_LIVE=1 OPENAI_API_KEY=sk-… swift test
# optional: IMG_ENDPOINT=… IMG_MODEL=…
```
