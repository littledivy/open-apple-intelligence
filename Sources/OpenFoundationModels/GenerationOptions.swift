import Foundation

/// Sampling and length controls for a request. Mirrors
/// `FoundationModels.GenerationOptions`.
public struct GenerationOptions: Equatable, Sendable {
    public var sampling: SamplingMode?
    public var temperature: Double?
    public var maximumResponseTokens: Int?

    public init(
        sampling: SamplingMode? = nil,
        temperature: Double? = nil,
        maximumResponseTokens: Int? = nil
    ) {
        self.sampling = sampling
        self.temperature = temperature
        self.maximumResponseTokens = maximumResponseTokens
    }

    /// How tokens are picked. Mirrors `GenerationOptions.SamplingMode`.
    public struct SamplingMode: Equatable, Sendable {
        enum Kind: Equatable, Sendable {
            case greedy
            case topP(threshold: Double, seed: UInt64?)
            case topK(k: Int, seed: UInt64?)
        }
        let kind: Kind
        private init(_ kind: Kind) { self.kind = kind }

        /// Always take the most likely token.
        public static var greedy: SamplingMode { .init(.greedy) }

        /// Nucleus (top-p) sampling.
        public static func random(probabilityThreshold: Double, seed: UInt64? = nil) -> SamplingMode {
            .init(.topP(threshold: probabilityThreshold, seed: seed))
        }

        /// Top-k sampling.
        public static func random(top k: Int, seed: UInt64? = nil) -> SamplingMode {
            .init(.topK(k: k, seed: seed))
        }
    }
}
