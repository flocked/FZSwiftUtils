//
//  Comparable+Clamp.swift
//
//
//  Created by Florian Zand on 06.06.22.
//

import Foundation

public extension Comparable {
    /// Returns the value clamped to the specified range.
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
    
    /// Clamps the value to the specified range.
    mutating func clamp(to range: ClosedRange<Self>) {
        self = clamped(to: range)
    }
    
    /// Returns the value clamped to the specified range.
    func clamped(to range: (Self, Self)) -> Self {
        clamped(to: min(range.0, range.1) ... max(range.0, range.1))
    }
    
    /// Clamps the value between the specified range.
    mutating func clamp(to range: (Self, Self)) {
        self = clamped(to: range)
    }

    /// Returns the value clamped to the specified range.
    func clamped(to range: PartialRangeFrom<Self>) -> Self {
        max(range.lowerBound, self)
    }
    
    /// Clamps the value to the specified range.
    mutating func clamp(to range: PartialRangeFrom<Self>) {
        self = clamped(to: range)
    }

    /// Returns the value clamped to the specified range.
    func clamped(to range: PartialRangeThrough<Self>) -> Self {
        Swift.min(self, range.upperBound)
    }
    
    /// Clamps the value to the specified range.
    mutating func clamp(to range: PartialRangeThrough<Self>) {
        self = clamped(to: range)
    }
    
    /// Returns the value clamped to the specified minimum value.
    func clamped(min minValue: Self) -> Self {
        max(minValue, self)
    }
    
    /// Clamps the value to the specified minimum value.
    mutating func clamp(min minValue: Self) {
        self = clamped(min: minValue)
    }

    /// Returns the value clamped to the specified maximum value.
    func clamped(max maxValue: Self) -> Self {
        min(maxValue, self)
    }

    /// Clamps the value to the specified maximum value.
    mutating func clamp(max maxValue: Self) {
        self = clamped(max: maxValue)
    }
    
    /// Returns the value clamped to the specified range.
    @_disfavoredOverload
    func clamped(to range: Range<Self>) -> Self? {
        guard !range.isEmpty, self < range.upperBound else { return nil }
        return Swift.max(self, range.lowerBound)
    }
    
    /// Clamps the value to the specified range.
    @_disfavoredOverload
    mutating func clamp(to range: Range<Self>) {
        guard let value = clamped(to: range) else { return }
        self = value
    }
    
    /// Returns the value clamped to the specified range.
    @_disfavoredOverload
    func clamped(to range: PartialRangeUpTo<Self>) -> Self? {
        self < range.upperBound ? self : nil
    }
    
    /// Clamps the value to the specified range.
    @_disfavoredOverload
    mutating func clamp(to range: PartialRangeUpTo<Self>) {
        guard let value = clamped(to: range) else { return }
        self = value
    }
}

public extension Comparable where Self: Strideable, Stride: SignedInteger {
    /// Returns the value clamped to the specified range.
    func clamped(to range: Range<Self>) -> Self? {
        guard !range.isEmpty else { return nil }
        if self < range.lowerBound { return range.lowerBound }
        if self >= range.upperBound { return range.upperBound.advanced(by: -1) }
        return self
    }
    
    /// Clamps the value to the specified range.
    mutating func clamp(to range: Range<Self>) {
        guard !range.isEmpty else { return }
        if self < range.lowerBound {
            self = range.lowerBound
        } else if self >= range.upperBound {
            self = range.upperBound.advanced(by: -1)
        }
    }
    
    /// Returns the value clamped to the specified range.
    func clamped(to range: PartialRangeUpTo<Self>) -> Self {
        self < range.upperBound ? self : range.upperBound.advanced(by: -1)
    }
    
    /// Clamps the value to the specified range.
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
