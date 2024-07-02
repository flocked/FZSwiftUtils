//
//  Range+.swift
//
//
//  Created by Florian Zand on 27.09.23.
//

import Foundation

public extension Range {
    init(safe a: Bound,_ b: Bound) {
        self = Swift.min(a,b)..<Swift.max(a,b)
    }
    
    func clamped(to range: ClosedRange<Bound>) -> Range {
        clamped(to: range.lowerBound..<range.upperBound)
    }
    
    /**
     A Boolean value indicating whether the specified range is contained within the range.

     - Parameter range: The range to check for containment.
     - Returns: `true` if the specified range is contained in the range; otherwise, `false`.
     */
    func contains(_ range: Range) -> Bool {
        range.lowerBound >= lowerBound && range.upperBound <= upperBound
    }
    
    /**
     A Boolean value indicating whether the specified range is contained within the range.

     - Parameter range: The range to check for containment.
     - Returns: `true` if the specified range is contained in the range; otherwise, `false`.
     */
    func contains(_ range: ClosedRange<Bound>) -> Bool {
        range.lowerBound >= lowerBound && range.upperBound <= upperBound
    }
    
    /**
     Returns a Boolean value indicating whether the given values are contained within the range.

     - Parameter values: The values to check for containment.
     - Returns: `true` if values are contained in the range; otherwise, `false`.
     */
    func contains<S>(_ values: S) -> Bool where S: Sequence<Bound> {
        for value in values.uniqued() {
            if contains(value) == false {
                return false
            }
        }
        return true
    }
    
    /**
     Clamps the lower bound to the minimum value.

     - Parameter minValue: The minimum value to clamp the lower bound.
     */
    func clamped(min minValue: Bound) -> Range {
        Swift.max(minValue, lowerBound)..<upperBound
    }
    
    /**
     Clamps the lower bound to the minimum value.

     - Parameter minValue: The minimum value to clamp the lower bound.
     */
   mutating func clamp(min minValue: Bound) {
       self = clamped(min: minValue)
    }
    
    /**
     Clamps the upper bound to the maximum value.

     - Parameter maxValue: The maximum value to clamp the upper bound.
     */
    func clamped(max maxValue: Bound) -> Range {
        lowerBound..<Swift.min(maxValue, upperBound)
    }
    
    /**
     Clamps the upper bound to the maximum value.

     - Parameter maxValue: The maximum value to clamp the upper bound.
     */
    mutating func clamp(max maxValue: Bound)  {
        self = clamped(max: maxValue)
    }
}

public extension Range where Bound == String.Index {
    /// `NSRange` representation of the range.
    func nsRange<S: StringProtocol>(in string: S) -> NSRange {
        NSRange(self, in: string)
    }
}

public extension ClosedRange  {
    init(safe a: Bound,_ b: Bound) {
        self = Swift.min(a,b)...Swift.min(a,b)
    }
    
    func clamped(to range: Range<Bound>) -> ClosedRange {
        clamped(to: range.lowerBound...range.upperBound)
    }
    
    /**
     A Boolean value indicating whether the specified range is contained within the range.

     - Parameter range: The range to check for containment.
     - Returns: `true` if the specified range is contained in the range; otherwise, `false`.
     */
    func contains(_ range: ClosedRange) -> Bool {
        range.lowerBound >= lowerBound && range.upperBound <= upperBound
    }
    
    /**
     A Boolean value indicating whether the specified range is contained within the range.

     - Parameter range: The range to check for containment.
     - Returns: `true` if the specified range is contained in the range; otherwise, `false`.
     */
    func contains(_ range: Range<Bound>) -> Bool {
        range.lowerBound >= lowerBound && range.upperBound <= upperBound
    }
    
    /**
     Returns a Boolean value indicating whether the given values are contained within the range.

     - Parameter values: The values to check for containment.
     - Returns: `true` if values are contained in the range; otherwise, `false`.
     */
    func contains<S>(_ values: S) -> Bool where S: Sequence<Bound> {
        for value in values.uniqued() {
            if contains(value) == false {
                return false
            }
        }
        return true
    }
    
    /**
     Clamps the lower bound to the minimum value.

     - Parameter minValue: The minimum value to clamp the lower bound.
     */
    func clamped(min minValue: Bound) -> ClosedRange {
        Swift.max(minValue, lowerBound)...upperBound
    }
    
    /**
     Clamps the lower bound to the minimum value.

     - Parameter minValue: The minimum value to clamp the lower bound.
     */
   mutating func clamp(min minValue: Bound) {
       self = clamped(min: minValue)
    }
    
    /**
     Clamps the upper bound to the maximum value.

     - Parameter maxValue: The maximum value to clamp the upper bound.
     */
    func clamped(max maxValue: Bound) -> ClosedRange {
        lowerBound...Swift.min(maxValue, upperBound)
    }
    
    /**
     Clamps the upper bound to the maximum value.

     - Parameter maxValue: The maximum value to clamp the upper bound.
     */
    mutating func clamp(max maxValue: Bound)  {
        self = clamped(max: maxValue)
    }
}

public extension Range where Bound: BinaryInteger, Bound.Stride: SignedInteger {
    /// `Array` representation of the range.
    var array: [Bound] {
        return compactMap({$0})
    }
}

public extension ClosedRange where Bound: BinaryInteger {
    /**
     Offsets the range by the specified value.

     - Parameter offset: The offset to shift.
     - Returns: The new range.
     */
    func offset(by offset: Bound) -> Self {
        lowerBound + offset ... upperBound + offset
    }
    
    /// The range as floating range.
    var toFloating: ClosedRange<Float> {
        Float(lowerBound)...Float(upperBound)
    }
    
    /// `Range` representation of the range.
    var toRange: Range<Bound> {
        lowerBound..<(upperBound + 1)
    }
    
    /// `NSRange` representation of the range.
    var nsRange: NSRange {
        let length = upperBound - lowerBound - 1
        return NSRange(location: Int(lowerBound), length: Int(length))
    }
}

public extension ClosedRange where Bound: BinaryInteger, Bound.Stride: SignedInteger {
    /// `Array` representation of the range.
    var array: [Bound] {
        return compactMap({$0})
    }
}

public extension ClosedRange where Bound: BinaryFloatingPoint {
    /**
     Shifts the range by the specified offset value.

     - Parameter offset: The offset to shift.
     - Returns: The new range.
     */
    func shfted(by offset: Bound) -> Self {
        lowerBound + offset ... upperBound + offset
    }
    
    /// `Range` representation of the range.
    var toRange: Range<Bound> {
        lowerBound..<(upperBound - 1)
    }
}

public extension Range where Bound: BinaryInteger {
    /**
     Shifts the range by the specified offset value.

     - Parameter offset: The offset to shift.
     - Returns: The new range.
     */
    func shfted(by offset: Bound) -> Self {
        lowerBound + offset ..< upperBound + offset
    }
    
    /// The range as floating range.
    var toFloating: Range<Float> {
        Float(lowerBound)..<Float(upperBound)
    }
    
    /// `ClosedRange` representation of the range.
    var toClosedRange: ClosedRange<Bound> {
        lowerBound...(upperBound - 1)
    }
    
    /// `NSRange` representation of the range.
    var nsRange: NSRange {
        let length = upperBound - lowerBound
        return NSRange(location: Int(lowerBound), length: Int(length))
    }
}

public extension Range where Bound: BinaryFloatingPoint {
    /**
     Shifts the range by the specified offset value.

     - Parameter offset: The offset to shift.
     - Returns: The new range.
     */
    func shfted(by offset: Bound) -> Self {
        lowerBound + offset ..< upperBound + offset
    }
    
    /// `ClosedRange` representation of the range.
    var toClosedRange: ClosedRange<Bound> {
        lowerBound...(upperBound - 1)
    }
}

public extension Sequence<ClosedRange<Int>> {
    /// The range that contains all ranges.
    var union: ClosedRange<Int>? {
        guard let min = min, let max = max else { return nil }
        return min...max
    }
    
    /// Returns the minimum lower bound in the sequence.
    var min: Int? {
        map(\.lowerBound).min()
    }
    
    /// Returns the maximum upper bound in the sequence.
    var max: Int? {
        map(\.upperBound).min()
    }
}

public extension Sequence<ClosedRange<Float>> {
    /// The range that contains all ranges.
    var union: ClosedRange<Float>? {
        guard let min = min, let max = max else { return nil }
        return min...max
    }
    
    /// Returns the minimum lower bound in the sequence.
    var min: Float? {
        map(\.lowerBound).min()
    }
    
    /// Returns the maximum upper bound in the sequence.
    var max: Float? {
        map(\.upperBound).min()
    }
}

public extension Sequence<ClosedRange<Double>> {
    /// The range that contains all ranges.
    var union: ClosedRange<Double>? {
        guard let min = min, let max = max else { return nil }
        return min...max
    }
    
    /// Returns the minimum lower bound in the sequence.
    var min: Double? {
        map(\.lowerBound).min()
    }
    
    /// Returns the maximum upper bound in the sequence.
    var max: Double? {
        map(\.upperBound).min()
    }
}

public extension Sequence<ClosedRange<CGFloat>> {
    /// The range that contains all ranges.
    var union: ClosedRange<CGFloat>? {
        guard let min = min, let max = max else { return nil }
        return min...max
    }
    
    /// Returns the minimum lower bound in the sequence.
    var min: CGFloat? {
        map(\.lowerBound).min()
    }
    
    /// Returns the maximum upper bound in the sequence.
    var max: CGFloat? {
        map(\.upperBound).min()
    }
}

public extension Sequence<Range<Int>> {
    /// The range that contains all ranges.
    var union: Range<Int>? {
        guard let min = min, let max = max else { return nil }
        return min ..< max
    }
    
    /// Returns the minimum lower bound in the sequence.
    var min: Int? {
        map(\.lowerBound).min()
    }
    
    /// Returns the maximum upper bound in the sequence.
    var max: Int? {
        map(\.upperBound).min()
    }
}

public extension Sequence<Range<Float>> {
    /// The range that contains all ranges.
    var union: Range<Float>? {
        guard let min = min, let max = max else { return nil }
        return min ..< max
    }
    
    /// Returns the minimum lower bound in the sequence.
    var min: Float? {
        map(\.lowerBound).min()
    }
    
    /// Returns the maximum upper bound in the sequence.
    var max: Float? {
        map(\.upperBound).min()
    }
}

public extension Sequence<Range<Double>> {
    /// The range that contains all ranges.
    var union: Range<Double>? {
        guard let min = min, let max = max else { return nil }
        return min ..< max
    }
    
    /// Returns the minimum lower bound in the sequence.
    var min: Double? {
        map(\.lowerBound).min()
    }
    
    /// Returns the maximum upper bound in the sequence.
    var max: Double? {
        map(\.upperBound).min()
    }
}

public extension Sequence<Range<CGFloat>> {
    /// The range that contains all ranges.
    var union: Range<CGFloat>? {
        guard let min = min, let max = max else { return nil }
        return min ..< max
    }
    
    /// Returns the minimum lower bound in the sequence.
    var min: CGFloat? {
        map(\.lowerBound).min()
    }
    
    /// Returns the maximum upper bound in the sequence.
    var max: CGFloat? {
        map(\.upperBound).min()
    }
}
