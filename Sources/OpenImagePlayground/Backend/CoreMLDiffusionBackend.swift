#if CoreMLDiffusion
import CoreGraphics
import CoreML
import Foundation
import StableDiffusion

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// The DEFAULT, zero-config backend: a REAL on-device Stable Diffusion pipeline running
/// via Apple's Core ML (`apple/ml-stable-diffusion`). No server, no API key, no Apple
/// Intelligence. The converted Core ML model (~1.5 GB) is lazily downloaded from Hugging
/// Face on first use, cached under Application Support, loaded into a
/// `StableDiffusionPipeline`, and driven through actual denoising steps to produce images.
///
/// This is the substance of the polyfill: `ImageCreator.images(for:style:limit:)` denoises
/// latents into real `CGImage`s here when no other backend is configured.
///
/// Runtime note: Core ML + Neural Engine/GPU require a real device or simulator; a
/// command-line `swift build` compiles this path but cannot exercise the ANE. Run under
/// Xcode / on-device to actually generate (same constraint as this repo's MLX backend).
public final class CoreMLDiffusionBackend: ImageGenerationBackend, @unchecked Sendable {
    public let identifier = "coreml-stable-diffusion"

    /// A downloadable, converted Core ML Stable Diffusion model on Hugging Face. Apple's
    /// repos publish the compiled `.mlmodelc` bundles as individual files under a variant
    /// subfolder (there is no single zip), so we snapshot the subfolder file-by-file.
    public struct Model: Sendable {
        /// Hugging Face repo id, e.g. `apple/coreml-stable-diffusion-2-1-base`.
        public let repoId: String
        /// Variant subfolder holding the compiled resources, e.g. `split_einsum/compiled`.
        public let subfolder: String
        /// Stable cache folder name for the downloaded resources.
        public let cacheName: String
        /// Whether the model expects the multilingual text encoder.
        public let useMultilingualTextEncoder: Bool

        public init(repoId: String, subfolder: String, cacheName: String, useMultilingualTextEncoder: Bool = false) {
            self.repoId = repoId
            self.subfolder = subfolder
            self.cacheName = cacheName
            self.useMultilingualTextEncoder = useMultilingualTextEncoder
        }

        /// Apple's converted Stable Diffusion 2.1 base, `split_einsum` variant (Neural Engine
        /// friendly). Published under `apple/coreml-stable-diffusion-2-1-base`.
        public static let sd21Base = Model(
            repoId: "apple/coreml-stable-diffusion-2-1-base",
            subfolder: "split_einsum/compiled",
            cacheName: "coreml-sd-2-1-base-split-einsum"
        )
    }

    private let model: Model
    private let stepCount: Int
    private let computeUnits: MLComputeUnits
    private let session: URLSession

    // The engine holds the non-Sendable Core ML pipeline; it is created lazily behind an
    // availability check (the pipeline requires iOS 16.2 / macOS 13.1, one minor above the
    // package floor). `any Sendable` box keeps the property free of the availability attr.
    private let engineLock = NSLock()
    nonisolated(unsafe) private var engineBox: (any Sendable)?

    public init(
        model: Model = .sd21Base,
        stepCount: Int = 20,
        computeUnits: MLComputeUnits = .cpuAndNeuralEngine,
        session: URLSession = .shared
    ) {
        self.model = model
        self.stepCount = stepCount
        self.computeUnits = computeUnits
        self.session = session
    }

    @available(iOS 16.2, macOS 13.1, *)
    private func engine() -> DiffusionEngine {
        engineLock.lock(); defer { engineLock.unlock() }
        if let existing = engineBox as? DiffusionEngine { return existing }
        let created = DiffusionEngine(model: model, computeUnits: computeUnits, session: session)
        engineBox = created
        return created
    }

    public func isReady() async -> Bool {
        // Ready if resources are already cached OR the Hugging Face API is reachable.
        if resourcesAlreadyDownloaded { return true }
        var req = URLRequest(url: URL(string: "https://huggingface.co/api/models/\(model.repoId)")!)
        req.httpMethod = "HEAD"
        req.timeoutInterval = 5
        if let (_, response) = try? await session.data(for: req) {
            return (response as? HTTPURLResponse)?.statusCode ?? 500 < 500
        }
        return false
    }

    public func generate(prompt: String, style: ImagePlaygroundStyle, count: Int) async throws -> [CGImage] {
        guard #available(iOS 16.2, macOS 13.1, *) else {
            throw ImageGenerationBackendError.decodingFailed(
                "On-device Stable Diffusion requires iOS 16.2 / macOS 13.1 or newer"
            )
        }
        // The non-Sendable Core ML pipeline is confined to `DiffusionEngine` (an actor);
        // only Sendable values (the prompt, counts) cross the boundary, and CGImages come back.
        let resources = try await ensureResources()
        return try await engine().generate(
            prompt: styledPrompt(prompt, style),
            count: max(1, count),
            stepCount: stepCount,
            resources: resources
        )
    }

    /// Fold Apple's style into the prompt as an art direction (the pipeline has no style field).
    private func styledPrompt(_ prompt: String, _ style: ImagePlaygroundStyle) -> String {
        switch style.id {
        case ImagePlaygroundStyle.animation.id: return "\(prompt), 3D animated character style"
        case ImagePlaygroundStyle.illustration.id: return "\(prompt), clean vector illustration"
        case ImagePlaygroundStyle.sketch.id: return "\(prompt), hand-drawn pencil sketch"
        default: return prompt
        }
    }

    // MARK: - Download + unzip

    private var cacheDirectory: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return base
            .appendingPathComponent("OpenImagePlayground", isDirectory: true)
            .appendingPathComponent(model.cacheName, isDirectory: true)
    }

    /// The unpacked resources dir holds the compiled `.mlmodelc` bundles.
    private var resourcesAlreadyDownloaded: Bool {
        let fm = FileManager.default
        guard let contents = try? fm.contentsOfDirectory(atPath: cacheDirectory.path) else { return false }
        return contents.contains { $0.hasSuffix(".mlmodelc") }
    }

    /// Ensure the compiled Core ML resources exist locally, snapshotting the model's
    /// subfolder from Hugging Face file-by-file once (no zip archive exists upstream).
    private func ensureResources() async throws -> URL {
        let fm = FileManager.default
        if resourcesAlreadyDownloaded { return cacheDirectory }
        try fm.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)

        // List every file in the repo, keep those under the variant subfolder.
        let prefix = model.subfolder.hasSuffix("/") ? model.subfolder : model.subfolder + "/"
        let files = try await listRepoFiles().filter { $0.hasPrefix(prefix) }
        guard !files.isEmpty else {
            throw ImageGenerationBackendError.decodingFailed(
                "No files under \(model.repoId)/\(model.subfolder) on Hugging Face"
            )
        }

        // Download each into the cache, stripping the subfolder prefix so `.mlmodelc`
        // bundles land at the resources root where StableDiffusionPipeline expects them.
        for rfilename in files {
            let relative = String(rfilename.dropFirst(prefix.count))
            if relative.isEmpty { continue }
            let dest = cacheDirectory.appendingPathComponent(relative)
            if fm.fileExists(atPath: dest.path) { continue }
            try fm.createDirectory(at: dest.deletingLastPathComponent(), withIntermediateDirectories: true)
            let resolve = "https://huggingface.co/\(model.repoId)/resolve/main/\(pathEscaped(rfilename))"
            guard let url = URL(string: resolve) else { continue }
            let (tempFile, response) = try await session.download(from: url)
            if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                throw ImageGenerationBackendError.http(status: http.statusCode, body: "download failed for \(rfilename)")
            }
            if fm.fileExists(atPath: dest.path) { try fm.removeItem(at: dest) }
            try fm.moveItem(at: tempFile, to: dest)
        }

        guard resourcesAlreadyDownloaded else {
            throw ImageGenerationBackendError.decodingFailed("download did not yield .mlmodelc resources")
        }
        return cacheDirectory
    }

    /// Fetch the list of files in the repo via the Hugging Face model API.
    private func listRepoFiles() async throws -> [String] {
        let api = URL(string: "https://huggingface.co/api/models/\(model.repoId)")!
        let (data, response) = try await session.data(from: api)
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw ImageGenerationBackendError.http(status: http.statusCode, body: "model listing failed")
        }
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let siblings = json["siblings"] as? [[String: Any]] else {
            throw ImageGenerationBackendError.decodingFailed("unexpected Hugging Face model listing")
        }
        return siblings.compactMap { $0["rfilename"] as? String }
    }

    /// Percent-escape each path segment (keeps `/` separators) for the resolve URL.
    private func pathEscaped(_ path: String) -> String {
        path.split(separator: "/", omittingEmptySubsequences: false)
            .map { $0.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? String($0) }
            .joined(separator: "/")
    }
}

/// Owns the non-`Sendable` `StableDiffusionPipeline` on a single isolation domain so it
/// never crosses a concurrency boundary. Loads once (lazily) and runs real denoising.
@available(iOS 16.2, macOS 13.1, *)
private actor DiffusionEngine {
    private let model: CoreMLDiffusionBackend.Model
    private let computeUnits: MLComputeUnits
    private let session: URLSession
    private var pipeline: StableDiffusionPipeline?

    init(model: CoreMLDiffusionBackend.Model, computeUnits: MLComputeUnits, session: URLSession) {
        self.model = model
        self.computeUnits = computeUnits
        self.session = session
    }

    /// Load the pipeline if needed, then run `stepCount` denoising steps to produce images.
    func generate(prompt: String, count: Int, stepCount: Int, resources: URL) throws -> [CGImage] {
        let pipeline = try loadedPipeline(resources: resources)
        var config = StableDiffusionPipeline.Configuration(prompt: prompt)
        config.imageCount = count
        config.stepCount = stepCount
        config.seed = UInt32.random(in: 0...UInt32.max)
        config.disableSafety = true

        // Real denoising: runs the UNet for `stepCount` steps and VAE-decodes latents.
        let images = try pipeline.generateImages(configuration: config) { _ in true }
        let produced = images.compactMap { $0 }
        guard !produced.isEmpty else {
            throw ImageGenerationBackendError.decodingFailed("pipeline produced no images")
        }
        return produced
    }

    private func loadedPipeline(resources: URL) throws -> StableDiffusionPipeline {
        if let pipeline { return pipeline }
        let mlConfig = MLModelConfiguration()
        mlConfig.computeUnits = computeUnits
        let created = try StableDiffusionPipeline(
            resourcesAt: resources,
            controlNet: [],
            configuration: mlConfig,
            disableSafety: true,
            reduceMemory: true,
            useMultilingualTextEncoder: model.useMultilingualTextEncoder,
            script: nil
        )
        try created.loadResources()
        pipeline = created
        return created
    }
}
#endif
