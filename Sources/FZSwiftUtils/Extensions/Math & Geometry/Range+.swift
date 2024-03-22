//
//  Range+.swift
//
//
//  Created by Florian Zand on 27.09.23.
//

import Foundation

public extension Range {
    func clamped(to range: ClosedRange<Bound>) -> Range {
        clamped(to: range.lowerBound..<range.upperBound)
    }
}

public extension ClosedRange {
    func clamped(to range: Range<Bound>) -> ClosedRange {
        clamped(to: range.lowerBound...range.upperBound)
    }
}

public extension Range where Bound: Comparable {
    /**
     Clamps the lower bound to the minimum value.

     - Parameter minValue: The minimum value to clamp the lower bound.
     */
    func clamped(min minValue: Bound) -> Range {
        Swift.max(minValue, lowerBound)..<upperBound
    }
    
    /**
     Clamps the upper bound to the maximum value.

     - Parameter maxValue: The maximum value to clamp the upper bound.
     */
    func clamped(max maxValue: Bound) -> Range {
        lowerBound..<Swift.min(maxValue, upperBound)
    }
}

public extension ClosedRange where Bound: Comparable {
    /**
     Clamps the lower bound to the minimum value.

     - Parameter minValue: The minimum value to clamp the lower bound.
     */
    func clamped(min minValue: Bound) -> ClosedRange {
        Swift.max(minValue, lowerBound)...upperBound
    }
    
    /**
     Clamps the upper bound to the maximum value.

     - Parameter maxValue: The maximum value to clamp the upper bound.
     */
    func clamped(max maxValue: Bound) -> ClosedRange {
        lowerBound...Swift.min(maxValue, upperBound)
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

    /**
     Returns a Boolean value indicating whether the given range is contained within the range.

     - Parameter range: The range to check for containment.
     - Returns: `true` if range is contained in the range; otherwise, `false`.
     */
    func contains(_ range: ClosedRange<Bound>) -> Bool {
        range.lowerBound >= lowerBound && range.upperBound <= upperBound
    }

    /**
     Returns a Boolean value indicating whether the given range is contained within the range.

     - Parameter range: The range to check for containment.
     - Returns: `true` if range is contained in the range; otherwise, `false`.
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

public extension Range where Bound: BinaryInteger {
    /**
     Shifts the range by the specified offset value.

     - Parameter offset: The offset to shift.
     - Returns: The new range.
     */
    func shfted(by offset: Bound) -> Self {
        lowerBound + offset ..< upperBound + offset
    }

    /**
     Returns a Boolean value indicating whether the given range is contained within the range.

     - Parameter range: The range to check for containment.
     - Returns: `true` if range is contained in the range; otherwise, `false`.
     */
    func contains(_ range: ClosedRange<Bound>) -> Bool {
        range.lowerBound >= lowerBound && range.upperBound <= upperBound
    }

    /**
     Returns a Boolean value indicating whether the given range is contained within the range.

     - Parameter range: The range to check for containment.
     - Returns: `true` if range is contained in the range; otherwise, `false`.
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

extension Sequence<ClosedRange<Int>> {
    /// The range that contains all ranges.
    var union: ClosedRange<Int>? {
        guard
            let lowerBound = map(\.lowerBound).min(),
            let upperBound = map(\.upperBound).max()
        else { return nil }
        return lowerBound ... upperBound
    }
}

extension Sequence<ClosedRange<Float>> {
    /// The range that contains all ranges.
    var union: ClosedRange<Float>? {
        guard
            let lowerBound = map(\.lowerBound).min(),
            let upperBound = map(\.upperBound).max()
        else { return nil }
        return lowerBound ... upperBound
    }
}

extension Sequence<ClosedRange<Double>> {
    /// The range that contains all ranges.
    var union: ClosedRange<Double>? {
        guard
            let lowerBound = map(\.lowerBound).min(),
            let upperBound = map(\.upperBound).max()
        else { return nil }
        return lowerBound ... upperBound
    }
}

extension Sequence<ClosedRange<CGFloat>> {
    /// The range that contains all ranges.
    var union: ClosedRange<CGFloat>? {
        guard
            let lowerBound = map(\.lowerBound).min(),
            let upperBound = map(\.upperBound).max()
        else { return nil }
        return lowerBound ... upperBound
    }
}

extension Sequence<Range<Int>> {
    /// The range that contains all ranges.
    var union: Range<Int>? {
        guard
            let lowerBound = map(\.lowerBound).min(),
            let upperBound = map(\.upperBound).max()
        else { return nil }
        return lowerBound ..< upperBound
    }
}

extension Sequence<Range<Float>> {
    /// The range that contains all ranges.
    var union: Range<Float>? {
        guard
            let lowerBound = map(\.lowerBound).min(),
            let upperBound = map(\.upperBound).max()
        else { return nil }
        return lowerBound ..< upperBound
    }
}

extension Sequence<Range<Double>> {
    /// The range that contains all ranges.
    var union: Range<Double>? {
        guard
            let lowerBound = map(\.lowerBound).min(),
            let upperBound = map(\.upperBound).max()
        else { return nil }
        return lowerBound ..< upperBound
    }
}

extension Sequence<Range<CGFloat>> {
    /// The range that contains all ranges.
    var union: Range<CGFloat>? {
        guard let lowerBound = map(\.lowerBound).min(),
              let upperBound = map(\.upperBound).max()
        else { return nil }
        return lowerBound ..< upperBound
    }
}
