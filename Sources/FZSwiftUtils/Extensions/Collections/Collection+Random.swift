//
//  Collection+Random.swift
//
//
//  Created by Florian Zand on 23.08.23.
//

import Foundation

public extension Collection {
    /**
     Returns an array of random elements of the collection.
     - Parameters:
        - amount: The amount of random elements.
        - unique: A Boolean value indicating whether the returned elements should be unique (non repeating).
     */
    func randomElements(amount: Int, unique: Bool = true) -> [Element] {
        if unique == false {
            guard !isEmpty else { return [] }
            return (0..<amount).reduce(into: [Element]()) { partialResult, _ in
                partialResult.append(randomElement()!)
            }
        }
        guard amount > 0 else { return [] }
        
        var rng = SystemRandomNumberGenerator()
        
        var w = 1.0
        var result: [Element] = []
        result.reserveCapacity(amount)
        
        // Fill the reservoir with the first `count` elements.
        var i = startIndex
        while i != endIndex, result.count < amount {
            result.append(self[i])
            formIndex(after: &i)
        }
        
        while i != endIndex {
            // Calculate the next value of w.
            w *= nextW(k: amount, using: &rng)
            
            // Find index of the next element to swap into the reservoir.
            let offset = nextOffset(w: w, using: &rng)
            i = index(i, offsetBy: offset, limitedBy: endIndex) ?? endIndex
            
            if i != endIndex {
                // Swap selected element with a randomly chosen one in the reservoir.
                let j = Int.random(in: 0..<result.count, using: &rng)
                result[j] = self[i]
                formIndex(after: &i)
            }
        }
        
        result.shuffle(using: &rng)
        return result
    }
}

public extension Collection where Element: Equatable {
    /**
     Returns a random element of the collection excluding the specified elements.

     - Parameter excluding: The elements of the collection to be excluded from returning.
     */
    func randomElement(excluding: [Element]) -> Element? {
        shuffled().first(where: { !excluding.contains($0) })
    }

    /**
     Returns an array of random elements excluding the specified elements.

     - Parameters:
        - amount: The amount of random elements.
        - excluding: The elements of the collection to be excluded from random.
        - unique: A Boolean value indicating whether the returned elements should be unique (non repeating).
     */
    func randomElements(amount: Int, excluding: [Element], unique: Bool = true) -> [Element] {
        let elements: [Element] = filter { excluding.contains($0) == false }
        return elements.randomElements(amount: amount, unique: unique)
    }
}

public extension Sequence {
    /**
     Returns an array of random elements of the collection.
     - Parameters:
        - amount: The amount of random elements.
        - unique: A Boolean value indicating whether the returned elements should be unique (non repeating).
     */
    func randomElements(amount: Int, unique: Bool = true) -> [Element] {
        if unique == false {
            return Array(self).randomElements(amount: amount)
        }
        guard amount > 0 else { return [] }
        
        var rng = SystemRandomNumberGenerator()
        
        var w = 1.0
        var result: [Element] = []
        result.reserveCapacity(amount)
        
        // Fill the reservoir with the first `k` elements.
        var iterator = makeIterator()
        while result.count < amount, let el = iterator.next() {
            result.append(el)
        }
        
        while true {
            // Calculate the next value of w.
            w *= nextW(k: amount, using: &rng)
            
            // Find the offset of the next element to swap into the reservoir.
            var offset = nextOffset(w: w, using: &rng)
            
            // Skip over `offset` elements to find the selected element.
            while offset > 0, let _ = iterator.next() {
                offset -= 1
            }
            guard let nextElement = iterator.next() else { break }
            
            // Swap selected element with a randomly chosen one in the reservoir.
            let j = Int.random(in: 0..<result.count, using: &rng)
            result[j] = nextElement
        }
        result.shuffle(using: &rng)
        return result
    }
}

extension Sequence {
    func nextW<G: RandomNumberGenerator>(k: Int, using rng: inout G) -> Double {
        Double.root(.random(in: 0..<1, using: &rng), k)
    }
    
    func nextOffset<G: RandomNumberGenerator>(w: Double, using rng: inout G) -> Int {
        let offset = log(Double.random(in: 0..<1, using: &rng)) / log1p(-w)
        return offset < Double(Int.max) ? Int(offset) : Int.max
    }
}

extension Double {
    static func root(_ x: Double, _ n: Int) -> Double {
        guard x >= 0 || n % 2 != 0 else { return .nan }
        if n == 3 { return cbrt(x) }
        return Double(signOf: x, magnitudeOf: pow(x.magnitude, 1/Double(n)))
    }
}
