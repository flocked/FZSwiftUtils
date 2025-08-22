//
//  Range+.swift
//
//
//  Created by Florian Zand on 27.09.23.
//

import Foundation

public extension ClosedRange where Bound: BinaryInteger {
    /// The range as double range.
    var toDouble: ClosedRange<Double> {
        Double(lowerBound)...Double(upperBound)
    }
}

public extension Range where Bound: BinaryInteger {
    /// The range as double range.
    var toDouble: Range<Double> {
        Double(lowerBound)..<Double(upperBound)
    }
}

public extension ClosedRange where Bound: Strideable {
    /// `Range` representation of the range.
    var toRange: Range<Bound> {
        lowerBound..<upperBound.advanced(by: 1)
    }
}

public extension Range where Bound: Strideable {
    var toClosedRange: ClosedRange<Bound> {
        lowerBound...Swift.min(lowerBound, upperBound.advanced(by: -1))
    }
}

public extension Range where Bound == String.Index {
    /// `NSRange` representation of the range.
    func nsRange<S: StringProtocol>(in string: S) -> NSRange {
        NSRange(self, in: string)
    }
}

/// A type that represents a range.
public protocol RangeRepresentable: RangeExpression {
    /// The range’s lower bound.
    var lowerBound: Bound { get }
    /// The range’s upper bound.
    var upperBound: Bound { get }
    /// Creates an instance with the given bounds.
    init(uncheckedBounds bounds: (lower: Bound, upper: Bound))
}

extension ClosedRange: RangeRepresentable { }
extension Range: RangeRepresentable { }
extension NSRange: RangeRepresentable {
    public init(uncheckedBounds bounds: (lower: Int, upper: Int)) {
        self.init(location: bounds.lower, length: bounds.upper-bounds.lower)
    }
}
extension CFRange: RangeRepresentable {
    public init(uncheckedBounds bounds: (lower: CFIndex, upper: CFIndex)) {
        self.init(location: bounds.lower, length: bounds.upper-bounds.lower)
    }
}

public extension RangeRepresentable {
    /**
     Clamps the range to the lower- and upper bound of the specified range.

     - Parameter range: The range fo clamp to.
     */
    func clamped<Range: RangeRepresentable>(to range: Range) -> Self where Range.Bound == Bound {
        .init(uncheckedBounds: (lowerBound.clamped(min: range.lowerBound), upperBound.clamped(max: range.upperBound)))
    }

    /**
     Clamps the range to the lower- and upper bound of the specified range.

     - Parameter range: The range fo clamp to.
     */
    mutating func clamp<Range: RangeRepresentable>(to range: Range) where Range.Bound == Bound {
        self = clamped(to: range)
    }

    /**
     Clamps the lower bound to the minimum value.

     - Parameter minValue: The minimum value to clamp the lower bound.
     */
    mutating func clamp(min minValue: Bound) {
        self = clamped(min: minValue)
    }

    /**
     Clamps the lower bound to the minimum value.

     - Parameter minValue: The minimum value to clamp the lower bound.
     */
    func clamped(min minValue: Bound) -> Self {
        .init(uncheckedBounds: upperBound < minValue ? (minValue, minValue) : (lowerBound.clamped(min: minValue), upperBound.clamped(min: minValue)))
    }

    /**
     Clamps the upper bound to the maximum value.

     - Parameter maxValue: The maximum value to clamp the upper bound.
     */
    mutating func clamp(max maxValue: Bound) {
        self = clamped(max: maxValue)
    }

    /**
     Clamps the upper bound to the maximum value.

     - Parameter maxValue: The maximum value to clamp the upper bound.
     */
    func clamped(max maxValue: Bound) -> Self {
        .init(uncheckedBounds: lowerBound > maxValue ? (maxValue, maxValue) : (lowerBound, upperBound.clamped(max: maxValue)))
    }

    /// A Boolean value indicating whether the other range is fully contained within the range.
    func contains<R: RangeRepresentable>(_ range: R) -> Bool where R.Bound == Bound {
        range.lowerBound >= lowerBound && range.upperBound <= upperBound
    }
    
    /**
     A Boolean value indicating whether the other range overlaps the range.
     
     It returns `true` if the other range's lower bound is smaller than the current's lower bound and the other range's upper bound is larger than the current's upper bound.
     
     Example usage:
     
     ```swift
     let range = 3...7
     range.overlaps(5...10) // true
     range.overlaps(8...12) // false
     ```
     */
    func overlaps<R: RangeRepresentable>(_ other: R) -> Bool where R.Bound == Bound {
        lowerBound < other.upperBound && upperBound > other.lowerBound
    }
    
    /**
     Returns the intersection of this range with another range, or `nil` if they do not overlap.
     
     Example usage:
     
     ```swift
     let range = 3...7
     range.intersection(5...10) // 5...7
     ```
     */
    func intersection<R: RangeRepresentable>(_ other: R) -> Self? where R.Bound == Bound {
        let lower = Swift.max(lowerBound, other.lowerBound)
        let upper = Swift.min(upperBound, other.upperBound)
        return lower <= upper ? .init(uncheckedBounds: (lower, upper)) : nil
    }
    
    /**
     Returns the smallest range that fully contains both ranges.
     
     Example usage:
     
     ```swift
     let range = 3...7
     range.union(5...10) // 3...10
     ```
     */
    func union<R: RangeRepresentable>(_ other: R) -> Self where R.Bound == Bound {
         .init(uncheckedBounds: (Swift.min(lowerBound, other.lowerBound), Swift.max(upperBound, other.upperBound)))
    }

    /// Creates an range from the specified values.
    init(checkedBounds value1: Bound, _ value2: Bound) {
        self = Self(uncheckedBounds: (Swift.min(value1, value2), Swift.max(value1, value2)))
    }
}

public extension RangeRepresentable where Bound: Strideable {
    /// The distance between the lower bound and upper bound.
    var length: Bound.Stride {
        lowerBound.distance(to: upperBound)
    }
}

public extension RangeRepresentable where Bound: BinaryInteger {
    /**
     Offsets the range by the specified value.

     - Parameter offset: The offset to shift.
     - Returns: The new range.
     */
    func shifted(by offset: Bound) -> Self {
        .init(uncheckedBounds: (lowerBound + offset, upperBound + offset))
    }
    
    /**
     Offsets the range by the specified value.

     - Parameter offset: The offset to shift.
     */
    mutating func shift(by offset: Bound) {
        self = shifted(by: offset)
    }

    /**
     Splits the range into an array of evenly spaced values.

     The returned array contains `amount` values starting at `lowerBound` and ending at `upperBound` (inclusive for the calculation).

     - Parameter amount: The number of segments to divide the range into.
     - Returns: An array of `Double` values evenly distributed across the range.

     Example usage:
     ```swift
     let values = (0...1).split(by: 5)
     // [0.0, 0.25, 0.5, 0.75, 1.0]
     ```
     */
    func split(by amount: Int) -> [Double] {
        guard amount > 1 else { return [Double(lowerBound), Double(upperBound)] }
        let step = Double(upperBound - lowerBound) / Double(amount)
        return (0...amount).map { Double(lowerBound) + Double($0) * step }
    }

    /// The midpoint value between the `lowerBound` and `upperBound`, using integer division.
    var center: Bound {
        (lowerBound + upperBound) / 2
    }
    
    /// `NSRange` representation of the range.
    var nsRange: NSRange {
        NSRange(uncheckedBounds: (Int(lowerBound), Int(upperBound)))
    }
}

extension RangeRepresentable where Bound: BinaryFloatingPoint {
    /**
     Shifts the range by the specified offset value.

     - Parameter offset: The offset to shift.
     - Returns: The new range.
     */
    func shifted(by offset: Bound) -> Self {
        .init(uncheckedBounds: (lowerBound + offset ,upperBound + offset ))
    }
    
    func sdsds() {
        //(0.0...1.0).
    }
    
    /**
     Offsets the range by the specified value.

     - Parameter offset: The offset to shift.
     */
    mutating func shift(by offset: Bound) {
        self = shifted(by: offset)
    }

    /**
     Splits the range into an array of evenly spaced values.

     The returned array contains `amount` values starting at `lowerBound` and ending at `upperBound` (inclusive for the calculation).

     - Parameter amount: The number of segments to divide the range into.
     - Returns: An array of `Bound` values evenly distributed across the range.

     Example usage:
     ```swift
     let values = (0.0...1.0).split(by: 5)
     // [0.0, 0.25, 0.5, 0.75, 1.0]
     ```
     */
    func split(by amount: Int) -> [Bound] {
        guard amount > 1 else { return amount == 1 ? [lowerBound] : [] }
        let step = (upperBound - lowerBound) / Bound(amount - 1)
        return (0..<amount).map { lowerBound + Bound($0) * step }
    }

    /// The midpoint value between the `lowerBound` and `upperBound`.
    var center: Bound {
        (lowerBound + upperBound) / 2.0
    }
}

public extension RangeRepresentable where Bound: BinaryInteger, Bound.Stride: SignedInteger {
    /// `Array` representation of the range.
    var array: [Bound] {
        self is ClosedRange<Bound> ? (lowerBound...upperBound).map({ $0 }) : (lowerBound..<upperBound).map({ $0 })
    }
}

public extension Sequence where Element: RangeRepresentable {
    /// Returns the union of all ranges in the sequence.
    var union: Element? {
        guard let min = min, let max = max else { return nil }
        return .init(uncheckedBounds: (min, max))
    }

    /// Returns the minimum lower bound in the sequence.
    var min: Element.Bound? {
        map(\.lowerBound).min()
    }

    /// Returns the maximum upper bound in the sequence.
    var max: Element.Bound? {
        map(\.upperBound).max()
    }
}

extension CFRange: Collection, BidirectionalCollection, RandomAccessCollection, RangeExpression {
    public var startIndex: CFIndex { lowerBound }

    public var endIndex: CFIndex { upperBound }

    public func index(after i: CFIndex) -> CFIndex {
        precondition(i < endIndex, "Index out of bounds")
        return i + 1
    }

    public func index(before i: CFIndex) -> CFIndex {
        precondition(i > startIndex, "Index out of bounds")
        return i - 1
    }

    public subscript(position: CFIndex) -> CFIndex {
        precondition(contains(position), "Index out of bounds")
        return position
    }

    public var count: Int { length }
    
    public func relative<C>(to collection: C) -> Range<CFIndex> where C: Collection, CFIndex == C.Index {
        location..<Swift.min(location + length, collection.count)
    }
    
    public func contains(_ bound: CFIndex) -> Bool {
        lowerBound <= bound && bound < upperBound
    }
    
    public var lowerBound: CFIndex { location }
    
    public var upperBound: CFIndex { location + length }
}
