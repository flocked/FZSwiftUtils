//
//  Sequence+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import Foundation

public extension Sequence {
    /// The first element of the sequence.
    var first: Element? {
        for element in self {
            return element
        }
        return nil
    }
    
    /// The last element of the sequence.
    var last: Element? {
        var last: Element?
        for element in self {
            last = element
        }
        return last
    }
}

public extension Sequence where Element: AdditiveArithmetic {
    /// The total sum value of all values in the sequence. If the sequence is empty, it returns `zero`.
    func sum() -> Element {
        reduce(.zero, +)
    }
}

public extension Sequence {
    /**
     A Boolean value indicating whether the sequence contains any of the given elements.

     - Parameter elements: The elements to find in the sequence.
     - Returns: `true` if any of the elements was found in the sequence; otherwise, `false`.
     */
    func contains<S>(any elements: S) -> Bool where Element: Equatable, S: Sequence<Element> {
        elements.contains(where: { contains($0) })
    }
    
    /**
     A Boolean value indicating whether the sequence contains any of the given elements.

     - Parameter elements: The elements to find in the sequence.
     - Returns: `true` if any of the elements was found in the sequence; otherwise, `false`.
     */
    func contains<S>(any elements: S) -> Bool where Element: Hashable, S: Sequence<Element> {
        let set = Set(self)
        return elements.contains { set.contains($0) }
    }
    
    /**
     A Boolean value indicating whether the sequence contains all given elements.

     - Parameters:
        - elements: The elements to find in the sequence.
        - inSameOrder: A Boolean value indicating whether the elements to find need to appear in the same order.
     - Returns: `true` if all elements were found in the sequence; otherwise, `false`.
     */
    func contains<S>(all elements: S, inSameOrder: Bool = false) -> Bool where Element: Equatable, S: Sequence<Element> {
        if !inSameOrder {
            return elements.allSatisfy { contains($0) }
        } else {
            return elements.allSatisfy(AnyIterator(makeIterator()).contains)
        }
    }
        
    /**
     A Boolean value indicating whether the sequence contains all given elements.

     - Parameters:
        - elements: The elements to find in the sequence.
        - inSameOrder: A Boolean value indicating whether the elements to find need to appear in the same order.
     - Returns: `true` if all elements were found in the sequence; otherwise, `false`.
     */
    func contains<S>(all elements: S, inSameOrder: Bool = false) -> Bool where Element: Hashable, S: Sequence<Element> {
        if !inSameOrder {
            let set = Set(self)
            return elements.allSatisfy { set.contains($0) }
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

public extension Sequence {
    var asArray: [Element] {
        /// The sequence as `Array`.
        Array(self)
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
    public func min<V: Comparable>(by keyPath: KeyPath<Element, V>) -> Element? {
        self.min(by: { $0[keyPath: keyPath] < $1[keyPath: keyPath] })
    }
    
    /**
     Returns the maximum element in the sequence, using the given value of the key path as the comparison between elements.
     
     - Parameter keyPath: The key path to the comparable value.
     - Returns: The sequence’s maximum element. If the sequence has no elements, returns `nil`.
     */
    public func max<V: Comparable>(by keyPath: KeyPath<Element, V>) -> Element? {
        self.max(by: { $0[keyPath: keyPath] < $1[keyPath: keyPath] })
    }

    /**
     Returns the minimum value found at the given key path among all elements in the sequence.

     - Parameter keyPath: A key path whose value will be extracted from each element and compared.
     - Returns: The minimum value for the given key path, or `nil` if the sequence is empty.
     */
    public func min<V: Comparable>(of keyPath: KeyPath<Element, V>) -> V? {
        map({$0[keyPath: keyPath]}).min()
    }
    
    
    /**
     Returns the maximum value found at the given key path among all elements in the sequence.

     - Parameter keyPath: A key path whose value will be extracted from each element and compared.
     - Returns: The maximum value for the given key path, or `nil` if the sequence is empty.
     */
    public func max<V: Comparable>(of keyPath: KeyPath<Element, V>) -> V? {
        map({$0[keyPath: keyPath]}).max()
    }
    
    /**
     Returns the sum of values found at the given key path among all elements in the sequence.

     - Parameter keyPath: A key path whose value will be extracted from each element and summed.
     - Returns: The total sum of all values for the given key path.
     */
    public func sum<V:AdditiveArithmetic>(of keyPath: KeyPath<Element, V>) -> V {
        map({$0[keyPath: keyPath]}).sum()
    }
}

public extension Sequence {
    /// Returns the elements of the sequence, repeated by the specified amount.
    func repeating(amount: Int) -> [Element] {
        var result: [Element] = []
        for _ in 0..<amount {
            result.append(contentsOf: self)
        }
        return result
    }
}

extension MutableCollection where Self: RangeReplaceableCollection {
    /// Repeats the elements of the collection by the specified amount.
    mutating func `repeat`(amount: Int) {
        guard amount > 1 else { return }
        self += Array(repeating: self, count: amount - 1).flatMap { $0 }
    }
}

extension Sequence {
    /**
     Returns a weighted shuffle of the collection.
     
     - Parameter weights: Values representing the relative likelihood of each element appearing earlier in the result.
     */
    public func shuffled(by weights: [Double]) -> [Element] {
        let elements = Array(self)
        guard !elements.isEmpty else { return [] }
        var weights = weights
        if weights.count < elements.count {
            weights += Array(repeating: weights.last ?? 1.0, count: elements.count - weights.count)
        }
        return zip(elements, weights)
            .map { element, weight in
                let exponent: Double
                if weight >= 0 {
                    exponent = 1.0 / (weight + Double.leastNonzeroMagnitude)
                } else {
                    exponent = 1.0 + abs(weight)
                }
                return (pow(Double.random(in: 0..<1), exponent), element)
            }
            .sorted { $0.0 > $1.0 }
            .map { $0.1 }
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

extension Sequence {
    /**
     Returns the first element of the sequence that is of the specified type.

     - Parameter type: The type to search for within the sequence.
     - Returns: The first element that is of type `T`, or `nil` if none is found.
     */
    public func first<T>(ofType type: T.Type) -> T? {
        lazy.compactMap({$0 as? T}).first
    }
    
    /**
     Returns an array containing all elements of the sequence that are of the specified type.

     - Parameter type: The type to filter for within the sequence.
     - Returns: An array of all elements that are of type `T`.
     */
    public func all<T>(ofType type: T.Type) -> [T] {
        compactMap { $0 as? T }
    }
    
    /// Returns a Boolean value indicating whether the sequence contains an element that is of the specified type.
    public func contains<T>(_ type: T.Type) -> Bool {
        contains(where: { $0 is T })
    }
}

extension BidirectionalCollection {
    /**
     Returns the last element of the collection that is of the specified type.

     - Parameter type: The type to search for within the sequence.
     - Returns: The last element that is of type `T`, or `nil` if none is found.
     */
    public func last<T>(ofType type: T.Type) -> T? {
        last(where: { $0 is T }) as? T
    }
}
