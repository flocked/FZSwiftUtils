//
//  Number+Interpolate.swift
//
//
//  Created by Florian Zand on 28.09.23.
//

import Foundation

extension BinaryInteger {
    /**
     Interpolates the value from one range to another range.

     - Parameters:
        - from: The source range.
        - to: The target range.

     - Returns: The interpolated value within the target range.
     */
    func interpolated(from: ClosedRange<Self>, to: ClosedRange<Self>) -> Self {
        interpolated(from: from.lowerBound, from.upperBound, to: to.lowerBound, to.upperBound)
    }
    
    /**
     Interpolates the value from one range to another range.

     - Parameters:
        - fromLower: The source lower bound value.
        - fromUpper: The source upper bound value.
        - toLower: The target lower bound value.
        - toUpper: The target upper bound value.

     - Returns: The interpolated value within the target range.
     */
    func interpolated(from fromLower: Self, _ fromUpper: Self, to toLower: Self, _ toUpper: Self) -> Self {
        Self(Float(self).interpolated(from: Float(fromLower), Float(fromUpper), to: Float(toLower), Float(toUpper)).rounded(.towardZero))
    }
}

public extension BinaryFloatingPoint {
    /**
     Interpolates the value from one range to another range.

     - Parameters:
        - from: The source range.
        - to: The target range.

     - Returns: The interpolated value within the target range.
     */
    func interpolated(from: ClosedRange<Self>, to: ClosedRange<Self>) -> Self {
        interpolated(from: from.lowerBound, from.upperBound, to: to.lowerBound, to.upperBound)
    }
    
    /**
     Interpolates the value from one range to another range.

     - Parameters:
        - fromLower: The source lower bound value.
        - fromUpper: The source upper bound value.
        - toLower: The target lower bound value.
        - toUpper: The target upper bound value.

     - Returns: The interpolated value within the target range.
     */
    func interpolated(from fromLower: Self, _ fromUpper: Self, to toLower: Self, _ toUpper: Self) -> Self {
        let positionInRange = (self - fromLower) / (fromUpper - fromLower)
        return (positionInRange * (toUpper - toLower)) + toLower
    }
}

public extension Sequence where Element: BinaryInteger {
    /**
     Interpolates the elements of the sequence from one range to another range.

     - Parameters:
        - from: The source range.
        - to: The target range.

     - Returns: An array of the interpolated values within the target range.
     */
    func interpolated(from: ClosedRange<Element>, to: ClosedRange<Element>) -> [Element] {
        compactMap { $0.interpolated(from: from, to: to) }
    }
    
    /**
     Interpolates the elements of the sequence from one range to another range.

     - Parameters:
        - fromLower: The source lower bound value.
        - fromUpper: The source upper bound value.
        - toLower: The target lower bound value.
        - toUpper: The target upper bound value.

     - Returns: An array of the interpolated values within the target range.
     */
    func interpolated(from fromLower: Element, _ fromUpper: Element, to toLower: Element, _ toUpper: Element) -> [Element] {
        compactMap({ $0.interpolated(from: fromLower, fromUpper, to: toLower, toUpper) })
    }

    /**
     Interpolates the elements of the sequence to another range by using the minimum and maximum value inside the sequence.

     - Parameter range: The target range.
     - Returns: An array of the interpolated values within the target range.
     */
    func interpolated(to range: ClosedRange<Element>) -> [Element] {
        guard let min = self.min(), let max = self.max() else { return Array(self) }
        return compactMap { $0.interpolated(from: min...max, to: range) }
    }
}

public extension Sequence where Element: BinaryFloatingPoint {
    /**
     Interpolates the elements of the sequence from one range to another range.

     - Parameters:
        - from: The source range.
        - to: The target range.

     - Returns: An array of the interpolated values within the target range.
     */
    func interpolated(from: ClosedRange<Element>, to: ClosedRange<Element>) -> [Element] {
        compactMap { $0.interpolated(from: from, to: to) }
    }
    
    /**
     Interpolates the elements of the sequence from one range to another range.

     - Parameters:
        - fromLower: The source lower bound value.
        - fromUpper: The source upper bound value.
        - toLower: The target lower bound value.
        - toUpper: The target upper bound value.

     - Returns: An array of the interpolated values within the target range.
     */
    func interpolated(from fromLower: Element, _ fromUpper: Element, to toLower: Element, _ toUpper: Element) -> [Element] {
        compactMap({ $0.interpolated(from: fromLower, fromUpper, to: toLower, toUpper) })
    }

    /**
     Interpolates the elements of the sequence to another range by using the minimum and maximum value inside the sequence.

     - Parameter range: The target range.
     - Returns: An array of the interpolated values within the target range.
     */
    func interpolated(to range: ClosedRange<Element>) -> [Element] {
        guard let min = self.min(), let max = self.max() else { return Array(self) }
        return compactMap { $0.interpolated(from: min...max, to: range) }
    }
}
