//
//  Sequence+Sort.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import Foundation

public extension Sequence {
    /// Returns the elements of the sequence, sorted by the specified order.
    func sorted(_ order: SortingOrder) -> [Element] where Element: Comparable {
        return order == .ascending ? sorted() : sorted(by: >)
    }
    
    /// Returns the elements of the sequence, sorted by the specified order.
    func sorted(_ order: SortingOrder = .ascending) -> [Element] where Element: OptionalProtocol, Element.Wrapped: Comparable {
        sorted {
            switch ($0.optional, $1.optional) {
            case let (a?, b?): return order == .ascending ? a < b : a > b
            case (_?, nil): return true
            default: return false
            }
        }
    }
}

public extension MutableCollection where Self: RandomAccessCollection, Element: Comparable {
    /// Sorts the collection in place by the specified order.
    mutating func sort(_ order: SortingOrder) {
        if order == .ascending {
            sort()
        } else {
            sort(by: >)
        }
    }
    
    /// Sorts the collection in place by the specified order.
    mutating func sort(_ order: SortingOrder = .ascending) where Element: OptionalProtocol, Element.Wrapped: Comparable {
        sort {
            switch ($0.optional, $1.optional) {
            case let (a?, b?): return order == .ascending ? a < b : a > b
            case (_?, nil): return true
            default: return false
            }
        }
    }
}

// MARK: - Sort by key path

public extension Sequence {
    /**
     An array of the elements sorted by the given keypath.

      - Parameters:
         - keyPath: The keypath to compare the elements.
         - order: The order of sorting.
      */
    func sorted<Value>(by keyPath: KeyPath<Element, Value>, _ order: SortingOrder = .ascending) -> [Element] where Value: Comparable {
        sorted(by: { $0[keyPath: keyPath]}, order)
    }

    /**
     An array of the elements sorted by the given keypath.

      - Parameters:
         - compare: The keypath to compare the elements.
         - order: The order of sorting.
      */
    func sorted<Value>(by keyPath: KeyPath<Element, Value?>, _ order: SortingOrder = .ascending) -> [Element] where Value: Comparable {
        sorted(by: { $0[keyPath: keyPath]}, order)
    }
    
    /**
     An array of the elements sorted by the given keypath.

      - Parameters:
        - keyPath: The keypath to compare the elements.
        - options: Options for comparing the key path strings.
        - range: The range of the string comparsion.
        - locale: The local of the string comparsion.
        - order: The order of sorting.
      */
    func sorted<Value>(by keyPath: KeyPath<Element, Value>, options: String.CompareOptions, range: Range<Value.Index>? = nil, locale: Locale? = nil, _ order: SortingOrder = .ascending) -> [Element] where Value: StringProtocol {
        sorted {
            $0[keyPath: keyPath].compare($1[keyPath: keyPath], options: options, range: range, locale: locale) == order.order
        }
    }
    
    /**
     An array of the elements sorted by the given keypath.

      - Parameters:
        - compare: The keypath to compare the elements.
        - options: Options for comparing the key path strings.
        - range: The range of the string comparsion.
        - locale: The local of the string comparsion.
        - order: The order of sorting.
      */
    func sorted<Value>(by keyPath: KeyPath<Element, Value?>, options: String.CompareOptions, range: Range<Value.Index>? = nil, locale: Locale? = nil, _ order: SortingOrder = .ascending) -> [Element] where Value: StringProtocol {
        sorted {
            switch ($0[keyPath: keyPath], $1[keyPath: keyPath]) {
            case let (a?, b?): return a.compare(b, options: options, range: range, locale: locale) == order.order
            case (_?, nil): return true
            default: return false
            }
        }
    }
}

public extension MutableCollection where Self: RandomAccessCollection & RangeReplaceableCollection {
    /**
      Sorts the collection by the given key path.

       - Parameters:
          - keyPath: The keypath to compare the elements.
          - order: The order of sorting.
     */
    mutating func sort<Value>(by keyPath: KeyPath<Element, Value>, _ order: SortingOrder = .ascending) where Value: Comparable {
        if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
            sort(using: KeyPathComparator(keyPath, order: order == .ascending ? .forward : .reverse))
        } else {
            sort(by: { $0[keyPath: keyPath] }, order)
        }
    }
    
    /**
      Sorts the collection by the given key path.

       - Parameters:
          - keyPath: The keypath to compare the elements.
          - order: The order of sorting.
     */
    mutating func sort<Value>(by keyPath: KeyPath<Element, Value?>, _ order: SortingOrder = .ascending) where Value: Comparable {
        if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
            sort(using: KeyPathComparator(keyPath, order: order == .ascending ? .forward : .reverse))
        } else {
            sort(by: { $0[keyPath: keyPath] }, order)
        }
    }
    
    /**
     Sorts the collection by the given key path.

      - Parameters:
        - keyPath: The keypath to compare the elements.
        - options: Options for comparing the key path strings.
        - range: The range of the string comparsion.
        - locale: The local of the string comparsion.
        - order: The order of sorting.
      */
    mutating func sort<Value>(by keyPath: KeyPath<Element, Value>, options: String.CompareOptions, range: Range<Value.Index>? = nil, locale: Locale? = nil,_ order: SortingOrder = .ascending) where Value: StringProtocol {
        sort {
            $0[keyPath: keyPath].compare($1[keyPath: keyPath], options: options, range: range, locale: locale) == order.order
        }
    }

    /**
     Sorts the collection by the given key path.

      - Parameters:
        - compare: The keypath to compare the elements.
        - options: Options for comparing the key path strings.
        - range: The range of the string comparsion.
        - locale: The local of the string comparsion.
        - order: The order of sorting.
      */
    mutating func sort<Value>(by keyPath: KeyPath<Element, Value?>, options: String.CompareOptions, range: Range<Value.Index>? = nil, locale: Locale? = nil, _ order: SortingOrder = .ascending) where Value: StringProtocol {
        sort {
            switch ($0[keyPath: keyPath], $1[keyPath: keyPath]) {
            case let (a?, b?): return a.compare(b, options: options, range: range, locale: locale) == order.order
            case (_?, nil): return true
            default: return false
            }
        }
    }
}

// MARK: - Sort by compare

public extension Sequence {
    /**
     An array of the elements sorted by the given predicate.

      - Parameters:
         - compare: A closure that provides a comparable value for each element in the sequence.
         - order: The order of sorting.
      */
    func sorted<Value>(by compare: (Element) throws -> Value, _ order: SortingOrder = .ascending) rethrows -> [Element] where Value: Comparable {
        try sorted { order == .ascending ? (try compare($0)) < (try compare($1)) : (try compare($0)) > (try compare($1)) }
    }

    /**
     An array of the elements sorted by the given predicate.

      - Parameters:
         - compare: A closure that provides a comparable value for each element in the sequence.
         - order: The order of sorting.
      */
    func sorted<Value>(by compare: (Element) throws -> Value?, _ order: SortingOrder = .ascending) rethrows -> [Element] where Value: Comparable {
        try sorted {
            switch (try compare($0), try compare($1)) {
            case let (x?, y?): return order == .ascending ? x < y : x > y
            case (nil, nil): return false
            case (nil, _): return false
            case (_, nil): return true
            }
        }
    }
}

public extension MutableCollection where Self: RandomAccessCollection & RangeReplaceableCollection {
    /**
     Sorts the collection in place, using the given predicate as the comparison between elements.
     
     - Parameters:
        - compare: A closure that extracts a comparable value from each element.
        - order: The sort order.
     */
    mutating func sort<Value>(by compare: (Element) throws -> Value, _ order: SortingOrder = .ascending) rethrows where Value: Comparable {
        try sort { order == .ascending ? (try compare($0)) < (try compare($1)) : (try compare($0)) > (try compare($1)) }
    }
    
    /**
     Sorts the collection in place, using the given predicate as the comparison between elements.
     
     - Parameters:
        - compare: A closure that extracts an optional comparable value from each element.
        - order: The sort order.
     */
    mutating func sort<Value>(by compare: (Element) throws -> Value?, _ order: SortingOrder = .ascending) rethrows where Value: Comparable {
        try sort {
            switch (try compare($0), try compare($1)) {
            case let (x?, y?): return order == .ascending ? x < y : x > y
            case (_?, nil): return true
            default: return false
            }
        }
    }
}

// MARK: - Sort by specifc order

public extension Sequence {
    /**
     Sorts the sequence according to the specified order of elements.

     Elements not present in the `order` array are sorted after explicitly ordered elements, preserving their original order.

     - Parameter order: An array specifying the desired order of elements.
     */
    func sorted(order: [Element]) -> [Element] where Element: Equatable {
        enumerated().sorted {
            (order.firstIndex(of: $0.element) ?? .max, $0.offset) <
            (order.firstIndex(of: $1.element) ?? .max, $1.offset)
        }.map(\.element)
    }

    /**
     Sorts the sequence according to the specified order of elements.

     Elements not present in the `order` array are sorted after explicitly ordered elements, preserving their original order.

     - Parameter order: An array specifying the desired order of elements.
     */
    func sorted(order: [Element]) -> [Element] where Element: Hashable {
        let orderMap = Dictionary(uniqueKeysWithValues: order.enumerated().map { ($1, $0) })
        return enumerated().sorted {
            (orderMap[$0.element] ?? .max, $0.offset) <
            (orderMap[$1.element] ?? .max, $1.offset)
        }.map(\.element)
    }
    
    /**
     Sorts the sequence based on the specified property and an array specifying the order of the property values.

     Elements whose key path values are not in the `order` array are sorted after explicitly ordered elements but before `nil` values.
     
     - Parameters:
        - keyPath: A key path to the property of each element to sort by.
        - order: An array specifying the desired order of key values.
     */
    func sorted<T: Equatable>(by keyPath: KeyPath<Element, T>, order: [T]) -> [Element] {
        map { (element: $0, rank: order.firstIndex(of: $0[keyPath: keyPath]) ?? .max) }.sorted(by: \.rank).map(\.element)
    }
    
    /**
     Sorts the sequence based on the specified property and an array specifying the order of the property values.

     - Elements with `nil` values for the specified key path are always sorted to the end.
     - Elements whose key path values are not in the `order` array are sorted after explicitly ordered elements but before `nil` values.
     
     - Parameters:
        - keyPath: A key path to the property of each element to sort by.
        - order: An array specifying the desired order of key path values.
     */
    func sorted<T: Equatable>(by keyPath: KeyPath<Element, T?>, order: [T]) -> [Element] {
        let ranked = enumerated().map { (offset: $0.offset, element: $0.element, rank: $0.element[keyPath: keyPath].flatMap { order.firstIndex(of: $0) } ?? ( $0.element[keyPath: keyPath] == nil ? Int.max : Int.max - 1 )) }
        return ranked.sorted { $0.rank != $1.rank ? $0.rank < $1.rank : $0.offset < $1.offset }.map(\.element)
    }
    
    /**
     Sorts the sequence based on the specified property and an array specifying the order of the property values.

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
     Sorts the sequence based on the specified property and an array specifying the order of the property values.
     
     - Elements with `nil` values for the specified key path are always sorted to the end.
     - Elements whose key path values are not in the `order` array are sorted after explicitly ordered elements but before `nil` values.
     
     - Parameters:
        - keyPath: A key path to the property of each element to sort by.
        - order: An array specifying the desired order of key values.
     */
    func sorted<T: Hashable>(by keyPath: KeyPath<Element, T?>, order: [T]) -> [Element] {
        let orderMap = Dictionary(uniqueKeysWithValues: order.enumerated().map { ($1, $0) })
        return enumerated().sorted {
            let lhsIndex = $0.element[keyPath: keyPath].flatMap { orderMap[$0] } ?? ( $0.element[keyPath: keyPath] == nil ? Int.max : Int.max - 1 )
            let rhsIndex = $1.element[keyPath: keyPath].flatMap { orderMap[$0] } ?? ( $1.element[keyPath: keyPath] == nil ? Int.max : Int.max - 1 )
            return lhsIndex != rhsIndex ? lhsIndex < rhsIndex : $0.offset < $1.offset
        }.map(\.element)
    }
}

public extension MutableCollection where Self: RandomAccessCollection & RangeReplaceableCollection {
    /**
     Sorts the collection in place according to the specified order of elements.

     Elements not present in the `order` array are sorted after explicitly ordered elements, preserving their original order.

     - Parameter order: An array specifying the desired order of elements.
     */
    mutating func sort(order: [Element]) where Element: Equatable {
        self = .init(sorted(order: order))
    }
    
    /**
     Sorts the collection in place according to the specified order of elements.

     Elements not present in the `order` array are sorted after explicitly ordered elements, preserving their original order.

     - Parameter order: An array specifying the desired order of elements.
     */
    mutating func sort(order: [Element]) where Element: Hashable {
        self = .init(sorted(order: order))
    }
    
    /**
     Sorts the collection in place based on the specified property and an array specifying the order of property values.

     Elements whose key path values are not in the `order` array are sorted after explicitly ordered elements but before `nil` values.
     
     - Parameters:
        - keyPath: A key path to the property of each element to sort by.
        - order: An array specifying the desired order of key values.
     */
    mutating func sort<T: Equatable>(by keyPath: KeyPath<Element, T>, order: [T]) {
        self = .init(sorted(by: keyPath, order: order))
    }
    
    /**
     Sorts the collection in place based on the specified property and an array specifying the order of property values.
     
     - Elements with `nil` values for the specified key path are always sorted to the end.
     - Elements whose key path values are not in the `order` array are sorted after explicitly ordered elements but before `nil` values.
     
     - Parameters:
        - keyPath: A key path to the property of each element to sort by.
        - order: An array specifying the desired order of key path values.
     */
    mutating func sort<T: Equatable>(by keyPath: KeyPath<Element, T?>, order: [T]) {
        self = .init(sorted(by: keyPath, order: order))
    }
    
    /**
     Sorts the collection in place based on the specified property and an array specifying the order of property values.

     Elements whose key path values are not in the `order` array are sorted after explicitly ordered elements but before `nil` values.
     
     - Parameters:
        - keyPath: A key path to the property of each element to sort by.
        - order: An array specifying the desired order of key values.
     */
    mutating func sort<T: Hashable>(by keyPath: KeyPath<Element, T>, order: [T]) {
        self = .init(sorted(by: keyPath, order: order))
    }
    
    /**
     Sorts the collection in place based on the specified property and an array specifying the order of property values.

     - Elements with `nil` values for the specified key path are always sorted to the end.
     - Elements whose key path values are not in the `order` array are sorted after explicitly ordered elements but before `nil` values.
     
     - Parameters:
        - keyPath: A key path to the property of each element to sort by.
        - order: An array specifying the desired order of key values.
     */
    mutating func sort<T: Hashable>(by keyPath: KeyPath<Element, T?>, order: [T]) {
        self = .init(sorted(by: keyPath, order: order))
    }
}

/// The orderings that you can perform sorts with.
public enum SortingOrder: Int, Hashable, Codable {
    /// An ascending sorting order.
    case ascending
    /// A descending sorting order.
    case descending
    
    /// Toggles the sort order.
    public mutating func toggle() {
        self = (self == .ascending) ? .descending : .ascending
    }
    
    /// An ascending sorting order.
    public static let oldestFirst = SortingOrder.ascending
    /// A descending sorting order.
    public static let newestFirst = SortingOrder.descending
    
    /// An ascending sorting order.
    public static let smallestFirst = SortingOrder.ascending
    /// A descending sorting order.
    public static let largestFirst = SortingOrder.descending
    
    /// An ascending sorting order.
    public static let shortestFirst = SortingOrder.ascending
    /// A descending sorting order.
    public static let longestFirst = SortingOrder.descending
    
    var order: ComparisonResult {
        self == .ascending ? .orderedAscending : .orderedDescending
    }
}
