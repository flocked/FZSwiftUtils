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

public extension Sequence where Element: Comparable {
    /**
     Returns the elements of the sequence, sorted.
     
     - Parameter order: The order of sorting.
     */
    func sorted(_ order: SequenceSortOrder) -> [Element] {
        order == .ascending ? sorted() : sorted().reversed()
    }
}

public extension Sequence {
    /**
     An array of the elements sorted by the given predicate.

      - Parameters:
         - compare: The closure to compare the elements.
         - order: The order of sorting. The default value is `ascending`.
      */
    func sorted<Value>(by compare: (Element) -> Value, _ order: SequenceSortOrder = .ascending) -> [Element] where Value: Comparable {
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
    func sorted<Value>(by compare: (Element) -> Value?, _ order: SequenceSortOrder = .ascending) -> [Element] where Value: Comparable {
        if order == .ascending {
            return sorted(by: compare, using: <)
        } else {
            return sorted(by: compare, using: >)
        }
    }

    /**
     An array of the elements sorted by the given keypath.

      - Parameters:
         - keyPath: The keypath to compare the elements.
         - order: The order of sorting. The default value is `ascending`.
      */
    func sorted<Value>(by keyPath: KeyPath<Element, Value>, _ order: SequenceSortOrder = .ascending) -> [Element] where Value: Comparable {
        if order == .ascending {
            return sorted(by: keyPath, using: <)
        } else {
            return sorted(by: keyPath, using: >)
        }
    }

    /**
     An array of the elements sorted by the given keypath.

      - Parameters:
         - compare: The keypath to compare the elements.
         - order: The order of sorting. The default value is `ascending`.
      */
    func sorted<Value>(by keyPath: KeyPath<Element, Value?>, _ order: SequenceSortOrder = .ascending) -> [Element] where Value: Comparable {
        if order == .ascending {
            return sorted(by: keyPath, using: <)
        } else {
            return sorted(by: keyPath, using: >)
        }
    }

    internal func sorted<Value>(by compare: (Element) -> Value?, using comparator: (Value, Value) -> Bool) -> [Element] where Value: Comparable {
        sorted { a, b in
            guard let b = compare(b) else { return true }
            guard let a = compare(a) else { return false }
            return comparator(a, b)
        }
    }

    internal func sorted<Value>(by keyPath: KeyPath<Element, Value>, using comparator: (Value, Value) -> Bool) -> [Element] where Value: Comparable {
        sorted { a, b in
            comparator(a[keyPath: keyPath], b[keyPath: keyPath])
        }
    }

    internal func sorted<Value>(by keyPath: KeyPath<Element, Value?>, using comparator: (Value, Value) -> Bool) -> [Element] where Value: Comparable {
        sorted { a, b in
            guard let b = b[keyPath: keyPath] else { return true }
            guard let a = a[keyPath: keyPath] else { return false }
            return comparator(a, b)
        }
    }
}

extension Sequence {
    /**
     Returns the elements of the sequence, sorted using given keypaths as comparison between elements.

     Each keypath defines its own sorting order by `ascending(_ keypath)` / `descending(_ keypath)` or by prependding `>>`(ascending) or `<<` (descending) to a keypath.

     ```swift
     images.sorted(by: [<<\.pixelSize, >>\.creationDate]
     images.sorted(by: [.ascending(\.pixelSize), .descending(\.creationDate)]
     ```

     - Parameter sortings: The keypaths  to `Comparable` properties used for sorting the elements.
     */
    public func sorted(by sortings: [ElementSorting<Element>]) -> [Element] {
        return sorted(by: { (elm1, elm2) -> Bool in
            for sorting in sortings {
                switch sorting.compare(elm1, elm2) {
                case .orderedSame:
                    break
                case .orderedAscending:
                    return true
                case .orderedDescending:
                    return false
                }
            }
            
            return false
        })
    }
    
    /**
     Returns the elements of the sequence, sorted using given keypaths as comparison between elements.

     Each keypath defines its own sorting order by `ascending(_ keypath)` / `descending(_ keypath)` or by prependding `>>`(ascending) or `<<` (descending) to a keypath.

     ```swift
     images.sorted(by: .ascending(\.pixelSize), .descending(\.creationDate]
     images.sorted(by: <<\.pixelSize, >>\.creationDate
     ```

     - Parameter sortings: The keypaths  to `Comparable` properties used for sorting the elements.
     */
    public func sorted(by sortings: ElementSorting<Element>...) -> [Element] {
        sorted(by: sortings)
    }
}

/**
 Sorts the elements of a sequence,
 
 To sort a sequence, use ``Swift/Sequence/sorted(by:)-5z4xd``.
 */
public struct ElementSorting<Element> {
    /// Handler that returns the comparison result between two elements.
    public private(set) var compare: (Element, Element) -> ComparisonResult
    
    /// Sorts the elements of a sequence by the specified key path in an ascending order.
    public static func ascending<T: Comparable>(_ attribute: KeyPath<Element, T>) -> ElementSorting<Element> {
        return ElementSorting(compare: { lhs, rhs -> ComparisonResult in
            let (x, y) = (lhs[keyPath: attribute], rhs[keyPath: attribute])
            return sort(x, y, ascending: true)
        })
    }
    
    /// Sorts the elements of a sequence by the specified key path in an ascending order.
    public static func ascending<T: Comparable>(_ attribute: KeyPath<Element, T?>) -> ElementSorting<Element> {
        return ElementSorting(compare: { lhs, rhs -> ComparisonResult in
            let (x, y) = (lhs[keyPath: attribute], rhs[keyPath: attribute])
            guard let y = y else { return .orderedDescending }
            guard let x = x else { return .orderedAscending }
            return sort(x, y, ascending: true)
        })
    }
    
    /// Sorts the elements of a sequence by the specified key path in an descending order.
    public static func descending<T: Comparable>(_ attribute: KeyPath<Element, T>) -> ElementSorting<Element> {
        return ElementSorting(compare: { lhs, rhs -> ComparisonResult in
            let (x, y) = (lhs[keyPath: attribute], rhs[keyPath: attribute])
            return sort(x, y, ascending: false)
        })
    }
    
    /// Sorts the elements of a sequence by the specified key path in an descending order.
    public static func descending<T: Comparable>(_ attribute: KeyPath<Element, T?>) -> ElementSorting<Element> {
        return ElementSorting(compare: { lhs, rhs -> ComparisonResult in
            let (x, y) = (lhs[keyPath: attribute], rhs[keyPath: attribute])
            guard let y = y else { return .orderedAscending }
            guard let x = x else { return .orderedDescending }
            return sort(x, y, ascending: false)
        })
    }
    
    /// Sorts the elements of a sequence by the specified comparison.
    public static func compare(_ compare: @escaping ((Element, Element) -> ComparisonResult)) -> ElementSorting<Element> {
        ElementSorting(compare: compare)
    }
    
    internal static func sort<T: Comparable>(_ x: T, _ y: T, ascending: Bool) -> ComparisonResult {
        if x == y {
            return .orderedSame
        } else if x < y {
            return ascending ? .orderedAscending : .orderedDescending
        } else {
            return ascending ? .orderedDescending : .orderedAscending
        }
    }
}

/// Sorts the elements of a sequence by the specified key path in an ascending order.
public prefix func << <Element, T: Comparable>(keyPath: KeyPath<Element, T>) -> ElementSorting<Element> {
    .ascending(keyPath)
}

/// Sorts the elements of a sequence by the specified key path in an ascending order.
public prefix func << <Element, T: Comparable>(keyPath: KeyPath<Element, T?>) -> ElementSorting<Element> {
    .ascending(keyPath)
}

/// Sorts the elements of a sequence by the specified key path in an descending order.
public prefix func >> <Element, T: Comparable>(keyPath: KeyPath<Element, T>) -> ElementSorting<Element> {
    .descending(keyPath)
}

/// Sorts the elements of a sequence by the specified key path in an descending order.
public prefix func >> <Element, T: Comparable>(keyPath: KeyPath<Element, T?>) -> ElementSorting<Element> {
    .descending(keyPath)
}
