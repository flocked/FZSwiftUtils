//
//  Collection+Average.swift
//  
//
//  Created by Florian Zand on 09.03.25.
//

import Foundation

public extension Collection where Element: BinaryInteger {
    /// The average value of all values in the collection. If the collection is empty, it returns `0`.
    func average() -> Double {
        guard !isEmpty else { return .zero }
        return Double(reduce(.zero, +)) / Double(count)
    }
    
    /// The weighted average value of all values in the collection. If the collection is empty, it returns `0`.
    func weightedAverage() -> Double {
        compactMap({Double($0)}).weightedAverage()
    }
    
    /**
     The weighted average value of all values in the collection. If the collection is empty, it returns `0`.
     
     - Parameter weights: The weight for each element in the collection.
     
     - Note: `weights` needs to have the same number of elements as the collection.
     */
    func weightedAverage(weights: [Double]) -> Double {
        compactMap({Double($0)}).weightedAverage(weights: weights)
    }
    
    /**
     The weighted average value of all values in the collection. If the collection is empty, it returns `0`.
     
     The first value of the collection is weighted by the upper bound value of the range and the last value by the lower bound value of the range.
     
     - Parameter weighting: The range of the weights.
     */
    func weightedAverage(weighting: ClosedRange<Double>) -> Double {
        compactMap({Double($0)}).weightedAverage(weighting: weighting)
    }
}

public extension Collection where Element: FloatingPoint {
    /// The average value of all values in the collection. If the collection is empty, it returns `0`.
    func average() -> Element {
        guard !isEmpty else { return .zero }
        return reduce(.zero, +) / Element(count)
    }
}

public extension Collection where Element: BinaryFloatingPoint {
    /// The weighted average value of all values in the collection. If the collection is empty, it returns `0`.
    func weightedAverage() -> Element {
        var weights: [Element] = []
        var value: Element = 1.0
        let divider: Element = 1.0/Element(count)
        for _ in 0..<count {
            weights.append(value)
            value = value - divider
        }
        return weightedAverage(weights: weights)
    }
    
    /**
     The weighted average value of all values in the collection. If the collection is empty, it returns `0`.
     
     - Parameter weights: The weight for each element in the collection.
     
     - Note: `weights` needs to have the same number of elements as the collection.
     */
    func weightedAverage(weights: [Element]) -> Element {
        guard !isEmpty, count == weights.count else { return .zero }
        let totalWeight = weights.sum()
        guard totalWeight > 0 else { return .zero }
        return zip(self, weights).map { $0 * $1 }.reduce(.zero, +) / totalWeight
    }
    
    /**
     The weighted average value of all values in the collection. If the collection is empty, it returns `0`.
          
     The first value of the collection is weighted by the upper bound value of the range and the last value by the lower bound value of the range.

     - Parameter weighting: The range of the weights.
     */
    func weightedAverage(weighting: ClosedRange<Element>) -> Element {
        var weights: [Element] = []
        let range = weighting.upperBound-weighting.lowerBound
        let divider: Element = 1.0/Element(count-1)
        var value: Element = 1.0
        for _ in 0..<count {
            weights.append((range*value)+weighting.lowerBound)
            value = value - divider
        }
        return weightedAverage(weights: weights)
    }
}
