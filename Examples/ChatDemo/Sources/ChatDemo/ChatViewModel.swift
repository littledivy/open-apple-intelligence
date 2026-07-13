import Foundation
import Observation
import OpenFoundationModels

struct ChatMessage: Identifiable, Equatable {
    enum Role: Equatable {
        case user
        case assistant
    }

    let id = UUID()
    let role: Role
    var text: String
}

@MainActor
@Observable
final class ChatViewModel {
    private(set) var messages: [ChatMessage] = []
    var draft: String = ""
    private(set) var isStreaming = false
    var errorText: String?

    /// Recreated whenever the backend changes so the new configuration takes effect
    /// on the next turn (a session pins the model it was created with).
    private var session = LanguageModelSession(
        instructions: "You are a friendly, concise assistant inside a SwiftUI demo app."
    )

    func resetSession() {
        session = LanguageModelSession(
            instructions: "You are a friendly, concise assistant inside a SwiftUI demo app."
        )
    }

    func send() {
        let prompt = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty, !isStreaming else { return }

        draft = ""
        errorText = nil
        messages.append(ChatMessage(role: .user, text: prompt))

        messages.append(ChatMessage(role: .assistant, text: ""))
        let assistantIndex = messages.count - 1

        isStreaming = true
        Task {
            defer { isStreaming = false }
            do {
                let stream = session.streamResponse(to: prompt)
                for try await snapshot in stream {
                    guard assistantIndex < messages.count else { break }
                    messages[assistantIndex].text = snapshot.content
                }
            } catch {
                if assistantIndex < messages.count, messages[assistantIndex].text.isEmpty {
                    messages.remove(at: assistantIndex)
                }
                errorText = Self.describe(error)
            }
        }
    }

    static func describe(_ error: Error) -> String {
        if let localized = error as? LocalizedError, let description = localized.errorDescription {
            return description
        }
        return String(describing: error)
    }
}
