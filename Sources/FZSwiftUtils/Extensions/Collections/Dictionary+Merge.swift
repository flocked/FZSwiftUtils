//
//  Dictionary+Merge.swift
//
//
//  Created by Florian Zand on 23.08.22.
//

public extension Dictionary {
    /// Strategies of merging two dictionaries
    enum MergeStrategy {
        /// Overwrite the value in the first dictionary with the value in the second dictionary.
        case overwrite
        /// Keep the value in the first dictionary, only adding new keys from the second dictionary.
        case keepFirst
        /// Keep the value in the second dictionary, overwriting existing values in the first.
        case keepSecond
        /// Custom merge strategy using a closure to combine values.
        case custom((Key, Value?, Value?) -> Value?)
    }
    
    /**
     Returns the current dictionary merged with another dictionary using the specified merge strategy.
     
     - Parameters:
        - dictionary: The dictionary to merge with the current dictionary.
        - strategy: The strategy to use when merging the dictionaries.
     
     - Returns: A new dictionary containing the merged results.
     */
    func merged(with dictionary: [Key: Value], strategy: MergeStrategy = .overwrite) -> [Key: Value] {
        var merged = self
        for (key, value) in dictionary {
            switch strategy {
            case .overwrite:
                merged[key] = value
            case .keepFirst:
                if merged[key] == nil {
                    merged[key] = value
                }
            case .keepSecond:
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
        - dictionary: The dictionary to merge with the current dictionary.
        - strategy: The strategy to use when merging the dictionaries.
     
     - Returns: A new dictionary containing the merged results.
     */
    mutating func merge(with dictionary: Self, strategy: MergeStrategy = .overwrite) {
        self += dictionary
    }
    
    /// Returns the left dictionary merged with the right dictionary using the `overwrite` merge strategy.
    static func + (lhs: Self, rhs: Self) -> Self {
        lhs.merged(with: rhs)
    }
    
    /// Merges the other dictionary with the current using the `overwrite` merge strategy.
    static func += (lhs: inout Self, rhs: Self) {
        lhs.merge(with: rhs)
    }
}
