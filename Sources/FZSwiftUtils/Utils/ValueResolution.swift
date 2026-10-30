//
//  ValueResolution.swift
//  
//
//  Created by Florian Zand on 30.10.26.
//

import Foundation

/// A strategy for resolving two values into a single value.
public struct ValueResolution<Value> {
    private let handler: (Value, Value) throws -> Value
    
    /**
     Creates a value resolution using the specified closure.
     
     - Parameter handler: A closure that resolves two values into a single value.
     */
    public init(_ handler: @escaping (_ first: Value, _ second: Value) throws -> Value) {
        self.handler = handler
    }
    
    /// Resolves the two specified values into a single value.
    public func resolve(_ first: Value, _ second: Value) throws -> Value {
        try handler(first, second)
    }
    
    /// Resolves the two specified values into a single value.
    public func callAsFunction(_ first: Value, _ second: Value) throws -> Value {
        try resolve(first, second)
    }
    
    /// Resolves the specified pair of values into a single value.
    public func resolve(_ values: (first: Value, second: Value)) throws -> Value {
        try resolve(values.first, values.second)
    }
    
    /// Resolves the specified pair of values into a single value.
    public func callAsFunction(_ values: (first: Value, second: Value)) throws -> Value {
        try resolve(values)
    }
    
    /// Keeps the first value.
    public static var keepFirst: Self {
        Self { first, _ in first }
    }
    
    /// Keeps the second value.
    public static var keepSecond: Self {
        Self { _, second in second }
    }
    
    /// Randomly keeps either the first or second value.
    public static var random: Self {
        Self { Bool.random() ? $0 : $1 }
    }
    
    /// Keeps the value with the minimum score produced by the specified closure.
    public static func keepMin<T: Comparable>(by score: @escaping (Value) -> T) -> Self {
        Self { first, second in score(first) <= score(second) ? first : second }
    }
    
    /// Keeps the value with the minimum value at the specified key path.
    public static func keepMin<T: Comparable>(by keyPath: KeyPath<Value, T>) -> Self {
        Self { $0[keyPath: keyPath] <= $1[keyPath: keyPath] ? $0 : $1 }
    }
    
    /// Keeps the value with the maximum score produced by the specified closure.
    public static func keepMax<T: Comparable>(by score: @escaping (Value) -> T) -> Self {
        Self { first, second in score(first) >= score(second) ? first : second }
    }
    
    /// Keeps the value with the maximum value at the specified key path.
    public static func keepMax<T: Comparable>(by keyPath: KeyPath<Value, T>) -> Self {
        Self { $0[keyPath: keyPath] >= $1[keyPath: keyPath] ? $0 : $1 }
    }
    
    /// Keeps the first value when the specified predicate returns `true`; otherwise, keeps the second value.
    public static func keep(where predicate: @escaping (_ first: Value, _ second: Value) throws -> Bool) -> Self {
        Self { try predicate($0, $1) ? $0 : $1 }
    }
}

public extension ValueResolution where Value: Comparable {
    /// Keeps the smaller value.
    static var keepMin: Self {
        Self { min($0, $1) }
    }
    
    /// Keeps the larger value.
    static var keepMax: Self {
        Self { max($0, $1) }
    }
}

public extension ValueResolution where Value == Date {
    /// Keeps the older date.
    static var keepOlder: Self {
        Self { min($0, $1) }
    }
    
    /// Keeps the newer date.
    static var keepNewer: Self {
        Self { max($0, $1) }
    }
}

public extension ValueResolution where Value: Collection {
    /// Keeps the collection with fewer elements.
    static var keepSmaller: Self {
        Self { $0.count <= $1.count ? $0 : $1 }
    }
    
    /// Keeps the collection with more elements.
    static var keepLarger: Self {
        Self { $0.count >= $1.count ? $0 : $1 }
    }
}

public extension ValueResolution where Value: RangeReplaceableCollection {
    /// Appends the second collection to the first collection.
    static var append: Self {
        Self { $0 + $1 }
    }
    
    /// Appends the second collection to the first collection and keeps only the first specified number of elements.
    static func append(keepingFirst limit: Int) -> Self {
        Self { Value(($0 + $1).prefix(limit.clamped(min: 0))) }
    }
    
    /// Appends the second collection to the first collection and keeps only the last specified number of elements.
    static func append(keepingLast limit: Int) -> Self {
        Self { Value(($0 + $1).suffix(limit.clamped(min: 0))) }
    }
    
    /// Prepends the second collection to the first collection.
    static var prepend: Self {
        Self { $1 + $0 }
    }
    
    /// Prepends the second collection to the first collection and keeps only the first specified number of elements.
    static func prepend(keepingFirst limit: Int) -> Self {
        Self { Value(($1 + $0).prefix(limit.clamped(min: 0))) }
    }
    
    /// Prepends the second collection to the first collection and keeps only the last specified number of elements.
    static func prepend(keepingLast limit: Int) -> Self {
        Self { Value(($1 + $0).suffix(limit.clamped(min: 0))) }
    }
}

public extension ValueResolution where Value: SetAlgebra {
    /// Returns the union of both values.
    static var union: Self {
        Self { $0.union($1) }
    }
    
    /// Returns the elements present in both values.
    static var intersection: Self {
        Self { $0.intersection($1) }
    }
    
    /// Removes the elements of the second value from the first value.
    static var subtracting: Self {
        Self { $0.subtracting($1) }
    }
    
    /// Returns the elements present in either value, but not both.
    static var symmetricDifference: Self {
        Self { $0.symmetricDifference($1) }
    }
}

public extension ValueResolution where Value: RangeReplaceableCollection, Value.Element: Equatable {
    /// Combines both collections, removing duplicate elements.
    static var unique: Self {
        Self { Value(($0 + $1).uniqued()) }
    }
}

public extension ValueResolution where Value: RangeReplaceableCollection, Value.Element: Hashable {
    /// Combines both collections, removing duplicate elements.
    static var unique: Self {
        Self { Value(($0 + $1).uniqued()) }
    }
}

public extension ValueResolution where Value: AdditiveArithmetic {
    /// Adds the two values.
    static var sum: Self {
        Self { $0 + $1 }
    }
    
    /// Subtracts the second value from the first value.
    static var subtract: Self {
        Self { $0 - $1 }
    }
}

public extension ValueResolution where Value: BinaryInteger {
    /// Returns the average of the two values using integer division.
    static var average: Self {
        Self { ($0 + $1) / 2 }
    }
}

public extension ValueResolution where Value: FloatingPoint {
    /// Returns the average of the two values.
    static var average: Self {
        Self { ($0 + $1) / 2 }
    }
}

public extension ValueResolution where Value == Bool {
    /// Returns the logical OR of the two values.
    static var or: Self {
        Self { $0 || $1 }
    }
    
    /// Returns the logical AND of the two values.
    static var and: Self {
        Self { $0 && $1 }
    }
    
    /// Returns the logical XOR of the two values.
    static var xor: Self {
        Self { $0 != $1 }
    }
}

public extension ValueResolution where Value: OptionalProtocol {
    /// Keeps a non-nil value if either value is non-nil, preferring the first value when both are non-nil.
    static var keepNonNil: Self {
        Self { $0.optional != nil ? $0 : $1 }
    }
    
    /// Keeps a non-nil value if either value is non-nil, preferring the second value when both are non-nil.
    static var overwriteWithNonNil: Self {
        Self { $1.optional != nil ? $1 : $0 }
    }
}

public extension ValueResolution {
    /// Merges two dictionary values using the specified resolution for duplicate keys.
    static func mergeValues<Key, Element>(with resolution: ValueResolution<Element> = .keepSecond) -> Self where Value == [Key: Element] {
        Self { try $0.merging($1, uniquingKeysWith: resolution.resolve) }
    }
}

