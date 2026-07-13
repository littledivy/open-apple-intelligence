import SwiftUI
import OpenFoundationModels

struct ContentView: View {
    @State private var backend = BackendSettings()

    var body: some View {
        TabView {
            ChatView()
                .environment(backend)
                .tabItem { Label("Chat", systemImage: "bubble.left.and.bubble.right") }

            GuidedGenView()
                .environment(backend)
                .tabItem { Label("Guided Generation", systemImage: "wand.and.stars") }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            BackendBar()
                .environment(backend)
        }
    }
}

/// Persistent top bar: backend picker + endpoint/model fields (when relevant) +
/// a live availability status line. Shared by both tabs.
private struct BackendBar: View {
    @Environment(BackendSettings.self) private var backend

    var body: some View {
        @Bindable var backend = backend

        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Picker("Backend", selection: $backend.kind) {
                    ForEach(BackendKind.allCases) { kind in
                        Text(kind.rawValue).tag(kind)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 320)
                .labelsHidden()

                Spacer()

                AvailabilityBadge()
            }

            if backend.kind == .localServer {
                HStack(spacing: 10) {
                    TextField("Endpoint", text: $backend.endpoint, prompt: Text("http://localhost:11434/v1"))
                        .textFieldStyle(.roundedBorder)
                        .frame(minWidth: 220)
                    TextField("Model", text: $backend.model, prompt: Text("qwen2.5:1.5b"))
                        .textFieldStyle(.roundedBorder)
                        .frame(minWidth: 140)
                    Text("Requires a local server, e.g. `ollama serve`.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.18), value: backend.kind)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }
}

private struct AvailabilityBadge: View {
    @Environment(BackendSettings.self) private var backend

    private var availability: SystemLanguageModel.Availability {
        _ = backend.revision // force re-evaluation when the backend changes
        return SystemLanguageModel.default.availability
    }

    private var isAvailable: Bool {
        availability == .available
    }

    private var label: String {
        switch availability {
        case .available:
            return "Model available"
        case .unavailable(.deviceNotEligible):
            return "Unavailable · device not eligible"
        case .unavailable(.appleIntelligenceNotEnabled):
            return "Unavailable · Apple Intelligence off"
        case .unavailable(.modelNotReady):
            return "Unavailable · model not ready"
        }
    }

    var body: some View {
        Label(label, systemImage: isAvailable ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
            .font(.caption.weight(.medium))
            .foregroundStyle(isAvailable ? .green : .orange)
            .labelStyle(.titleAndIcon)
    }
}

#Preview {
    ContentView()
        .frame(width: 720, height: 620)
}
