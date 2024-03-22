//
//  Number+Interpolate.swift
//
//
//  Created by Florian Zand on 28.09.23.
//

import Foundation

extension BinaryInteger {
    /**
     Interpolates a value from one range to another range.

     - Parameters:
        - from: The source range.
        - to: The target range.

     - Returns: The interpolated value within the target range.
     */
    func interpolated(from: ClosedRange<Self>, to: ClosedRange<Self>) -> Self {
        Self(Float(self).interpolated(from: from.toFloating, to: to.toFloating).rounded(.towardZero))
    }
}

public extension BinaryFloatingPoint {
    /**
     Interpolates a value from one range to another range.

     - Parameters:
        - from: The source range.
        - to: The target range.

     - Returns: The interpolated value within the target range.
     */
    func interpolated(from: ClosedRange<Self>, to: ClosedRange<Self>) -> Self {
        // 14 0 10
        let positionInRange = (self - from.lowerBound) / (from.upperBound - from.lowerBound)
        return (positionInRange * (to.upperBound - to.lowerBound)) + to.lowerBound
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
     Interpolates the elements of the sequence to another range by using the minimum and maximum value inside the sequence.

     - Parameters:
        - range: The target range.

     - Returns: An array of the interpolated values within the target range.
     */
    func interpolated(to range: ClosedRange<Element>) -> [Element] {
        guard let min = self.min(), let max = self.max() else { return Array(self) }
        let from = min ... max
        return compactMap { $0.interpolated(from: from, to: range) }
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
     Interpolates the elements of the sequence to another range by using the minimum and maximum value inside the sequence.

     - Parameters:
        - range: The target range.

     - Returns: An array of the interpolated values within the target range.
     */
    func interpolated(to range: ClosedRange<Element>) -> [Element] {
        guard let min = self.min(), let max = self.max() else { return Array(self) }
        let from = min ... max
        return compactMap { $0.interpolated(from: from, to: range) }
    }
}
