import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

/// Delegates to Apple's real on-device `FoundationModels` when the framework exists
/// (SDK ≥ iOS 26 / macOS 26) and the device is eligible. On any other target this is
/// inert (`isReady()` → false) so the polyfill falls back to another backend.
public final class AppleOnDeviceBackend: ModelBackend, @unchecked Sendable {
    public static let shared = AppleOnDeviceBackend()
    public let identifier = "apple.on-device"

    public init() {}

    /// True only when the real framework is present *and* reports `.available`.
    public static var isEligible: Bool {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
            return FoundationModels.SystemLanguageModel.default.isAvailable
        }
        #endif
        return false
    }

    public func isReady() async -> Bool { Self.isEligible }

    public func generate(_ request: GenerationRequest) async throws -> String {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
            let session = Self.makeSession(request)
            let response = try await session.respond(
                to: request.prompt,
                options: Self.mapOptions(request.options)
            )
            return response.content
        }
        #endif
        throw GenerationBackendError.appleModelUnavailable
    }

    public func stream(_ request: GenerationRequest) -> AsyncThrowingStream<String, Error> {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
            return AsyncThrowingStream { continuation in
                let task = Task {
                    do {
                        let session = Self.makeSession(request)
                        let stream = session.streamResponse(
                            to: request.prompt,
                            options: Self.mapOptions(request.options)
                        )
                        for try await partial in stream {
                            continuation.yield(partial.content)
                        }
                        continuation.finish()
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }
                continuation.onTermination = { _ in task.cancel() }
            }
        }
        #endif
        return AsyncThrowingStream { $0.finish(throwing: GenerationBackendError.appleModelUnavailable) }
    }

    #if canImport(FoundationModels)
    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    private static func makeSession(_ request: GenerationRequest) -> FoundationModels.LanguageModelSession {
        if let instructions = request.instructions, !instructions.isEmpty {
            return FoundationModels.LanguageModelSession(instructions: instructions)
        }
        return FoundationModels.LanguageModelSession()
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    private static func mapOptions(_ options: GenerationOptions) -> FoundationModels.GenerationOptions {
        FoundationModels.GenerationOptions(
            temperature: options.temperature,
            maximumResponseTokens: options.maximumResponseTokens
        )
    }
    #endif
}

public enum GenerationBackendError: Error, LocalizedError {
    case appleModelUnavailable
    case noBackendConfigured
    case invalidResponse(String)
    case http(status: Int, body: String)

    public var errorDescription: String? {
        switch self {
        case .appleModelUnavailable:
            return "Apple's on-device model is not available on this device."
        case .noBackendConfigured:
            return "No OpenFoundationModels backend configured. Call OpenFoundationModels.configure(backend:)."
        case .invalidResponse(let detail):
            return "Backend returned an invalid response: \(detail)"
        case .http(let status, let body):
            return "Backend HTTP \(status): \(body)"
        }
    }
}
