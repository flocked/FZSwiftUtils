//
//  Dictionary+Merge.swift
//
//
//  Created by Florian Zand on 23.08.22.
//

import Foundation

public extension Dictionary {
    /// Returns the dictionary merged with the given dictionary using the specified merge strategy.
    func merging(_ other: Self, strategy: MergeStrategy = .overwrite) -> Self {
        merging(other, uniquingKeysWith: strategy.handler)
    }
    
    /// Returns the dictionary merged with the key-value pairs in a sequence, using the specified merge strategy.
    func merging<S>(_ other: S, strategy: MergeStrategy = .overwrite) -> Self where S : Sequence, S.Element == (Key, Value) {
        merging(other, uniquingKeysWith: strategy.handler)
    }
    
    /// Merges the other dictionary with the current using the specified merge strategy.
    mutating func merge(_ other: Self, strategy: MergeStrategy = .overwrite) {
        merge(other, uniquingKeysWith: strategy.handler)
    }
    
    /// Merges the key-value pairs in a sequence with the dictionary, using the specified merge strategy.
    mutating func merge<S>(_ other: S, strategy: MergeStrategy = .overwrite) where S : Sequence, S.Element == (Key, Value) {
        merge(other, uniquingKeysWith: strategy.handler)
    }
    
    /// Returns the left dictionary merged with the right dictionary using the ``MergeStrategy/overwrite`` merge strategy.
    static func + (lhs: Self, rhs: Self) -> Self {
        lhs.merging(rhs)
    }
    
    /// Merges the other dictionary with the current using the ``MergeStrategy/overwrite`` merge strategy.
    static func += (lhs: inout Self, rhs: Self) {
        lhs.merge(rhs)
    }
}

extension Dictionary {
    /// Strategy for handling a duplicate value when merging two dictionaries.
    public struct MergeStrategy {
        let handler: ((_ old: Value, _ new: Value) -> Value)
        
        /**
         Creates a merge strategy using the specified closure.
         
         - Parameters:
            - oldValue: The current value in the dictionary.
            - newValue: The value in the other dictionary.
         - Returns: The value to be set.
         */
        public init(handler: @escaping (_ oldValue: Value, _ newValue: Value) -> Value) {
            self.handler = handler
        }
                
        /// Overwrite the values of the current dictionary with the values of the other dictionary.
        public static var overwrite: Self {
            .init { _, new in new }
        }
        
        /// Keep the values of the current dictionary, only adding new values of the other dictionary.
        public static var keepOriginal: Self {
            .init { old,_ in old }
        }
        
        /// Randomly keeps either the current or new value.
        public static var random: Self {
            .init { Bool.random() ? $0 : $1 }
        }
        
        /// Chooses the value according to a scoring function, keeping the minimum score.
        public static func keepMin<T: Comparable>(by score: @escaping (Value) -> T) -> Self {
            .init { old, new in score(old) <= score(new) ? old : new }
        }
        
        /// Chooses the value according to a scoring function.
        public static func keepMax<T: Comparable>(by score: @escaping (Value) -> T) -> Self {
            .init { old, new in score(old) >= score(new) ? old : new }
        }
        
        /// Recursively merges nested dictionaries using th specified strategy for duplicate nested values.
        public static func mergeValues<NestedKey, NestedValue>(with strategy: Value.MergeStrategy = .overwrite) -> Self where Value == [NestedKey: NestedValue] {
            .init { $0.merging($1, strategy: strategy) }
        }
    }
}

public extension Dictionary.MergeStrategy where Value: Comparable {
    /// Keeps the smaller value.
    static var keepMin: Self {
        .init { min($0, $1) }
    }
    
    /// Keeps the larger value.
    static var keepMax: Self {
        .init { max($0, $1) }
    }
    
    /// Keeps the smaller value.
    static var keepSmaller: Self {
        .init { min($0, $1) }
    }
    
    /// Keeps the larger value.
    static var keepLarger: Self {
        .init { max($0, $1) }
    }
}

public extension Dictionary.MergeStrategy where Value == Date {
    /// Keeps the older date.
    static var keepOlder: Self {
        .init { min($0, $1) }
    }
    
    /// Keeps the newer date.
    static var keepNewer: Self {
        .init { max($0, $1) }
    }
}

public extension Dictionary.MergeStrategy where Value: Collection {
    /// Keeps the smaller collection.
    static var keepSmaller: Self {
        .init { $0.count <= $1.count ? $0 : $1 }
    }

    /// Keeps the larger collection.
    static var keepLarger: Self {
        .init { $0.count >= $1.count ? $0 : $1 }
    }
}

public extension Dictionary.MergeStrategy where Value: RangeReplaceableCollection {
    /// Appends the new collection to the existing collection.
    static var append: Self {
        .init { $0 + $1 }
    }
    
    /// Appends the new collection and keeps only the first specified number of elements.
    static func append(keepingFirst limit: Int) -> Self {
        .init { Value(($0 + $1).prefix(limit.clamped(min: 0))) }
    }
    
    /// Appends the new collection and keeps only the last specified number of elements.
    static func append(keepingLast limit: Int) -> Self {
        .init { Value(($0 + $1).suffix(limit.clamped(min: 0))) }
    }
    
    /// Prepends the new collection before the existing collection.
    static var prepend: Self {
        .init { $1 + $0 }
    }
    
    /// Prepends the new collection and keeps only the first specified number of elements.
    static func prepend(keepingFirst limit: Int) -> Self {
        .init { Value(($1 + $0).prefix(limit.clamped(min: 0))) }
    }
    
    /// Prepends the new collection and keeps only the last specified number of elements.
    static func prepend(keepingLast limit: Int) -> Self {
        .init { Value(($1 + $0).suffix(limit.clamped(min: 0))) }
    }
}

public extension Dictionary.MergeStrategy where Value: SetAlgebra {
    /// Inserts the values of the other dictionary.
    static var union: Self {
        .init { $0.union($1) }
    }
    
    /// Keeps only elements present in both values.
    static var intersection: Self {
        .init { $0.intersection($1) }
    }
    
    /// Removes elements of the new value from the old value.
    static var subtracting: Self {
        .init { $0.subtracting($1) }
    }
    
    /// Keeps elements present in either value, but not both.
    static var symmetricDifference: Self {
        .init { $0.symmetricDifference($1) }
    }
}

public extension Dictionary.MergeStrategy where Value: RangeReplaceableCollection, Value.Element: Equatable {
    /// Keeps the unique elements of the current dictionary and other dictionary.
    static var unique: Self {
        .init { Value(($0 + $1).uniqued()) }
    }
}

public extension Dictionary.MergeStrategy where Value: RangeReplaceableCollection, Value.Element: Hashable {
    /// Keeps the unique elements of the current dictionary and other dictionary.
    static var unique: Self {
        .init { Value(($0 + $1).uniqued()) }
    }
}

public extension Dictionary.MergeStrategy where Value: AdditiveArithmetic {
    /// Adds both values together.
    static var sum: Self {
        .init { $0 + $1 }
    }
    
    /// Subtracts the new value from the old value.
    static var subtract: Self {
        .init { $0 - $1 }
    }
}

public extension Dictionary.MergeStrategy where Value: BinaryInteger {
    /// Averages the values using integer division.
    static var average: Self {
        .init { ($0 + $1) / 2 }
    }
}

public extension Dictionary.MergeStrategy where Value: FloatingPoint {
    /// Averages the values.
    static var average: Self {
        .init { ($0 + $1) / 2 }
    }
}

public extension Dictionary.MergeStrategy where Value == Bool {
    /// Logical OR.
    static var or: Self {
        .init { $0 || $1 }
    }
    
    /// Logical AND.
    static var and: Self {
        .init { $0 && $1 }
    }
    
    /// Logical XOR.
    static var xor: Self {
        .init { $0 != $1 }
    }
}

public extension Dictionary.MergeStrategy where Value: OptionalProtocol {
    /// Keeps a non-nil value if either value is non-nil, preferring the old value when both are non-nil.
    static var keepNonNil: Self {
        .init { $0.optional != nil ? $0 : $1 }
    }
    
    /// Keeps a non-nil value if either value is non-nil, preferring the new value when both are non-nil.
    static var overwriteWithNonNil: Self {
        .init { $1.optional != nil ? $1 : $0 }
    }
}
