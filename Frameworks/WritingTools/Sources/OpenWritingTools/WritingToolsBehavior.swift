import Foundation

/// Mirror of UIKit's `UIWritingToolsBehavior` (declared in `UITextInputTraits.h`),
/// with availability gating stripped so it exists on every OS.
///
/// Raw values match Apple's exactly so the two are interchangeable where the real
/// type is present.
public enum WritingToolsBehavior: Int, Sendable {
    /// Writing Tools will ignore this view. (`UIWritingToolsBehaviorNone`)
    case none = -1
    /// System-defined behavior; may resolve to `none`, `complete`, or `limited`.
    /// (`UIWritingToolsBehaviorDefault`)
    case `default` = 0
    /// The complete inline-editing experience, if possible.
    /// (`UIWritingToolsBehaviorComplete`)
    case complete = 1
    /// The limited, overlay-panel experience, if possible.
    /// (`UIWritingToolsBehaviorLimited`)
    case limited = 2
}

/// Mirror of UIKit's `UIWritingToolsResultOptions` (an `NS_OPTIONS` in
/// `UITextInputTraits.h`), availability gating stripped.
public struct WritingToolsResultOptions: OptionSet, Sendable {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }

    /// System-defined behavior. (`UIWritingToolsResultDefault`)
    public static let `default`: WritingToolsResultOptions = []
    /// Provide plain text in proofreading suggestions or rewrites.
    /// (`UIWritingToolsResultPlainText`)
    public static let plainText = WritingToolsResultOptions(rawValue: 1 << 0)
    /// Also provide natively-supported text attributes. (`UIWritingToolsResultRichText`)
    public static let richText = WritingToolsResultOptions(rawValue: 1 << 1)
    /// Also provide list-layout attributes. (`UIWritingToolsResultList`)
    public static let list = WritingToolsResultOptions(rawValue: 1 << 2)
}
