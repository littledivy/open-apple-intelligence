import Foundation

/// Whether personalized (person-identity) generation is permitted. Mirrors
/// `ImagePlayground.ImagePlaygroundPersonalizationPolicy`. In this polyfill it is a
/// surface-level preference — no on-device personalization exists off Apple Intelligence.
public enum ImagePlaygroundPersonalizationPolicy: Int, Equatable, Hashable, RawRepresentable, Sendable {
    case automatic
    case enabled
    case disabled
}
