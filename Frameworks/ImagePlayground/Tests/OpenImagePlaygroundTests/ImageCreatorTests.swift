import CoreGraphics
import ImageIO
import XCTest
@testable import OpenImagePlayground

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

final class ImageCreatorTests: XCTestCase {
    override func setUp() {
        super.setUp()
        OpenImagePlayground.reset()
    }

    override func tearDown() {
        OpenImagePlayground.reset()
        super.tearDown()
    }

    func testStubBackendReturnsRequestedNumberOfImages() async throws {
        OpenImagePlayground.configure(backend: StubImageBackend())
        let creator = try await ImageCreator()
        var images: [ImageCreator.CreatedImage] = []
        for try await created in creator.images(
            for: [.text("a red bicycle")],
            style: .illustration,
            limit: 3
        ) {
            images.append(created)
        }
        XCTAssertEqual(images.count, 3)
        XCTAssertEqual(images.first?.cgImage.width, 64)
        XCTAssertEqual(images.first?.cgImage.height, 64)
    }

    func testLimitOfOne() async throws {
        let creator = ImageCreator(backend: StubImageBackend())
        var count = 0
        for try await _ in creator.images(for: [.text("cat")], style: .sketch, limit: 1) {
            count += 1
        }
        XCTAssertEqual(count, 1)
    }

    func testDefaultBackendIsOnDeviceDiffusion() {
        // With no explicit configuration, the shipping default is the REAL on-device
        // Core ML Stable Diffusion pipeline (not a stub/rectangle).
        XCTAssertFalse(OpenImagePlayground.isExplicitlyConfigured)
        XCTAssertTrue(OpenImagePlayground.backend is CoreMLDiffusionBackend)
        XCTAssertTrue(OpenImagePlayground.isExplicitlyConfigured == false)
        XCTAssertEqual(OpenImagePlayground.backend?.identifier, "coreml-stable-diffusion")
    }

    func testConfigureOverridesDefault() {
        OpenImagePlayground.configure(backend: StubImageBackend())
        XCTAssertTrue(OpenImagePlayground.isExplicitlyConfigured)
        XCTAssertTrue(OpenImagePlayground.backend is StubImageBackend)
    }

    func testBuildPromptJoinsConcepts() {
        let prompt = ImageCreator.buildPrompt(from: [
            .text("a fox"),
            .extracted(from: "autumn forest", title: "Scene"),
        ])
        XCTAssertEqual(prompt, "a fox, Scene: autumn forest")
    }

    func testAvailableStyles() {
        let creator = ImageCreator(backend: StubImageBackend())
        XCTAssertEqual(creator.availableStyles, ImagePlaygroundStyle.all)
    }

    func testStyleCodableRoundTrip() throws {
        let data = try JSONEncoder().encode(ImagePlaygroundStyle.sketch)
        let decoded = try JSONDecoder().decode(ImagePlaygroundStyle.self, from: data)
        XCTAssertEqual(decoded, .sketch)
        XCTAssertEqual(decoded.id, "sketch")
    }

    func testErrorAllCasesIncludesEveryCase() {
        XCTAssertTrue(ImageCreator.Error.allCases.contains(.notSupported))
        XCTAssertTrue(ImageCreator.Error.allCases.contains(.conceptsRequirePersonIdentity))
    }

    func testPersonalizationPolicyRawValues() {
        XCTAssertEqual(ImagePlaygroundPersonalizationPolicy.automatic.rawValue, 0)
        XCTAssertEqual(ImagePlaygroundPersonalizationPolicy(rawValue: 2), .disabled)
    }
}

// Gated live test against a real OpenAI-compatible images endpoint.
// Run with: IMG_LIVE=1 OPENAI_API_KEY=sk-… swift test
final class LiveImageBackendTests: XCTestCase {
    func testLiveGeneration() async throws {
        let env = ProcessInfo.processInfo.environment
        try XCTSkipUnless(env["IMG_LIVE"] == "1", "set IMG_LIVE=1 to run live endpoint test")

        let endpointString = env["IMG_ENDPOINT"] ?? "https://api.openai.com/v1"
        let backend = OpenAIImageBackend(
            endpoint: URL(string: endpointString)!,
            model: env["IMG_MODEL"] ?? "gpt-image-1",
            apiKey: env["OPENAI_API_KEY"]
        )
        OpenImagePlayground.configure(backend: backend)
        defer { OpenImagePlayground.reset() }

        let creator = try await ImageCreator()
        var count = 0
        for try await created in creator.images(
            for: [.text("a friendly robot waving")],
            style: .illustration,
            limit: 1
        ) {
            XCTAssertGreaterThan(created.cgImage.width, 0)
            count += 1
        }
        XCTAssertEqual(count, 1)
    }
}

// Gated live test against the REAL default on-device Core ML Stable Diffusion backend
// (`CoreMLDiffusionBackend`). Downloads Apple's converted SD 2.1-base model (~1.5-2 GB)
// from Hugging Face on first run, loads it into a `StableDiffusionPipeline`, and runs
// actual UNet denoising + VAE decode on-device (Neural Engine/GPU via Core ML). This
// exercises Metal/Core ML compute, which `swift test` cannot do headless — run via
// `xcodebuild test` with a real destination so the ANE/GPU compute graph actually executes.
//
// Run with:
// IMG_LIVE=1 xcodebuild test -scheme OpenImagePlayground \
//   -destination 'platform=macOS,arch=arm64' -only-testing:OpenImagePlaygroundTests/LiveCoreMLDiffusionTests
//
// `xcodebuild test` does not propagate the invoking shell's environment into the test
// process, so the gate also accepts a marker file (same trigger, different transport):
// `touch /tmp/ofm-imageplayground-img-live` before invoking `xcodebuild test`.
final class LiveCoreMLDiffusionTests: XCTestCase {
    private static let markerFile = "/tmp/ofm-imageplayground-img-live"

    func testLiveOnDeviceGeneration() async throws {
        let env = ProcessInfo.processInfo.environment
        let gated = env["IMG_LIVE"] == "1" || FileManager.default.fileExists(atPath: Self.markerFile)
        try XCTSkipUnless(
            gated,
            "set IMG_LIVE=1 (or touch \(Self.markerFile)) to run the live on-device Core ML diffusion test"
        )

        OpenImagePlayground.reset()
        defer { OpenImagePlayground.reset() }

        // Default, zero-config backend: real on-device Core ML Stable Diffusion.
        let creator = try await ImageCreator()

        var produced: CGImage?
        for try await created in creator.images(
            for: [.text("a red apple on a table")],
            style: .illustration,
            limit: 1
        ) {
            produced = created.cgImage
        }

        guard let cgImage = produced else {
            XCTFail("on-device Core ML diffusion produced no image")
            return
        }

        XCTAssertGreaterThan(cgImage.width, 0)
        XCTAssertGreaterThan(cgImage.height, 0)

        let outputURL = URL(fileURLWithPath: "/tmp/ofm-imageplayground-proof.png")
        try Self.writePNG(cgImage, to: outputURL)

        print("[LiveCoreMLDiffusionTests] wrote \(cgImage.width)x\(cgImage.height) PNG to \(outputURL.path)")
    }

    /// Encode a `CGImage` to a PNG file on disk via ImageIO (no UIKit/AppKit dependency).
    private static func writePNG(_ image: CGImage, to url: URL) throws {
        let type: CFString
        #if canImport(UniformTypeIdentifiers)
        type = UTType.png.identifier as CFString
        #else
        type = "public.png" as CFString
        #endif
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, type, 1, nil) else {
            throw ImageGenerationBackendError.decodingFailed("could not create PNG destination at \(url.path)")
        }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else {
            throw ImageGenerationBackendError.decodingFailed("failed to finalize PNG at \(url.path)")
        }
    }
}
