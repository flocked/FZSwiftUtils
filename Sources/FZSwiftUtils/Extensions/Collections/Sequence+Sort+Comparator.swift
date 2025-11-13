//
//  Sequence+Sort+Comparator.swift
//
//
//  Created by Florian Zand on 07.11.25.
//

import Foundation

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
        - order: The order of sorting.
     */
    public func sorted(by comparators: [SortingComparator<Element>], order: SortingOrder = .ascending) -> [Element] {
        sorted {
            for comparator in comparators {
                switch comparator.compare($0, $1) {
                case .orderedAscending: return order == .ascending ? true : false
                case .orderedDescending: return order == .ascending ? false : true
                case .orderedSame: continue
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
        - order: The order of sorting.
     */
    public func sorted(by comparators: SortingComparator<Element>..., order: SortingOrder = .ascending) -> [Element] {
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
                case .orderedAscending: return order == .ascending
                case .orderedDescending: return order == .descending
                case .orderedSame: continue
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
     Sorts the collection using the given comparators to compare elements.
     
     - Parameters:
        - comparators: The sort comparators used to compare elements.
        - order: The order of sorting.
     */
    mutating func sort(by comparators: [SortingComparator<Element>], order: SortingOrder = .ascending) {
        sort {
            for sorting in comparators {
                switch sorting.compare($0, $1) {
                case .orderedAscending: return order == .ascending
                case .orderedDescending: return order == .descending
                case .orderedSame: continue
                }
            }
            return false
        }
    }
    
    /**
     Sorts the collection using the given comparators to compare elements.

     - Parameters:
        - comparators: The sort comparators used to compare elements.
        - order: The order of sorting.
     */
    mutating func sort(by comparators: SortingComparator<Element>..., order: SortingOrder = .ascending) {
        sort(by: comparators)
    }
    
    /**
     Sorts the collection using the given comparators to compare elements.

     - Parameters:
        - comparators: The sort comparators used to compare elements.
        - order: The order of sorting. The default value is `forward`.
     */
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    mutating func sort(by comparators: [any SortComparator<Element>], _ order: SortOrder = .forward) {
        sort {
            for sorting in comparators {
                switch sorting.compare($0, $1) {
                case .orderedAscending: return order == .ascending
                case .orderedDescending: return order == .descending
                case .orderedSame: continue
                }
            }
            return false
        }
    }
    
    /**
     Sorts the collection using the given comparators to compare elements.

     - Parameters:
        - comparators: The sort comparators used to compare elements.
        - order: The order of sorting. The default value is `forward`.
     */
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    mutating func sort(by comparators: any SortComparator<Element>..., order: SortOrder = .forward) {
        sort(by: comparators, order)
    }
}

/**
 A comparison algorithm for a specified type.
 
 To sort a sequence, use ``Swift/Sequence/sorted(by:order:)-([SortingComparator<Element>],_)``.
 */
public struct SortingComparator<Compared> {
    private let typeID: String
    private let comparator: (_ lhs: Compared, _ rhs: Compared) -> ComparisonResult
    
    /// The sort order that the comparator uses to compare.
    public var order: SortingOrder

    /// Provides the relative ordering of two elements based on the sort order of the comparator.
    public func compare(_ lhs: Compared, _ rhs: Compared) -> ComparisonResult {
        switch comparator(lhs, rhs) {
        case .orderedSame: return .orderedSame
        case .orderedAscending: return order == .ascending ? .orderedAscending : .orderedDescending
        case .orderedDescending: return order == .ascending ? .orderedDescending : .orderedAscending
        }
    }

    // MARK: - Initializers

    init(typeID: String, order: SortingOrder = .ascending, comparator: @escaping (_ lhs: Compared, _ rhs: Compared) -> ComparisonResult) {
        self.comparator = comparator
        self.order = order
        self.typeID = typeID
    }

    init<Value>(typeID: String, order: SortingOrder = .ascending, compare: @escaping (Compared) -> Value) where Value: Comparable {
        self.order = order
        self.typeID = typeID
        self.comparator = { lhs, rhs in
            let lhsValue = compare(lhs)
            let rhsValue = compare(rhs)
            if lhsValue < rhsValue { return .orderedAscending }
            if lhsValue > rhsValue { return .orderedDescending }
            return .orderedSame
        }
    }

    init<Value>(typeID: String, order: SortingOrder = .ascending, compare: @escaping (Compared) -> Value?) where Value: Comparable {
        self.order = order
        self.typeID = typeID
        self.comparator = { lhs, rhs in
            let lhsValue = compare(lhs)
            let rhsValue = compare(rhs)
            switch (lhsValue, rhsValue) {
            case let (l?, r?):
                if l < r { return .orderedAscending }
                if l > r { return .orderedDescending }
                return .orderedSame
            case (nil, nil): return .orderedSame
            case (nil, _): return .orderedAscending
            case (_, nil): return .orderedDescending
            }
        }
    }

    /// A key path sort comparator that sorts in a ascending order.
    public static func ascending<T: Comparable>(_ keyPath: KeyPath<Compared, T>) -> Self {
        .init(typeID: "KeyPathComparator(\(keyPath.stringValue))", compare: { $0[keyPath: keyPath] })
    }

    /// A key path sort comparator that sorts in a descending order.
    public static func descending<T: Comparable>(_ keyPath: KeyPath<Compared, T>) -> Self {
        .init(typeID: "KeyPathComparator(\(keyPath.stringValue))", order: .descending, compare: { $0[keyPath: keyPath] })
    }

    /// A key path sort comparator that sorts in a ascending order.
    public static func ascending<T: Comparable>(_ keyPath: KeyPath<Compared, T?>) -> Self {
        .init(typeID: "KeyPathComparator(\(keyPath.stringValue))", compare: { $0[keyPath: keyPath] })
    }

    /// A key path sort comparator that sorts in a descending order.
    public static func descending<T: Comparable>(_ keyPath: KeyPath<Compared, T?>) -> Self {
        .init(typeID: "KeyPathComparator(\(keyPath.stringValue))", order: .descending, compare: { $0[keyPath: keyPath] })
    }

    /// A comparator that sorts by the specified compare block.
    public static func compare(_ comparator: @escaping ((Compared, Compared) -> ComparisonResult)) -> Self {
        .init(typeID: "CustomComparator", comparator: comparator)
    }

    /// A comparator that sorts by the specified compare block.
    public static func compare<Value: Comparable>(_ compare: @escaping ((Compared) -> Value)) -> Self {
        .init(typeID: "CustomComparator", compare: compare)
    }

    /// A comparator that sorts by the specified compare block.
    public static func compare<Value: Comparable>(_ compare: @escaping ((Compared) -> Value?)) -> Self {
        .init(typeID: "CustomComparator", compare: compare)
    }

    /**
     A comparator that sorts by the string value of the specified property.
     
     - Parameters:
       - keyPath: The key path to the string property to compare.
       - options: Options for string comparison.
       - range: The range of the string to compare.
       - locale: The locale to use for comparison.
     */
    public static func stringCompare<T>(_ keyPath: KeyPath<Compared, T>,
                                        options: String.CompareOptions,
                                        range: Range<T.Index>? = nil,
                                        locale: Locale? = nil) -> Self where T: StringProtocol {
        .init(typeID: "StringKeyPathComparator(\(keyPath.stringValue), options: \(options), range: \(range.map { "\($0)" } ?? "nil"), locale: \(locale?.identifier ?? "nil"))") {
            $0[keyPath: keyPath].compare($1[keyPath: keyPath], options: options, range: range, locale: locale)
        }
    }

    /**
     A comparator that sorts by the string value of the specified property.
     
     - Parameters:
       - keyPath: The key path to the string property to compare.
       - options: Options for string comparison.
       - range: The range of the string to compare.
       - locale: The locale to use for comparison.
     */
    public static func stringCompare<T>(_ keyPath: KeyPath<Compared, T>,
                                        options: String.CompareOptions,
                                        range: Range<T.Wrapped.Index>? = nil,
                                        locale: Locale? = nil) -> Self where T: OptionalProtocol, T.Wrapped: StringProtocol {
        .init(typeID: "StringKeyPathComparator(\(keyPath.stringValue), options: \(options), range: \(range.map { "\($0)" } ?? "nil"), locale: \(locale?.identifier ?? "nil"))") {
            switch ($0[keyPath: keyPath].optional, $1[keyPath: keyPath].optional) {
            case let (a?, b?): return a.compare(b, options: options, range: range, locale: locale)
            case (nil, nil): return .orderedSame
            case (nil, _): return .orderedAscending
            case (_, nil): return .orderedDescending
            }
        }
    }
}

extension SortingComparator: Hashable, CustomStringConvertible {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(typeID)
        hasher.combine(order)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.typeID == rhs.typeID && lhs.order == rhs.order
    }
    
    public var description: String {
        typeID
    }
}

extension SortingComparator where Compared: Comparable {
    /// A comparator that sorts in an ascending order.
    public static var ascending: Self { .init(typeID: "ComparableComparator") { $0 } }
    
    /// A comparator that sorts in an descending order.
    public static var descending: Self { .init(typeID: "ComparableComparator", order: .descending) { $0 } }
}

extension SortingComparator where Compared: StringProtocol {
    /**
     A comparator that sorts the string values by the specified string comparison options.
     
     - Parameters:
       - options: Options for string comparison.
       - range: The range of the string to compare.
       - locale: The locale to use for comparison.
       - order: The sorting order.
     */
    public static func stringCompare(options: String.CompareOptions = [],
                                     range: Range<String.Index>? = nil,
                                     locale: Locale? = nil) -> Self {
        .init(typeID: "StringComparator(options: \(options), range: \(range.map { "\($0)" } ?? "nil"), locale: \(locale?.identifier ?? "nil"))") { $0.compare($1, options: options, range: range, locale: locale) }
    }
}

extension SortingComparator where Compared: OptionalProtocol, Compared.Wrapped: StringProtocol {
    /**
     A comparator that sorts the string values by the specified string comparison options.
     
     - Parameters:
       - options: Options for string comparison.
       - range: The range of the string to compare.
       - locale: The locale to use for comparison.
       - order: The sorting order.
     */
    public static func stringCompare(options: String.CompareOptions = [],
                                     range: Range<String.Index>? = nil,
                                     locale: Locale? = nil) -> Self {
        .init(typeID: "StringComparator(options: \(options), range: \(range.map { "\($0)" } ?? "nil"), locale: \(locale?.identifier ?? "nil"))") {
            switch ($0.optional, $1.optional) {
            case let (a?, b?): return a.compare(b, options: options, range: range, locale: locale)
            case (nil, nil): return .orderedSame
            case (nil, _): return .orderedAscending
            case (_, nil): return .orderedDescending
            }
        }
    }
}

/// A key path sort comparator that sorts in an ascending order.
public prefix func << <Element, T: Comparable>(keyPath: KeyPath<Element, T>) -> SortingComparator<Element> {
    .ascending(keyPath)
}

/// A key path sort comparator that sorts in an ascending order.
public prefix func << <Element, T: Comparable>(keyPath: KeyPath<Element, T?>) -> SortingComparator<Element> {
    .ascending(keyPath)
}

/// A key path sort comparator that sorts in a descending order.
public prefix func >> <Element, T: Comparable>(keyPath: KeyPath<Element, T>) -> SortingComparator<Element> {
    .descending(keyPath)
}

/// A key path sort comparator that sorts in a descending order.
public prefix func >> <Element, T: Comparable>(keyPath: KeyPath<Element, T?>) -> SortingComparator<Element> {
    .descending(keyPath)
}
