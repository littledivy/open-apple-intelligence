import Foundation

/// A visual style for generated images. Mirrors `ImagePlayground.ImagePlaygroundStyle`.
/// (Spec `@available(iOS 26.0…) externalProvider` is kept unconditionally here since
/// this polyfill targets old OSes and strips availability gating.)
public struct ImagePlaygroundStyle: Codable, Equatable, Hashable, Identifiable, Sendable {
    public static let animation = ImagePlaygroundStyle(id: "animation")
    public static let illustration = ImagePlaygroundStyle(id: "illustration")
    public static let sketch = ImagePlaygroundStyle(id: "sketch")
    public static let externalProvider = ImagePlaygroundStyle(id: "externalProvider")

    public static var all: [ImagePlaygroundStyle] {
        [.animation, .illustration, .sketch]
    }

    public typealias ID = String
    public let id: String

    private init(id: String) {
        self.id = id
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.id = try container.decode(String.self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(id)
    }
}
