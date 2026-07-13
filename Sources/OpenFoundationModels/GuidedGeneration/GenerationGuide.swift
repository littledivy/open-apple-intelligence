import Foundation

/// A constraint that guides how a value is generated. Mirrors
/// `FoundationModels.GenerationGuide`.
///
/// Guides are created through the static factory methods in the extensions
/// below (e.g. `.minimum(0)`, `.anyOf([...])`, `.count(3)`). Internally each
/// guide carries a `Constraint` so schemas can translate it into JSON-Schema
/// keywords for constrained decoding.
public struct GenerationGuide<Value> {
    let constraint: GuideConstraint

    init(constraint: GuideConstraint) {
        self.constraint = constraint
    }
}

/// Internal, non-generic description of a guide's constraint. Consumed by
/// `GenerationSchema` when emitting JSON Schema. Being non-generic lets a
/// nested element guide be stored without an unsafe cast.
indirect enum GuideConstraint: Sendable {
    case constant(String)
    case anyOf([String])
    case pattern(String)
    case minimum(Double)
    case maximum(Double)
    case range(ClosedRange<Double>)
    case minimumCount(Int)
    case maximumCount(Int)
    case countRange(ClosedRange<Int>)
    case count(Int)
    case element(GuideConstraint)
}

// MARK: - String guides

extension GenerationGuide where Value == String {
    public static func constant(_ value: String) -> GenerationGuide<String> {
        GenerationGuide(constraint: .constant(value))
    }

    public static func anyOf(_ values: [String]) -> GenerationGuide<String> {
        GenerationGuide(constraint: .anyOf(values))
    }

    public static func pattern<Output>(_ regex: Regex<Output>) -> GenerationGuide<String> {
        // Minimal body: retain the pattern text where available.
        GenerationGuide(constraint: .pattern(String(describing: regex)))
    }
}

// MARK: - Int guides

extension GenerationGuide where Value == Int {
    public static func minimum(_ value: Int) -> GenerationGuide<Int> {
        GenerationGuide(constraint: .minimum(Double(value)))
    }

    public static func maximum(_ value: Int) -> GenerationGuide<Int> {
        GenerationGuide(constraint: .maximum(Double(value)))
    }

    public static func range(_ range: ClosedRange<Int>) -> GenerationGuide<Int> {
        GenerationGuide(constraint: .range(Double(range.lowerBound)...Double(range.upperBound)))
    }
}

// MARK: - Float guides

extension GenerationGuide where Value == Float {
    public static func minimum(_ value: Float) -> GenerationGuide<Float> {
        GenerationGuide(constraint: .minimum(Double(value)))
    }

    public static func maximum(_ value: Float) -> GenerationGuide<Float> {
        GenerationGuide(constraint: .maximum(Double(value)))
    }

    public static func range(_ range: ClosedRange<Float>) -> GenerationGuide<Float> {
        GenerationGuide(constraint: .range(Double(range.lowerBound)...Double(range.upperBound)))
    }
}

// MARK: - Decimal guides

extension GenerationGuide where Value == Decimal {
    public static func minimum(_ value: Decimal) -> GenerationGuide<Decimal> {
        GenerationGuide(constraint: .minimum((value as NSDecimalNumber).doubleValue))
    }

    public static func maximum(_ value: Decimal) -> GenerationGuide<Decimal> {
        GenerationGuide(constraint: .maximum((value as NSDecimalNumber).doubleValue))
    }

    public static func range(_ range: ClosedRange<Decimal>) -> GenerationGuide<Decimal> {
        let lower = (range.lowerBound as NSDecimalNumber).doubleValue
        let upper = (range.upperBound as NSDecimalNumber).doubleValue
        return GenerationGuide(constraint: .range(lower...upper))
    }
}

// MARK: - Double guides

extension GenerationGuide where Value == Double {
    public static func minimum(_ value: Double) -> GenerationGuide<Double> {
        GenerationGuide(constraint: .minimum(value))
    }

    public static func maximum(_ value: Double) -> GenerationGuide<Double> {
        GenerationGuide(constraint: .maximum(value))
    }

    public static func range(_ range: ClosedRange<Double>) -> GenerationGuide<Double> {
        GenerationGuide(constraint: .range(range))
    }
}

// MARK: - Array guides

extension GenerationGuide {
    public static func minimumCount<Element>(_ count: Int) -> GenerationGuide<[Element]> where Value == [Element] {
        GenerationGuide<[Element]>(constraint: .minimumCount(count))
    }

    public static func maximumCount<Element>(_ count: Int) -> GenerationGuide<[Element]> where Value == [Element] {
        GenerationGuide<[Element]>(constraint: .maximumCount(count))
    }

    public static func count<Element>(_ range: ClosedRange<Int>) -> GenerationGuide<[Element]> where Value == [Element] {
        GenerationGuide<[Element]>(constraint: .countRange(range))
    }

    public static func count<Element>(_ count: Int) -> GenerationGuide<[Element]> where Value == [Element] {
        GenerationGuide<[Element]>(constraint: .count(count))
    }

    public static func element<Element>(_ guide: GenerationGuide<Element>) -> GenerationGuide<[Element]> where Value == [Element] {
        GenerationGuide<[Element]>(constraint: .element(guide.constraint))
    }
}

// MARK: - [Never] guides (spec-mandated fatalError stubs)

extension GenerationGuide where Value == [Never] {
    @_alwaysEmitIntoClient public static func minimumCount(_ count: Int) -> GenerationGuide<Value> {
        fatalError("GenerationGuide<[Never]>.\(#function) should not be called.")
    }
    @_alwaysEmitIntoClient public static func maximumCount(_ count: Int) -> GenerationGuide<Value> {
        fatalError("GenerationGuide<[Never]>.\(#function) should not be called.")
    }
    @_alwaysEmitIntoClient public static func count(_ range: ClosedRange<Int>) -> GenerationGuide<Value> {
        fatalError("GenerationGuide<[Never]>.\(#function) should not be called.")
    }
    @_disfavoredOverload @_alwaysEmitIntoClient public static func count(_ count: Int) -> GenerationGuide<Value> {
        fatalError("GenerationGuide<[Never]>.\(#function) should not be called.")
    }
}
