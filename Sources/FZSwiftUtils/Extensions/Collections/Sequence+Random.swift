//
//  Collection+Random.swift
//
//
//  Created by Florian Zand on 23.08.23.
//

import Foundation

public extension Sequence where Element: Equatable {
    /**
     Returns a random element of the collection excluding any of the specified elements.

     - Parameter excluding: The elements excluded for the returned element.
     - Returns: A random element from the collection excluding any of the specified elements. If the collection is empty, the method returns `nil.
     */
    func randomElement<S: Sequence<Element>>(excluding: S) -> Element? {
        shuffled().first(where: { !excluding.contains($0) })
    }
}


public extension Collection {
    /**
     Returns an array of random elements excluding the specified elements.

     - Parameters:
        - amount: The number of elements to return.
        - unique: A Boolean value indicating whether returned elements should be unique (non repeating).
        - strategy: A sampling strategy to use.
     */
    func randomElements(amount: Int, unique: Bool = true, strategy: SequenceSamplingStrategy = .shuffle) -> [Element] {
        guard amount > 0 else { return [] }
        var rng = SystemRandomNumberGenerator()
        
        if !unique {
            return (0..<amount).compactMap { _ in randomElement(using: &rng) }
        }

        switch strategy {
        case .shuffle:
            return shuffled().prefix(amount).map { $0 }
        case .reservoir:
            return reservoirSample(amount: amount, using: &rng)
        case .vitter:
            return vitterSample(amount: amount, using: &rng)
        }
    }
}

public extension Collection where Element: Equatable {
    /**
     Returns a random element of the collection excluding the specified elements.

     - Parameter excluding: The elements to be excluded from returning.
     */
    func randomElement(excluding: [Element]) -> Element? {
        shuffled().first(where: { !excluding.contains($0) })
    }

    /**
     Returns an array of random elements excluding the specified elements.

     - Parameters:
        - amount: The number of elements to return.
        - excluding: The elements to be excluded from returning.
        - unique: A Boolean value indicating whether returned elements should be unique (non repeating).
        - strategy: A sampling strategy to use.
     */
    func randomElements(amount: Int, excluding: [Element], unique: Bool = true, strategy: SequenceSamplingStrategy = .reservoir) -> [Element] {
        let elements: [Element] = filter { excluding.contains($0) == false }
        return elements.randomElements(amount: amount, unique: unique, strategy: strategy)
    }
}

public extension Sequence {
    /**
     Returns an array of random elements from the sequence.

     - Parameters:
        - amount: The number of elements to return.
        - unique: A Boolean value indicating whether returned elements should be unique (non repeating).
        - strategy: A sampling strategy to use.

     - Returns: An array of randomly selected elements.
     */
    func randomElements(amount: Int, unique: Bool = true, strategy: SequenceSamplingStrategy = .reservoir) -> [Element] {
        guard amount > 0 else { return [] }
        var rng = SystemRandomNumberGenerator()
        
        if !unique {
            let elements = Array(self)
            guard !elements.isEmpty else { return [] }
            return (0..<amount).compactMap { _ in elements.randomElement(using: &rng) }
        }
        
        switch strategy {
        case .shuffle:
            return shuffled().prefix(amount).map { $0 }
        case .reservoir:
            return reservoirSample(amount: amount, using: &rng)
        case .vitter:
            return vitterSample(amount: amount, using: &rng)
        }
    }
}

/// Strategy for selecting a unique random sample from a sequence.
public enum SequenceSamplingStrategy {
    /**
     Reservoir sampling algorithm (`R`).
     
     A simple and efficient algorithm for streaming data or when the sequence size is unknown.
     
     Every item has an equal probability of being included in the result.
     */
    case reservoir
    /**
     Vitter sampling algorithm (`X`).
     
     It is more efficient compared to ``reservoir`` when the desired sample size is much smaller than the total sequence size.
     
     It skips over elements probabilistically to reduce iteration steps.
     */
    case vitter
    /**
     Full shuffle.
     
     Fastest algorithm if the collection is already in memory and has known count.
     */
    case shuffle
}

fileprivate extension Sequence {
    func reservoirSample<G: RandomNumberGenerator>(amount: Int, using rng: inout G) -> [Element] {
        var reservoir: [Element] = []
        reservoir.reserveCapacity(amount)

        var iterator = makeIterator()
        var i = 0

        while i < amount, let next = iterator.next() {
            reservoir.append(next)
            i += 1
        }

        guard i == amount else {
            // Fewer elements than amount
            return reservoir
        }

        while let next = iterator.next() {
            i += 1
            let j = Int.random(in: 0..<i, using: &rng)
            if j < amount {
                reservoir[j] = next
            }
        }

        return reservoir
    }

    func vitterSample<G: RandomNumberGenerator>(amount: Int, using rng: inout G) -> [Element] {
        var result: [Element] = []
        result.reserveCapacity(amount)

        var iterator = makeIterator()
        var i = 0

        // Fill the reservoir
        while i < amount, let el = iterator.next() {
            result.append(el)
            i += 1
        }

        guard i == amount else {
            return result // not enough elements
        }

        var w = 1.0

        while true {
            w *= Self.nextW(k: amount, using: &rng)
            var offset = Self.nextOffset(w: w, using: &rng)

            while offset > 0, let _ = iterator.next() {
                offset -= 1
            }

            guard let next = iterator.next() else { break }

            let j = Int.random(in: 0..<amount, using: &rng)
            result[j] = next
        }

        return result
    }

    static func nextW<G: RandomNumberGenerator>(k: Int, using rng: inout G) -> Double {
        pow(Double.random(in: 0..<1, using: &rng), 1.0 / Double(k))
    }

    static func nextOffset<G: RandomNumberGenerator>(w: Double, using rng: inout G) -> Int {
        let offset = log(Double.random(in: 0..<1, using: &rng)) / log1p(-w)
        return offset < Double(Int.max) ? Int(offset) : Int.max
    }
}
