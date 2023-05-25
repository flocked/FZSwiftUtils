//
//  NSRange+.swift
//
//
//  Created by 1024jp on 2023-02-15.
//  © 2023 1024jp

import Foundation

public extension NSRange {
    func closedRange() -> ClosedRange<Int> {
        return self.lowerBound...self.upperBound
    }
    
    static let notFound = NSRange(location: NSNotFound, length: 0)
    
    
    /// A boolean value indicating whether the range contains no elements.
    var isEmpty: Bool {
        self.length == 0
    }
    
    
    /// A boolean value indicating whether the range is not found.
    var isNotFound: Bool {
        self.location == NSNotFound
    }
    
    
    /// Check if the given index is in the receiver or touchs to one of the receiver's bounds.
    ///
    /// - Parameter index: The index to test.
    func touches(_ index: Int) -> Bool {
        self.lowerBound <= index && index <= self.upperBound
    }
    
    
    /// Return a boolean indicating whether the specified range intersects the receiver’s range.
    ///
    /// - Parameter other: The other range.
    func intersects(_ other: NSRange) -> Bool {
        self.intersection(other) != nil
    }
    
    
    /// Check if the two ranges overlap or touch each other.
    ///
    /// - Parameter range: The range to test.
    /// - Note: Unlike Swift.Range's `overlaps(_:)`, this method returns `true` when a range length is 0.
    func touches(_ range: NSRange) -> Bool {
        if self.location == NSNotFound { return false }
        if range.location == NSNotFound { return false }
        if self.upperBound < range.lowerBound { return false }
        if range.upperBound < self.lowerBound { return false }
        
        return true
    }
    
    
    /// Return a copied NSRange but whose location is shifted toward the given `offset`.
    ///
    /// - Parameter offset: The offset to shift.
    /// - Returns: A new NSRange.
    func shifted(by offset: Int) -> NSRange {
        NSRange(location: self.location + offset, length: self.length)
    }
}


extension Sequence<NSRange> {
    /// The range that contains all ranges.
    var union: NSRange? {
        guard
            let lowerBound = self.map(\.lowerBound).min(),
            let upperBound = self.map(\.upperBound).max()
        else { return nil }
        
        return NSRange(lowerBound..<upperBound)
    }
}
