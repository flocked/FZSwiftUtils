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
     Returns the elements sorted with the specified element sort comparators.

     Example usage:
     
     ```swift
     images.sorted(by: .ascending(\.pixelSize), .descending(\.creationDate]
     images.sorted(by: <<\.pixelSize, >>\.creationDate
     ```

     - Parameter comparators: The sort comparators used for sorting the elements.
     */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public func sorted(by comparators: [ElementSortComparator<Element>]) -> [Element] {
        return sorted(by: { (elm1, elm2) -> Bool in
            for comparator in comparators {
                switch comparator.compare(elm1, elm2) {
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
     Returns the elements sorted with the specified element sort comparators.

     Example usage:
     
     ```swift
     images.sorted(by: .ascending(\.pixelSize), .descending(\.creationDate]
     images.sorted(by: <<\.pixelSize, >>\.creationDate
     ```

     - Parameter comparators: The sort comparators used for sorting the elements.
     */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public func sorted(by comparators: ElementSortComparator<Element>...) -> [Element] {
        sorted(by: comparators)
    }
    
    /**
     Returns the elements sorted with the specified sort comparators.

     - Parameter comparators: The sort comparators used for sorting the elements.
     */
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public func sorted(by comparators: [any SortComparator<Element>]) -> [Element] {
        return sorted(by: { (elm1, elm2) -> Bool in
            for sorting in comparators {
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
     Returns the elements sorted with the specified sort comparators.

     - Parameter comparators: The sort comparators used for sorting the elements.
     */
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public func sorted(by comparators: any SortComparator<Element>...) -> [Element] {
        sorted(by: comparators)
    }
}

/**
 A comparison algorithm for a specified type.
 
 To sort a sequence, use ``Swift/Sequence/sorted(by:)-9kf1n``.
 */
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public struct ElementSortComparator<Element>: Hashable, SortComparator {
        
    /// The sort order that the comparator uses to compare.
    public var order: SortOrder {
        get { comperator.order }
        set { comperator.order = newValue }
    }
    
    /**
     Provides the relative ordering of two elements based on the sort order of the comparator.
     
     - Parameters:
        - lhs: The first element to compare.
        - rhs: The second element to compare.
     
     - Returns: The relative ordering between the two elements according to the sort order of the comparator.
     */
    public func compare(_ lhs: Element, _ rhs: Element) -> ComparisonResult {
        comperator.compare(lhs, rhs)
    }
    
    /// Sorts the elements of a sequence by the specified key path in an ascending order.
    public static func ascending<T: Comparable>(_ keyPath: KeyPath<Element, T>) -> ElementSortComparator {
        .init(KeyPathComparator(keyPath, order: .forward))
    }
    
    /// Sorts the elements of a sequence by the specified key path in an ascending order.
    public static func ascending<T: Comparable>(_ keyPath: KeyPath<Element, T?>) -> ElementSortComparator {
        .init(KeyPathComparator(keyPath, order: .forward))
    }
    
    /// Sorts the elements of a sequence by the specified key path in a descending order.
    public static func descending<T: Comparable>(_ keyPath: KeyPath<Element, T>) -> ElementSortComparator {
        .init(KeyPathComparator(keyPath, order: .reverse))
    }
    
    /// Sorts the elements of a sequence by the specified key path in a descending order.
    public static func descending<T: Comparable>(_ keyPath: KeyPath<Element, T?>) -> ElementSortComparator {
        .init(KeyPathComparator(keyPath, order: .reverse))
    }
    
    /// Sorts the elements of a sequence by the specified comparison.
    public static func compare(_ compare: @escaping ((Element, Element) -> ComparisonResult)) -> ElementSortComparator {
        .init(HandlerComparator(handler: compare))
    }
    
    var comperator: any SortComparator<Element>
    
    init(_ comperator: some SortComparator<Element>) {
        self.comperator = comperator
    }
        
    public static func == (lhs: ElementSortComparator<Element>, rhs: ElementSortComparator<Element>) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(comperator)
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension ElementSortComparator where Element: Comparable {
    /// Sorts the elements of a sequence in an ascending order.
    public static var ascending: ElementSortComparator {
        if #available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *) {
            return .init(ComparableComparator(order: .forward))
        } else {
            return .init(_ComparableComparator(order: .forward))
        }
    }
    
    /// Sorts the elements of a sequence in a descending order.
    public static var descending: ElementSortComparator {
        if #available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *) {
            return .init(ComparableComparator(order: .reverse))
        } else {
            return .init(_ComparableComparator(order: .reverse))
        }
    }
}

/// Sorts the elements of a sequence by the specified key path in an ascending order.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public prefix func << <Element, T: Comparable>(keyPath: KeyPath<Element, T>) -> ElementSortComparator<Element> {
    .ascending(keyPath)
}

/// Sorts the elements of a sequence by the specified key path in an ascending order.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public prefix func << <Element, T: Comparable>(keyPath: KeyPath<Element, T?>) -> ElementSortComparator<Element> {
    .ascending(keyPath)
}

/// Sorts the elements of a sequence by the specified key path in a descending order.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public prefix func >> <Element, T: Comparable>(keyPath: KeyPath<Element, T>) -> ElementSortComparator<Element> {
    .descending(keyPath)
}

/// Sorts the elements of a sequence by the specified key path in a descending order.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public prefix func >> <Element, T: Comparable>(keyPath: KeyPath<Element, T?>) -> ElementSortComparator<Element> {
    .descending(keyPath)
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
struct _ComparableComparator<Compared>: SortComparator where Compared : Comparable {
    func compare(_ lhs: Compared, _ rhs: Compared) -> ComparisonResult {
        if lhs == rhs {
            return .orderedSame
        } else if lhs < rhs {
            return order == .forward ? .orderedAscending : .orderedDescending
        }
        return order == .forward ? .orderedDescending : .orderedAscending
    }
    
    var order: SortOrder
    
    init(order: SortOrder = .forward) {
        self.order = order
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
struct HandlerComparator<Compared>: SortComparator {
    var order: SortOrder
    
    let handler: (_ lhs: Compared, _ rhs: Compared)->ComparisonResult
    let id = UUID()
    
    func compare(_ lhs: Compared, _ rhs: Compared) -> ComparisonResult {
        let result = handler(lhs, rhs)
        return order == .reverse ? result.reversed : result
    }
    
    init(order: SortOrder = .forward, handler: @escaping (_ lhs: Compared, _ rhs: Compared)->ComparisonResult) {
        self.order = order
        self.handler = handler
    }
    
    static func == (lhs: HandlerComparator<Compared>, rhs: HandlerComparator<Compared>) -> Bool {
        return false
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(order)
        hasher.combine(id)
    }
}

fileprivate extension ComparisonResult {
    var reversed: ComparisonResult {
        switch self {
        case .orderedDescending: return .orderedAscending
        case .orderedAscending: return .orderedDescending
        case .orderedSame: return .orderedSame
        }
    }
}

/*
 /**
  Sorts the elements of a sequence,
  
  To sort a sequence, use ``Swift/Sequence/sorted(by:)-5z4xd``.
  */
 public struct ElementSorting<Element> {
     /// Handler that returns the comparison result between two elements.
     public private(set) var compare: (Element, Element) -> ComparisonResult
         
     /// Sorts the elements of a sequence by the specified key path in an ascending order.
     public static func ascending<T: Comparable>(_ keyPath: KeyPath<Element, T>) -> ElementSorting<Element> {
         return ElementSorting(compare: { lhs, rhs -> ComparisonResult in
             let (x, y) = (lhs[keyPath: keyPath], rhs[keyPath: keyPath])
             return sort(x, y, ascending: true)
         })
     }
     
     /// Sorts the elements of a sequence by the specified key path in an ascending order.
     public static func ascending<T: Comparable>(_ keyPath: KeyPath<Element, T?>) -> ElementSorting<Element> {
         return ElementSorting(compare: { lhs, rhs -> ComparisonResult in
             let (x, y) = (lhs[keyPath: keyPath], rhs[keyPath: keyPath])
             guard let y = y else { return .orderedDescending }
             guard let x = x else { return .orderedAscending }
             return sort(x, y, ascending: true)
         })
     }
     
     /// Sorts the elements of a sequence by the specified key path in a descending order.
     public static func descending<T: Comparable>(_ keyPath: KeyPath<Element, T>) -> ElementSorting<Element> {
         return ElementSorting(compare: { lhs, rhs -> ComparisonResult in
             let (x, y) = (lhs[keyPath: keyPath], rhs[keyPath: keyPath])
             return sort(x, y, ascending: false)
         })
     }
     
     /// Sorts the elements of a sequence by the specified key path in a descending order.
     public static func descending<T: Comparable>(_ keyPath: KeyPath<Element, T?>) -> ElementSorting<Element> {
         return ElementSorting(compare: { lhs, rhs -> ComparisonResult in
             let (x, y) = (lhs[keyPath: keyPath], rhs[keyPath: keyPath])
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

 extension ElementSorting where Element: Comparable {
     /// Sorts the elements of a sequence in an ascending order.
     public static var ascending: ElementSorting {
         ElementSorting(compare: { lhs, rhs -> ComparisonResult in
             return sort(lhs, rhs, ascending: true)
         })
     }
     
     /// Sorts the elements of a sequence in a descending order.
     public static var descending: ElementSorting {
         ElementSorting(compare: { lhs, rhs -> ComparisonResult in
             return sort(lhs, rhs, ascending: false)
         })
     }
 }
 */
