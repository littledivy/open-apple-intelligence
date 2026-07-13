import SwiftUI
import OpenFoundationModels

struct ChatView: View {
    @Environment(BackendSettings.self) private var backend
    @State private var viewModel = ChatViewModel()
    @FocusState private var fieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.messages.isEmpty {
                emptyState
            } else {
                messageList
            }

            if let errorText = viewModel.errorText {
                ErrorBanner(text: errorText) { viewModel.errorText = nil }
            }

            composer()
        }
        .onChange(of: backend.revision) {
            viewModel.resetSession()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 40))
                .foregroundStyle(.tertiary)
            Text("Say something to get started")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                }
                .padding(16)
            }
            .onChange(of: viewModel.messages.last?.text) {
                scrollToBottom(proxy)
            }
            .onChange(of: viewModel.messages.count) {
                scrollToBottom(proxy)
            }
        }
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        guard let last = viewModel.messages.last else { return }
        withAnimation(.easeOut(duration: 0.2)) {
            proxy.scrollTo(last.id, anchor: .bottom)
        }
    }

    @ViewBuilder
    private func composer() -> some View {
        @Bindable var viewModel = viewModel

        HStack(alignment: .bottom, spacing: 10) {
            TextField("Message", text: $viewModel.draft, prompt: Text("Ask me anything…"), axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...5)
                .focused($fieldFocused)
                .onSubmit { viewModel.send() }
                .disabled(viewModel.isStreaming)

            Button {
                viewModel.send()
            } label: {
                Image(systemName: viewModel.isStreaming ? "hourglass" : "arrow.up.circle.fill")
                    .font(.system(size: 26))
            }
            .buttonStyle(.plain)
            .foregroundStyle(canSend ? Color.accentColor : Color.secondary.opacity(0.4))
            .disabled(!canSend)
            .keyboardShortcut(.return, modifiers: [])
        }
        .padding(12)
        .background(.bar)
        .overlay(alignment: .top) { Divider() }
        .task { fieldFocused = true }
    }

    private var canSend: Bool {
        !viewModel.isStreaming && !viewModel.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

private struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == .user { Spacer(minLength: 40) }

            Text(message.text.isEmpty ? " " : message.text)
                .textSelection(.enabled)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(bubbleBackground)
                .foregroundStyle(message.role == .user ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            if message.role == .assistant { Spacer(minLength: 40) }
        }
    }

    private var bubbleBackground: some ShapeStyle {
        message.role == .user ? AnyShapeStyle(Color.accentColor) : AnyShapeStyle(.quaternary)
    }
}

private struct ErrorBanner: View {
    let text: String
    let dismiss: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            Text(text)
                .font(.callout)
                .textSelection(.enabled)
            Spacer()
            Button(action: dismiss) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .background(Color.orange.opacity(0.12))
        .overlay(alignment: .top) { Divider() }
    }
}
