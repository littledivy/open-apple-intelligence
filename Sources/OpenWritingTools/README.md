# OpenWritingTools

A drop-in polyfill for Apple's **Writing Tools** and **Genmoji** — the
Apple-Intelligence-gated UIKit surface (`UIWritingToolsCoordinator`,
`NSAdaptiveImageGlyph`). It mirrors Apple's type and enum names (with availability
gating stripped) so your code compiles and runs on older OSes and on macOS, and it
backs the *text transforms* with the sibling
[`OpenFoundationModels`](../..) polyfill as the LLM engine.

```swift
import OpenFoundationModels
import OpenWritingTools
```

## What you get

| Area | Status | Notes |
| --- | --- | --- |
| `WritingTools.apply(_:to:)` / `.stream(_:_:)` | **Fully functional** | Real LLM transforms for all 9 actions. |
| `WritingToolsAction` | **Fully functional** | 9 tuned prompts matching Apple's actions. |
| `WritingToolsBehavior` / `WritingToolsResultOptions` | **Fully functional** | Exact mirror of the UIKit enums (raw values match). |
| `WritingToolsCoordinator` + delegate | **Functional bridge** | Really transforms text through delegate callbacks. Full system-UI inline editing needs the real OS. |
| `UITextView` / `NSTextView` helpers | **Fully functional** | Run an action on the selection and replace in place; ready-made `UIMenu`/`NSMenu`. |
| `AdaptiveImageGlyph` (Genmoji) | **Fully functional** | Always produces a real image — a plugged-in backend, or a built-in bitmap renderer. |

## Text transforms (the real value)

Zero configuration required. On first use the engine auto-installs a sensible
default backend: Apple's on-device model when eligible, otherwise a local
OpenAI-compatible server (llama.cpp on `:8091`, launch with `--jinja -np 1`).

```swift
// Optional — override the default before the first call:
OpenFoundationModels.configure(backend: OpenAICompatibleBackend(endpoint: url))
// or
WritingTools.useDefaultBackend(EchoBackend())   // deterministic, for tests/previews

// One-shot:
let fixed = try await WritingTools.apply(.proofread, to: draft)

// Streaming (cumulative snapshots — each value is the full text so far):
for try await partial in WritingTools.stream(.rewrite, draft) {
    textView.text = partial
}
```

### Actions (mirror Apple's Writing Tools)

`.proofread`, `.rewrite`, `.friendly`, `.professional`, `.concise`,
`.summarize`, `.keyPoints`, `.list`, `.table` — each maps to a tuned
instruction/prompt.

## Host helpers (UIKit / AppKit)

The practical substitute for the on-device inline-editing overlay: run an action
on a text view's current selection and replace it in place.

```swift
// iOS
try await textView.applyWritingToolsAction(.professional)
textView.writingToolsMenu()          // a UIMenu of all actions

// macOS
try await nsTextView.applyWritingToolsAction(.concise)
nsTextView.writingToolsMenu()        // an NSMenu of all actions
```

## `WritingToolsCoordinator`

Source-compatible mirror of `UIWritingToolsCoordinator` — same init, `delegate`,
`state`, `preferredBehavior`/`behavior`, and nested `State` / `TextReplacementReason`
/ `ContextScope` / `Context` types. Its `runWritingTools(_:on:)` genuinely fetches
contexts from your delegate, transforms each via the LLM engine, and delivers
replacements back through the standard `replaceRange:in:proposedText:` callback:

```swift
let coordinator = WritingToolsCoordinator(delegate: self)
try await coordinator.runWritingTools(.rewrite, on: .allText)
```

## Genmoji (`AdaptiveImageGlyph`)

Mirror of `NSAdaptiveImageGlyph` behind `#if canImport(UIKit)`, including the
`imageContent` / `contentIdentifier` / `contentDescription` surface and the
`NSAttributedString.withAdaptiveImageGlyph(_:)` convenience.

Generation always yields a **real image**. Plug in a proper image backend for
high-quality Genmoji, or use the built-in deterministic renderer:

```swift
// Optional: register a real image-generation backend.
GenmojiGenerator.shared = MyDiffusionBackend()

// Always returns a real, rendered PNG-backed glyph:
let glyph = try await GenmojiGenerator.generate(prompt: "🎉 party rocket")
let attributed = NSAttributedString.withAdaptiveImageGlyph(glyph)
```

## Honest limits (not polyfillable off-device)

- **System inline-editing UI.** The real `UIWritingToolsCoordinator` is a
  `UIInteraction` that injects an Apple Intelligence overlay into the responder
  chain and animates text. That system UI depends on private OS services and
  cannot be reproduced. This package instead exposes the type/delegate surface
  plus a working transform bridge and text-view helpers.
- **Native Genmoji image quality.** Producing an Apple-quality Genmoji from a
  prompt needs an on-device image model. Without a registered backend the package
  renders a real (but simple) tinted tile with the prompt's emoji/initials — a
  genuine image, never a placeholder or error.

## Tests

```bash
swift build          # macOS: UIKit files compile out; core + AppKit path build
swift test           # offline tests (EchoBackend), all green
OFM_LIVE=1 swift test # also runs the gated local-server integration tests
```
