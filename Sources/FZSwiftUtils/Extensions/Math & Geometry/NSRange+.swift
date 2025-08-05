//
//  NSRange+.swift
//
//
//  Created by Florian Zand on 06.06.22.
//

import Foundation

extension NSRange: RandomAccessCollection {
    public typealias Index = Int
    public typealias Element = Int

    public var startIndex: Index { 0 }
    public var endIndex: Index { location + length }

    public subscript(index: Index) -> Element {
        precondition(indices.contains(index), "Index out of range")
        return index
    }

    public func index(after i: Index) -> Index {
        i + 1
    }

    public func index(before i: Index) -> Index {
        i - 1
    }
}

public extension NSRange {
    /// `ClosedRange` representation of the range.
    var closedRange: ClosedRange<Int> {
        guard location >= 0, length >= 0 else { return 0...0 }
        return location...(location + length - 1)
    }

    /// `Range` representation of the range.
    var range: Range<Int> {
        guard location >= 0, length >= 0 else { return 0..<0 }
        return location..<location + length
    }
    
    /// `CFRange` representation of the range.
    var cfRange: CFRange {
        CFRange(location: location, length: length)
    }
    
    /// `Array` representation of the range.
    var array: [Int] {
        map({$0})
    }
    
    /// The maximum value.
    var max: Int {
        NSMaxRange(self)
    }

    /// A Boolean value indicating whether the range is not found.
    var isNotFound: Bool {
        location == NSNotFound
    }

    /// A Boolean value indicating whether the given range is contained within the range.
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

    /// A Boolean value indicating whether this range and the given range contain an element in common.
    func overlaps(_ other: NSRange) -> Bool {
        intersection(other) != nil
    }
    
    /// The zero range.
    static var zero = NSRange(location: 0, length: 0)
    
    /// Not found range.
    static let notFound = NSRange(location: NSNotFound, length: 0)
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
