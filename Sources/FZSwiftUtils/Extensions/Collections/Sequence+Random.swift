//
//  Collection+Random.swift
//
//
//  Created by Florian Zand on 23.08.23.
//

import Foundation

/// A strategy for selecting random elements from a sequence.
public enum SequenceSamplingStrategy: Hashable, Sendable {
    /// Reservoir sampling using Algorithm R. O(n) time and O(k) memory.
    case reservoir

    /// Skip-based reservoir sampling using Algorithm L. O(n) traversal time and O(k) memory.
    case vitter

    /// Selects elements by shuffling the sequence. O(n) time and O(n) memory.
    case shuffle
}

// MARK: - Sequence

public extension Sequence {
    /**
     Returns randomly selected elements from the sequence.

     When sampling without replacement, each position can be selected at most once.
     Equal values at different positions may still appear multiple times.

     - Parameters:
       - amount: The number of elements to select.
       - withoutReplacement: Whether each position can be selected only once.
       - strategy: The sampling strategy.
       - rng: The random number generator.
     - Returns: An array containing the randomly selected elements.
     */
    func randomElements<G: RandomNumberGenerator>(amount: Int, withoutReplacement: Bool = true, strategy: SequenceSamplingStrategy = .reservoir, using rng: inout G) -> [Element] {
        guard amount > 0 else { return [] }

        guard withoutReplacement else {
            let elements = Array(self)
            guard !elements.isEmpty else { return [] }
            return (0..<amount).map { _ in elements.randomElement(using: &rng)! }
        }

        let result: [Element]

        switch strategy {
        case .reservoir:
            result = reservoirSample(amount: amount, using: &rng)
        case .vitter:
            result = vitterSample(amount: amount, using: &rng)
        case .shuffle:
            result = Array(shuffled(using: &rng).prefix(amount))
        }

        return result.shuffled(using: &rng)
    }

    /// Returns randomly selected elements from the sequence.
    func randomElements(amount: Int, withoutReplacement: Bool = true, strategy: SequenceSamplingStrategy = .reservoir) -> [Element] {
        var rng = SystemRandomNumberGenerator()
        return randomElements(amount: amount, withoutReplacement: withoutReplacement, strategy: strategy, using: &rng)
    }
}

// MARK: - Collection

public extension Collection {
    /**
     Returns randomly selected elements from the collection.

     Uses `.shuffle` by default because the collection supports repeated traversal.
     */
    func randomElements<G: RandomNumberGenerator>(amount: Int, withoutReplacement: Bool = true, strategy: SequenceSamplingStrategy = .shuffle, using rng: inout G) -> [Element] {
        guard amount > 0 else { return [] }

        guard withoutReplacement else {
            guard !isEmpty else { return [] }
            return (0..<amount).map { _ in randomElement(using: &rng)! }
        }

        let result: [Element]

        switch strategy {
        case .shuffle:
            result = Array(shuffled(using: &rng).prefix(amount))
        case .reservoir:
            result = reservoirSample(amount: amount, using: &rng)
        case .vitter:
            result = vitterSample(amount: amount, using: &rng)
        }

        return result.shuffled(using: &rng)
    }

    /// Returns randomly selected elements from the collection.
    func randomElements(amount: Int, withoutReplacement: Bool = true, strategy: SequenceSamplingStrategy = .shuffle) -> [Element] {
        var rng = SystemRandomNumberGenerator()
        return randomElements(amount: amount, withoutReplacement: withoutReplacement, strategy: strategy, using: &rng)
    }
}

// MARK: - Sequence + Equatable

public extension Sequence where Element: Equatable {
    /// Returns a uniformly random element excluding the specified elements.
    func randomElement<S: Sequence>(excluding: S) -> Element? where S.Element == Element {
        var rng = SystemRandomNumberGenerator()
        return randomElement(excluding: excluding, using: &rng)
    }

    /// Returns a uniformly random element excluding the specified elements.
    func randomElement<S: Sequence, G: RandomNumberGenerator>(excluding: S, using rng: inout G) -> Element? where S.Element == Element {
        let excluded = Array(excluding)
        var selected: Element?
        var matchingCount = 0

        for element in self {
            guard !excluded.contains(element) else { continue }

            matchingCount += 1

            if Int.random(in: 0..<matchingCount, using: &rng) == 0 {
                selected = element
            }
        }

        return selected
    }

    /// Returns randomly selected elements excluding the specified elements.
    func randomElements<S: Sequence>(amount: Int, excluding: S, withoutReplacement: Bool = true, strategy: SequenceSamplingStrategy = .reservoir) -> [Element] where S.Element == Element {
        var rng = SystemRandomNumberGenerator()
        return randomElements(amount: amount, excluding: excluding, withoutReplacement: withoutReplacement, strategy: strategy, using: &rng)
    }

    /// Returns randomly selected elements excluding the specified elements.
    func randomElements<S: Sequence, G: RandomNumberGenerator>(amount: Int, excluding: S, withoutReplacement: Bool = true, strategy: SequenceSamplingStrategy = .reservoir, using rng: inout G) -> [Element] where S.Element == Element {
        guard amount > 0 else { return [] }

        let excluded = Array(excluding)
        return lazy.filter { !excluded.contains($0) }.randomElements(amount: amount, withoutReplacement: withoutReplacement, strategy: strategy, using: &rng)
    }
}

// MARK: - Sequence + Hashable

public extension Sequence where Element: Hashable {
    /// Returns a uniformly random element excluding the specified elements using a set for efficient membership checks.
    func randomElement<S: Sequence>(excluding: S) -> Element? where S.Element == Element {
        var rng = SystemRandomNumberGenerator()
        return randomElement(excluding: excluding, using: &rng)
    }

    /// Returns a uniformly random element excluding the specified elements using a set for efficient membership checks.
    func randomElement<S: Sequence, G: RandomNumberGenerator>(excluding: S, using rng: inout G) -> Element? where S.Element == Element {
        let excluded = Set(excluding)
        var selected: Element?
        var matchingCount = 0

        for element in self {
            guard !excluded.contains(element) else { continue }

            matchingCount += 1

            if Int.random(in: 0..<matchingCount, using: &rng) == 0 {
                selected = element
            }
        }

        return selected
    }

    /// Returns randomly selected elements excluding the specified elements using a set for efficient membership checks.
    func randomElements<S: Sequence>(amount: Int, excluding: S, withoutReplacement: Bool = true, strategy: SequenceSamplingStrategy = .reservoir) -> [Element] where S.Element == Element {
        var rng = SystemRandomNumberGenerator()
        return randomElements(amount: amount, excluding: excluding, withoutReplacement: withoutReplacement, strategy: strategy, using: &rng)
    }

    /// Returns randomly selected elements excluding the specified elements using a set for efficient membership checks.
    func randomElements<S: Sequence, G: RandomNumberGenerator>(amount: Int, excluding: S, withoutReplacement: Bool = true, strategy: SequenceSamplingStrategy = .reservoir, using rng: inout G) -> [Element] where S.Element == Element {
        guard amount > 0 else { return [] }

        let excluded = Set(excluding)
        return lazy.filter { !excluded.contains($0) }.randomElements(amount: amount, withoutReplacement: withoutReplacement, strategy: strategy, using: &rng)
    }
}

// MARK: - Sampling Algorithms

fileprivate extension Sequence {
    /// Selects elements using reservoir sampling Algorithm R.
    func reservoirSample<G: RandomNumberGenerator>(amount: Int, using rng: inout G) -> [Element] {
        guard amount > 0 else { return [] }

        var iterator = makeIterator()
        var reservoir: [Element] = []
        reservoir.reserveCapacity(Swift.min(amount, underestimatedCount))

        while reservoir.count < amount, let element = iterator.next() {
            reservoir.append(element)
        }

        guard reservoir.count == amount else { return reservoir }

        var count = amount

        while let element = iterator.next() {
            count += 1
            let index = Int.random(in: 0..<count, using: &rng)

            if index < amount {
                reservoir[index] = element
            }
        }

        return reservoir
    }

    /// Selects elements using skip-based reservoir sampling Algorithm L.
    func vitterSample<G: RandomNumberGenerator>(amount: Int, using rng: inout G) -> [Element] {
        guard amount > 0 else { return [] }

        var iterator = makeIterator()
        var reservoir: [Element] = []
        reservoir.reserveCapacity(Swift.min(amount, underestimatedCount))

        while reservoir.count < amount, let element = iterator.next() {
            reservoir.append(element)
        }

        guard reservoir.count == amount else { return reservoir }

        let k = Double(amount)

        // Returns a random value in (0, 1].
        func randomUnit() -> Double {
            1.0 - Double.random(in: 0..<1, using: &rng)
        }

        var weight = exp(log(randomUnit()) / k)

        while true {
            let denominator = log1p(-weight)
            let skip = log(randomUnit()) / denominator

            guard skip.isFinite, skip >= 0, skip < Double(Int.max) else {
                return reservoir
            }

            var remaining = Int(skip)

            while remaining > 0 {
                guard iterator.next() != nil else { return reservoir }
                remaining -= 1
            }

            guard let element = iterator.next() else { return reservoir }

            let index = Int.random(in: 0..<amount, using: &rng)
            reservoir[index] = element

            weight *= exp(log(randomUnit()) / k)
        }
    }
}

/*
public extension Sequence where Element: Equatable {
    /**
     Returns a random element of the collection excluding any of the specified elements.

     - Parameter excluding: The elements excluded for the returned element.
     - Returns: A random element from the collection excluding any of the specified elements. If the collection is empty, the method returns `nil.
     */
    func randomElement<S: Sequence<Element>>(excluding: S) -> Element? {
        return shuffled().first(where: { !excluding.contains($0) })
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
        guard amount > 0 else { return [] }

        var iterator = makeIterator()
        var reservoir: [Element] = []
        reservoir.reserveCapacity(amount)

        while reservoir.count < amount, let element = iterator.next() {
            reservoir.append(element)
        }

        guard reservoir.count == amount else {
            return reservoir
        }

        let k = Double(amount)

        func randomUnit() -> Double {
            // Generate U in (0, 1].
            1.0 - Double.random(in: 0..<1, using: &rng)
        }

        var w = exp(log(randomUnit()) / k)

        while true {
            let denominator = log1p(-w)
            let skip = log(randomUnit()) / denominator

            guard skip.isFinite, skip >= 0, skip < Double(Int.max) else {
                break
            }

            var remaining = Int(skip)

            while remaining > 0 {
                guard iterator.next() != nil else {
                    return reservoir
                }
                remaining -= 1
            }

            guard let element = iterator.next() else {
                return reservoir
            }

            let index = Int.random(in: 0..<amount, using: &rng)
            reservoir[index] = element

            w *= exp(log(randomUnit()) / k)
        }

        return reservoir
    }

    static func nextW<G: RandomNumberGenerator>(k: Int, using rng: inout G) -> Double {
        pow(Double.random(in: 0..<1, using: &rng), 1.0 / Double(k))
    }

    static func nextOffset<G: RandomNumberGenerator>(w: Double, using rng: inout G) -> Int {
        let offset = log(Double.random(in: 0..<1, using: &rng)) / log1p(-w)
        return offset < Double(Int.max) ? Int(offset) : Int.max
    }
}
*/

public enum RandomSelectionStrategy: Hashable, Sendable {
    /// Uniformly selects among all matching elements using reservoir sampling.
    case uniform
    /// Starts at a random index and searches forward, wrapping around if necessary.
    case firstMatch
    /// Starts at a random index and searches backward, wrapping around if necessary.
    case lastMatch
    /// Visits elements in random order until a matching element is found.
    case shuffled
}

extension Collection {
    /**
     Returns a random element satisfying the predicate using the specified selection strategy.

     - Parameters:
       - strategy: The strategy used to select a matching element.
       - predicate: A closure that determines whether an element is eligible.
     - Returns: A matching element, or `nil` if no element satisfies the predicate.
     */
    public func randomElement(using strategy: RandomSelectionStrategy = .uniform, where predicate: (Element) throws -> Bool) rethrows -> Element? {
        try _randomElementBase(using: strategy, where: predicate)
    }
    
    fileprivate func _randomElementBase(using strategy: RandomSelectionStrategy, where predicate: (Element) throws -> Bool) rethrows -> Element? {
        guard !isEmpty else { return nil }
        switch strategy {
        case .uniform:
            var selected: Element?
            var count = 0
            for element in self {
                if try predicate(element) {
                    count += 1
                    if Int.random(in: 0..<count) == 0 {
                        selected = element
                    }
                }
            }
            return selected
        case .firstMatch:
            let offset = Int.random(in: 0..<count)
            let start = index(startIndex, offsetBy: offset)
            for element in self[start...] {
                if try predicate(element) {
                    return element
                }
            }
            for element in self[..<start] {
                if try predicate(element) {
                    return element
                }
            }
            return nil
        case .lastMatch:
            let indices = Array(self.indices)
            let start = Int.random(in: 0..<indices.count)
            for position in stride(from: start, through: 0, by: -1) {
                let element = self[indices[position]]
                if try predicate(element) {
                    return element
                }
            }
            if start + 1 < indices.count {
                for position in stride(from: indices.count - 1, through: start + 1, by: -1) {
                    let element = self[indices[position]]
                    if try predicate(element) {
                        return element
                    }
                }
            }
            return nil
        case .shuffled:
            for index in indices.shuffled() {
                if try predicate(self[index]) {
                    return self[index]
                }
            }
            return nil
        }
    }
}

// MARK: - BidirectionalCollection

public extension BidirectionalCollection {
    /**
     Returns a random element satisfying the predicate using the specified selection strategy.

     - Parameters:
       - strategy: The strategy used to select a matching element.
       - predicate: A closure that determines whether an element is eligible.
     - Returns: A matching element, or `nil` if no element satisfies the predicate.
     */
    func randomElement(using strategy: RandomSelectionStrategy = .uniform, where predicate: (Element) throws -> Bool) rethrows -> Element? {
        guard !isEmpty else { return nil }
        switch strategy {
        case .lastMatch:
            let offset = Int.random(in: 0..<count)
            let start = index(startIndex, offsetBy: offset)
            var i = start
            repeat {
                if try predicate(self[i]) {
                    return self[i]
                }
                if i == startIndex {
                    i = index(before: endIndex)
                } else {
                    formIndex(before: &i)
                }
            } while i != start
            return nil
        default:
            return try _randomElementBase(using: strategy, where: predicate)
        }
    }
}

// MARK: - RandomAccessCollection

public extension RandomAccessCollection {
    /**
     Returns a random element satisfying the predicate using the specified selection strategy.

     - Parameters:
       - strategy: The strategy used to select a matching element.
       - predicate: A closure that determines whether an element is eligible.
     - Returns: A matching element, or `nil` if no element satisfies the predicate.
     */
    func randomElement(using strategy: RandomSelectionStrategy = .uniform, where predicate: (Element) throws -> Bool) rethrows -> Element? {
        guard !isEmpty else { return nil }

        switch strategy {
        case .shuffled:
            var remaining = Array(indices)
            while !remaining.isEmpty {
                let position = Int.random(in: 0..<remaining.count)
                remaining.swapAt(position, remaining.count - 1)
                let index = remaining.removeLast()

                if try predicate(self[index]) {
                    return self[index]
                }
            }
            return nil
        case .lastMatch:
            let offset = Int.random(in: 0..<count)
            let start = index(startIndex, offsetBy: offset)
            var i = start
            repeat {
                if try predicate(self[i]) {
                    return self[i]
                }
                if i == startIndex {
                    i = index(before: endIndex)
                } else {
                    formIndex(before: &i)
                }
            } while i != start
            return nil
        default:
            return try _randomElementBase(using: strategy, where: predicate)
        }
    }
}
