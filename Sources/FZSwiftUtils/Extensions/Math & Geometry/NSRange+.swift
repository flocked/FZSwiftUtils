//
//  NSRange+.swift
//
//
//  Created by Florian Zand on 06.06.22.
//

import Foundation

public extension NSRange {
    /// The range as `ClosedRange`.
    var closedRange: ClosedRange<Int> {
        lowerBound ... upperBound
    }

    /// The range as `Range`.
    var range: Range<Int> {
        lowerBound ..< upperBound + 1
    }

    /// Not found range.
    static let notFound = NSRange(location: NSNotFound, length: 0)

    /// A Boolean value indicating whether the range contains no elements.
    var isEmpty: Bool {
        length == 0
    }

    /// A Boolean value indicating whether the range is not found.
    var isNotFound: Bool {
        location == NSNotFound
    }

    /**
     A Boolean value indicating whether range constains the specified index.
     - Parameter index: The index to test.
     - Returns: `true` if the range contains the index, or `false` if not.
     */
    func contains(_ index: Int) -> Bool {
        index >= lowerBound && index <= upperBound
    }

    /**
     Returns a Boolean value indicating whether the given range is contained within the range.

     - Parameter range: The range to check for containment.
     - Returns: `true` if range is contained in the range; otherwise, `false`.
     */
    func contains(_ range: NSRange) -> Bool {
        if location == NSNotFound { return false }
        if range.location == NSNotFound { return false }
        return range.lowerBound >= lowerBound && range.upperBound <= upperBound
    }

    /**
     Return a copied NSRange but whose location is shifted toward the given `offset`.

     - Parameter offset: The offset to shift.
     - Returns: A new NSRange.
     */
    func shifted(by offset: Int) -> NSRange {
        NSRange(location: location + offset, length: length)
    }

    /**
     Returns a Boolean value indicating whether this range and the given range contain an element in common.

     - Parameter other: A range to check for elements in common.
     - Returns: `true` if this range and other have at least one element in common; otherwise, `false`.
     */
    func overlaps(_ other: NSRange) -> Bool {
        intersection(other) != nil
    }
}

extension Sequence<NSRange> {
    /// The range that contains all ranges.
    var union: NSRange? {
        guard
            let lowerBound = map(\.lowerBound).min(),
            let upperBound = map(\.upperBound).max()
        else { return nil }

        return NSRange(lowerBound ..< upperBound)
    }
}
