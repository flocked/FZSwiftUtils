//
//  Range+.swift
//
//
//  Created by Florian Zand on 27.09.23.
//

import Foundation

public extension ClosedRange where Bound == Int {
    /**
     Offsets the range by the specified value.

     - Parameter offset: The offset to shift.
     - Returns: The new range.
     */
    func offset(by offset: Int) -> Self {
        lowerBound + offset ... upperBound + offset
    }

    /**
     Returns a Boolean value indicating whether the given range is contained within the range.

     - Parameter range: The range to check for containment.
     - Returns: `true` if range is contained in the range; otherwise, `false`.
     */
    func contains(_ range: ClosedRange<Int>) -> Bool {
        range.lowerBound >= lowerBound && range.upperBound <= upperBound
    }

    /**
     Returns a Boolean value indicating whether the given range is contained within the range.

     - Parameter range: The range to check for containment.
     - Returns: `true` if range is contained in the range; otherwise, `false`.
     */
    func contains(_ range: Range<Int>) -> Bool {
        range.lowerBound >= lowerBound && range.upperBound <= upperBound
    }

    /**
     Returns a Boolean value indicating whether the given values are contained within the range.

     - Parameter values: The values to check for containment.
     - Returns: `true` if values are contained in the range; otherwise, `false`.
     */
    func contains<S>(_ values: S) -> Bool where S: Sequence<Int> {
        for value in values.uniqued() {
            if contains(value) == false {
                return false
            }
        }
        return true
    }
}

public extension Range where Bound == Int {
    /**
     Shifts the range by the specified offset value.

     - Parameter offset: The offset to shift.
     - Returns: The new range.
     */
    func shfted(by offset: Int) -> Self {
        lowerBound + offset ..< upperBound + offset
    }

    /**
     Returns a Boolean value indicating whether the given range is contained within the range.

     - Parameter range: The range to check for containment.
     - Returns: `true` if range is contained in the range; otherwise, `false`.
     */
    func contains(_ range: ClosedRange<Int>) -> Bool {
        range.lowerBound >= lowerBound && range.upperBound <= upperBound
    }

    /**
     Returns a Boolean value indicating whether the given range is contained within the range.

     - Parameter range: The range to check for containment.
     - Returns: `true` if range is contained in the range; otherwise, `false`.
     */
    func contains(_ range: Range<Int>) -> Bool {
        range.lowerBound >= lowerBound && range.upperBound <= upperBound
    }

    /**
     Returns a Boolean value indicating whether the given values are contained within the range.

     - Parameter values: The values to check for containment.
     - Returns: `true` if values are contained in the range; otherwise, `false`.
     */
    func contains<S>(_ values: S) -> Bool where S: Sequence<Int> {
        for value in values.uniqued() {
            if contains(value) == false {
                return false
            }
        }
        return true
    }
}

public extension ClosedRange where Bound: BinaryInteger {
    /// The range as `NSRange`.
    var nsRange: NSRange {
        let length = upperBound - lowerBound - 1
        return NSRange(location: Int(lowerBound), length: Int(length))
    }
}

public extension Range where Bound: BinaryInteger {
    /// The range as `NSRange`.
    var nsRange: NSRange {
        let length = upperBound - lowerBound
        return NSRange(location: Int(lowerBound), length: Int(length))
    }
}

public extension ClosedRange where Bound: BinaryInteger {
    /// The range as floating range.
    var toFloating: ClosedRange<Float> {
        Float(lowerBound) ... Float(upperBound)
    }
}

public extension Range where Bound: BinaryInteger {
    /// The range as floating range.
    var toFloating: Range<Float> {
        Float(lowerBound) ..< Float(upperBound)
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
