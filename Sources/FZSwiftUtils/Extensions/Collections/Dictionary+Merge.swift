//
//  Dictionary+Merge.swift
//
//
//  Created by Florian Zand on 23.08.22.
//

public extension Dictionary {
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
            switch strategy.rawValue {
            case "keepOriginal":
                if merged[key] == nil {
                    merged[key] = value
                }
            case "custom":
                merged[key] = strategy.handler!(key, merged[key], value)
            default:
                merged[key] = value
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
    mutating func merge(with other: [Key: Value], strategy: MergeStrategy = .overwrite) {
        self = merged(with: other, strategy: strategy)
    }
    
    /**
     Returns the current dictionary merged with another dictionary using the specified merge strategy.
     
     - Parameters:
        - other: The dictionary to merge with the current dictionary.
        - strategy: The strategy to use for merging the dictionaries.
     
     - Returns: A new dictionary containing the merged results.
     */
    func merged(with other: [Key: Value], strategy: MergeStrategy = .overwrite) -> [Key: Value] where Value: Comparable {
        var merged = self
        for (key, value) in other {
            switch strategy.rawValue {
            case "keepOriginal":
                if merged[key] == nil {
                    merged[key] = value
                }
            case "custom":
                merged[key] = strategy.handler!(key, merged[key], value)
            case "keepMin":
                if let old = merged[key] {
                    merged[key] = Swift.min(old, value)
                } else {
                    merged[key] = value
                }
            case "keepMax":
                if let old = merged[key] {
                    merged[key] = Swift.max(old, value)
                } else {
                    merged[key] = value
                }
            default:
                merged[key] = value
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
    mutating func merge(with other: [Key: Value], strategy: MergeStrategy = .overwrite) where Value: Comparable {
        self = merged(with: other, strategy: strategy)
    }
    
    /**
     Returns the current dictionary merged with another dictionary using the specified merge strategy.
     
     - Parameters:
        - other: The dictionary to merge with the current dictionary.
        - strategy: The strategy to use for merging the dictionaries.
     
     - Returns: A new dictionary containing the merged results.
     */
    func merged(with other: [Key: Value], strategy: MergeStrategy = .overwrite) -> [Key: Value] where Value: RangeReplaceableCollection {
        var merged = self
        for (key, value) in other {
            switch strategy.rawValue {
            case "keepOriginal":
                if merged[key] == nil {
                    merged[key] = value
                }
            case "custom":
                merged[key] = strategy.handler!(key, merged[key], value)
            case "append":
                merged[key, default: .init()].append(contentsOf: value)
            default:
                merged[key] = value
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
    mutating func merge(with other: [Key: Value], strategy: MergeStrategy = .overwrite) where Value: RangeReplaceableCollection {
        self = merged(with: other, strategy: strategy)
    }
    
    /**
     Returns the current dictionary merged with another dictionary using the specified merge strategy.
     
     - Parameters:
        - other: The dictionary to merge with the current dictionary.
        - strategy: The strategy to use for merging the dictionaries.
     
     - Returns: A new dictionary containing the merged results.
     */
    func merged(with other: [Key: Value], strategy: MergeStrategy = .overwrite) -> [Key: Value] where Value: RangeReplaceableCollection, Value.Element: Hashable {
        var merged = self
        for (key, value) in other {
            switch strategy.rawValue {
            case "keepOriginal":
                if merged[key] == nil {
                    merged[key] = value
                }
            case "custom":
                merged[key] = strategy.handler!(key, merged[key], value)
            case "append":
                merged[key, default: .init()].append(contentsOf: value)
            case "unique":
                if let old = merged[key] {
                    merged[key] = .init((old + value).uniqued())
                } else {
                    merged[key] = value
                }
            default:
                merged[key] = value
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
    mutating func merge(with other: [Key: Value], strategy: MergeStrategy = .overwrite) where Value: RangeReplaceableCollection, Value.Element: Hashable {
        self = merged(with: other, strategy: strategy)
    }
    
    /**
     Returns the current dictionary merged with another dictionary using the specified merge strategy.
     
     - Parameters:
        - other: The dictionary to merge with the current dictionary.
        - strategy: The strategy to use for merging the dictionaries.
     
     - Returns: A new dictionary containing the merged results.
     */
    func merged(with other: [Key: Value], strategy: MergeStrategy = .overwrite) -> [Key: Value] where Value: SetType {
        var merged = self
        for (key, value) in other {
            switch strategy.rawValue {
            case "keepOriginal":
                if merged[key] == nil {
                    merged[key] = value
                }
            case "custom":
                merged[key] = strategy.handler!(key, merged[key], value)
            case "union":
                merged[key, default: .init()].insert(value)
            default:
                merged[key] = value
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
    mutating func merge(with other: [Key: Value], strategy: MergeStrategy = .overwrite) where Value: SetType {
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

extension Dictionary {
    /// Strategy for merging two dictionaries.
    public struct MergeStrategy {
        let rawValue: String
        let handler: ((_ key: Key, _ old: Value?, _ new: Value) -> Value?)?
        
        fileprivate init(_ rawValue: String, _ handler: ((_ key: Key, _ old: Value?, _ new: Value) -> Value?)? = nil) {
            self.rawValue = rawValue
            self.handler = handler
        }
        
        /// Overwrite the values of the current dictionary with the values of the other dictionary.
        public static var overwrite: Self {
            Self("overwrite")
        }
        
        /// Keep the values of the current dictionary, only adding new values of the other dictionary.
        public static var keepOriginal: Self {
            Self("keepOriginal")
        }
        
        /**
         Custom merge strategy using a closure to combine values.
         
         - Parameters:
            - key: The key of the element to be merged.
            - old: The value in the current dictionary.
            - new: The value in the other dictionary.
         - Returns: The value to be used.
         */
        public static func custom(_ handler: @escaping ((_ key: Key, _ old: Value?, _ new: Value) -> Value?)) -> Self {
            Self("custom", handler)
        }
    }
}

extension Dictionary.MergeStrategy where Value: Comparable {
    /// Keeps the smaller value.
    public static var keepMin: Self {
        Self("keepMin")
    }
    
    /// Keeps the larger value.
    public static var keepMax: Self {
        Self("keepMax")
    }
}

extension Dictionary.MergeStrategy where Value: RangeReplaceableCollection {
    /// Appends the values of the other dictionary.
    public static var append: Self {
        Self("append")
    }
}

extension Dictionary.MergeStrategy where Value: RangeReplaceableCollection, Value.Element: Hashable {
    /// Keeps the unique elements of the current dictionary and other dictionary.
    public static var unique: Self {
        Self("unique")
    }
}

extension Dictionary.MergeStrategy where Value: SetAlgebra {
    /// Inserts the values of the other dictionary.
    public static var union: Self {
        Self("union")
    }
}

public protocol SetType: SetAlgebra, Collection where Element: Hashable {
    mutating func insert(_ members: Self)
}

extension Set: SetType { }
