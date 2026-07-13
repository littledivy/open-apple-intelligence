import CoreGraphics
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Backend for any OpenAI-compatible `/v1/images/generations` endpoint: OpenAI, or a
/// local/self-hosted server exposing the same shape. Decodes both `b64_json` and `url`
/// response items into `CGImage`.
///
/// ```swift
/// OpenImagePlayground.configure(backend: OpenAIImageBackend(
///     endpoint: URL(string: "https://api.openai.com/v1")!,
///     model: "gpt-image-1",
///     apiKey: "sk-…"
/// ))
/// ```
public final class OpenAIImageBackend: ImageGenerationBackend, @unchecked Sendable {
    public let identifier: String
    private let endpoint: URL          // base, e.g. https://api.openai.com/v1
    private let model: String
    private let apiKey: String?
    private let size: String
    private let session: URLSession

    public init(
        endpoint: URL,
        model: String = "gpt-image-1",
        apiKey: String? = nil,
        size: String = "1024x1024",
        session: URLSession = .shared
    ) {
        self.endpoint = endpoint
        self.model = model
        self.apiKey = apiKey
        self.size = size
        self.session = session
        self.identifier = "openai-image(\(endpoint.host ?? "?"))"
    }

    private var generationsURL: URL { endpoint.appendingPathComponent("images/generations") }

    /// Fold the requested style into the prompt — the images API has no style field,
    /// so we describe it in words (matches how Apple's styles read as art directions).
    private func styledPrompt(_ prompt: String, _ style: ImagePlaygroundStyle) -> String {
        switch style.id {
        case ImagePlaygroundStyle.animation.id: return "\(prompt), in a 3D animated character style"
        case ImagePlaygroundStyle.illustration.id: return "\(prompt), as a clean vector illustration"
        case ImagePlaygroundStyle.sketch.id: return "\(prompt), as a hand-drawn pencil sketch"
        default: return prompt
        }
    }

    public func isReady() async -> Bool {
        apiKey != nil
    }

    public func generate(prompt: String, style: ImagePlaygroundStyle, count: Int) async throws -> [CGImage] {
        let body: [String: Any] = [
            "model": model,
            "prompt": styledPrompt(prompt, style),
            "n": max(1, count),
            "size": size,
        ]
        var req = URLRequest(url: generationsURL)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let apiKey { req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization") }
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: req)
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw ImageGenerationBackendError.http(
                status: http.statusCode,
                body: String(data: data, encoding: .utf8) ?? ""
            )
        }
        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let items = json["data"] as? [[String: Any]]
        else {
            throw ImageGenerationBackendError.invalidResponse(String(data: data, encoding: .utf8) ?? "<binary>")
        }

        var images: [CGImage] = []
        for item in items {
            if let b64 = item["b64_json"] as? String {
                images.append(try ImageDecoding.cgImage(fromBase64: b64))
            } else if let urlString = item["url"] as? String, let url = URL(string: urlString) {
                let (imgData, _) = try await session.data(from: url)
                images.append(try ImageDecoding.cgImage(from: imgData))
            }
        }
        guard !images.isEmpty else {
            throw ImageGenerationBackendError.invalidResponse("response contained no decodable images")
        }
        return images
    }
}

/// Alias for the generic HTTP name mentioned in the design; identical behaviour.
public typealias HTTPImageBackend = OpenAIImageBackend
