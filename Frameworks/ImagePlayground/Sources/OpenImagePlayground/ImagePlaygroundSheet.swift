#if canImport(SwiftUI)
import CoreGraphics
import Foundation
import ImageIO
import SwiftUI

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

// MARK: - Environment

private struct AllowedGenerationStylesKey: EnvironmentKey {
    static let defaultValue: [ImagePlaygroundStyle] = ImagePlaygroundStyle.all
}
private struct SelectedGenerationStyleKey: EnvironmentKey {
    static let defaultValue: ImagePlaygroundStyle = .illustration
}
private struct PersonalizationPolicyKey: EnvironmentKey {
    static let defaultValue: ImagePlaygroundPersonalizationPolicy = .automatic
}
private struct SupportsImagePlaygroundKey: EnvironmentKey {
    static var defaultValue: Bool { OpenImagePlayground.backend != nil }
}

public extension EnvironmentValues {
    var imagePlaygroundAllowedGenerationStyles: [ImagePlaygroundStyle] {
        get { self[AllowedGenerationStylesKey.self] }
        set { self[AllowedGenerationStylesKey.self] = newValue }
    }
    var imagePlaygroundSelectedGenerationStyle: ImagePlaygroundStyle {
        get { self[SelectedGenerationStyleKey.self] }
        set { self[SelectedGenerationStyleKey.self] = newValue }
    }
    var imagePlaygroundPersonalizationPolicy: ImagePlaygroundPersonalizationPolicy {
        get { self[PersonalizationPolicyKey.self] }
        set { self[PersonalizationPolicyKey.self] = newValue }
    }
    var supportsImagePlayground: Bool {
        get { self[SupportsImagePlaygroundKey.self] }
        set { self[SupportsImagePlaygroundKey.self] = newValue }
    }
}

// MARK: - Style / policy modifiers

public extension View {
    func imagePlaygroundGenerationStyle(
        _ style: ImagePlaygroundStyle,
        in allowedStyles: [ImagePlaygroundStyle] = ImagePlaygroundStyle.all
    ) -> some View {
        environment(\.imagePlaygroundSelectedGenerationStyle, style)
            .environment(\.imagePlaygroundAllowedGenerationStyles, allowedStyles)
    }

    func imagePlaygroundPersonalizationPolicy(
        _ policy: ImagePlaygroundPersonalizationPolicy = .automatic
    ) -> some View {
        environment(\.imagePlaygroundPersonalizationPolicy, policy)
    }
}

// MARK: - Sheet modifiers (mirror the four spec overloads)

public extension View {
    func imagePlaygroundSheet(
        isPresented: Binding<Bool>,
        concepts: [ImagePlaygroundConcept] = [],
        sourceImage: Image? = nil,
        onCompletion: @escaping (URL) -> Void,
        onCancellation: (() -> Void)? = nil
    ) -> some View {
        modifier(ImagePlaygroundSheetModifier(
            isPresented: isPresented,
            concepts: concepts,
            onCompletion: onCompletion,
            onCancellation: onCancellation
        ))
    }

    func imagePlaygroundSheet(
        isPresented: Binding<Bool>,
        concepts: [ImagePlaygroundConcept] = [],
        sourceImageURL: URL,
        onCompletion: @escaping (_ url: URL) -> Void,
        onCancellation: (() -> Void)? = nil
    ) -> some View {
        var seeded = concepts
        if let concept = ImagePlaygroundConcept.image(sourceImageURL) {
            seeded.append(concept)
        }
        return modifier(ImagePlaygroundSheetModifier(
            isPresented: isPresented,
            concepts: seeded,
            onCompletion: onCompletion,
            onCancellation: onCancellation
        ))
    }

    func imagePlaygroundSheet(
        isPresented: Binding<Bool>,
        concept: String,
        sourceImageURL: URL,
        onCompletion: @escaping (_ url: URL) -> Void,
        onCancellation: (() -> Void)? = nil
    ) -> some View {
        var seeded: [ImagePlaygroundConcept] = [.text(concept)]
        if let imageConcept = ImagePlaygroundConcept.image(sourceImageURL) {
            seeded.append(imageConcept)
        }
        return modifier(ImagePlaygroundSheetModifier(
            isPresented: isPresented,
            concepts: seeded,
            onCompletion: onCompletion,
            onCancellation: onCancellation
        ))
    }

    func imagePlaygroundSheet(
        isPresented: Binding<Bool>,
        concept: String,
        sourceImage: Image? = nil,
        onCompletion: @escaping (_ url: URL) -> Void,
        onCancellation: (() -> Void)? = nil
    ) -> some View {
        modifier(ImagePlaygroundSheetModifier(
            isPresented: isPresented,
            concepts: [.text(concept)],
            onCompletion: onCompletion,
            onCancellation: onCancellation
        ))
    }
}

// MARK: - Implementation

private struct ImagePlaygroundSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    let concepts: [ImagePlaygroundConcept]
    let onCompletion: (URL) -> Void
    let onCancellation: (() -> Void)?

    func body(content: Content) -> some View {
        content.sheet(isPresented: $isPresented) {
            ImagePlaygroundSheetView(
                concepts: concepts,
                onCompletion: { url in
                    isPresented = false
                    onCompletion(url)
                },
                onCancellation: {
                    isPresented = false
                    onCancellation?()
                }
            )
        }
    }
}

/// Minimal generation UI: shows progress, generates from the backend, previews the
/// result, and returns its temporary-file URL via `onCompletion`.
private struct ImagePlaygroundSheetView: View {
    @Environment(\.imagePlaygroundSelectedGenerationStyle) private var style
    let concepts: [ImagePlaygroundConcept]
    let onCompletion: (URL) -> Void
    let onCancellation: () -> Void

    @State private var image: CGImage?
    @State private var errorText: String?
    @State private var isWorking = true
    @State private var resultURL: URL?

    var body: some View {
        VStack(spacing: 16) {
            Text("Image Playground")
                .font(.headline)

            if isWorking {
                ProgressView("Generating…")
            } else if let errorText {
                Text(errorText)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            } else if let image {
                Image(decorative: image, scale: 1.0)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 300, maxHeight: 300)
            }

            HStack {
                Button("Cancel", action: onCancellation)
                Spacer()
                if let resultURL, !isWorking {
                    Button("Use") { onCompletion(resultURL) }
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .task { await generate() }
    }

    private func generate() async {
        do {
            let creator = try await ImageCreator()
            var seed = concepts
            if seed.isEmpty { seed = [.text("")] }
            for try await created in creator.images(for: seed, style: style, limit: 1) {
                let url = try writeTemporaryPNG(created.cgImage)
                image = created.cgImage
                resultURL = url
                isWorking = false
                return
            }
            errorText = "No image was generated."
            isWorking = false
        } catch {
            errorText = (error as? LocalizedError)?.errorDescription ?? "\(error)"
            isWorking = false
        }
    }

    private func writeTemporaryPNG(_ image: CGImage) throws -> URL {
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
#endif
