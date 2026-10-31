//
//  Sequence+Sort.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import Foundation

public extension Sequence {
    /// Returns the elements of the sequence, sorted by the specified order.
    func sorted(_ order: SortOrder) -> [Element] where Element: Comparable {
        return order == .ascending ? sorted() : sorted(by: >)
    }

    /// Returns the elements of the sequence, sorted by the specified order.
    func sorted(_ order: SortOrder = .ascending) -> [Element] where Element: OptionalProtocol, Element.Wrapped: Comparable {
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
    mutating func sort(_ order: SortOrder) {
        if order == .ascending {
            sort()
        } else {
            sort(by: >)
        }
    }

    /// Sorts the collection in place by the specified order.
    mutating func sort(_ order: SortOrder = .ascending) where Element: OptionalProtocol, Element.Wrapped: Comparable {
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
    func sorted<Value: Comparable>(by keyPath: KeyPath<Element, Value>, _ order: SortOrder = .ascending) -> [Element] {
        sorted(by: { $0[keyPath: keyPath] }, order)
    }

    /**
     An array of the elements sorted by the given keypath.

      - Parameters:
         - compare: The keypath to compare the elements.
         - order: The order of sorting.
      */
    func sorted<Value: Comparable>(by keyPath: KeyPath<Element, Value?>, _ order: SortOrder = .ascending) -> [Element] {
        sorted(by: { $0[keyPath: keyPath] }, order)
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
    func sorted<Value: StringProtocol>(by keyPath: KeyPath<Element, Value>, options: String.CompareOptions, range: Range<Value.Index>? = nil, locale: Locale? = nil, _ order: SortOrder = .ascending) -> [Element] {
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
    func sorted<Value: StringProtocol>(by keyPath: KeyPath<Element, Value?>, options: String.CompareOptions, range: Range<Value.Index>? = nil, locale: Locale? = nil, _ order: SortOrder = .ascending) -> [Element] {
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
    mutating func sort<Value: Comparable>(by keyPath: KeyPath<Element, Value>, _ order: SortOrder = .ascending) {
        sort(using: KeyPathComparator(keyPath, order: order == .ascending ? .forward : .reverse))
    }

    /**
      Sorts the collection by the given key path.

       - Parameters:
          - keyPath: The keypath to compare the elements.
          - order: The order of sorting.
     */
    mutating func sort<Value: Comparable>(by keyPath: KeyPath<Element, Value?>, _ order: SortOrder = .ascending) {
        sort(using: KeyPathComparator(keyPath, order: order == .ascending ? .forward : .reverse))
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
    mutating func sort<Value: StringProtocol>(by keyPath: KeyPath<Element, Value>, options: String.CompareOptions, range: Range<Value.Index>? = nil, locale: Locale? = nil, _ order: SortOrder = .ascending) {
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
    mutating func sort<Value: StringProtocol>(by keyPath: KeyPath<Element, Value?>, options: String.CompareOptions, range: Range<Value.Index>? = nil, locale: Locale? = nil, _ order: SortOrder = .ascending) {
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
    func sorted<Value: Comparable>(by compare: (Element) throws -> Value, _ order: SortOrder = .ascending) rethrows -> [Element] {
        try sorted { try order == .ascending ? compare($0) < compare($1) : compare($0) > compare($1) }
    }

    /**
     An array of the elements sorted by the given predicate.

      - Parameters:
         - compare: A closure that provides a comparable value for each element in the sequence.
         - order: The order of sorting.
      */
    func sorted<Value: Comparable>(by compare: (Element) throws -> Value?, _ order: SortOrder = .ascending) rethrows -> [Element] {
        try sorted {
            switch try (compare($0), compare($1)) {
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
    mutating func sort<Value: Comparable>(by compare: (Element) throws -> Value, _ order: SortOrder = .ascending) rethrows {
        try sort { try order == .ascending ? compare($0) < compare($1) : compare($0) > compare($1) }
    }

    /**
     Sorts the collection in place, using the given predicate as the comparison between elements.

     - Parameters:
        - compare: A closure that extracts an optional comparable value from each element.
        - order: The sort order.
     */
    mutating func sort<Value: Comparable>(by compare: (Element) throws -> Value?, _ order: SortOrder = .ascending) rethrows {
        try sort {
            switch try (compare($0), compare($1)) {
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
        let ranked = enumerated().map { (offset: $0.offset, element: $0.element, rank: $0.element[keyPath: keyPath].flatMap { order.firstIndex(of: $0) } ?? ($0.element[keyPath: keyPath] == nil ? Int.max : Int.max - 1)) }
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
            let lhsIndex = $0.element[keyPath: keyPath].flatMap { orderMap[$0] } ?? ($0.element[keyPath: keyPath] == nil ? Int.max : Int.max - 1)
            let rhsIndex = $1.element[keyPath: keyPath].flatMap { orderMap[$0] } ?? ($1.element[keyPath: keyPath] == nil ? Int.max : Int.max - 1)
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

extension Sequence where Element: StringProtocol {
    /**
     Returns the elements of the sequence sorted using the specified string comparison options.

     - Parameters:
        - options: The options to use when comparing elements.
        - range: The range of each element to compare, or `nil` to compare the full element.
        - locale: The locale to use for the comparison.
        - order: The sort order.
     - Returns: The elements of the sequence sorted in ascending order.
     */
    func sorted(options: String.CompareOptions, range: Range<Element.Index>? = nil, locale: Locale? = nil, _ order: SortOrder = .ascending) -> [Element] {
        sorted { $0.compare($1, options: options, range: range, locale: locale) == order.order }
    }
}

extension Sequence where Element: OptionalProtocol, Element.Wrapped: StringProtocol {
    /**
     Returns the elements of the sequence sorted using the specified string comparison options.

     - Parameters:
        - options: The options to use when comparing elements.
        - range: The range of each element to compare, or `nil` to compare the full element.
        - locale: The locale to use for the comparison.
        - order: The sort order.
     - Returns: The elements of the sequence sorted in ascending order.
     */
    func sorted(options: String.CompareOptions, range: Range<Element.Wrapped.Index>? = nil, locale: Locale? = nil, _ order: SortOrder = .ascending) -> [Element] {
        sorted { lhs, rhs in
            switch (lhs.optional, rhs.optional) {
            case let (a?, b?):
                return a.compare(b, options: options, range: range, locale: locale) == order.order
            case (_?, nil): return true
            default: return false
            }
        }
    }
}

public extension Sequence {
    /**
     Returns the elements of the sequence, sorted by the frequency of the values at the specified key path.

     Elements whose property values occur more frequently appear first by default.

     - Parameters:
       - keyPath: The key path to a hashable property of each element.
       - mostFrequentFirst: Whether elements with more frequently occurring values appear first.
     - Returns: An array containing the elements sorted by the frequency of their property values.
     */
    func sortedByFrequency<Value: Hashable>(of keyPath: KeyPath<Element, Value>, mostFrequentFirst: Bool = true) -> [Element] {
        sortedByFrequency(by: { $0[keyPath: keyPath] }, mostFrequentFirst: mostFrequentFirst)
    }

    /**
     Returns the elements of the sequence, sorted by the frequency of the values produced by the given transformation.

     The transformation is evaluated once for each element. Elements whose transformed values occur more frequently appear first by default.

     - Parameters:
       - transform: A closure that produces a hashable value for each element.
       - mostFrequentFirst: Whether elements with more frequently occurring values appear first.
     - Returns: An array containing the elements sorted by the frequency of their transformed values.
     - Throws: An error if the transformation throws.
     */
    func sortedByFrequency<Value: Hashable>(by transform: (Element) throws -> Value, mostFrequentFirst: Bool = true) rethrows -> [Element] {
        var counts: [Value: [Element]] = [:]
        for element in self {
            try counts[transform(element), default: []].append(element)
        }
        return counts.values.sorted(by: \.count, mostFrequentFirst ? .descending : .ascending).flattened()
    }
}
