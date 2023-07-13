//
//  NSRange+.swift
//
//
//  Created by Florian Zand on 06.06.22.
//


import Foundation

public extension NSRange {
    func closedRange() -> ClosedRange<Int> {
        return lowerBound ... upperBound
    }

    static let notFound = NSRange(location: NSNotFound, length: 0)

    /// A boolean value indicating whether the range contains no elements.
    var isEmpty: Bool {
        length == 0
    }

    /// A boolean value indicating whether the range is not found.
    var isNotFound: Bool {
        location == NSNotFound
    }

    /// Check if the given index is in the receiver or touchs to one of the receiver's bounds.
    ///
    /// - Parameter index: The index to test.
    func touches(_ index: Int) -> Bool {
        lowerBound <= index && index <= upperBound
    }

    /// Return a boolean indicating whether the specified range intersects the receiver’s range.
    ///
    /// - Parameter other: The other range.
    func intersects(_ other: NSRange) -> Bool {
        intersection(other) != nil
    }

    /// Check if the two ranges overlap or touch each other.
    ///
    /// - Parameter range: The range to test.
    /// - Note: Unlike Swift.Range's `overlaps(_:)`, this method returns `true` when a range length is 0.
    func touches(_ range: NSRange) -> Bool {
        if location == NSNotFound { return false }
        if range.location == NSNotFound { return false }
        if upperBound < range.lowerBound { return false }
        if range.upperBound < lowerBound { return false }

        return true
    }

    /// Return a copied NSRange but whose location is shifted toward the given `offset`.
    ///
    /// - Parameter offset: The offset to shift.
    /// - Returns: A new NSRange.
    func shifted(by offset: Int) -> NSRange {
        NSRange(location: location + offset, length: length)
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
