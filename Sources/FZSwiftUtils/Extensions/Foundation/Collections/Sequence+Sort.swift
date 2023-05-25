//
//  Sequence+Sort.swift
//  
//
//  Created by Florian Zand on 16.03.23.
//

import Foundation

public extension Sequence {
    func sorted<T: Comparable>(by compare: (Element) -> T, ascending: Bool = true) -> [Element] {
        if ascending {
            return self.sorted {compare($0) < compare($1)}
        } else {
            return self.sorted {compare($0) > compare($1)}
        }
    }
    
    func sorted<T: Comparable>(
        by keyPath: KeyPath<Element, T>,
        using comparator: (T, T) -> Bool = (<)
    ) -> [Element] {
        sorted { a, b in
            comparator(a[keyPath: keyPath], b[keyPath: keyPath])
        }
    }

    func sorted<T: Comparable>(
        by keyPath: KeyPath<Element, T?>,
        using comparator: (T, T) -> Bool = (<)
    ) -> [Element] {
        sorted { a, b in
            guard let b = b[keyPath: keyPath] else { return true }
            guard let a = a[keyPath: keyPath] else { return false }
            return comparator(a, b)
        }
    }
}

public extension Sequence where Element: Comparable & Hashable {
    func numberOfOccurences() -> [Element: Int] {
        self.reduce(into: [Element:Int](), { currentResult, element in
            currentResult[element, default: 0] += 1
        })
    }
    func sortedByNumberOfOccurences<T>(of keyPath: KeyPath<Element, T?>) -> [Element] {
        let numberOfOccurences = self.reduce(into: [Element:Int](), { currentResult, element in
            if (element[keyPath: keyPath] != nil) {
                currentResult[element, default: 0] += 1
            } else if ( currentResult[element] == nil ) {
                currentResult[element] = 0
            }
        })
        return self.sorted(by: { current, next in numberOfOccurences[current]! < numberOfOccurences[next]!})
    }
    
    func sortedByNumberOfOccurences() -> [Element] {
        let numberOfOccurences = self.numberOfOccurences()
        return self.sorted(by: { current, next in numberOfOccurences[current]! < numberOfOccurences[next]!})
    }
}

public extension Sequence {
    /**
     Returns the elements of the sequence, sorted using given keyPaths as comparison between elements.
        
     Provided keyPath's that don't conform to Comparable will be ingnored when sorting.
     
     - Parameters:
        - keyPaths: The keypaths used for sorting the elements.
        - ascending: If true, the sequence will be sorted in a ascending order, otherwise, descending.
     */
    func sorted<S: Sequence<PartialKeyPath<Element>>>(by keyPaths: S, ascending: Bool = true) -> [Element] {
        return sorted(by: keyPaths.compactMap({PartialSortingKeyPath($0, ascending: ascending)}))
        }
    
    func sorted(by keyPaths: PartialKeyPath<Element>..., ascending: Bool = true) -> [Element] {
        return sorted(by: keyPaths, ascending: ascending)
    }
    /**
     Returns the elements of the sequence, sorted using given keypaths as comparison between elements. Each keypath defines its own sorting order by `ascending(_ keypath)` / `descending(_ keypath)` or by prependding `>>`(ascending) or `<<` (descending) to a keypath.

     ```
     images.sorted(by: [<<\.pixelSize, >>\.creationDate]
     images.sorted(by: [ascending(\.pixelSize), descending(\.creationDate)]
     
     Provided keykaths that don't conform to Comparable will be ingnored when sorting.
     ```
     - Parameters:
        - keyPaths: The keypaths used for sorting the elements.
     */
    func sorted<S: Sequence<PartialSortingKeyPath<Element>>>(
        by keyPaths: S) -> [Element] {
            sorted { a, b in
                for kp in keyPaths {
                    let ascending = kp.ascending
                    for keyPath in kp.keyPaths {
                        if let val1 = a[keyPath: keyPath] as? any Comparable, let val2 = b[keyPath: keyPath] as? any Comparable {
                            if val1.isEqual(val2) == false {
                                return (ascending == true) ? val1.isLessThan(val2) : !val1.isLessThan(val2)
                            }
                        } else if let valus1 = a[keyPath: keyPath] as? (any Comparable)?, let value2 = b[keyPath: keyPath] as? (any Comparable)? {
                            guard value2 != nil else { return  true }
                            guard valus1 != nil else { return false }
                            if valus1?.isEqual(value2) == false {
                                return (ascending == true) ? (valus1?.isLessThan(value2) ?? false) : !(valus1?.isLessThan(value2) ?? false)
                            }
                        } else {
                            return false
                        }
                    }
                }
                return false
            }
        }
    
    func sorted(by keyPaths: PartialSortingKeyPath<Element>...) -> [Element] {
            return sorted(by: keyPaths)
        }
}

public prefix func << <Root>(keyPath: PartialKeyPath<Root>) -> PartialSortingKeyPath<Root> {
    return PartialSortingKeyPath(keyPath, ascending: true)
}

public prefix func >> <Root>(keyPath: PartialKeyPath<Root>) -> PartialSortingKeyPath<Root> {
    return PartialSortingKeyPath(keyPath, ascending: false)
}

public struct PartialSortingKeyPath<Root> {
    let keyPaths: [PartialKeyPath<Root>]
    let ascending: Bool
    
    internal init(_ keyPath: PartialKeyPath<Root>, ascending: Bool = true) {
        self.keyPaths = [keyPath]
        self.ascending = ascending
    }
    
    internal init(_ keyPaths: [PartialKeyPath<Root>], ascending: Bool = true) {
        self.keyPaths = keyPaths
        self.ascending = ascending
    }
    
    
    /// Returns a KeyPath used for sorting a sequence ascending.
    public static func ascending(_ keyPath: PartialKeyPath<Root>...) -> Self {
        return Self(keyPath, ascending: true)
    }
    
    /// Returns a KeyPath used for sorting a sequence descending.
    public static func descending(_ keyPath: PartialKeyPath<Root>...) -> Self {
        return Self(keyPath, ascending: false)
    }
    
    /// Returns a KeyPath used for sorting a sequence ascending.
    public static func ascending(_ keyPaths: [PartialKeyPath<Root>]) -> Self {
        return Self(keyPaths, ascending: true)
    }
    
    /// Returns a KeyPath used for sorting a sequence descending.
    public static func descending(_ keyPaths: [PartialKeyPath<Root>]) -> Self {
        return Self(keyPaths, ascending: false)
    }
}

internal extension Equatable {
    func isEqual(_ other: any Equatable) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self == other
    }
    
     func isEqual(_ other: (any Equatable)?) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self == other
    }
}

internal extension Comparable {
     func isLessThan(_ other: any Comparable) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self < other
    }
    
   func isLessThan(_ other: (any Comparable)?) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self < other
    }
    
    static func < (lhs: Self, other: any Comparable) -> Bool {
       guard let other = other as? Self else {
           return false
       }
       return lhs < other
   }
    
    static func < (lhs: Self, other: (any Comparable)?) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return lhs < other
    }
}

