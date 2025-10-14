//
//  Sequence+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import Foundation

public extension Sequence where Element: AdditiveArithmetic {
    /// The total sum value of all values in the sequence. If the sequence is empty, it returns `zero`.
    func sum() -> Element {
        reduce(.zero, +)
    }
}

public extension Sequence where Element: Equatable {
    /**
     A Boolean value indicating whether the sequence contains any of the given elements.

     - Parameter elements: The elements to find in the sequence.
     - Returns: `true` if any of the elements was found in the sequence; otherwise, `false`.
     */
    func contains<S>(any elements: S) -> Bool where S: Sequence<Element> {
        elements.contains(where: { contains($0) })
    }
    
    /**
     A Boolean value indicating whether the sequence contains all given elements.

     - Parameters:
        - elements: The elements to find in the sequence.
        - inSameOrder: A Boolean value indicating whether the elements to find need to appear in the same order.
     - Returns: `true` if all elements were found in the sequence; otherwise, `false`.
     */
    func contains<S>(all elements: S, inSameOrder: Bool = false) -> Bool where S: Sequence<Element> {
        if !inSameOrder {
            return elements.allSatisfy { contains($0) }
        } else {
            return elements.allSatisfy(AnyIterator(makeIterator()).contains)
        }
    }
}

public extension Sequence {
    /**
     Returns a dictionary whose keys are the groupings returned by the given closure and whose values are arrays of the elements that returned each key.
     
     - Parameter keyForValue: A closure that returns a key for each element in the sequence.
     */
    func grouped<Key>(by keyForValue: (Element) throws -> Key) rethrows -> [Key: [Element]] {
        try Dictionary(grouping: self, by: keyForValue)
    }
    
    /**
     Returns a dictionary whose keys are the groupings returned by the given closure and whose values are arrays of the elements that returned each key.
     
     - Parameter keyForValue: A closure that returns a potential key for each element in the sequence.
     */
    func grouped<Key>(byNonNil keyForValue: (Element) throws -> Key?) rethrows -> [Key: [Element]] {
        try Dictionary(grouping: self, byNonNil: keyForValue)
    }

    /// Splits the elements of sequence by the key returned from the specified closure and values that are returned for each key.
    func split<Key>(by keyForValue: (Element) throws -> Key) rethrows -> [(key: Key, values: [Element])] where Key: Equatable {
        try reduce(into: []) { values, value in
            let key = try keyForValue(value)
            if let index = values.firstIndex(where: { $0.key == key }) {
                values[index].values.append(value)
            } else {
                values.append((key, [value]))
            }
        }
    }
    
    /**
     Returns a dictionary from the elements of the sequence, keyed by the results returned by the specified closure.

     If the key derived for a new element collides with an existing key from a previous element, the latest value will be kept.
     
     - Parameters:
        - keyForValue: A closure that returns a key for each element in the sequence.
        - keepLastMatching: A Boolean value indicating whether later elements with the same key replace earlier ones.
     */
    @inlinable
    func keyed<Key>(by keyForValue: (Element) throws -> Key, keepLastMatching: Bool = true) rethrows -> [Key: Element] {
        try self.keyed(by: keyForValue, resolvingConflictsWith: { _, old, new in keepLastMatching ? new : old })
    }
    
    /**
     Returns a dictionary from the elements of the sequence, keyed by the results returned by the specified closure.
     
     As the dictionary is built, the initializer calls the `resolve` closure with the current and new values for any duplicate keys. Pass a closure as `resolve` that returns the value to use in the resulting dictionary: The closure can choose between the two values, combine them to produce a new value, or even throw an error.
     
     - Parameters:
       - keyForValue: A closure that returns a key for each element in `self`.
       - resolve: A closure that is called with the values for any duplicate keys that are encountered. The closure returns the desired value for the final dictionary.
     */
    func keyed<Key>(by keyForValue: (Element) throws -> Key, resolvingConflictsWith resolve: (Key, Element, Element) throws -> Element) rethrows -> [Key: Element] {
        try reduce(into: [:]) { result, element in
            let key = try keyForValue(element)
            if let existing = result[key] {
                result[key] = try resolve(key, existing, element)
            } else {
                result[key] = element
            }
        }
    }
}


public extension Sequence where Element: OptionalProtocol {
    /// Returns an array of all non optional elements of the sequence.
    var nonNil: [Element.Wrapped] {
        compactMap(\.optional)
    }
    
    /// Returns the first non optional element in the sequence.
    var firstNonNil: Element.Wrapped? {
        first(where: { $0.optional != nil })?.optional
    }
        
    /**
     Returns the first non-`nil` result obtained from applying the given transformation to the elements of the sequence.
     
     Example:
     ```swift
         let strings = ["three", "3.14", "-5", "2"]
         if let firstInt = strings.firstNonNil({ Int($0) }) {
             print(firstInt)
             // -5
         }
     ```

     - Parameter transform: A closure that takes an element of the sequence as its argument and returns an optional transformed value.
     - Returns: The first non-`nil` return value of the transformation, or `nil` if no transformation is successful.
    */
    func firstNonNil<Result>( _ transform: (Element) throws -> Result?) rethrows -> Result? {
        try self.lazy.compactMap({ try transform($0) }).first
    }
}

public extension BidirectionalCollection where Element: OptionalProtocol {
    /// Returns the last non optional element in the sequence.
    var lastNonNil: Element.Wrapped? {
        last(where: { $0.optional != nil })?.optional
    }
}

public extension Sequence where Element: Hashable {
    /// The sequence as `Set`.
    var asSet: Set<Element> {
        Set(self)
    }
}

public extension Sequence where Element: RawRepresentable {
    /// The raw values of the elements in the sequence.
    var rawValues: [Element.RawValue] {
        compactMap(\.rawValue)
    }
}

public extension Sequence where Element: RawRepresentable, Element.RawValue: Equatable {
    /**
     Returns the first element of the collection that satisfies the  raw value.

     - Parameter rawValue: The raw value.

     - Returns: The first element of the collection that matches the raw value.
     */
    func first(rawValue: Element.RawValue) -> Element? {
        first(where: { $0.rawValue == rawValue })
    }

    subscript(rawValue rawValue: Element.RawValue) -> [Element] {
        filter { $0.rawValue == rawValue }
    }

    subscript(firstRawValue rawValue: Element.RawValue) -> Element? {
        first(where: { $0.rawValue == rawValue })
    }
}

extension Sequence {
    /**
     Returns the minimum element in the sequence, using the given value of the key path as the comparison between elements.
     
     - Parameter keyPath: The key path to the comparable value.
     - Returns: The sequence’s minimum element. If the sequence has no elements, returns `nil`.
     */
    public func min<Value: Comparable>(by keyPath: KeyPath<Element, Value>) -> Element? {
        self.min(by: { $0[keyPath: keyPath] < $1[keyPath: keyPath] })
    }
    
    /**
     Returns the maximum element in the sequence, using the given value of the key path as the comparison between elements.
     
     - Parameter keyPath: The key path to the comparable value.
     - Returns: The sequence’s maximum element. If the sequence has no elements, returns `nil`.
     */
    public func max<Value: Comparable>(by keyPath: KeyPath<Element, Value>) -> Element? {
        self.max(by: { $0[keyPath: keyPath] < $1[keyPath: keyPath] })
    }
}

public extension Sequence {
    /// Returns the elements of the sequence, repeated by the specified amount.
    func repeating(amount: Int) -> [Element] {
        Array(repeating: Array(self), count: amount.clamped(min: 0)).flattened()
    }
}

extension MutableCollection where Self: RangeReplaceableCollection {
    /// Repeats the elements of the collection by the specified amount.
    mutating func `repeat`(amount: Int) {
        guard amount > 1 else { return }
        self += Array(repeating: self, count: amount - 1).flatMap { $0 }
    }
}



extension Collection {
    /**
     Returns a weighted shuffle of the collection.
     
     - Parameter weights: Values representing the relative likelihood of each element appearing earlier in the result.
     */
    public func shuffled(by weights: [Double]) -> [Element] {
        guard !isEmpty else { return [] }
        var weights = weights
        if weights.isEmpty || weights.contains(where: { $0 < 0}) {
            return self.shuffled()
        } else if weights.count < count {
            let lastWeight = weights.last ?? 1.0
            weights = weights + Array(repeating: lastWeight, count: count - weights.count)
        }
        return zip(self, weights).map { element, weight in
            let key = pow(Double.random(in: 0..<1), 1.0 / (weight + .leastNonzeroMagnitude))
            return (key, element)
        }.sorted { $0.0 > $1.0 }.map { $0.1 }

    }
}

extension RangeReplaceableCollection {
    /**
     Shuffles the collection weighted.
     
     - Parameter weights: Values representing the relative likelihood of each element appearing earlier in the result.
     */
    public mutating func shuffle(by weights: [Double]) {
        self = Self(shuffled(by: weights))
    }
}
