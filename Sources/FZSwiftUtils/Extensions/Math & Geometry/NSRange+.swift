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
        guard location >= 0, length >= 0 else { return 0...0 }
        return location...(location + length - 1)
    }

    /// The range as `Range`.
    var range: Range<Int> {
        guard location >= 0, length >= 0 else { return 0..<0 }
        return location..<location + length
    }
    
    /// The range as `CFRange`.
    var cfRange: CFRange {
        CFRange(location: location, length: length)
    }
    
    /// The maximum value.
    var max: Int {
        NSMaxRange(self)
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
     A Boolean value indicating whether the given range is contained within the range.

     - Parameter range: The range to check for containment.
     - Returns: `true` if range is contained in the range; otherwise, `false`.
     */
    func contains(_ range: NSRange) -> Bool {
        guard !isNotFound, !range.isNotFound else { return false }
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
     A Boolean value indicating whether this range and the given range contain an element in common.

     - Parameter other: A range to check for elements in common.
     - Returns: `true` if this range and other have at least one element in common; otherwise, `false`.
     */
    func overlaps(_ other: NSRange) -> Bool {
        intersection(other) != nil
    }
    
    /// `Array` representation of the range.
    var array: [Int] {
        return (location..<location+length).array
    }
    
    /// The zero range.
    static var zero = NSRange(location: 0, length: 0)
}

public extension Sequence<NSRange> {
    /// The range that contains all ranges.
    var union: NSRange? {
        guard let min = min, let max = max else { return nil }
        return NSRange(min..<max)
    }
    
    /// Returns the minimum lower bound in the sequence.
    var min: Int? {
        filter({!$0.isNotFound}).map(\.lowerBound).min()
    }
    
    /// Returns the maximum upper bound in the sequence.
    var max: Int? {
        filter({!$0.isNotFound}).map(\.upperBound).max()
    }
}

public extension CFRange {
    /// The range as `NSRange`.
    var nsRange: NSRange {
        NSRange(location: location, length: length)
    }
}
