//
//  Comparable+Clamp.swift
//
//
//  Created by Florian Zand on 06.06.22.
//

import Foundation

public extension Comparable {
    /// Returns the value clamped to the specified closed range.
    func clamped(to range: ClosedRange<Self>) -> Self {
        max(range.lowerBound, min(self, range.upperBound))
    }
    
    /// Returns the value clamped between the specified bounds.
    func clamped(to range: (Self, Self)) -> Self {
        clamped(to: min(range.0, range.1)...max(range.0, range.1))
    }

    /// Returns the value clamped to the specified lower-bounded range.
    func clamped(to range: PartialRangeFrom<Self>) -> Self {
        max(range.lowerBound, self)
    }

    /// Returns the value clamped to the specified upper-bounded range.
    func clamped(to range: PartialRangeThrough<Self>) -> Self {
        Swift.min(self, range.upperBound)
    }
    
    /// Returns the value clamped to the specified minimum value.
    func clamped(min minValue: Self) -> Self {
        max(minValue, self)
    }

    /// Returns the value clamped to the specified maximum value.
    func clamped(max maxValue: Self) -> Self {
        min(maxValue, self)
    }

    /// Clamps the value to the specified closed range.
    mutating func clamp(to range: ClosedRange<Self>) {
        self = clamped(to: range)
    }
    
    /// Clamps the value between the specified bounds.
    mutating func clamp(to range: (Self, Self)) {
        self = clamped(to: range)
    }

    /// Clamps the value to the specified lower-bounded range.
    mutating func clamp(to range: PartialRangeFrom<Self>) {
        self = clamped(to: range)
    }

    /// Clamps the value to the specified upper-bounded range.
    mutating func clamp(to range: PartialRangeThrough<Self>) {
        self = clamped(to: range)
    }

    /// Clamps the value to the specified minimum value.
    mutating func clamp(min minValue: Self) {
        self = clamped(min: minValue)
    }

    /// Clamps the value to the specified maximum value.
    mutating func clamp(max maxValue: Self) {
        self = clamped(max: maxValue)
    }
}

public extension Comparable {
    /// Returns the value clamped to the specified range, or `nil` if the value cannot be clamped to the range.
    @_disfavoredOverload
    func clamped(to range: Range<Self>) -> Self? {
        guard !range.isEmpty, self < range.upperBound else { return nil }
        return Swift.max(self, range.lowerBound)
    }
    
    /// Returns the value if it is below the specified upper bound, or `nil` otherwise.
    @_disfavoredOverload
    func clamped(to range: PartialRangeUpTo<Self>) -> Self? {
        self < range.upperBound ? self : nil
    }
}

public extension Comparable where Self: Strideable, Stride: SignedInteger {
    /// Returns the value clamped to the specified range, or `nil` if the range is empty.
    func clamped(to range: Range<Self>) -> Self? {
        guard !range.isEmpty else { return nil }
        if self < range.lowerBound { return range.lowerBound }
        if self >= range.upperBound { return range.upperBound.advanced(by: -1) }
        return self
    }
    
    /// Returns the value clamped below the specified upper bound.
    func clamped(to range: PartialRangeUpTo<Self>) -> Self {
        self < range.upperBound ? self : range.upperBound.advanced(by: -1)
    }
    
    /// Clamps the value below the specified upper bound.
    mutating func clamp(to range: PartialRangeUpTo<Self>) {
        self = clamped(to: range)
    }
}

public extension Sequence where Element: Comparable {
    /// Returns the elements clamped to the specified closed range.
    func clamped(to range: ClosedRange<Element>) -> [Element] {
        map { $0.clamped(to: range) }
    }
    
    /// Returns the elements clamped between the specified bounds.
    func clamped(to range: (Element, Element)) -> [Element] {
        map { $0.clamped(to: range) }
    }
    
    /// Returns the elements clamped to the specified lower-bounded range.
    func clamped(to range: PartialRangeFrom<Element>) -> [Element] {
        map { $0.clamped(to: range) }
    }
    
    /// Returns the elements clamped to the specified upper-bounded range.
    func clamped(to range: PartialRangeThrough<Element>) -> [Element] {
        map { $0.clamped(to: range) }
    }
    
    /// Returns the elements clamped to the specified minimum value.
    func clamped(min minValue: Element) -> [Element] {
        map { $0.clamped(min: minValue) }
    }
    
    /// Returns the elements clamped to the specified maximum value.
    func clamped(max maxValue: Element) -> [Element] {
        map { $0.clamped(max: maxValue) }
    }
}

public extension MutableCollection where Element: Comparable {
    /// Clamps the elements to the specified closed range.
    mutating func clamp(to range: ClosedRange<Element>) {
        editEach { $0.clamp(to: range) }
    }
    
    /// Clamps the elements between the specified bounds.
    mutating func clamp(to range: (Element, Element)) {
        editEach { $0.clamp(to: range) }
    }
    
    /// Clamps the elements to the specified lower-bounded range.
    mutating func clamp(to range: PartialRangeFrom<Element>) {
        editEach { $0.clamp(to: range) }
    }
    
    /// Clamps the elements to the specified upper-bounded range.
    mutating func clamp(to range: PartialRangeThrough<Element>) {
        editEach { $0.clamp(to: range) }
    }

    /// Clamps the elements to the specified minimum value.
    mutating func clamp(min minValue: Element) {
        editEach { $0.clamp(min: minValue) }
    }
    
    /// Clamps the elements to the specified maximum value.
    mutating func clamp(max maxValue: Element) {
        editEach { $0.clamp(max: maxValue) }
    }
}
