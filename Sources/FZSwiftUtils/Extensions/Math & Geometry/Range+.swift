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

public extension RangeRepresentable {
    /**
     Clamps the range to the lower- and upper bound of the specified range.

     - Parameter range: The range fo clamp to.
     */
    func clamped<Range: RangeRepresentable>(to range: Range) -> Self where Range.Bound == Bound {
        .init(uncheckedBounds: (lower: lowerBound.clamped(min: range.lowerBound), upper: upperBound.clamped(max: range.upperBound)))
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
        .init(uncheckedBounds: (lower: lowerBound.clamped(min: minValue), upper: upperBound.clamped(min: minValue)))
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
        .init(uncheckedBounds: (lower: lowerBound.clamped(max: maxValue), upper: upperBound.clamped(max: maxValue)))
    }
    
    func contains<Range: RangeRepresentable>(_ range: Range) -> Bool where Range.Bound == Bound {
        range.lowerBound >= lowerBound && range.upperBound <= upperBound
    }
    
    func contains<S>(_ values: S) -> Bool where S: Sequence<Bound> {
        !values.contains(where: { !contains($0) })
    }
    
    init(checkedBounds a: Bound,_ b: Bound) {
        self = Self(uncheckedBounds: (Swift.min(a,b), Swift.max(a,b)))
    }
}

public extension RangeRepresentable where Bound: BinaryInteger {
    /**
     Offsets the range by the specified value.

     - Parameter offset: The offset to shift.
     - Returns: The new range.
     */
    func offset(by offset: Bound) -> Self {
        .init(uncheckedBounds: (lowerBound + offset, upperBound + offset))
    }
    
    /// `NSRange` representation of the range.
    var nsRange: NSRange {
        NSRange(uncheckedBounds: (Int(lowerBound), Int(upperBound)))
    }
    
    /// The value at the midpoint between the lower and upper bounds, using integer division.
    var center: Bound {
        (lowerBound + upperBound) / 2
    }
}

extension RangeRepresentable where Bound: BinaryFloatingPoint {
    /**
     Shifts the range by the specified offset value.

     - Parameter offset: The offset to shift.
     - Returns: The new range.
     */
    func shfted(by offset: Bound) -> Self {
        .init(uncheckedBounds: (lowerBound + offset ,upperBound + offset ))
    }
    
    /// Returns an array of `amount` evenly spaced values in the range, including the lower and upper bounds.
    func divided(into amount: Int) -> [Bound] {
        guard amount > 1 else {
            return amount == 1 ? [lowerBound] : []
        }
        
        let step = (upperBound - lowerBound) / Bound(amount - 1)
        return (0..<amount).map { i in
            lowerBound + Bound(i) * step
        }
    }
    
    /// The value at the midpoint between the lower and upper bounds, using integer division.
    var center: Bound {
        (lowerBound + upperBound) / 2.0
    }
}

public extension RangeRepresentable where Bound: BinaryInteger, Bound.Stride: SignedInteger {
    /// `Array` representation of the range.
    var array: [Bound] {
        (lowerBound..<upperBound).map({ $0 })
    }
}

public extension Sequence where Element: RangeRepresentable {
    /// The range that contains all ranges.
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
        map(\.upperBound).min()
    }
}

