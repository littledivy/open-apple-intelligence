#if canImport(UIKit) && !os(watchOS)
import CoreGraphics
import Foundation
import ImageIO
import UIKit

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

/// Presents a minimal image-generation UI. Mirrors
/// `ImagePlayground.ImagePlaygroundViewController`.
///
/// On Apple's OS this is the system Image Playground sheet; here it is a small
/// backend-driven controller: it generates from `concepts` + `selectedGenerationStyle`,
/// writes the first result to a temporary file, and calls the delegate with its URL.
@MainActor
open class ImagePlaygroundViewController: UIViewController {
    /// Receives creation / cancellation callbacks. Mirrors the spec's `Delegate` protocol.
    @objc(ImageGenerationViewControllerDelegate)
    public protocol Delegate: NSObjectProtocol {
        @objc func imagePlaygroundViewController(
            _ imagePlaygroundViewController: ImagePlaygroundViewController,
            didCreateImageAt imageURL: URL
        )
        @objc optional func imagePlaygroundViewControllerDidCancel(
            _ imagePlaygroundViewController: ImagePlaygroundViewController
        )
    }

    public var allowedGenerationStyles: [ImagePlaygroundStyle] = ImagePlaygroundStyle.all
    public var selectedGenerationStyle: ImagePlaygroundStyle = .illustration
    public var personalizationPolicy: ImagePlaygroundPersonalizationPolicy = .automatic
    public var sourceImage: UIImage?
    public weak var delegate: (any Delegate)?
    public var concepts: [ImagePlaygroundConcept] = []

    public convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    /// Whether generation is available (a backend is configured). Mirrors `isAvailable`.
    @objc(available)
    public class var isAvailable: Bool {
        OpenImagePlayground.backend != nil
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        Task { await generate() }
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    private func generate() async {
        do {
            let creator = try await ImageCreator()
            let prompt = ImageCreator.buildPrompt(from: concepts)
            var seedConcepts = concepts
            if seedConcepts.isEmpty { seedConcepts = [.text(prompt)] }
            for try await created in creator.images(
                for: seedConcepts,
                style: selectedGenerationStyle,
                limit: 1
            ) {
                let url = try Self.writeTemporaryPNG(created.cgImage)
                delegate?.imagePlaygroundViewController(self, didCreateImageAt: url)
                return
            }
            // No image produced → treat as cancellation.
            delegate?.imagePlaygroundViewControllerDidCancel?(self)
        } catch {
            delegate?.imagePlaygroundViewControllerDidCancel?(self)
        }
    }

    static func writeTemporaryPNG(_ image: CGImage) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("png")
        let type: CFString
        #if canImport(UniformTypeIdentifiers)
        type = UTType.png.identifier as CFString
        #else
        type = "public.png" as CFString
        #endif
        guard let dest = CGImageDestinationCreateWithURL(url as CFURL, type, 1, nil) else {
            throw ImageCreator.Error.creationFailed
        }
        CGImageDestinationAddImage(dest, image, nil)
        guard CGImageDestinationFinalize(dest) else {
            throw ImageCreator.Error.creationFailed
        }
        return url
    }
}

extension ImagePlaygroundViewController: @unchecked Sendable {}
#endif
