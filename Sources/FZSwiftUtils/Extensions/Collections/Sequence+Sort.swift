//
//  Sequence+Sort.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import Foundation

/// The order of sorting for a sequence
public enum SequenceSortOrder: Int, Hashable {
    /// An ascending sorting order.
    case ascending
    /// A descending sorting order.
    case descending
  
    /// An ascending sorting order.
    public static let oldestFirst = SequenceSortOrder.ascending
    /// A descending sorting order.
    public static let newestFirst = SequenceSortOrder.descending
    
    /// An ascending sorting order.
    public static let smallestFirst = SequenceSortOrder.ascending
    /// A descending sorting order.
    public static let largestFirst = SequenceSortOrder.descending
    
    /// An ascending sorting order.
    public static let shortestFirst = SequenceSortOrder.ascending
    /// A descending sorting order.
    public static let longestFirst = SequenceSortOrder.descending
}

extension Sequence {
    /**
    An array of the elements sorted by the given predicate.
     
     - Parameters:
        - compare: The closure to compare the elements.
        - order: The order of sorting. The default value is `ascending`.
     */
    public func sorted<Value>(by compare: ((Element) -> Value), _ order: SequenceSortOrder = .ascending) -> [Element] where Value: Comparable {
        if order == .ascending {
            return sorted { compare($0) < compare($1) }
        } else {
            return sorted { compare($0) > compare($1) }
        }
    }
    
    /**
    An array of the elements sorted by the given predicate.
     
     - Parameters:
        - compare: The closure to compare the elements.
        - order: The order of sorting. The default value is `ascending`.
     */
    public func sorted<Value>(by compare: ((Element) -> Value?), _ order: SequenceSortOrder = .ascending) -> [Element] where Value: Comparable {
        if order == .ascending {
            return self.sorted(by: compare, using: <)
        } else {
            return self.sorted(by: compare, using: >)
        }
    }
    
    /**
    An array of the elements sorted by the given keypath.
     
     - Parameters:
        - keyPath: The keypath to compare the elements.
        - order: The order of sorting. The default value is `ascending`.
     */
    public func sorted<Value>(by keyPath: KeyPath<Element, Value>, _ order: SequenceSortOrder = .ascending) -> [Element] where Value: Comparable {
        if order == .ascending {
            return self.sorted(by: keyPath, using: <)
        } else {
            return self.sorted(by: keyPath, using: >)
        }
    }
    
    /**
    An array of the elements sorted by the given keypath.
     
     - Parameters:
        - compare: The keypath to compare the elements.
        - order: The order of sorting. The default value is `ascending`.
     */
    public func sorted<Value>(by keyPath: KeyPath<Element, Value?>, _ order: SequenceSortOrder = .ascending) -> [Element] where Value: Comparable {
        if order == .ascending {
            return self.sorted(by: keyPath, using: <)
        } else {
            return self.sorted(by: keyPath, using: >)
        }
    }
    
    func sorted<Value>(by compare: (Element) -> Value?, using comparator: (Value, Value) -> Bool) -> [Element] where Value: Comparable {
        sorted { a, b in
            guard let b = compare(b) else { return true }
            guard let a = compare(a) else { return false }
            return comparator(a, b)
        }
    }
    
    func sorted<Value>(by keyPath: KeyPath<Element, Value>, using comparator: (Value, Value) -> Bool) -> [Element] where Value: Comparable {
        sorted { a, b in
            return comparator(a[keyPath: keyPath], b[keyPath: keyPath])
        }
    }
    
    func sorted<Value>(by keyPath: KeyPath<Element, Value?>, using comparator: (Value, Value) -> Bool) -> [Element] where Value: Comparable {
        sorted { a, b in
            guard let b = b[keyPath: keyPath] else { return true }
            guard let a = a[keyPath: keyPath] else { return false }
            return comparator(a, b)
        }
    }
}

extension Sequence {
    /**
     Returns the elements of the sequence, sorted using given keyPaths as comparison between elements.

     Provided keyPath's that don't conform to Comparable will be ingnored when sorting.

     - Parameters:
        - keyPaths: The keypaths used for sorting the elements.
        - order: The order of sorting. The default value is `ascending`.
     */
    public func sorted(by keyPaths: [PartialKeyPath<Element>], order: SequenceSortOrder = .ascending) -> [Element] {
        return sorted(by: keyPaths.compactMap { PartialSortingKeyPath($0, order: order) })
    }

    /**
     Returns the elements of the sequence, sorted using given keypaths as comparison between elements.
     
     Each keypath defines its own sorting order by `ascending(_ keypath)` / `descending(_ keypath)` or by prependding `>>`(ascending) or `<<` (descending) to a keypath.
     
     ```swift
     images.sorted(by: [<<\.pixelSize, >>\.creationDate]
     images.sorted(by: [.ascending(\.pixelSize), .descending(\.creationDate)]
     ```
          
     - Parameter keyPaths: The keypaths used for sorting the elements.
     
     - Note:Provided keypaths that don't conform to `Comparable` will be ignored for sorting.
     */
    public func sorted(by keyPaths: [PartialSortingKeyPath<Element>]) -> [Element] {
        sorted { a, b in
            for kp in keyPaths {
                let order = kp.order
                for keyPath in kp.keyPaths {
                    if let val1 = a[keyPath: keyPath] as? any Comparable, let val2 = b[keyPath: keyPath] as? any Comparable {
                            return (order == .ascending) ? val1.isLessThan(val2) : !val1.isLessThan(val2)
                    } else if let valus1 = a[keyPath: keyPath] as? (any Comparable)?, let value2 = b[keyPath: keyPath] as? (any Comparable)? {
                        guard value2 != nil else { return true }
                        guard valus1 != nil else { return false }
                        return (order == .ascending) ? (valus1?.isLessThan(value2) ?? false) : !(valus1?.isLessThan(value2) ?? false)
                    } else {
                        return false
                    }
                }
            }
            return false
        }
    }
    
    /**
     Returns the elements of the sequence, sorted using given keypaths as comparison between elements.
     
     Each keypath defines its own sorting order by `ascending(_ keypath)` / `descending(_ keypath)` or by prependding `>>`(ascending) or `<<` (descending) to a keypath.
     
     ```swift
     images.sorted(by: [<<\.pixelSize, >>\.creationDate]
     images.sorted(by: [.ascending(\.pixelSize), .descending(\.creationDate)]
     ```
          
     - Parameter keyPaths: The keypaths used for sorting the elements.
     
     - Note:Provided keypaths that don't conform to `Comparable` will be ignored for sorting.
     */
    public func sorted(by keyPaths: PartialSortingKeyPath<Element>...) -> [Element] {
        self.sorted(by: keyPaths)
    }
}

/// Returns a keypath used for sorting a sequence in an ascending order.
public prefix func << <Root>(keyPath: PartialKeyPath<Root>) -> PartialSortingKeyPath<Root> {
    return .ascending(keyPath)
}

/// Returns a keypath used for sorting a sequence in an ascending order.
public prefix func << <Root>(keyPaths: [PartialKeyPath<Root>]) -> PartialSortingKeyPath<Root> {
    return .ascending(keyPaths)
}

/// Returns a keypath used for sorting a sequence in a descending order.
public prefix func >> <Root>(keyPath: PartialKeyPath<Root>) -> PartialSortingKeyPath<Root> {
    return .descending(keyPath)
}

/// Returns a keypath used for sorting a sequence in a descending order.
public prefix func >> <Root>(keyPaths: [PartialKeyPath<Root>]) -> PartialSortingKeyPath<Root> {
    return .descending(keyPaths)
}

/// A keypath that is used for sorting a sequence.
public struct PartialSortingKeyPath<Root> {
    let keyPaths: [PartialKeyPath<Root>]
    let order: SequenceSortOrder

    init(_ keyPath: PartialKeyPath<Root>, order: SequenceSortOrder = .ascending) {
        self.keyPaths = [keyPath]
        self.order = order
    }

    init(_ keyPaths: [PartialKeyPath<Root>], order: SequenceSortOrder = .ascending) {
        self.keyPaths = keyPaths
        self.order = order
    }

    /// Returns a keypath used for sorting a sequence in an ascending order.
    public static func ascending(_ keyPath: PartialKeyPath<Root>...) -> Self {
        return Self(keyPath, order: .ascending)
    }
    
    /// Returns a keypath used for sorting a sequence in an ascending order.
    public static func ascending(_ keyPaths: [PartialKeyPath<Root>]) -> Self {
        return Self(keyPaths, order: .ascending)
    }

    /// Returns a keypath used for sorting a sequence in a descending order.
    public static func descending(_ keyPath: PartialKeyPath<Root>...) -> Self {
        return Self(keyPath, order: .descending)
    }

    /// Returns a keypath used for sorting a sequence in a descending order.
    public static func descending(_ keyPaths: [PartialKeyPath<Root>]) -> Self {
        return Self(keyPaths, order: .descending)
    }
    
    /// Returns a keypath used for sorting a sequence in an ascending order.
    public static func oldestFirst(_ keyPath: PartialKeyPath<Root>...) -> Self {
        return Self(keyPath, order: .ascending)
    }
    
    /// Returns a keypath used for sorting a sequence in an ascending order.
    public static func oldestFirst(_ keyPaths: [PartialKeyPath<Root>]) -> Self {
        return Self(keyPaths, order: .ascending)
    }

    /// Returns a keypath used for sorting a sequence in a descending order.
    public static func newestFirst(_ keyPath: PartialKeyPath<Root>...) -> Self {
        return Self(keyPath, order: .descending)
    }

    /// Returns a keypath used for sorting a sequence in a descending order.
    public static func newestFirst(_ keyPaths: [PartialKeyPath<Root>]) -> Self {
        return Self(keyPaths, order: .descending)
    }
    
    /// Returns a keypath used for sorting a sequence in an ascending order.
    public static func smallestFirst(_ keyPath: PartialKeyPath<Root>...) -> Self {
        return Self(keyPath, order: .ascending)
    }
    
    /// Returns a keypath used for sorting a sequence in an ascending order.
    public static func smallestFirst(_ keyPaths: [PartialKeyPath<Root>]) -> Self {
        return Self(keyPaths, order: .ascending)
    }

    /// Returns a keypath used for sorting a sequence in a descending order.
    public static func largestFirst(_ keyPath: PartialKeyPath<Root>...) -> Self {
        return Self(keyPath, order: .descending)
    }
    
    /// Returns a keypath used for sorting a sequence in a descending order.
    public static func largestFirst(_ keyPaths: [PartialKeyPath<Root>]) -> Self {
        return Self(keyPaths, order: .descending)
    }
    
    /// Returns a keypath used for sorting a sequence in an ascending order.
    public static func shortestFirst(_ keyPath: PartialKeyPath<Root>...) -> Self {
        return Self(keyPath, order: .ascending)
    }

    /// Returns a keypath used for sorting a sequence in an ascending order.
    public static func shortestFirst(_ keyPaths: [PartialKeyPath<Root>]) -> Self {
        return Self(keyPaths, order: .ascending)
    }
    
    /// Returns a keypath used for sorting a sequence in a descending order.
    public static func longestFirst(_ keyPath: PartialKeyPath<Root>...) -> Self {
        return Self(keyPath, order: .descending)
    }

    /// Returns a keypath used for sorting a sequence in a descending order.
    public static func longestFirst(_ keyPaths: [PartialKeyPath<Root>]) -> Self {
        return Self(keyPaths, order: .descending)
    }
}
