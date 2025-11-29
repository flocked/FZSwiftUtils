//
//  Collection+Average.swift
//  
//
//  Created by Florian Zand on 09.03.25.
//

import Foundation

public extension Collection where Element: BinaryInteger {
    /**
     The average value of all values in the collection.
     
     If the collection is empty, it returns `0`.
     */
    func average() -> Double {
        map({Double($0)}).average()
    }
    
    /**
     The weighted average value of all values in the collection with linearly decreasing weight.
     
     If the collection is empty, it returns `0`.
     */
    func weightedAverage() -> Double {
        map({Double($0)}).weightedAverage()
    }
    
    /**
     The weighted average value of all values in the collection.
          
     * If the count of `weights` matches the collection's count, each element uses its corresponding weight.
     * Otherwise weights are linearly interpolated across the collection.
          
     If the collection is empty, it returns `0`.
     
     ```swift
     let values = [10, 30, 50]
     // Decreasing weight: higher weight at the start, lower at the end
     values.weightedAverage(using: [1, 0])
     // Bell curve weight: higher weight in the middle
     values.weightedAverage(using: [0, 1, 0])
     ```
     
     - Parameter weights: The weights to apply.
     */
    func weightedAverage(using weights: [Double]) -> Double {
        map({Double($0)}).weightedAverage(using: weights)
    }
}

public extension Collection where Element: BinaryFloatingPoint {
    /**
     The average value of all values in the collection.
     
     If the collection is empty, it returns `0`.
     */
    func average() -> Element {
        guard !isEmpty else { return .zero }
        return reduce(.zero, +) / Element(count)
    }
    
    /**
     The weighted average value of all values in the collection with linearly decreasing weight.
     
     If the collection is empty, it returns `0`.
     */
    func weightedAverage() -> Element {
        let weights = (0..<count).map { i in  1.0 - Element(i) / Element(count) }
        return weightedAverage(using: weights)
    }
    
    /**
     The weighted average value of all values in the collection.
          
     * If the count of `weights` matches the collection's count, each element uses its corresponding weight.
     * Otherwise weights are linearly interpolated across the collection.

     If the collection is empty, it returns `0`.
     
     ```swift
     let values = [10.0, 30.ß, 50.0]
     // Decreasing weight: higher weight at the start, lower at the end
     values.weightedAverage(using: [1, 0])
     // Bell curve weight: higher weight in the middle
     values.weightedAverage(using: [0, 1, 0])
     ```
     
     - Parameter weights: The weights to apply.
     */
    func weightedAverage(using weights: [Element]) -> Element {
        guard !isEmpty else { return .zero }
        guard !weights.isEmpty else { return weightedAverage() }
        var weights = weights
        if weights.count > count {
            weights = Array(weights[0..<count])
        } else if weights.count < endIndex {
            let lastIndex = weights.count - 1
            let step = Element(weights.count - 1) / Element(count - 1)
            weights = (0..<count).map { i in
                let pos = Element(i) * step
                 let j = Int(pos)
                 let frac = pos - Element(j)
                 if j >= lastIndex {
                     return weights[lastIndex]
                 } else {
                     let start = weights[j]
                     let end = weights[j + 1]
                     return start + (end - start) * frac
                 }
            }
        }
        let totalWeight = weights.sum()
        guard totalWeight > 0 else { return .zero }
        return zip(self, weights).map { $0 * $1 }.sum() / totalWeight
    }
    
    /**
     The standard deviation of the collection.
     
     The standard deviation measures how spread out the values are from the average value.
     
     - Parameter isSample: `true` to compute the **sample standard deviation** (dividing by `n-1`), , or `false` to compute the **population standard deviation** (dividing by `n`).
     */
    func standardDeviation(isSample: Bool = true) -> Element? {
        guard !isEmpty, count > 1 || !isSample else { return nil }
        let average = average()
        let varianceSum = reduce(.zero) { $0 + ($1 - average) * ($1 - average) }
        return Element(sqrt(varianceSum / Element(isSample ? count - 1 : count)))
    }
}

/*
import Accelerate

extension Array where Element == Double {
    func average() -> Element {
        var average: Double = 0
        vDSP_meanvD(self, 1, &average, vDSP_Length(count))
        return average
    }
    
    func standardDeviation(isSample: Bool = true) -> Double {
        guard !isEmpty, !isSample || count > 1 else { return 0.0 }
        var mean = 0.0
        var stdDev = 0.0
        vDSP_normalizeD(self, 1, nil, 1, &mean, &stdDev, vDSP_Length(count))
        if isSample {
            stdDev *= sqrt(Double(count) / Double(count - 1))
        }
        return stdDev
    }
}

extension Array where Element == Float {
    func average() -> Element {
        var average: Float = 0
        vDSP_meanv(self, 1, &average, vDSP_Length(count))
        return average
    }
    
    func standardDeviation(isSample: Bool = true) -> Float {
        guard !isEmpty, !isSample || count > 1 else { return 0.0 }
        var mean: Float = 0.0
        var stdDev: Float = 0.0
        vDSP_normalize(self, 1, nil, 1, &mean, &stdDev, vDSP_Length(count))
        if isSample {
            stdDev *= Element(sqrt(Double(count) / Double(count - 1)))
        }
        return stdDev
    }
}
*/
