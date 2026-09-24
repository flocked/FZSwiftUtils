//
//  Dictionary+Merge.swift
//
//
//  Created by Florian Zand on 23.08.22.
//

import Foundation

public extension Dictionary {
    /**
     Creates a dictionary from a sequence of key-value pairs.

     - Parameters:
       - keysAndValues: A sequence of key-value pairs to use for the new dictionary.
       - retainLastOccurrences: A Boolean value indicating whether to retain the last value when a key occurs more than once. If `false`, the first value is retained.
     */
    init<S: Sequence<(Key, Value)>>(_ keysAndValues: S, retainLastOccurrences: Bool = false) {
        self.init(keysAndValues) { retainLastOccurrences ? $1 : $0 }
    }
    
    /// Creates a dictionary from the key-value pairs in the given sequence using the specified strategy for duplicate keys.
    init<S: Sequence<(Key, Value)>>(_ keysAndValues: S, uniquingKeysWith strategy: MergeStrategy) throws {
        try self.init(keysAndValues, uniquingKeysWith: strategy.handler)
    }
    
    /**
     Returns the dictionary merged with the given dictionary.

     - Parameters:
       - other: The dictionary to merge with this dictionary.
       - retainLastOccurrences: A Boolean value indicating whether values from the given dictionary replace existing values for duplicate keys.
     - Returns: A dictionary containing the merged key-value pairs.
     */
    func merging(_ other: Self, retainLastOccurrences: Bool = false) -> Self {
        merging(other) { retainLastOccurrences ? $1 : $0 }
    }

    /**
     Returns the dictionary merged with the given dictionary using the specified strategy for duplicate keys.

     - Parameters:
       - other: The dictionary to merge with this dictionary.
       - strategy: The strategy for resolving values for duplicate keys.
     - Returns: A dictionary containing the merged key-value pairs.
     */
    func merging(_ other: Self, uniquingKeysWith strategy: MergeStrategy) throws -> Self {
        try merging(other, uniquingKeysWith: strategy.handler)
    }

    /**
     Returns the dictionary merged with the key-value pairs in the given sequence.

     - Parameters:
       - other: The sequence of key-value pairs to merge with this dictionary.
       - retainLastOccurrences: A Boolean value indicating whether incoming values replace existing values for duplicate keys.
     - Returns: A dictionary containing the merged key-value pairs.
     */
    func merging<S: Sequence<(Key, Value)>>(_ other: S, retainLastOccurrences: Bool = false) -> Self {
        merging(other) { retainLastOccurrences ? $1 : $0 }
    }

    /**
     Returns the dictionary merged with the key-value pairs in the given sequence using the specified strategy for duplicate keys.

     - Parameters:
       - other: The sequence of key-value pairs to merge with this dictionary.
       - strategy: The strategy for resolving values for duplicate keys.
     - Returns: A dictionary containing the merged key-value pairs.
     */
    func merging<S: Sequence<(Key, Value)>>(_ other: S, uniquingKeysWith strategy: MergeStrategy) throws -> Self {
        try merging(other, uniquingKeysWith: strategy.handler)
    }

    /**
     Merges the given dictionary into this dictionary.

     - Parameters:
       - other: The dictionary to merge into this dictionary.
       - retainLastOccurrences: A Boolean value indicating whether values from the given dictionary replace existing values for duplicate keys.
     */
    mutating func merge(_ other: Self, retainLastOccurrences: Bool = false) {
        merge(other) { retainLastOccurrences ? $1 : $0 }
    }

    /**
     Merges the given dictionary into this dictionary using the specified strategy for duplicate keys.

     - Parameters:
       - other: The dictionary to merge into this dictionary.
       - strategy: The strategy for resolving values for duplicate keys.
     */
    mutating func merge(_ other: Self, uniquingKeysWith strategy: MergeStrategy) throws {
        try merge(other, uniquingKeysWith: strategy.handler)
    }

    /**
     Merges the key-value pairs in the given sequence into this dictionary.

     - Parameters:
       - other: The sequence of key-value pairs to merge into this dictionary.
       - retainLastOccurrences: A Boolean value indicating whether incoming values replace existing values for duplicate keys.
     */
    mutating func merge<S: Sequence<(Key, Value)>>(_ other: S, retainLastOccurrences: Bool = false) {
        merge(other) { retainLastOccurrences ? $1 : $0 }
    }

    /**
     Merges the key-value pairs in the given sequence into this dictionary using the specified strategy for duplicate keys.

     - Parameters:
       - other: The sequence of key-value pairs to merge into this dictionary.
       - strategy: The strategy for resolving values for duplicate keys.
     */
    mutating func merge<S: Sequence<(Key, Value)>>(_ other: S, uniquingKeysWith strategy: MergeStrategy) throws {
        try merge(other, uniquingKeysWith: strategy.handler)
    }
    
    /// Returns the left dictionary merged with the right dictionary, with values from the right dictionary replacing duplicate values.
    static func + (lhs: Self, rhs: Self) -> Self {
        lhs.merging(rhs, retainLastOccurrences: true)
    }

    /// Returns the dictionary merged with the key-value pairs in the given sequence, with later values replacing duplicate values.
    static func +<S: Sequence<(Key, Value)>>(lhs: Self, rhs: S) -> Self {
        lhs.merging(rhs, retainLastOccurrences: true)
    }

    /// Merges the right dictionary into the left dictionary, replacing duplicate values with values from the right dictionary.
    static func += (lhs: inout Self, rhs: Self) {
        lhs.merge(rhs, retainLastOccurrences: true)
    }

    /// Merges the key-value pairs in the given sequence into the dictionary, with later values replacing duplicate values.
    static func +=<S: Sequence<(Key, Value)>>(lhs: inout Self, rhs: S) {
        lhs.merge(rhs, retainLastOccurrences: true)
    }
}

public extension Dictionary {
    /**
     Transforms the keys of the dictionary using the given closure and strategy for duplicate keys.

     - Parameters:
       - transform: The closure that transforms a key of the dictionary.
       - strategy: The strategy for resolving values when duplicate keys are produced.
     - Returns: A new dictionary with transformed keys and resolved values for duplicates.
     */
    func mapKeys<T: Hashable>(_ transform: (Key) throws -> T, uniquingKeysWith strategy: Dictionary<T, Value>.MergeStrategy) throws -> [T: Value] {
        try mapKeys(transform, uniquingKeysWith: strategy.handler)
    }
    
    /**
     Transforms the keys of the dictionary using the given closure, combining values for duplicate keys using the provided closure.

     - Parameters:
       - transform: The closure that transforms a key of the dictionary.
       - combine: A closure that takes the existing and new values for a duplicate key and returns the value to retain.
     - Returns: A new dictionary with transformed keys and combined values for duplicates.
     */
    func mapKeys<T: Hashable>(_ transform: (Key) throws -> T, uniquingKeysWith combine: (Value, Value) throws -> Value) throws -> [T: Value] {
        try Dictionary<T, Value>(lazy.map { (try transform($0.key), $0.value) }, uniquingKeysWith: combine)
    }
    
    /**
     Transforms the keys of the dictionary using the given closure.

     - Parameters:
       - transform: The closure that transforms a key of the dictionary.
       - retainLastOccurrences: A Boolean value indicating whether to retain the last value when duplicate keys are produced. If `false`, the first value is retained.
     - Returns: A new dictionary with transformed keys and the same values.
     */
    func mapKeys<T: Hashable>(_ transform: (Key) throws -> T, retainLastOccurrences: Bool = false) throws -> [T: Value] {
        try mapKeys(transform) { retainLastOccurrences ? $1 : $0 }
    }
    
    /**
     Transforms the keys of the dictionary using the given closure.

     - Parameters:
       - transform: The closure that transforms a key of the dictionary.
       - retainLastOccurrences: A Boolean value indicating whether to retain the last value when duplicate keys are produced. If `false`, the first value is retained.
     - Returns: A new dictionary with transformed keys and the same values.
     */
    func mapKeys<T: Hashable>(_ transform: (Key) -> T, retainLastOccurrences: Bool = false) -> [T: Value] {
        mapKeys(transform) { retainLastOccurrences ? $1 : $0 }
    }

    /**
     Transforms the keys of the dictionary using the given closure, combining values for duplicate keys using the provided closure.

     - Parameters:
       - transform: The closure that transforms a key of the dictionary.
       - combine: A closure that takes the existing and new values for a duplicate key and returns the value to retain.
     - Returns: A new dictionary with transformed keys and combined values for duplicates.
     */
    func mapKeys<T: Hashable>(_ transform: (Key) -> T, uniquingKeysWith combine: (Value, Value) -> Value) -> [T: Value] {
        Dictionary<T, Value>(map { (transform($0.key), $0.value) }, uniquingKeysWith: combine)
    }

    /**
     Transforms the keys of the dictionary using the given closure and strategy for duplicate keys, discarding keys that map to `nil`.

     - Parameters:
       - transform: The closure that transforms a key of the dictionary, or returns `nil` to discard it.
       - strategy: The strategy for resolving values when duplicate keys are produced.
     - Returns: A new dictionary with non-nil transformed keys and resolved values for duplicates.
     */
    func compactMapKeys<T: Hashable>(_ transform: (Key) throws -> T?, uniquingKeysWith strategy: Dictionary<T, Value>.MergeStrategy) throws -> [T: Value] {
        try compactMapKeys(transform, uniquingKeysWith: strategy.handler)
    }
    
    /**
     Transforms the keys of the dictionary using the given closure, discarding keys that map to `nil` and combining values for duplicate keys.

     - Parameters:
       - transform: The closure that transforms a key of the dictionary, or returns `nil` to discard it.
       - combine: A closure that takes the existing and new values for a duplicate key and returns the value to retain.
     - Returns: A new dictionary with non-nil transformed keys and combined values for duplicates.
     */
    func compactMapKeys<T: Hashable>(_ transform: (Key) throws -> T?, uniquingKeysWith combine: (Value, Value) throws -> Value) throws -> [T: Value] {
        try Dictionary<T, Value>(lazy.compactMap { element in try transform(element.key).map { ($0, element.value) } }, uniquingKeysWith: combine)
    }
    
    /**
     Transforms the keys of the dictionary using the given closure, discarding keys that map to `nil`.

     - Parameters:
       - transform: The closure that transforms a key of the dictionary, or returns `nil` to discard it.
       - retainLastOccurrences: A Boolean value indicating whether to retain the last value when duplicate keys are produced. If `false`, the first value is retained.
     - Returns: A new dictionary with non-nil transformed keys and the same values.
     */
    func compactMapKeys<T: Hashable>(_ transform: (Key) throws -> T?, retainLastOccurrences: Bool = false) throws -> [T: Value] {
        try compactMapKeys(transform) { retainLastOccurrences ? $1 : $0 }
    }
    
    /**
     Transforms the keys of the dictionary using the given closure, discarding keys that map to `nil`.

     - Parameters:
       - transform: The closure that transforms a key of the dictionary, or returns `nil` to discard it.
       - retainLastOccurrences: A Boolean value indicating whether to retain the last value when duplicate keys are produced. If `false`, the first value is retained.
     - Returns: A new dictionary with non-nil transformed keys and the same values.
     */
    func compactMapKeys<T: Hashable>(_ transform: (Key) -> T?, retainLastOccurrences: Bool = false) -> [T: Value] {
        compactMapKeys(transform) { retainLastOccurrences ? $1 : $0 }
    }

    /**
     Transforms the keys of the dictionary using the given closure, discarding keys that map to `nil` and combining values for duplicate keys.

     - Parameters:
       - transform: The closure that transforms a key of the dictionary, or returns `nil` to discard it.
       - combine: A closure that takes the existing and new values for a duplicate key and returns the value to retain.
     - Returns: A new dictionary with non-nil transformed keys and combined values for duplicates.
     */
    func compactMapKeys<T: Hashable>(_ transform: (Key) -> T?, uniquingKeysWith combine: (Value, Value) -> Value) -> [T: Value] {
        Dictionary<T, Value>(compactMap { element in transform(element.key).map { ($0, element.value) } }, uniquingKeysWith: combine)
    }
    
    /**
     Transforms both the keys and values of the dictionary using the given closure.

     - Parameters:
       - transform: The closure that transforms a key-value pair of the dictionary.
       - retainLastOccurrences: A Boolean value indicating whether to retain the last value when duplicate keys are produced. If `false`, the first value is retained.
     - Returns: A new dictionary with transformed keys and values.
     */
    func mapKeyValues<T: Hashable, U>(_ transform: (Element) -> (T, U), retainLastOccurrences: Bool = false) -> [T: U] {
        mapKeyValues(transform) { retainLastOccurrences ? $1 : $0 }
    }

    /**
     Transforms both the keys and values of the dictionary, combining values for duplicate keys using the provided closure.

     - Parameters:
       - transform: The closure that transforms a key-value pair of the dictionary.
       - combine: A closure that takes the existing and new values for a duplicate key and returns the value to retain.
     - Returns: A new dictionary with transformed keys and values, combining duplicates as specified.
     */
    func mapKeyValues<T: Hashable, U>(_ transform: (Element) -> (T, U), uniquingKeysWith combine: (U, U) -> U) -> [T: U] {
        Dictionary<T, U>(lazy.map(transform), uniquingKeysWith: combine)
    }

    /**
     Transforms both the keys and values of the dictionary using the given closure and strategy for duplicate keys.

     - Parameters:
       - transform: The closure that transforms a key-value pair of the dictionary.
       - strategy: The strategy for resolving values when duplicate keys are produced.
     - Returns: A new dictionary with transformed keys and values.
     */
    func mapKeyValues<T: Hashable, U>(_ transform: (Element) throws -> (T, U), uniquingKeysWith strategy: Dictionary<T, U>.MergeStrategy) throws -> [T: U] {
        try mapKeyValues(transform, uniquingKeysWith: strategy.handler)
    }
    
    /**
     Transforms both the keys and values of the dictionary, combining values for duplicate keys using the provided closure.

     - Parameters:
       - transform: The closure that transforms a key-value pair of the dictionary.
       - combine: A closure that takes the existing and new values for a duplicate key and returns the value to retain.
     - Returns: A new dictionary with transformed keys and values, combining duplicates as specified.
     */
    func mapKeyValues<T: Hashable, U>(_ transform: (Element) throws -> (T, U), uniquingKeysWith combine: (U, U) throws -> U) throws -> [T: U] {
        try Dictionary<T, U>(lazy.map(transform), uniquingKeysWith: combine)
    }
    
    /**
     Transforms both the keys and values of the dictionary using the given closure.

     - Parameters:
       - transform: The closure that transforms a key-value pair of the dictionary.
       - retainLastOccurrences: A Boolean value indicating whether to retain the last value when duplicate keys are produced. If `false`, the first value is retained.
     - Returns: A new dictionary with transformed keys and values.
     */
    func mapKeyValues<T: Hashable, U>(_ transform: (Element) throws -> (T, U), retainLastOccurrences: Bool = false) throws -> [T: U] {
        try mapKeyValues(transform) { retainLastOccurrences ? $1 : $0 }
    }
    
    /**
     Transforms both the keys and values of the dictionary using the given closure and strategy for duplicate keys, discarding results that are `nil`.

     - Parameters:
       - transform: The closure that transforms a key-value pair of the dictionary, or returns `nil` to discard it.
       - strategy: The strategy for resolving values when duplicate keys are produced.
     - Returns: A new dictionary containing the non-nil transformed key-value pairs.
     */
    func compactMapKeyValues<T: Hashable, U>(_ transform: (Element) throws -> (T, U)?, uniquingKeysWith strategy: Dictionary<T, U>.MergeStrategy) throws -> [T: U] {
        try compactMapKeyValues(transform, uniquingKeysWith: strategy.handler)
    }
    
    /**
     Transforms both the keys and values of the dictionary, discarding results that are `nil` and combining values for duplicate keys using the provided closure.

     - Parameters:
       - transform: The closure that transforms a key-value pair of the dictionary, or returns `nil` to discard it.
       - combine: A closure that takes the existing and new values for a duplicate key and returns the value to retain.
     - Returns: A new dictionary containing the non-nil transformed key-value pairs, combining duplicates as specified.
     */
    func compactMapKeyValues<T: Hashable, U>(_ transform: (Element) throws -> (T, U)?, uniquingKeysWith combine: (U, U) throws -> U) throws -> [T: U] {
        try Dictionary<T, U>(lazy.compactMap(transform), uniquingKeysWith: combine)
    }
    
    /**
     Transforms both the keys and values of the dictionary using the given closure, discarding results that are `nil`.

     - Parameters:
       - transform: The closure that transforms a key-value pair of the dictionary, or returns `nil` to discard it.
       - retainLastOccurrences: A Boolean value indicating whether to retain the last value when duplicate keys are produced. If `false`, the first value is retained.
     - Returns: A new dictionary containing the non-nil transformed key-value pairs.
     */
    func compactMapKeyValues<T: Hashable, U>(_ transform: (Element) throws -> (T, U)?, retainLastOccurrences: Bool = false) throws -> [T: U] {
        try compactMapKeyValues(transform) { retainLastOccurrences ? $1 : $0 }
    }
    
    /**
     Transforms both the keys and values of the dictionary using the given closure, discarding results that are `nil`.

     - Parameters:
       - transform: The closure that transforms a key-value pair of the dictionary, or returns `nil` to discard it.
       - retainLastOccurrences: A Boolean value indicating whether to retain the last value when duplicate keys are produced. If `false`, the first value is retained.
     - Returns: A new dictionary containing the non-nil transformed key-value pairs.
     */
    func compactMapKeyValues<T: Hashable, U>(_ transform: (Element) -> (T, U)?, retainLastOccurrences: Bool = false) -> [T: U] {
        compactMapKeyValues(transform) { retainLastOccurrences ? $1 : $0 }
    }

    /**
     Transforms both the keys and values of the dictionary using the given closure, discarding results that are `nil` and combining values for duplicate keys.

     - Parameters:
       - transform: The closure that transforms a key-value pair of the dictionary, or returns `nil` to discard it.
       - combine: A closure that takes the existing and new values for a duplicate key and returns the value to retain.
     - Returns: A new dictionary containing the non-nil transformed key-value pairs, combining duplicates as specified.
     */
    func compactMapKeyValues<T: Hashable, U>(_ transform: (Element) -> (T, U)?, uniquingKeysWith combine: (U, U) -> U) -> [T: U] {
        Dictionary<T, U>(lazy.compactMap(transform), uniquingKeysWith: combine)
    }
}

extension Dictionary {
    /// A strategy for resolving duplicate values associated with the same key.
    public struct MergeStrategy {
        let handler: (_ old: Value, _ new: Value) throws -> Value
        
        /**
         Creates a merge strategy using the specified closure.
         
         - Parameters:
           - oldValue: The existing value for the key.
           - newValue: The new value for the key.
         - Returns: The value to retain for the key.
         */
        public init(_ handler: @escaping (_ oldValue: Value, _ newValue: Value) throws -> Value) {
            self.handler = handler
        }
                
        /// Replaces the existing value with the new value.
        public static var overwrite: Self {
            Self { _, new in new }
        }
        
        /// Keeps the existing value.
        public static var keepOriginal: Self {
            Self { old, _ in old }
        }
        
        /// Randomly keeps either the existing or new value.
        public static var random: Self {
            Self { Bool.random() ? $0 : $1 }
        }
        
        /// Keeps the value with the minimum score produced by the specified closure.
        public static func keepMin<T: Comparable>(by score: @escaping (Value) -> T) -> Self {
            Self { old, new in score(old) <= score(new) ? old : new }
        }
        
        /// Keeps the value with the minimum value at the specified key path.
        public static func keepMin<T: Comparable>(by keyPath: KeyPath<Value, T>) -> Self {
            Self { $0[keyPath: keyPath] <= $1[keyPath: keyPath] ? $0 : $1 }
        }
        
        /// Keeps the value with the maximum score produced by the specified closure.
        public static func keepMax<T: Comparable>(by score: @escaping (Value) -> T) -> Self {
            Self { old, new in score(old) >= score(new) ? old : new }
        }

        /// Keeps the value with the maximum value at the specified key path.
        public static func keepMax<T: Comparable>(by keyPath: KeyPath<Value, T>) -> Self {
            Self { $0[keyPath: keyPath] >= $1[keyPath: keyPath] ? $0 : $1 }
        }
        
        /// Recursively merges nested dictionary values using the specified strategy for duplicate nested keys.
        public static func mergeValues<NestedKey, NestedValue>(with strategy: Value.MergeStrategy = .overwrite) -> Self where Value == [NestedKey: NestedValue] {
            Self { try $0.merging($1, uniquingKeysWith: strategy) }
        }
        
        /// Keeps the existing value when the specified predicate returns `true`; otherwise, keeps the new value.
        public static func keep(where predicate: @escaping (_ old: Value, _ new: Value) throws -> Bool) -> Self {
            Self { try predicate($0, $1) ? $0 : $1 }
        }
    }
}

public extension Dictionary.MergeStrategy where Value: Comparable {
    /// Keeps the smaller value.
    static var keepMin: Self {
        Self { min($0, $1) }
    }
    
    /// Keeps the larger value.
    static var keepMax: Self {
        Self { max($0, $1) }
    }
}

public extension Dictionary.MergeStrategy where Value == Date {
    /// Keeps the older date.
    static var keepOlder: Self {
        Self { min($0, $1) }
    }
    
    /// Keeps the newer date.
    static var keepNewer: Self {
        Self { max($0, $1) }
    }
}

public extension Dictionary.MergeStrategy where Value: Collection {
    /// Keeps the collection with fewer elements.
    static var keepSmaller: Self {
        Self { $0.count <= $1.count ? $0 : $1 }
    }

    /// Keeps the collection with more elements.
    static var keepLarger: Self {
        Self { $0.count >= $1.count ? $0 : $1 }
    }
}

public extension Dictionary.MergeStrategy where Value: RangeReplaceableCollection {
    /// Appends the new collection to the existing collection.
    static var append: Self {
        Self { $0 + $1 }
    }
    
    /// Appends the new collection to the existing collection and keeps only the first specified number of elements.
    static func append(keepingFirst limit: Int) -> Self {
        Self { Value(($0 + $1).prefix(limit.clamped(min: 0))) }
    }
    
    /// Appends the new collection to the existing collection and keeps only the last specified number of elements.
    static func append(keepingLast limit: Int) -> Self {
        Self { Value(($0 + $1).suffix(limit.clamped(min: 0))) }
    }
    
    /// Prepends the new collection to the existing collection.
    static var prepend: Self {
        Self { $1 + $0 }
    }
    
    /// Prepends the new collection to the existing collection and keeps only the first specified number of elements.
    static func prepend(keepingFirst limit: Int) -> Self {
        Self { Value(($1 + $0).prefix(limit.clamped(min: 0))) }
    }
    
    /// Prepends the new collection to the existing collection and keeps only the last specified number of elements.
    static func prepend(keepingLast limit: Int) -> Self {
        Self { Value(($1 + $0).suffix(limit.clamped(min: 0))) }
    }
}

public extension Dictionary.MergeStrategy where Value: SetAlgebra {
    /// Keeps the union of the existing and new values.
    static var union: Self {
        Self { $0.union($1) }
    }
    
    /// Keeps only the elements present in both the existing and new values.
    static var intersection: Self {
        Self { $0.intersection($1) }
    }
    
    /// Removes the elements of the new value from the existing value.
    static var subtracting: Self {
        Self { $0.subtracting($1) }
    }
    
    /// Keeps the elements present in either value, but not both.
    static var symmetricDifference: Self {
        Self { $0.symmetricDifference($1) }
    }
}

public extension Dictionary.MergeStrategy where Value: RangeReplaceableCollection, Value.Element: Equatable {
    /// Combines the existing and new collections, removing duplicate elements.
    static var unique: Self {
        Self { Value(($0 + $1).uniqued()) }
    }
}

public extension Dictionary.MergeStrategy where Value: RangeReplaceableCollection, Value.Element: Hashable {
    /// Combines the existing and new collections, removing duplicate elements.
    static var unique: Self {
        Self { Value(($0 + $1).uniqued()) }
    }
}

public extension Dictionary.MergeStrategy where Value: AdditiveArithmetic {
    /// Adds the existing and new values.
    static var sum: Self {
        Self { $0 + $1 }
    }
    
    /// Subtracts the new value from the existing value.
    static var subtract: Self {
        Self { $0 - $1 }
    }
}

public extension Dictionary.MergeStrategy where Value: BinaryInteger {
    /// Keeps the average of the existing and new values using integer division.
    static var average: Self {
        Self { ($0 + $1) / 2 }
    }
}

public extension Dictionary.MergeStrategy where Value: FloatingPoint {
    /// Keeps the average of the existing and new values.
    static var average: Self {
        Self { ($0 + $1) / 2 }
    }
}

public extension Dictionary.MergeStrategy where Value == Bool {
    /// Keeps the logical OR of the existing and new values.
    static var or: Self {
        Self { $0 || $1 }
    }
    
    /// Keeps the logical AND of the existing and new values.
    static var and: Self {
        Self { $0 && $1 }
    }
    
    /// Keeps the logical XOR of the existing and new values.
    static var xor: Self {
        Self { $0 != $1 }
    }
}

public extension Dictionary.MergeStrategy where Value: OptionalProtocol {
    /// Keeps a non-nil value if either value is non-nil, preferring the existing value when both are non-nil.
    static var keepNonNil: Self {
        Self { $0.optional != nil ? $0 : $1 }
    }
    
    /// Keeps a non-nil value if either value is non-nil, preferring the new value when both are non-nil.
    static var overwriteWithNonNil: Self {
        Self { $1.optional != nil ? $1 : $0 }
    }
}
