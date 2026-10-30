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

public extension Range where Bound: Strideable, Bound.Stride: SignedInteger {
    /// `ClosedRange` representation of the range.
    var closedRange: ClosedRange<Bound> {
        ClosedRange(self)
    }
}

public extension ClosedRange where Bound: Strideable, Bound.Stride: SignedInteger {
    /// `Range` representation of the range.
    var range: Range<Bound> {
        Range(self)
    }
}

public extension Range<String.Index> {
    /// `NSRange` representation of the range.
    func nsRange<S: StringProtocol>(in string: S) -> NSRange {
        NSRange(self, in: string)
    }
}

public extension ClosedRange<String.Index> {
    /// `NSRange` representation of the range.
    func nsRange<S: StringProtocol>(in string: S) -> NSRange {
        NSRange(self, in: string)
    }
}

public extension Range where Bound: Strideable, Bound.Stride: SignedInteger {
    /// The values of the range.
    var values: [Bound] {
        map { $0 }
    }
}

public extension ClosedRange where Bound: Strideable, Bound.Stride: SignedInteger {
    /// The values of the range.
    var values: [Bound] {
        map { $0 }
    }
}

public extension NSRange {
    /// The values of the range.
    var values: [Int] {
        isNotFound ? [] : map { $0 }
    }
}

/*
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
     /* 
      Clamps the range to the lower- and upper bound of the specified range.

      - Parameter range: The range fo clamp to.
      */
     func clamped<Range: RangeRepresentable>(to range: Range) -> Self where Range.Bound == Bound {
         .init(uncheckedBounds: (lowerBound.clamped(min: range.lowerBound), upperBound.clamped(max: range.upperBound)))
     }

     /* 
      Clamps the range to the lower- and upper bound of the specified range.

      - Parameter range: The range fo clamp to.
      */
     mutating func clamp<Range: RangeRepresentable>(to range: Range) where Range.Bound == Bound {
         self = clamped(to: range)
     }

     /* 
      Clamps the lower bound to the minimum value.

      - Parameter minValue: The minimum value to clamp the lower bound.
      */
     mutating func clamp(min minValue: Bound) {
         self = clamped(min: minValue)
     }

     /* 
      Clamps the lower bound to the minimum value.

      - Parameter minValue: The minimum value to clamp the lower bound.
      */
     func clamped(min minValue: Bound) -> Self {
         .init(uncheckedBounds: upperBound < minValue ? (minValue, minValue) : (lowerBound.clamped(min: minValue), upperBound.clamped(min: minValue)))
     }

     /* 
      Clamps the upper bound to the maximum value.

      - Parameter maxValue: The maximum value to clamp the upper bound.
      */
     mutating func clamp(max maxValue: Bound) {
         self = clamped(max: maxValue)
     }

     /* 
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

     /* 
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

     /* 
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

     /* 
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
     /* 
      Offsets the range by the specified value.

      - Parameter offset: The offset to shift.
      - Returns: The new range.
      */
     func shifted(by offset: Bound) -> Self {
         .init(uncheckedBounds: (lowerBound + offset, upperBound + offset))
     }

     /* 
      Offsets the range by the specified value.

      - Parameter offset: The offset to shift.
      */
     mutating func shift(by offset: Bound) {
         self = shifted(by: offset)
     }

     /* 
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
     /* 
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

     /* 
      Offsets the range by the specified value.

      - Parameter offset: The offset to shift.
      */
     mutating func shift(by offset: Bound) {
         self = shifted(by: offset)
     }

     /* 
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
     /// values of of the range.
     var values: [Bound] {
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

 extension CFRange: Swift.Collection, Swift.BidirectionalCollection, Swift.RandomAccessCollection, Swift.RangeExpression, Swift.Sequence {
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
 */

public extension Range {
    /**
     Creates a range from the specified bounds if the lower bound is less than or equal to the upper bound.

     - Parameter bounds: A tuple of the lower and upper bounds of the range.
     */
    init?(validating bounds: (lower: Bound, upper: Bound)) {
        guard bounds.lower <= bounds.upper else { return nil }
        self.init(uncheckedBounds: bounds)
    }

    /**
     Creates a range from the specified bounds by ordering them in ascending order if necessary.

     - Parameter bounds: A tuple of the lower and upper bounds of the range.
     */
    init(normalizing bounds: (lower: Bound, upper: Bound)) {
        self = Self(uncheckedBounds: (Swift.min(bounds.lower, bounds.upper), Swift.max(bounds.lower, bounds.upper)))
    }
}

public extension ClosedRange {
    /**
     Creates a range from the specified bounds if the lower bound is less than or equal to the upper bound.

     - Parameter bounds: A tuple of the lower and upper bounds of the range.
     */
    init?(validating bounds: (lower: Bound, upper: Bound)) {
        guard bounds.lower <= bounds.upper else { return nil }
        self.init(uncheckedBounds: bounds)
    }

    /**
     Creates a closed range from the specified bounds by ordering them in ascending order if necessary.

     - Parameter bounds: A tuple of the lower and upper bounds of the range.
     */
    init(normalizing bounds: (lower: Bound, upper: Bound)) {
        self = Self(uncheckedBounds: (Swift.min(bounds.lower, bounds.upper), Swift.max(bounds.lower, bounds.upper)))
    }
}

public extension Range {
    /// A Boolean value indicating whether the other range is fully contained within the range.
    func contains(_ range: Self) -> Bool {
        range.lowerBound >= lowerBound && range.upperBound <= upperBound
    }

    /**
     Returns the intersection of this range with another range, or `nil` if they do not overlap.

     Example usage:

     ```swift
     let range = 3...7
     range.intersection(5...10) // 5...7
     ```
     */
    func intersection(_ other: Self) -> Self? {
        let lower = Swift.max(lowerBound, other.lowerBound)
        let upper = Swift.min(upperBound, other.upperBound)
        return lower < upper ? lower..<upper : nil
    }

    /**
     Returns the smallest range that fully contains both ranges.

     Example usage:

     ```swift
     let range = 3...7
     range.boundingUnion(5...10) // 3...10
     ```
     */
    func boundingUnion(_ other: Self) -> Self {
        Swift.min(lowerBound, other.lowerBound)..<Swift.max(upperBound, other.upperBound)
    }

    /// Returns the range clamped to the specified minimum value.
    func clamped(min minValue: Bound) -> Self {
        Self(uncheckedBounds: (Swift.max(lowerBound, minValue), Swift.max(upperBound, minValue)))
    }

    /// Returns the range clamped to the specified maximum value.
    func clamped(max maxValue: Bound) -> Self {
        Self(uncheckedBounds: (Swift.min(lowerBound, maxValue), Swift.min(upperBound, maxValue)))
    }
}

public extension ClosedRange {
    /// A Boolean value indicating whether the other range is fully contained within the range.
    func contains(_ range: Self) -> Bool {
        range.lowerBound >= lowerBound && range.upperBound <= upperBound
    }

    /**
     Returns the intersection of this range with another range, or `nil` if they do not overlap.

     Example usage:

     ```swift
     let range = 3...7
     range.intersection(5...10) // 5...7
     ```
     */
    func intersection(_ other: Self) -> Self? {
        let lower = Swift.max(lowerBound, other.lowerBound)
        let upper = Swift.min(upperBound, other.upperBound)
        return lower <= upper ? lower...upper : nil
    }

    /**
     Returns the smallest range that fully contains both ranges.

     Example usage:

     ```swift
     let range = 3...7
     range.boundingUnion(5...10) // 3...10
     ```
     */
    func boundingUnion(_ other: Self) -> Self {
        Swift.min(lowerBound, other.lowerBound)...Swift.max(upperBound, other.upperBound)
    }

    /// Returns the range clamped to the specified minimum value.
    func clamped(min minValue: Bound) -> Self {
        Self(uncheckedBounds: (Swift.max(lowerBound, minValue), Swift.max(upperBound, minValue)))
    }

    /// Returns the range clamped to the specified maximum value.
    func clamped(max maxValue: Bound) -> Self {
        Self(uncheckedBounds: (Swift.min(lowerBound, maxValue), Swift.min(upperBound, maxValue)))
    }
}

public extension Range where Bound: AdditiveArithmetic {
    /**
     Offsets the range by the specified value.

     - Parameter offset: The offset to shift.
     - Returns: The new range.
     */
    func shifted(by offset: Bound) -> Self {
        Self(uncheckedBounds: (lowerBound + offset, upperBound + offset))
    }
}

public extension ClosedRange where Bound: AdditiveArithmetic {
    /**
     Offsets the range by the specified value.

     - Parameter offset: The offset to shift.
     - Returns: The new range.
     */
    func shifted(by offset: Bound) -> Self {
        Self(uncheckedBounds: (lowerBound + offset, upperBound + offset))
    }
}

public extension Range where Bound: Strideable, Bound.Stride: SignedInteger {
    var center: Bound {
        lowerBound.advanced(by: lowerBound.distance(to: upperBound) / 2)
    }
}

public extension ClosedRange where Bound: Strideable, Bound.Stride: SignedInteger {
    var center: Bound {
        lowerBound.advanced(by: lowerBound.distance(to: upperBound) / 2)
    }
}

public extension Range where Bound: BinaryInteger {
    /// The midpoint value between the `lowerBound` and `upperBound`, using integer division.
    var center: Bound {
        lowerBound + (upperBound - lowerBound) / 2
    }

    /// `NSRange` representation of the range.
    var nsRange: NSRange {
        guard lowerBound >= 0, let location = Int(exactly: lowerBound), let length = Int(exactly: upperBound - lowerBound) else {
            return .notFound
        }
        return NSRange(location: location, length: length)
    }
}

public extension ClosedRange where Bound: BinaryInteger {
    /// The midpoint value between the `lowerBound` and `upperBound`, using integer division.
    var center: Bound {
        lowerBound + (upperBound - lowerBound) / 2
    }

    /// `NSRange` representation of the range.
    var nsRange: NSRange {
        guard lowerBound >= 0, let location = Int(exactly: lowerBound), let distance = Int(exactly: upperBound - lowerBound), distance < Int.max else {
            return .notFound
        }
        return NSRange(location: location, length: distance + 1)
    }
}

public extension Range where Bound: BinaryFloatingPoint {
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
    func split(into amount: Int) -> [Bound] {
        guard amount > 1 else { return amount == 1 ? [lowerBound] : [] }
        let step = (upperBound - lowerBound) / Bound(amount - 1)
        return (0..<amount).map { lowerBound + Bound($0) * step }
    }

    /// The midpoint value between the `lowerBound` and `upperBound`, using integer division.
    var center: Bound {
        lowerBound + (upperBound - lowerBound) / 2.0
    }
}

public extension ClosedRange where Bound: BinaryFloatingPoint {
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
    func split(into amount: Int) -> [Bound] {
        guard amount > 1 else { return amount == 1 ? [lowerBound] : [] }
        let step = (upperBound - lowerBound) / Bound(amount - 1)
        return (0..<amount).map { lowerBound + Bound($0) * step }
    }

    /// The midpoint value between the `lowerBound` and `upperBound`, using integer division.
    var center: Bound {
        lowerBound + (upperBound - lowerBound) / 2.0
    }
}

public extension Range where Bound: Strideable {
    /// The distance between the lower bound and upper bound.
    var length: Bound.Stride {
        lowerBound.distance(to: upperBound)
    }
}

public extension ClosedRange where Bound: Strideable {
    /// The distance between the lower bound and upper bound.
    var length: Bound.Stride {
        lowerBound.distance(to: upperBound)
    }
}

public extension NSRange {
    /// Returns the range clamped to the specified minimum value.
    func clamped(min minValue: Int) -> NSRange {
        let lower = Swift.max(lowerBound, minValue)
        let upper = Swift.max(upperBound, lower)
        return NSRange(location: lower, length: upper - lower)
    }

    /// Returns the range clamped to the specified maximum value.
    func clamped(max maxValue: Int) -> NSRange {
        let lower = Swift.min(lowerBound, maxValue)
        let upper = Swift.min(upperBound, lower)
        return NSRange(location: lower, length: upper - lower)
    }

    /// Returns a copy of this range clamped to the given limiting range.
    func clamped(to range: NSRange) -> NSRange {
        NSRange(self.range.clamped(to: range.range))
    }

    /// Returns a copy of this range clamped to the given limiting range.
    func clamped(to range: Range<Int>) -> NSRange {
        NSRange(self.range.clamped(to: range))
    }
}

/*
 public extension Range {
     func clamped(to range: PartialRangeFrom<Bound>) -> Self {
         Swift.min(Swift.max(lowerBound, range.lowerBound), upperBound)..<upperBound
     }

     func clamped(to range: PartialRangeUpTo<Bound>) -> Self {
         lowerBound..<Swift.max(Swift.min(upperBound, range.upperBound), lowerBound)
     }
 }

 public extension Range where Bound: BinaryInteger {
     func clamped(to range: NSRange) -> Self? {
         Range<Bound>(range).map { clamped(to: $0) }
     }
 }

 public extension Range where Bound: Strideable, Bound.Stride: SignedInteger {
     func clamped(to range: ClosedRange<Bound>) -> Self {
         let lowerBound = Swift.min(Swift.max(lowerBound, range.lowerBound), upperBound)
         let limit = range.upperBound >= upperBound ? upperBound : range.upperBound.advanced(by: 1)
         let upperBound = Swift.max(Swift.min(upperBound, limit), lowerBound)
         return lowerBound..<upperBound
     }

     func clamped(to range: PartialRangeThrough<Bound>) -> Self {
         let limit = range.upperBound >= upperBound ? upperBound : range.upperBound.advanced(by: 1)
         let upperBound = Swift.max(Swift.min(upperBound, limit), lowerBound)
         return lowerBound..<upperBound
     }
 }

 public extension ClosedRange {
     func clamped(to range: PartialRangeFrom<Bound>) -> Self? {
         let lowerBound = Swift.max(lowerBound, range.lowerBound)
         guard lowerBound <= upperBound else { return nil }
         return lowerBound...upperBound
     }

     func clamped(to range: PartialRangeThrough<Bound>) -> Self? {
         let upperBound = Swift.min(upperBound, range.upperBound)
         guard lowerBound <= upperBound else { return nil }
         return lowerBound...upperBound
     }
 }

 public extension ClosedRange where Bound: BinaryInteger, Bound.Stride: SignedInteger {
     func clamped(to range: NSRange) -> Self? {
         Range<Bound>(range).flatMap { clamped(to: $0) }
     }
 }

 public extension ClosedRange where Bound: Strideable, Bound.Stride: SignedInteger {
     func clamped(to range: Range<Bound>) -> Self? {
         guard range.upperBound > lowerBound else { return nil }
         let lowerBound = Swift.max(lowerBound, range.lowerBound)
         let upperBound = range.upperBound > upperBound ? upperBound : range.upperBound.advanced(by: -1)
         guard lowerBound <= upperBound else { return nil }
         return lowerBound...upperBound
     }

     func clamped(to range: PartialRangeUpTo<Bound>) -> Self? {
         guard range.upperBound > lowerBound else { return nil }
         let upperBound = range.upperBound > upperBound ? upperBound : range.upperBound.advanced(by: -1)
         guard lowerBound <= upperBound else { return nil }
         return lowerBound...upperBound
     }
 }

 public extension NSRange {
     func clamped(to range: NSRange) -> NSRange? {
         Range(range).flatMap { clamped(to: $0) }
     }

     func clamped<I: FixedWidthInteger>(to range: Range<I>) -> NSRange? {
         Range<I>(self).map { NSRange($0.clamped(to: range)) }
     }

     func clamped<I: FixedWidthInteger>(to range: PartialRangeFrom<I>) -> NSRange? {
         Range<I>(self).map { NSRange($0.clamped(to: range)) }
     }

     func clamped<I: FixedWidthInteger>(to range: PartialRangeUpTo<I>) -> NSRange? {
         Range<I>(self).map { NSRange($0.clamped(to: range)) }
     }

     func clamped<I: FixedWidthInteger>(to range: PartialRangeThrough<I>) -> NSRange? {
         Range<I>(self).map { NSRange($0.clamped(to: range)) }
     }
 }
 */

private protocol RelativeRange<Bound> {
    associatedtype Bound: Comparable
    func relative<C: Collection>(safe collection: C) -> Range<Bound>? where C.Index == Bound
    func relative<C: Collection>(clampedTo collection: C) -> Range<Bound> where C.Index == Bound
}

extension Range: RelativeRange {
    /// Returns the range relative to the specified collection, or `nil` if the range is outside the collection's bounds.
    public func relative<C: Collection>(safe collection: C) -> Self? where C.Index == Bound {
        guard lowerBound >= collection.startIndex, upperBound <= collection.endIndex else { return nil }
        return self
    }

    /// Returns the range relative to the specified collection, clamped to the collection's bounds.
    public func relative<C: Collection>(clampedTo collection: C) -> Self where C.Index == Bound {
        let lowerBound = Swift.min(Swift.max(lowerBound, collection.startIndex), collection.endIndex)
        let upperBound = Swift.min(Swift.max(upperBound, collection.startIndex), collection.endIndex)
        return lowerBound..<Swift.max(lowerBound, upperBound)
    }
}

extension ClosedRange: RelativeRange {
    /// Returns the range relative to the specified collection, or `nil` if the range is outside the collection's bounds.
    public func relative<C: Collection>(safe collection: C) -> Range<Bound>? where C.Index == Bound {
        guard lowerBound >= collection.startIndex, upperBound < collection.endIndex else { return nil }
        return lowerBound..<collection.index(after: upperBound)
    }

    /// Returns the range relative to the specified collection, clamped to the collection's bounds.
    public func relative<C: Collection>(clampedTo collection: C) -> Range<Bound> where C.Index == Bound {
        let lowerBound = Swift.min(Swift.max(lowerBound, collection.startIndex), collection.endIndex)
        guard lowerBound < collection.endIndex, upperBound >= collection.startIndex else {
            return lowerBound..<lowerBound
        }
        let upperBound = upperBound >= collection.endIndex ? collection.endIndex : collection.index(after: upperBound)
        return lowerBound..<Swift.max(lowerBound, upperBound)
    }
}

extension PartialRangeFrom: RelativeRange {
    /// Returns the range relative to the specified collection, or `nil` if the range is outside the collection's bounds.
    public func relative<C: Collection>(safe collection: C) -> Range<Bound>? where C.Index == Bound {
        guard lowerBound >= collection.startIndex, lowerBound <= collection.endIndex else { return nil }
        return lowerBound..<collection.endIndex
    }

    /// Returns the range relative to the specified collection, clamped to the collection's bounds.
    public func relative<C: Collection>(clampedTo collection: C) -> Range<Bound> where C.Index == Bound {
        Swift.min(Swift.max(lowerBound, collection.startIndex), collection.endIndex)..<collection.endIndex
    }
}

extension PartialRangeThrough: RelativeRange {
    /// Returns the range relative to the specified collection, or `nil` if the range is outside the collection's bounds.
    public func relative<C: Collection>(safe collection: C) -> Range<Bound>? where C.Index == Bound {
        guard upperBound >= collection.startIndex, upperBound < collection.endIndex else { return nil }
        return collection.startIndex..<collection.index(after: upperBound)
    }

    /// Returns the range relative to the specified collection, clamped to the collection's bounds.
    public func relative<C: Collection>(clampedTo collection: C) -> Range<Bound> where C.Index == Bound {
        guard !collection.isEmpty, upperBound >= collection.startIndex else {
            return collection.startIndex..<collection.startIndex
        }
        return collection.startIndex..<(upperBound >= collection.endIndex ? collection.endIndex : collection.index(after: upperBound))
    }
}

extension PartialRangeUpTo: RelativeRange {
    /// Returns the range relative to the specified collection, or `nil` if the range is outside the collection's bounds.
    public func relative<C: Collection>(safe collection: C) -> Range<Bound>? where C.Index == Bound {
        guard upperBound >= collection.startIndex, upperBound <= collection.endIndex else { return nil }
        return collection.startIndex..<upperBound
    }

    /// Returns the range relative to the specified collection, clamped to the collection's bounds.
    public func relative<C: Collection>(clampedTo collection: C) -> Range<Bound> where C.Index == Bound {
        collection.startIndex..<Swift.min(Swift.max(upperBound, collection.startIndex), collection.endIndex)
    }
}

public extension RangeExpression {
    /// Returns the range relative to the specified collection, or `nil` if the range is outside the collection's bounds.
    @_disfavoredOverload
    func relative<C: Collection>(safe collection: C) -> Range<Bound>? where C.Index == Bound {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *) {
            return (self as? any RelativeRange<Bound>)?.relative(safe: collection)
        } else {
            if let range = self as? Range<Bound> {
                return range.relative(safe: collection)
            } else if let range = self as? ClosedRange<Bound> {
                return range.relative(safe: collection)
            } else if let range = self as? PartialRangeFrom<Bound> {
                return range.relative(safe: collection)
            } else if let range = self as? PartialRangeThrough<Bound> {
                return range.relative(safe: collection)
            } else if let range = self as? PartialRangeUpTo<Bound> {
                return range.relative(safe: collection)
            }
            return nil
        }
    }

    /// Returns the range relative to the specified collection, clamped to the collection's bounds.
    @_disfavoredOverload
    func relative<C: Collection>(clampedTo collection: C) -> Range<Bound> where C.Index == Bound {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *) {
            return (self as? any RelativeRange<Bound>)?.relative(clampedTo: collection) ?? relative(to: collection).relative(clampedTo: collection)
        } else {
            if let range = self as? Range<Bound> {
                return range.relative(clampedTo: collection)
            } else if let range = self as? ClosedRange<Bound> {
                return range.relative(clampedTo: collection)
            } else if let range = self as? PartialRangeFrom<Bound> {
                return range.relative(clampedTo: collection)
            } else if let range = self as? PartialRangeThrough<Bound> {
                return range.relative(clampedTo: collection)
            } else if let range = self as? PartialRangeUpTo<Bound> {
                return range.relative(clampedTo: collection)
            }
            return relative(to: collection).relative(clampedTo: collection)
        }
    }
}

@available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public extension RangeSet where Bound: Strideable, Bound.Stride: SignedInteger {
    /// The values of the range set.
    var values: [Bound] {
        ranges.flatMap(\.values)
    }
}

@available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public extension RangeSet.Ranges {
    /// The lowest bound in the range set, or `nil` if the range set is empty.
    var lowerBound: Bound? {
        first?.lowerBound
    }

    /// The highest bound in the range set, or `nil` if the range set is empty.
    var upperBound: Bound? {
        last?.upperBound
    }
}

@available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public extension RangeSet {
    /// Returns the range set relative to the specified collection.
    func relative<C: Collection>(to collection: C) -> Self where C.Index == Bound {
        Self(ranges.compactMap { $0.relative(safe: collection) })
    }

    /// Returns the range set relative to the specified collection, or `nil` if the collection's bound doesn't contain the range set.
    func relative<C: Collection>(safe collection: C) -> Self? where C.Index == Bound {
        isEmpty || (lowerBound! >= collection.startIndex && upperBound! <= collection.endIndex) ? self : nil
    }

    /// Returns the range set relative to the specified collection, clamped to the collection’s bounds.
    func relative<C: Collection>(clampedTo collection: C) -> Self where C.Index == Bound {
        Self(ranges.map { $0.relative(clampedTo: collection) })
    }
    
    /// The lowest bound in the range set, or `nil` if the range set is empty.
    var lowerBound: Bound? {
        ranges.first?.lowerBound
    }

    /// The highest bound in the range set, or `nil` if the range set is empty.
    var upperBound: Bound? {
        ranges.last?.upperBound
    }
}
