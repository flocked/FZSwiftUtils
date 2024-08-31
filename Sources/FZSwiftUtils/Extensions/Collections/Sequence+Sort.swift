//
//  Sequence+Sort.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import Foundation

public extension Sequence where Element: Comparable {
    /**
     Returns the elements of the sequence, sorted.
     
     - Parameter order: The order of sorting.
     */
    func sorted(_ order: SequenceSortOrder) -> [Element] {
        return order == .ascending ? sorted() : sorted(by: >)
    }
}

public extension MutableCollection where Self: RandomAccessCollection, Element: Comparable {
    /// Sorts the collection in place by the specified order.
    mutating func sort(_ order: SequenceSortOrder) {
        if order == .ascending {
            sort()
        } else {
            sort(by: >)
        }
    }
}

public extension Sequence {
    /**
     An array of the elements sorted by the given keypath.

      - Parameters:
         - keyPath: The keypath to compare the elements.
         - order: The order of sorting. The default value is `ascending`.
      */
    func sorted<Value>(by keyPath: KeyPath<Element, Value>, _ order: SequenceSortOrder = .ascending) -> [Element] where Value: Comparable {
        if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
            return sorted(using: KeyPathComparator(keyPath, order: order.sortOrder))
        }
        return order == .ascending ? sorted(by: keyPath, using: <) : sorted(by: keyPath, using: >)
    }

    /**
     An array of the elements sorted by the given keypath.

      - Parameters:
         - compare: The keypath to compare the elements.
         - order: The order of sorting. The default value is `ascending`.
      */
    func sorted<Value>(by keyPath: KeyPath<Element, Value?>, _ order: SequenceSortOrder = .ascending) -> [Element] where Value: Comparable {
        if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
            return sorted(using: KeyPathComparator(keyPath, order: order.sortOrder))
        }
        return order == .ascending ? sorted(by: keyPath, using: <) : sorted(by: keyPath, using: >)
    }
    
    /**
     An array of the elements sorted by the given predicate.

      - Parameters:
         - compare: The closure to compare the elements.
         - order: The order of sorting. The default value is `ascending`.
      */
    internal func sorted<Value>(by compare: (Element) -> Value, _ order: SequenceSortOrder = .ascending) -> [Element] where Value: Comparable {
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
    internal func sorted<Value>(by compare: (Element) -> Value?, _ order: SequenceSortOrder = .ascending) -> [Element] where Value: Comparable {
        if order == .ascending {
            return sorted(by: compare, using: <)
        } else {
            return sorted(by: compare, using: >)
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
     Returns the elements, sorted using the given comparators to compare elements.

     Example usage:
     
     ```swift
     files.sorted(by: [.ascending(\.creationDate), .descending(\.fileSize)])
     files.sorted(by: [<<\.creationDate, >>\.fileSize])
     ```

     - Parameters:
        - comparators: The sort comparators used to compare elements.
        - order: The order of sorting. The default value is `ascending`.
     */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public func sorted(by comparators: [SortingComparator<Element>], order: SequenceSortOrder = .ascending) -> [Element] {
        sorted {
            for comparator in comparators {
                switch comparator.compare($0, $1) {
                case .orderedSame:
                    break
                case .orderedAscending:
                    return order == .ascending ? true : false
                case .orderedDescending:
                    return order == .ascending ? false : true
                }
            }
            return false
        }
    }
    
    /**
     Returns the elements, sorted using the given comparators to compare elements.

     - Parameters:
        - comparators: The sort comparators used to compare elements.
        - order: The order of sorting. The default value is `forward`.
     */
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public func sorted(by comparators: [any SortComparator<Element>], order: SortOrder = .forward) -> [Element] {
        sorted {
            for sorting in comparators {
                switch sorting.compare($0, $1) {
                case .orderedSame:
                    break
                case .orderedAscending:
                    return order == .forward ? true : false
                case .orderedDescending:
                    return order == .forward ? false : true
                }
            }
            return false
        }
    }
}

public extension MutableCollection where Self: RandomAccessCollection & RangeReplaceableCollection {
    /**
     Sorts the collection by the given key path.

      - Parameters:
         - keyPath: The keypath to compare the elements.
         - order: The order of sorting. The default value is `ascending`.
    */
    mutating func sort<Value>(by keyPath: KeyPath<Element, Value>, _ order: SequenceSortOrder = .ascending) where Value: Comparable {
        if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
            sort(using: KeyPathComparator(keyPath, order: order.sortOrder))
        } else {
            self = Self(sorted(by: keyPath, order))
        }
    }
    
    /**
     Sorts the collection by the given key path.

      - Parameters:
         - keyPath: The keypath to compare the elements.
         - order: The order of sorting. The default value is `ascending`.
    */
    mutating func sort<Value>(by keyPath: KeyPath<Element, Value?>, _ order: SequenceSortOrder = .ascending) where Value: Comparable {
        if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
            sort(using: KeyPathComparator(keyPath, order: order.sortOrder))
        } else {
            self = Self(sorted(by: keyPath, order))
        }
    }
    
    /**
     Sorts the collection using the given comparators to compare elements.
     
     - Parameters:
        - comparators: The sort comparators used to compare elements.
        - order: The order of sorting. The default value is `ascending`.
     */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    mutating func sort(by comparators: [SortingComparator<Element>], order: SequenceSortOrder = .ascending) {
        self = Self(sorted(by: comparators, order: order))
    }
    
    /**
     Sorts the collection using the given comparators to compare elements.

     - Parameters:
        - comparators: The sort comparators used to compare elements.
        - order: The order of sorting. The default value is `ascending`.
     */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    mutating func sort(by comparators: SortingComparator<Element>..., order: SequenceSortOrder = .ascending) {
        self = Self(sorted(by: comparators, order: order))
    }
    
    /**
     Sorts the collection using the given comparators to compare elements.

     - Parameters:
        - comparators: The sort comparators used to compare elements.
        - order: The order of sorting. The default value is `forward`.
     */
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    mutating func sort(by comparators: [any SortComparator<Element>], order: SortOrder = .forward) {
        self = Self(sorted(by: comparators, order: order))
    }
    
    /**
     Sorts the collection using the given comparators to compare elements.

     - Parameters:
        - comparators: The sort comparators used to compare elements.
        - order: The order of sorting. The default value is `forward`.
     */
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    mutating func sort(by comparators: any SortComparator<Element>..., order: SortOrder = .forward) {
        self = Self(sorted(by: comparators, order: order))
    }
}

/**
 A comparison algorithm for a specified type.
 
 To sort a sequence, use ``Swift/Sequence/sorted(by:order:)-9dbx0``.
 */
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public struct SortingComparator<Element>: Hashable, SortComparator {
        
    /// The sort order that the comparator uses to compare.
    public var order: SortOrder {
        get { comperator.order }
        set { comperator.order = newValue }
    }
    
    public var keyPath: PartialKeyPath<Element>? = nil
    
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
    
    /// A key path comparator that sorts in an ascending order.
    public static func ascending<T: Comparable>(_ keyPath: KeyPath<Element, T>) -> SortingComparator {
        .init(KeyPathComparator(keyPath, order: .forward), keyPath)
    }
    
    /// A key path comparator that sorts in an ascending order.
    public static func ascending<T: Comparable>(_ keyPath: KeyPath<Element, T?>) -> SortingComparator {
        .init(KeyPathComparator(keyPath, order: .forward), keyPath)
    }
    
    /// A key path comparator that sorts in an ascending order.
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    public static func ascending(_ keyPath: KeyPath<Element, String>, comparator: String.StandardComparator = .localizedStandard) -> SortingComparator {
        .init(SortDescriptor(keyPath, comparator: comparator, order: .ascending), keyPath)
    }
    
    /// A key path comparator that sorts in an ascending order.
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    public static func ascending(_ keyPath: KeyPath<Element, String?>, comparator: String.StandardComparator = .localizedStandard) -> SortingComparator {
        .init(SortDescriptor(keyPath, comparator: comparator, order: .ascending), keyPath)
    }
    
    /// A key path comparator that sorts in a descending order.
    public static func descending<T: Comparable>(_ keyPath: KeyPath<Element, T>) -> SortingComparator {
        .init(KeyPathComparator(keyPath, order: .reverse), keyPath)
    }
    
    /// A key path comparator that sorts in a descending order.
    public static func descending<T: Comparable>(_ keyPath: KeyPath<Element, T?>) -> SortingComparator {
        .init(KeyPathComparator(keyPath, order: .reverse), keyPath)
    }
    
    /// A key path comparator that sorts in a descending order.
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    public static func descending(_ keyPath: KeyPath<Element, String>, comparator: String.StandardComparator = .localizedStandard) -> SortingComparator {
        .init(SortDescriptor(keyPath, comparator: comparator, order: .reverse), keyPath)
    }
    
    /// A key path comparator that sorts in a descending order.
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    public static func descending(_ keyPath: KeyPath<Element, String?>, comparator: String.StandardComparator = .localizedStandard) -> SortingComparator {
        .init(SortDescriptor(keyPath, comparator: comparator, order: .reverse), keyPath)
    }
    
    /// A comparator that sorts by the specified compare block.
    public static func compare(_ compare: @escaping ((Element, Element) -> ComparisonResult)) -> SortingComparator {
        .init(HandlerComparator(handler: compare))
    }
    
    /// A key path comparator that sorts by partial key paths.
    static func partialKeyPath(_ keyPath: PartialKeyPath<Element>, order: SortOrder) -> SortingComparator {
        .init(PartialKeyPathComparator(keyPath, order: order), keyPath)
    }
        
    var comperator: any SortComparator<Element>
    
    init(_ comperator: some SortComparator<Element>, _ keyPath: PartialKeyPath<Element>? = nil) {
        self.comperator = comperator
        self.keyPath = keyPath
    }
        
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(comperator)
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension SortingComparator where Element: Comparable {
    /// A comparator that sorts in an ascending order.
    public static var ascending: SortingComparator {
        SortingComparator(_ComparableComparator(order: .forward))
    }
    
    /// A comparator that sorts in a descending order.
    public static var descending: SortingComparator {
        SortingComparator(_ComparableComparator<Element>(order: .reverse))
    }
}

/// A key path sort comparator that sorts in an ascending order.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public prefix func << <Element, T: Comparable>(keyPath: KeyPath<Element, T>) -> SortingComparator<Element> {
    .ascending(keyPath)
}

/// A key path sort comparator that sorts in an ascending order.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public prefix func << <Element, T: Comparable>(keyPath: KeyPath<Element, T?>) -> SortingComparator<Element> {
    .ascending(keyPath)
}

/// A key path sort comparator that sorts in a descending order.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public prefix func >> <Element, T: Comparable>(keyPath: KeyPath<Element, T>) -> SortingComparator<Element> {
    .descending(keyPath)
}

/// A key path sort comparator that sorts in a descending order.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public prefix func >> <Element, T: Comparable>(keyPath: KeyPath<Element, T?>) -> SortingComparator<Element> {
    .descending(keyPath)
}

/// The order of sorting for a sequence
public enum SequenceSortOrder: Int, Hashable {
    /// An ascending sorting order.
    case ascending
    /// A descending sorting order.
    case descending
    
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    var sortOrder: SortOrder {
        self == .ascending ? .forward : .reverse
    }

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
