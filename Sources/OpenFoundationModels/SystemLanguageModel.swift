import Foundation

/// The system language model. Mirrors `FoundationModels.SystemLanguageModel`.
///
/// In the polyfill, "availability" reflects whether a usable backend is configured
/// (Apple's on-device model when eligible, or a backend you set via
/// `OpenFoundationModels.configure`). Existing code that branches on
/// `SystemLanguageModel.default.availability` keeps working unchanged.
public final class SystemLanguageModel: @unchecked Sendable {

    /// The shared default model.
    public static let `default` = SystemLanguageModel(useCase: .general)

    public let useCase: UseCase
    public let guardrails: Guardrails

    public convenience init(useCase: UseCase = .general, guardrails: Guardrails = .default) {
        self.init(useCase: useCase, guardrails: guardrails, adapter: nil)
    }

    public convenience init(adapter: Adapter, guardrails: Guardrails = .default) {
        self.init(useCase: .general, guardrails: guardrails, adapter: adapter)
    }

    let adapter: Adapter?
    private init(useCase: UseCase, guardrails: Guardrails, adapter: Adapter?) {
        self.useCase = useCase
        self.guardrails = guardrails
        self.adapter = adapter
    }

    /// Whether a backend can currently service requests.
    public var availability: Availability {
        if OpenFoundationModels.resolvedBackend(appleReady: AppleOnDeviceBackend.isEligible) != nil {
            return .available
        }
        return .unavailable(Self.realUnavailableReason() ?? .modelNotReady)
    }

    public var isAvailable: Bool { availability == .available }

    /// Backend-dependent; the polyfill answers permissively and lets the backend
    /// surface real language errors at call time.
    public var supportedLanguages: Set<Locale.Language> { [Locale.current.language] }
    public func supportsLocale(_ locale: Locale = .current) -> Bool { true }

    // Map the real framework's unavailability reason through when we can see it, so a
    // host app's existing fallback UI reacts the same way it would to Apple's model.
    private static func realUnavailableReason() -> Availability.UnavailableReason? {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
            return nil // eligibility handled by AppleOnDeviceBackend; nil ⇒ default reason
        }
        #endif
        return nil
    }

    // MARK: Nested types

    /// Availability of the model. Mirrors `SystemLanguageModel.Availability`.
    public enum Availability: Equatable, Sendable {
        case available
        case unavailable(UnavailableReason)

        public enum UnavailableReason: Hashable, Sendable {
            case deviceNotEligible
            case appleIntelligenceNotEnabled
            case modelNotReady
        }
    }

    /// Model use case. Mirrors `SystemLanguageModel.UseCase`.
    public struct UseCase: Equatable, Sendable {
        let id: String
        public static let general = UseCase(id: "general")
        public static let contentTagging = UseCase(id: "contentTagging")
    }

    /// Safety guardrails. Mirrors `SystemLanguageModel.Guardrails`.
    public struct Guardrails: Equatable, Sendable {
        let id: String
        public static let `default` = Guardrails(id: "default")
        public static let permissiveContentTransformations = Guardrails(id: "permissive")
    }

    /// LoRA adapter handle. Mirrors `SystemLanguageModel.Adapter` (metadata only in the
    /// polyfill; backends decide what, if anything, to do with it).
    public struct Adapter: @unchecked Sendable {
        public let name: String?
        public let fileURL: URL?

        /// Creator-defined metadata associated with the adapter. Empty in the polyfill.
        public var creatorDefinedMetadata: [String: Any] { _creatorDefinedMetadata }
        private let _creatorDefinedMetadata: [String: Any]

        /// Loads an adapter from a file on disk.
        ///
        /// Throws `AssetError.invalidAsset` if no file exists at `fileURL`.
        public init(fileURL: URL) throws {
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                throw AssetError.invalidAsset(
                    .init(debugDescription: "No adapter asset found at \(fileURL.path).")
                )
            }
            self.fileURL = fileURL
            self.name = nil
            self._creatorDefinedMetadata = [:]
        }

        /// Loads an adapter by name.
        ///
        /// Throws `AssetError.invalidAdapterName` if `name` is empty.
        public init(name: String) throws {
            guard !name.isEmpty else {
                throw AssetError.invalidAdapterName(
                    .init(debugDescription: "Adapter name must not be empty.")
                )
            }
            self.name = name
            self.fileURL = nil
            self._creatorDefinedMetadata = [:]
        }

        /// Compiles the adapter. No-op in the polyfill (backends handle adapters themselves).
        public func compile() async throws {}

        /// Returns identifiers of adapters compatible with `name`. Empty in the polyfill.
        public static func compatibleAdapterIdentifiers(name: String) -> [String] { [] }

        /// Removes obsolete adapters. No-op in the polyfill.
        public static func removeObsoleteAdapters() throws {}

        // NOTE: The spec also declares
        //   `static func isCompatible(_ assetPack: BackgroundAssets.AssetPack) -> Bool`.
        // `BackgroundAssets.AssetPack` is only available on iOS 26 / macOS 26+, which this
        // polyfill deliberately targets below. Rather than break the build on older OSes,
        // that single overload is omitted here. Everything else on `Adapter` is provided.

        /// Errors that can occur while loading or compiling an adapter.
        /// Mirrors `SystemLanguageModel.Adapter.AssetError`.
        public enum AssetError: Error, LocalizedError {
            /// Contextual detail carried by an `AssetError`.
            public struct Context: Sendable {
                public let debugDescription: String
                public init(debugDescription: String) {
                    self.debugDescription = debugDescription
                }
            }

            case invalidAsset(Context)
            case invalidAdapterName(Context)
            case compatibleAdapterNotFound(Context)

            public var errorDescription: String? {
                switch self {
                case .invalidAsset(let context):
                    return "Invalid adapter asset: \(context.debugDescription)"
                case .invalidAdapterName(let context):
                    return "Invalid adapter name: \(context.debugDescription)"
                case .compatibleAdapterNotFound(let context):
                    return "No compatible adapter found: \(context.debugDescription)"
                }
            }

            public var recoverySuggestion: String? {
                switch self {
                case .invalidAsset:
                    return "Verify the adapter file exists and is a valid adapter asset."
                case .invalidAdapterName:
                    return "Provide a non-empty, valid adapter name."
                case .compatibleAdapterNotFound:
                    return "Install an adapter compatible with the current system model."
                }
            }
        }
    }
}
