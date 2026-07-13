import Foundation
import Observation
import OpenFoundationModels

/// Which backend the demo is currently wired to. `EchoBackend` needs nothing;
/// `Local server` talks to an OpenAI-compatible endpoint (e.g. Ollama).
enum BackendKind: String, CaseIterable, Identifiable {
    case echo = "Echo (offline)"
    case localServer = "Local server"

    var id: String { rawValue }
}

/// Shared, app-wide backend configuration. Both the chat tab and the guided
/// generation tab read `SystemLanguageModel.default.availability`, which
/// reflects whatever was last passed to `OpenFoundationModels.configure(backend:)`.
@Observable
final class BackendSettings {
    var kind: BackendKind = .echo {
        didSet { apply() }
    }

    var endpoint: String = "http://localhost:11434/v1" {
        didSet { if kind == .localServer { apply() } }
    }

    var model: String = "qwen2.5:1.5b" {
        didSet { if kind == .localServer { apply() } }
    }

    /// Bumped every time `apply()` runs so views can force a re-read of
    /// `SystemLanguageModel.default.availability` (it isn't itself Observable).
    private(set) var revision: Int = 0

    init() {
        apply()
    }

    func apply() {
        switch kind {
        case .echo:
            OpenFoundationModels.configure(backend: EchoBackend())
        case .localServer:
            let url = URL(string: endpoint) ?? URL(string: "http://localhost:11434/v1")!
            OpenFoundationModels.configure(
                backend: OpenAICompatibleBackend(endpoint: url, model: model)
            )
        }
        revision += 1
    }
}
