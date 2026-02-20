//
//  Comparable+Clamp.swift
//
//
//  Created by Florian Zand on 06.06.22.
//

import Foundation

public extension Comparable {
    /**
     Clamps the value to the specified closed range.

     - Parameter range: The closed range to clamp the value to.
     - Returns: The clamped value.
     */
    func clamped(to range: ClosedRange<Self>) -> Self {
        max(range.lowerBound, min(self, range.upperBound))
    }
    
    /**
     Clamps the value to the specified range.

     - Parameter range: The closed range to clamp the value to.
     - Returns: The clamped value.
     */
    func clamped(to range: Range<Self>) -> Self where Self: BinaryInteger {
        max(range.lowerBound, min(self, range.upperBound-1))
    }
    
    /**
     Clamps the value to the specified closed range.

     - Parameter range: The closed range to clamp the value to.
     - Returns: The clamped value.
     */
    func clamped(to range: (Self, Self)) -> Self {
        clamped(to: min(range.0, range.1)...max(range.0, range.1))
    }

    /**
     Clamps the value to the specified partial range.

     - Parameter range: The partial range to clamp the value to.
     - Returns: The clamped value.
     */
    func clamped(to range: PartialRangeFrom<Self>) -> Self {
        max(range.lowerBound, self)
    }

    /**
     Clamps the value to the specified partial range.

     - Parameter range: The partial range to clamp the value to.
     - Returns: The clamped value.
     */
    func clamped(to range: PartialRangeUpTo<Self>) -> Self {
        min(range.upperBound, self)
    }
    
    /**
     Clamps the value to the specified minimum value.

     - Parameter minValue: The minimum value to clamp the value to.
     - Returns: The clamped value.
     */
    func clamped(min minValue: Self) -> Self {
        max(minValue, self)
    }
    
    /**
     Clamps the value to the specified maximum value.

     - Parameter maxValue: The maximum value to clamp the value to.
     - Returns: The clamped value.
     */
    func clamped(max maxValue: Self) -> Self {
        min(maxValue, self)
    }

    /**
     Clamps the value to the specified closed range.

     - Parameter range: The closed range to clamp the value to.
     */
    mutating func clamp(to range: ClosedRange<Self>) {
        self = clamped(to: range)
    }
    
    /**
     Clamps the value to the specified range.

     - Parameter range: The range to clamp the value to.
     */
    mutating func clamp(to range: Range<Self>) where Self: BinaryInteger {
        self = clamped(to: range)
    }
    
    /**
     Clamps the value to the specified closed range.

     - Parameter range: The closed range to clamp the value to.
     */
    mutating func clamp(to range: (Self, Self)) {
        self = clamped(to: range)
    }

    /**
     Clamps the value to specified partial range.

     - Parameter range: The partial range to clamp the value to.
     */
    mutating func clamp(to range: PartialRangeFrom<Self>) {
        self = clamped(to: range)
    }

    /**
     Clamps the value to specified partial range.

     - Parameter range: The partial range to clamp the value to.
     */
    mutating func clamp(to range: PartialRangeUpTo<Self>) {
        self = clamped(to: range)
    }
    
    /**
     Clamps the value to a minimum value.

     - Parameter minValue: The minimum value to clamp the value to.
     */
    mutating func clamp(min minValue: Self) {
        self = clamped(min: minValue)
    }
    
    /**
     Clamps the value to a maximum value.

     - Parameter maxValue: The maximum value to clamp the value to.
     */
    mutating func clamp(max maxValue: Self) {
        self = clamped(max: maxValue)
    }
}

public extension Sequence where Element: Comparable {
    /**
     Clamps the elements of the sequence to the specified minimum and maximum value.
     
     - Parameters:
        - minValue: The minimum value.
        - maxValue: The maximum value.
     - Returns: The clamped elements.
     */
    func clamped(to minValue: Element, _ maxValue: Element) -> [Element] {
        clamped(to: Swift.min(minValue, maxValue)...Swift.max(minValue, maxValue))
    }

    /**
     Clamps the elements of the sequence to the specified range.

     - Parameter range: The range to clamp the elements to.
     - Returns: The clamped elements.
     */
    func clamped(to range: ClosedRange<Element>) -> [Element] {
        map({ $0.clamped(to: range)})
    }
    
    /**
     Clamps the elements of the sequence to the specified range.

     - Parameter range: The range to clamp the elements to.
     - Returns: The clamped elements.
     */
    func clamped(to range: PartialRangeFrom<Element>) -> [Element] {
        map({ $0.clamped(to: range)})
    }
    
    /**
     Clamps the elements of the sequence to the specified range.

     - Parameter range: The range to clamp the elements to.
     - Returns: The clamped elements.
     */
    func clamped(to range: PartialRangeUpTo<Element>) -> [Element] {
        map({ $0.clamped(to: range)})
    }
      
    /**
     Clamps the elements of the sequence to the specified minimum value.

     - Parameter maxValue: The minimum value to clamp the elements to.
     - Returns: The clamped elements.
     */
    func clamped(min minValue: Element) -> [Element] {
        map({ $0.clamped(min: minValue)})
    }
    
    /**
     Clamps the elements of the sequence to the specified maximum value.

     - Parameter maxValue: The maximum value to clamp the elements to.
     - Returns: The clamped elements.
     */
    func clamped(max maxValue: Element) -> [Element] {
        map({ $0.clamped(max: maxValue)})
    }
}

public extension Sequence where Element: Comparable, Self: RangeReplaceableCollection {
    /**
     Clamps the elements of the sequence to the specified minimum and maximum value.
     
     - Parameters:
        - minValue: The minimum value.
        - maxValue: The maximum value.
     */
    mutating func clamped(to minValue: Element, _ maxValue: Element) {
        clamp(to: Swift.min(minValue, maxValue)...Swift.max(minValue, maxValue))
    }
    
    /**
     Clamps the elements of the sequence to the specified range.

     - Parameter range: The range to clamp the elements to.
     */
    mutating func clamp(to range: ClosedRange<Element>) {
        self = Self(clamped(to: range))
    }
    
    /**
     Clamps the elements of the sequence to the specified range.

     - Parameter range: The range to clamp the elements to.
     */
    mutating func clamp(to range: PartialRangeFrom<Element>) {
        self = Self(clamped(to: range))
    }
    
    /**
     Clamps the elements of the sequence to the specified range.

     - Parameter range: The range to clamp the elements to.
     */
    mutating func clamp(to range: PartialRangeUpTo<Element>) {
        self = Self(clamped(to: range))
    }
    
    /**
     Clamps the elements of the sequence to the specified minimum value.

     - Parameter maxValue: The minimum value to clamp the elements to.
     - Returns: The clamped elements.
     */
    mutating func clamp(min minValue: Element) {
        self = Self(clamped(min: minValue))
    }
    
    /**
     Clamps the elements of the sequence to the specified maximum value.

     - Parameter maxValue: The maximum value to clamp the elements to.
     */
    mutating func clamp(max maxValue: Element) {
        self = Self(clamped(max: maxValue))
    }
}
