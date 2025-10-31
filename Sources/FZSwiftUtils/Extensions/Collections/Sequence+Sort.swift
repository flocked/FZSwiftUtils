//
//  Sequence+Sort.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import Foundation

public extension Sequence where Element: Comparable {
    /// Returns the elements of the sequence, sorted by the specified order.
    func sorted(_ order: SequenceSortOrder) -> [Element] {
        return order == .ascending ? sorted() : sorted(by: >)
    }
    
    /// Returns the elements of the sequence, sorted by the specified order.
    func sorted(_ order: SequenceSortOrder = .ascending) -> [Element] where Element: OptionalProtocol, Element.Wrapped: Comparable {
        sorted { a, b in
            let aValue = a.optional
            let bValue = b.optional
            switch (aValue, bValue) {
            case let (a?, b?):
                return order == .ascending ? a < b : a > b
            case (nil, nil):
                return false
            case (nil, _):
                return false
            case (_, nil):
                return true
            }
        }
    }
    
    /**
     Returns the elements of the sequence, sorted.
     
     - Parameters:
        - options: Options for comparing the strings.
        - range: The range of the string comparsion.
        - locale: The local of the string comparsion.
        - order: The order of sorting. The default value is `ascending`.
     */
    func sorted(options: String.CompareOptions, range: Range<Element.Index>? = nil, locale: Locale? = nil, _ order: SequenceSortOrder = .ascending) -> [Element] where Element: StringProtocol {
        sorted { (a, b) -> Bool in
            let comparsion = a.compare(b, options: options, range: range, locale: locale)
            return order == .ascending ? (comparsion == .orderedAscending) : (comparsion == .orderedDescending)
        }
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
    
    /// Sorts the collection in place by the specified order.
    mutating func sort(_ order: SequenceSortOrder) where Element: OptionalProtocol, Element.Wrapped: Comparable {
        sort { a, b in
            let aValue = a.optional
            let bValue = b.optional
            switch (aValue, bValue) {
            case let (a?, b?):
                return order == .ascending ? a < b : a > b
            case (nil, nil):
                return false
            case (nil, _):
                return false
            case (_, nil):
                return true
            }
        }
    }
    
    /**
     Sorts the collection in place by the specified order.
     
     - Parameters:
        - options: Options for comparing the strings.
        - range: The range of the string comparsion.
        - locale: The local of the string comparsion.
        - order: The order of sorting. The default value is `ascending`.
     */
    mutating func sort(options: String.CompareOptions, range: Range<Element.Index>? = nil, locale: Locale? = nil, _ order: SequenceSortOrder = .ascending) where Element: StringProtocol {
        sort { (a, b) -> Bool in
            let comparsion = a.compare(b, options: options, range: range, locale: locale)
            return order == .ascending ? (comparsion == .orderedAscending) : (comparsion == .orderedDescending)
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
        compactMap({ ComparableElement($0, $0[keyPath: keyPath]) }).sorted(order).compactMap({$0.element})
    }
    
    /**
     An array of the elements sorted by the given keypath.

      - Parameters:
        - keyPath: The keypath to compare the elements.
        - options: Options for comparing the key path strings.
        - range: The range of the string comparsion.
        - locale: The local of the string comparsion.
        - order: The order of sorting. The default value is `ascending`.
      */
    func sorted<Value>(by keyPath: KeyPath<Element, Value>, options: String.CompareOptions, range: Range<Value.Index>? = nil, locale: Locale? = nil, _ order: SequenceSortOrder = .ascending) -> [Element] where Value: StringProtocol {
        sorted { (a, b) -> Bool in
            let aValue = a[keyPath: keyPath]
            let bValue = b[keyPath: keyPath]
            let comparsion = aValue.compare(bValue, options: options, range: range, locale: locale)
            return order == .ascending ? (comparsion == .orderedAscending) : (comparsion == .orderedDescending)
        }
    }

    /**
     An array of the elements sorted by the given keypath.

      - Parameters:
         - compare: The keypath to compare the elements.
         - order: The order of sorting. The default value is `ascending`.
      */
    func sorted<Value>(by keyPath: KeyPath<Element, Value?>, _ order: SequenceSortOrder = .ascending) -> [Element] where Value: Comparable {
        sorted { (a, b) -> Bool in
                    let aValue = a[keyPath: keyPath]
                    let bValue = b[keyPath: keyPath]
                    switch (aValue, bValue) {
                    case let (a?, b?):
                        return order == .ascending ? a < b : a > b
                    case (nil, nil):
                        return false
                    case (nil, _):
                        return false
                    case (_, nil):
                        return true
                    }
                }
    }
    
    /**
     An array of the elements sorted by the given keypath.

      - Parameters:
        - compare: The keypath to compare the elements.
        - options: Options for comparing the key path strings.
        - range: The range of the string comparsion.
        - locale: The local of the string comparsion.
        - order: The order of sorting. The default value is `ascending`.
      */
    func sorted<Value>(by keyPath: KeyPath<Element, Value?>, options: String.CompareOptions, range: Range<Value.Index>? = nil, locale: Locale? = nil, _ order: SequenceSortOrder = .ascending) -> [Element] where Value: StringProtocol {
        sorted { (a, b) -> Bool in
                    let aValue = a[keyPath: keyPath]
                    let bValue = b[keyPath: keyPath]
                    switch (aValue, bValue) {
                    case let (a?, b?):
                        let comparsion = a.compare(b, options: options, range: range, locale: locale)
                        return order == .ascending ? (comparsion == .orderedAscending) : (comparsion == .orderedDescending)
                    case (nil, nil):
                        return false
                    case (nil, _):
                        return false
                    case (_, nil):
                        return true
                    }
                }
    }
    
    /**
     An array of the elements sorted by the given predicate.

      - Parameters:
         - compare: A closure that provides a comparable value for each element in the sequence.
         - order: The order of sorting. The default value is `ascending`.
      */
    func sorted<Value>(by compare: (Element) throws -> Value, _ order: SequenceSortOrder = .ascending) rethrows -> [Element] where Value: Comparable {
        try compactMap({ ComparableElement($0, try compare($0)) }).sorted(order).compactMap({$0.element})
    }

    /**
     An array of the elements sorted by the given predicate.

      - Parameters:
         - compare: A closure that provides a comparable value for each element in the sequence.
         - order: The order of sorting. The default value is `ascending`.
      */
    func sorted<Value>(by compare: (Element) throws -> Value?, _ order: SequenceSortOrder = .ascending) rethrows -> [Element] where Value: Comparable {
        try compactMap({ ComparableElement($0, try compare($0)) }).sorted(order).compactMap({$0.element})
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

     Example usage:
     
     ```swift
     files.sorted(by: .ascending(\.creationDate), .descending(\.fileSize))
     files.sorted(by: <<\.creationDate, >>\.fileSize)
     ```

     - Parameters:
        - comparators: The sort comparators used to compare elements.
        - order: The order of sorting. The default value is `ascending`.
     */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public func sorted(by comparators: SortingComparator<Element>..., order: SequenceSortOrder = .ascending) -> [Element] {
        sorted(by: comparators, order: order)
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
    
    /**
     Returns the elements, sorted using the given comparators to compare elements.

     - Parameters:
        - comparators: The sort comparators used to compare elements.
        - order: The order of sorting. The default value is `forward`.
     */
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public func sorted(by comparators: any SortComparator<Element>..., order: SortOrder = .forward) -> [Element] {
        sorted(by: comparators, order: order)
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
    public static func ascending(_ keyPath: KeyPath<Element, String>, comparator: String.StandardComparator) -> SortingComparator {
        .init(SortDescriptor(keyPath, comparator: comparator, order: .ascending), keyPath)
    }
    
    /// A key path comparator that sorts in an ascending order.
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    public static func ascending(_ keyPath: KeyPath<Element, String?>, comparator: String.StandardComparator) -> SortingComparator {
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
    public static func descending(_ keyPath: KeyPath<Element, String>, comparator: String.StandardComparator) -> SortingComparator {
        .init(SortDescriptor(keyPath, comparator: comparator, order: .reverse), keyPath)
    }
    
    /// A key path comparator that sorts in a descending order.
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    public static func descending(_ keyPath: KeyPath<Element, String?>, comparator: String.StandardComparator) -> SortingComparator {
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
        hasher.combine(keyPath)
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
public enum SequenceSortOrder: Int, Hashable, Codable {
    /// An ascending sorting order.
    case ascending
    /// A descending sorting order.
    case descending
    
    /// Toggles the sort order.
    public mutating func toggle() {
        self = (self == .ascending) ? .descending : .ascending
    }
    
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

struct ComparableElement<Element, Compare: Comparable>: Comparable {
    let element: Element
    let compare: Compare?
    
    init(_ element: Element, _ compare: Compare) {
        self.element = element
        self.compare = compare
    }
    
    init(_ element: Element, _ compare: Compare?) {
        self.element = element
        self.compare = compare
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.compare == rhs.compare
    }
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        guard let rhs = rhs.compare else { return true }
        guard let lhs = lhs.compare else { return false }
        return lhs < rhs
    }
}

public extension Sequence {
    /**
     Sorts the sequence based on a key path and an array specifying the order of key values.
     
     Elements whose key path values are not in the `order` array are sorted after explicitly ordered elements but before `nil` values.
     
     - Parameters:
        - keyPath: A key path to the property of each element to sort by.
        - order: An array specifying the desired order of key values.
     */
    func sorted<T: Equatable>(by keyPath: KeyPath<Element, T>, order: [T]) -> [Element] {
        map { (element: $0, index: order.firstIndex(of: $0[keyPath: keyPath]) ?? .max) }
                .sorted { $0.index < $1.index }
                .map(\.element)
    }
    
    /**
     Sorts the sequence based on a key path and an array specifying the order of key values.
     
     - Elements with `nil` values for the specified key path are always sorted to the end.
     - Elements whose key path values are not in the `order` array are sorted after explicitly ordered elements but before `nil` values.
     
     - Parameters:
        - keyPath: A key path to the property of each element to sort by.
        - order: An array specifying the desired order of key values.
     */
    func sorted<T: Equatable>(by keyPath: KeyPath<Element, T?>, order: [T]) -> [Element] {
        map { ($0, $0[keyPath: keyPath].flatMap({ order.firstIndex(of: $0) }) ?? .max) }
        .sorted { $0.1 < $1.1 }
        .map(\.0)
    }
    
    /**
     Sorts the sequence based on a key path and an array specifying the order of key values.
     
     Elements whose key path values are not in the `order` array are sorted after explicitly ordered elements but before `nil` values.
     
     - Parameters:
        - keyPath: A key path to the property of each element to sort by.
        - order: An array specifying the desired order of key values.
     */
    func sorted<T: Hashable>(by keyPath: KeyPath<Element, T>, order: [T]) -> [Element] {
        let orderMap = Dictionary(uniqueKeysWithValues: order.enumerated().map { ($1, $0) })
        return enumerated().sorted {
            let lhsIndex = orderMap[$0.element[keyPath: keyPath]] ?? .max
            let rhsIndex = orderMap[$1.element[keyPath: keyPath]] ?? .max
            return lhsIndex != rhsIndex ? lhsIndex < rhsIndex : $0.offset < $1.offset
        }.map(\.element)
    }
    
    /**
     Sorts the sequence based on a key path and an array specifying the order of key values.
     
     - Elements with `nil` values for the specified key path are always sorted to the end.
     - Elements whose key path values are not in the `order` array are sorted after explicitly ordered elements but before `nil` values.
     
     - Parameters:
        - keyPath: A key path to the property of each element to sort by.
        - order: An array specifying the desired order of key values.
     */
    func sorted<T: Hashable>(by keyPath: KeyPath<Element, T?>, order: [T]) -> [Element] {
        let orderMap = Dictionary(uniqueKeysWithValues: order.enumerated().map { ($1, $0) })
        return enumerated()
            .sorted {
                let lhsIndex = $0.element[keyPath: keyPath].flatMap({ orderMap[$0] }) ?? .max
                let rhsIndex = $1.element[keyPath: keyPath].flatMap({ orderMap[$0] }) ?? .max
                return lhsIndex != rhsIndex ? lhsIndex < rhsIndex : $0.offset < $1.offset
            }.map(\.element)
     }
}
