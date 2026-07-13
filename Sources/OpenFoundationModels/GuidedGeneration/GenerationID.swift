import Foundation

/// A unique identifier for a generated content value. Mirrors `FoundationModels.GenerationID`.
///
/// Used to correlate content across partial-generation snapshots so that UI can
/// diff and update in place while a response streams in.
public struct GenerationID: Sendable, Hashable {
    private let uuid: UUID

    public init() {
        self.uuid = UUID()
    }

    public static func == (a: GenerationID, b: GenerationID) -> Bool {
        a.uuid == b.uuid
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}
