import Foundation

/// The set of text transforms Apple's Writing Tools exposes in its UI, mirrored
/// here as a plain, OS-independent enum. Each case maps to a tuned instruction +
/// prompt that drives the LLM engine (`OpenFoundationModels.LanguageModelSession`).
///
/// Apple gates the real feature behind Apple Intelligence eligibility. This
/// polyfill runs the same transforms anywhere the sibling `OpenFoundationModels`
/// polyfill has a configured backend.
public enum WritingToolsAction: String, CaseIterable, Sendable {
    /// Fix spelling, grammar and punctuation without changing meaning or voice.
    case proofread
    /// Rewrite for clarity and flow, preserving meaning.
    case rewrite
    /// Rewrite in a warmer, more friendly tone.
    case friendly
    /// Rewrite in a more formal, professional tone.
    case professional
    /// Rewrite to be more concise.
    case concise
    /// Produce a short prose summary.
    case summarize
    /// Extract the key points as a bulleted list.
    case keyPoints
    /// Reformat the content as a bulleted list.
    case list
    /// Reformat the content as a Markdown table.
    case table

    /// A human-readable title suitable for a menu item, matching Apple's labels.
    public var title: String {
        switch self {
        case .proofread:    return "Proofread"
        case .rewrite:      return "Rewrite"
        case .friendly:     return "Friendly"
        case .professional: return "Professional"
        case .concise:      return "Concise"
        case .summarize:    return "Summary"
        case .keyPoints:    return "Key Points"
        case .list:         return "List"
        case .table:        return "Table"
        }
    }

    /// The system-level instruction that primes the model for this transform.
    /// Kept terse and imperative so small local models follow it reliably.
    var instruction: String {
        let base = "You are a writing assistant. Apply exactly the requested transformation to the user's text. "
            + "Return only the transformed text with no preamble, no explanation, no quotation marks, and no commentary."
        switch self {
        case .proofread:
            return base + " Task: Correct spelling, grammar, and punctuation. Do not change the meaning, tone, or word choice beyond what is needed for correctness."
        case .rewrite:
            return base + " Task: Rewrite the text so it reads more clearly and flows better, while preserving the original meaning and intent."
        case .friendly:
            return base + " Task: Rewrite the text in a warm, friendly, approachable tone while keeping the same meaning."
        case .professional:
            return base + " Task: Rewrite the text in a formal, professional tone suitable for business communication, keeping the same meaning."
        case .concise:
            return base + " Task: Rewrite the text to be as concise as possible without losing essential meaning. Remove redundancy."
        case .summarize:
            return base + " Task: Write a brief prose summary that captures the main idea. Keep it to a few sentences."
        case .keyPoints:
            return base + " Task: Extract the key points as a Markdown bulleted list. Each bullet starts with '- '. One idea per bullet."
        case .list:
            return base + " Task: Reorganize the content into a Markdown bulleted list. Each item starts with '- '."
        case .table:
            return base + " Task: Reorganize the content into a Markdown table with a header row and a separator row. Use pipes '|' to delimit columns."
        }
    }

    /// Wraps the caller's text into the prompt for this transform.
    func prompt(for text: String) -> String {
        "Text:\n\(text)"
    }
}
