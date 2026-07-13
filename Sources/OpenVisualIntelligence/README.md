# OpenVisualIntelligence

Drop-in polyfill for Apple's **VisualIntelligence** framework on devices where Apple gates
off Apple Intelligence (ineligible hardware, or OS older than iOS 26 / macOS 26).

Same type names as Apple's framework, so adopting it is a one-line change:

```diff
- import VisualIntelligence
+ import OpenVisualIntelligence
```

## Honest scope

Apple's real `VisualIntelligence` framework is not really "code you call" — it's the type
surface AppIntents uses when the **system camera** or **on-screen semantic search** hands
your app a `SemanticContentDescriptor` for something the user pointed at or circled. That
surfacing happens deep in the OS (Camera Control, visual search UI, App Intents dispatch)
and is fundamentally not something a userspace package can reproduce. There is no polyfill
for "the system recognized what's under the user's finger."

So this package draws a clear line:

| Surface | Status |
| --- | --- |
| `SemanticContentDescriptor` type (struct, `labels`, `pixelBuffer`, `description`) | **Type surface** — mirrors the spec so dependent code compiles |
| `AppIntents._SystemIntentValue` conformance (persistent identifiers, resolver specs, System Intents plumbing) | **Not included** — this is Apple-internal SPI (leading underscore) used to wire the type into system-triggered intents; there is no system to wire it to outside of Apple's OS, and the protocol isn't public API to conform to |
| Constructing a `SemanticContentDescriptor` from data you already have | **Functional** — `init(labels:pixelBuffer:)` |
| Deriving `labels` from an actual image, zero-config | **Functional, real default** — `init(analyzing:)` runs the real on-device `VisionBackend` (`VNClassifyImageRequest` + `VNGenerateImageFeaturePrintRequest`) automatically; no setup required |
| Deriving `labels` from an actual image, custom backend | **Functional** — `init(analyzing:backend:)` via a pluggable `VisualAnalysisBackend`, for swapping in your own analysis or (in tests only) `StubVisualBackend` |
| The system camera / on-screen semantic search itself deciding what the user is pointing at | **Not polyfillable** — no userspace equivalent exists |

In short: if your code just consumes a `SemanticContentDescriptor` that was handed to it,
it will compile unchanged. If your code needs to *produce* one from an image (e.g. for
tests, previews, or your own on-device analysis pipeline), `init(analyzing:)` gives you a
real, working, zero-config on-device analysis path — no stub, no manual backend wiring.

## Usage

### Mirroring Apple's shape exactly

```swift
import OpenVisualIntelligence

let descriptor = SemanticContentDescriptor(labels: ["dog", "animal"])
print(descriptor.labels)          // ["dog", "animal"]
print(descriptor.pixelBuffer)     // nil
print(descriptor.description)     // "SemanticContentDescriptor(labels: [\"dog\", \"animal\"])"
```

### Functional analysis — zero config (the default)

No setup, no backend to choose — this runs real, on-device Vision analysis:

```swift
import OpenVisualIntelligence

let descriptor = try await SemanticContentDescriptor(analyzing: someCGImage)
print(descriptor.labels)   // e.g. ["dog", "animal", ..., "feature-print:3a1c9e0b7f2d4488"]
```

Under the hood this is `VisionBackend()` — `VNClassifyImageRequest` for semantic
classification labels, plus `VNGenerateImageFeaturePrintRequest` for a stable
`feature-print:<hash>` content fingerprint (on by default; set
`VisionBackend(includesFeaturePrint: false)` to disable it if you supply a custom
backend instance). Available wherever Vision is (this package's whole deployment range —
iOS 16+ / macOS 13+).

```swift
let descriptor = try await SemanticContentDescriptor(
    analyzing: someCGImage,
    backend: VisionBackend(maxLabels: 5, minimumConfidence: 0.2)
)
```

### Pluggable backend (custom analysis, or tests)

```swift
import OpenVisualIntelligence

protocol VisualAnalysisBackend: Sendable {
    func analyze(_ image: CGImage) async throws -> [String]
}
```

`init(analyzing:backend:)` lets you swap in your own analysis. **`StubVisualBackend` is
for unit tests only** — it returns fixed labels regardless of image content and must never
be used as an app's shipping analysis path:

```swift
// Tests only:
let descriptor = try await SemanticContentDescriptor(
    analyzing: someCGImage,
    backend: StubVisualBackend(labels: ["cat", "pet"])
)
```

## `pixelBuffer` type note

Apple's spec types `SemanticContentDescriptor.pixelBuffer` as `CVReadOnlyPixelBuffer?` — a
noncopyable/nonescapable CoreVideo type gated behind the Swift `NonescapableTypes`
experimental feature and only available iOS 26+. That type has no equivalent on this
package's older deployment targets, so `pixelBuffer` here is typed as the classic
`CVPixelBuffer?` under the same property name. Treat it as read-only, matching the
contract Apple's real type enforces at the type-system level.

## What's stripped

All `@available(iOS 26.0, *)` availability annotations from the spec are removed — this
package targets iOS 16+ / macOS 13+, which is the point of a polyfill.
