//
//  Dictionary+Merge.swift
//
//
//  Created by Florian Zand on 23.08.22.
//

public extension Dictionary {
    /// Strategy for merging two dictionaries.
    enum MergeStrategy {
        /// Overwrite the value in the first dictionary with the value in the second dictionary.
        case overwrite
        /// Keep the value in the first dictionary, only adding new keys from the second dictionary.
        case keepOld
        /// Keeps the value in the second dictionary, overwriting existing values in the first.
        case keepNew
        /**
         Custom merge strategy using a closure to combine values.
         
         - Parameters:
            - key: The key of the element to be merged.
            - old: The value in the first dictionary.
            - new: The value in the second dictionary.
         - Returns: The value to be used.
         */
        case custom((_ key: Key, _ old: Value?, _ new: Value?) -> Value?)
    }
    
    /**
     Returns the current dictionary merged with another dictionary using the specified merge strategy.
     
     - Parameters:
        - other: The dictionary to merge with the current dictionary.
        - strategy: The strategy to use for merging the dictionaries.
     
     - Returns: A new dictionary containing the merged results.
     */
    func merged(with other: [Key: Value], strategy: MergeStrategy = .overwrite) -> [Key: Value] {
        var merged = self
        for (key, value) in other {
            switch strategy {
            case .overwrite:
                merged[key] = value
            case .keepOld:
                if merged[key] == nil {
                    merged[key] = value
                }
            case .keepNew:
                merged[key] = value
            case .custom(let mergeClosure):
                let existingValue = merged[key]
                merged[key] = mergeClosure(key, existingValue, value)
            }
        }
        return merged
    }

    /**
     Merges the current dictionary with another dictionary using the specified merge strategy.
     
     - Parameters:
        - other: The dictionary to merge with the current dictionary.
        - strategy: The strategy to use for merging the dictionaries.
     
     - Returns: A new dictionary containing the merged results.
     */
    mutating func merge(with other: Self, strategy: MergeStrategy = .overwrite) {
        self = merged(with: other, strategy: strategy)
    }
    
    /// Returns the left dictionary merged with the right dictionary using the ``MergeStrategy/overwrite`` merge strategy.
    static func + (lhs: Self, rhs: Self) -> Self {
        lhs.merged(with: rhs)
    }
    
    /// Merges the other dictionary with the current using the ``MergeStrategy/overwrite`` merge strategy.
    static func += (lhs: inout Self, rhs: Self) {
        lhs.merge(with: rhs)
    }
}
