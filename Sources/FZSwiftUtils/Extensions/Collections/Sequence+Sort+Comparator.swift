//
//  Sequence+Sort+Comparator.swift
//
//
//  Created by Florian Zand on 07.11.25.
//

import Foundation

extension Sequence {
    /**
     Returns the elements of the sequence, sorted using the given comparator and order to compare elements.
     
     - Parameters:
        - comparator: The comparator to use in ordering elements
        - order: The sort order that the comparator uses to compare.
     - Returns: An array of the elements sorted using `comparator`.
     */
    public func sorted<Comparator: SortComparator<Element>>(using comparator: Comparator, _ order: SortOrder) -> [Element] {
        var comparator = comparator
        comparator.order = order
        return sorted(using: comparator)
    }
    
    /**
     Returns the elements, sorted using the given comparators to compare elements.

     - Parameters:
        - comparators: The sort comparators used to compare elements.
        - order: The order of sorting. The default value is `forward`.
     */
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public func sorted(using comparators: [any SortComparator<Element>], order: SortOrder = .forward) -> [Element] {
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
    
    /*
    /**
     Returns the elements, sorted using the given comparators to compare elements.

     - Parameters:
        - comparators: The sort comparators used to compare elements.
        - order: The order of sorting. The default value is `forward`.
     */
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public func sorted(using comparators: any SortComparator<Element>..., order: SortOrder = .forward) -> [Element] {
        sorted(using: comparators, order: order)
    }
    */
}

public extension MutableCollection where Self: RandomAccessCollection & RangeReplaceableCollection {
    /**
     Sorts the collection using the given comparator and sort order to compare elements.

     - Parameters:
        - comparator: The sort comparator used to compare elements.
        - order: The sort order that the comparator uses to compare.
     */
    mutating func sort<Comparator: SortComparator<Element>>(using comparator: Comparator, _ order: SortOrder) {
        var comparator = comparator
        comparator.order = order
        sort(using: comparator)
    }
    
    /**
     Sorts the collection using the given comparators to compare elements.

     - Parameters:
        - comparators: The sort comparators used to compare elements.
        - order: The order of sorting. The default value is `forward`.
     */
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    mutating func sort(using comparators: [any SortComparator<Element>], _ order: SortOrder = .forward) {
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
    
    /*
    /**
     Sorts the collection using the given comparators to compare elements.

     - Parameters:
        - comparators: The sort comparators used to compare elements.
        - order: The order of sorting. The default value is `forward`.
     */
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    mutating func sort(using comparators: any SortComparator<Element>..., order: SortOrder = .forward) {
        sort(using: comparators, order)
    }
    */
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
        - order: The order of sorting.
     */
    public func sorted(by comparators: [SortingComparator<Element>], order: SortOrder = .ascending) -> [Element] {
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
    
    /*
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
    public func sorted(by comparators: SortingComparator<Element>..., order: SortOrder = .ascending) -> [Element] {
        sorted(by: comparators, order: order)
    }
     */
}

public extension MutableCollection where Self: RandomAccessCollection & RangeReplaceableCollection {
    /**
     Sorts the collection using the given comparators to compare elements.
     
     - Parameters:
        - comparators: The sort comparators used to compare elements.
        - order: The order of sorting.
     */
    mutating func sort(by comparators: [SortingComparator<Element>], order: SortOrder = .ascending) {
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
    
    /*
    /**
     Sorts the collection using the given comparators to compare elements.

     - Parameters:
        - comparators: The sort comparators used to compare elements.
        - order: The order of sorting.
     */
    mutating func sort(by comparators: SortingComparator<Element>..., order: SortOrder = .ascending) {
        sort(by: comparators)
    }
     */
}

/**
 A comparison algorithm for a specified type.
 
 To sort a sequence, use ``Swift/Sequence/sorted(by:order:)-([SortingComparator<Element>],_)``.
 */
public struct SortingComparator<Compared>: Hashable {
    private let comparator: (_ lhs: Compared, _ rhs: Compared) -> ComparisonResult
    private let comparatorHash: Int
    
    /// The sort order that the comparator uses to compare.
    public var order: SortOrder
    
    private init(_ comparator: any SortComparator<Compared>) {
        self.order = comparator.order
        self.comparatorHash = comparator.hashValue
        self.comparator = { comparator.compare($0, $1) }
    }
    
    @_disfavoredOverload
    private init(_ comparator: any SortComparator<Compared.Wrapped>) where Compared: OptionalProtocol {
        self.init(ComparisonComparator(order: .forward) {
            switch ($0.optional, $1.optional) {
            case let (a?, b?): return comparator.compare(a, b)
            case (nil, nil): return .orderedSame
            case (nil, _): return .orderedAscending
            case (_, nil): return  .orderedDescending
            }
        })
    }
    
    /// Provides the relative ordering of two elements based on the sort order of the comparator.
    public func compare(_ lhs: Compared, _ rhs: Compared) -> ComparisonResult {
        comparator(lhs, rhs)
    }
    
    // MARK: - Comparing using properties
    
    /// A comparator that uses the specified sort comparator to provide the comparison of values at the specified key path.
    public static func ascending<Value, Comparator: SortComparator<Value>>(_ keyPath: KeyPath<Compared, Value>, comparator: Comparator) -> Self {
        .init(KeyPathComparator(keyPath, comparator: comparator, order: .forward))
    }
    
    /// A comparator that uses the specified sort comparator to provide the comparison of values at the specified key path.
    public static func ascending<Value, Comparator: SortComparator<Value>>(_ keyPath: KeyPath<Compared, Value?>, comparator: Comparator) -> Self {
        .init(KeyPathComparator(keyPath, comparator: comparator, order: .forward))
    }

    /// A comparator that uses the specified sort comparator to provide the comparison of values at the specified key path.
    public static func ascending<Value: Comparable>(_ keyPath: KeyPath<Compared, Value>) -> Self {
        .init(KeyPathComparator(keyPath, order: .forward))
    }
    
    /// A comparator that uses the specified sort comparator to provide the comparison of values at the specified key path.
    public static func ascending<Value: Comparable>(_ keyPath: KeyPath<Compared, Value?>) -> Self {
        .init(KeyPathComparator(keyPath, order: .forward))
    }
    
    /// A comparator that uses the specified sort comparator to provide the comparison of values at the specified key path.
    public static func descending<Value, Comparator: SortComparator<Value>>(_ keyPath: KeyPath<Compared, Value>, comparator: Comparator) -> Self {
        .init(KeyPathComparator(keyPath, comparator: comparator, order: .reverse))
    }
    
    /// A comparator that uses the specified sort comparator to provide the comparison of values at the specified key path.
    public static func descending<Value, Comparator: SortComparator<Value>>(_ keyPath: KeyPath<Compared, Value?>, comparator: Comparator) -> Self {
        .init(KeyPathComparator(keyPath, comparator: comparator, order: .reverse))
    }

    /// A comparator that uses the specified sort comparator to provide the comparison of values at the specified key path.
    public static func descending<Value: Comparable>(_ keyPath: KeyPath<Compared, Value>) -> Self {
        .init(KeyPathComparator(keyPath, order: .reverse))
    }
    
    /// A comparator that uses the specified sort comparator to provide the comparison of values at the specified key path.
    public static func descending<Value: Comparable>(_ keyPath: KeyPath<Compared, Value?>) -> Self {
        .init(KeyPathComparator(keyPath, order: .reverse))
    }
    
    // MARK: - Comparing using String properties
    
    /// A comparator that uses the specified string comparsion optons to provide the comparison of strings at the specified key path.
    public static func ascending(_ keyPath: KeyPath<Compared, String>, options: String.CompareOptions, locale: Locale? = nil) -> Self {
        .init(KeyPathComparator(keyPath, comparator: String.Comparator(options: options, locale: locale, order: .forward)))
    }
    
    /// A comparator that uses the specified string comparsion optons to provide the comparison of strings at the specified key path.
    public static func ascending(_ keyPath: KeyPath<Compared, String?>, options: String.CompareOptions, locale: Locale? = nil) -> Self {
        .init(KeyPathComparator(keyPath, comparator: String.Comparator(options: options, locale: locale, order: .forward)))
    }
    
    /// A comparator that uses the specified string comparsion optons to provide the comparison of strings at the specified key path.
    public static func descending(_ keyPath: KeyPath<Compared, String>, options: String.CompareOptions, locale: Locale? = nil) -> Self {
        .init(KeyPathComparator(keyPath, comparator: String.Comparator(options: options, locale: locale, order: .reverse)))
    }
    
    /// A comparator that uses the specified string comparsion optons to provide the comparison of strings at the specified key path.
    public static func descending(_ keyPath: KeyPath<Compared, String?>, options: String.CompareOptions, locale: Locale? = nil) -> Self {
        .init(KeyPathComparator(keyPath, comparator: String.Comparator(options: options, locale: locale, order: .reverse)))
    }
    
    /// A comparator that compares using the specified block.
    public static func compare(_ comparator: @escaping ((_ lhs: Compared, _ rhs: Compared) -> ComparisonResult), order: SortOrder = .forward) -> Self {
        Self(ComparisonComparator(order: order, handler: comparator))
    }
    
    /// A comparator that compares using the specified comparator.
    public static func compare<Comparator: SortComparator<Compared>>(_ comparator: Comparator, order: SortOrder = .forward) -> Self {
        var comparator = comparator
        comparator.order = order
        return Self(comparator)
    }
    
    /// A comparator that compares using the specified comparator.
    public static func compare<Comparator: SortComparator<Compared>>(_ comparator: Comparator, order: SortOrder = .forward) -> Self where Compared: OptionalProtocol {
        var comparator = comparator
        comparator.order = order
        return Self(comparator)
    }
    
    /// A comparator that compares the values provided by the specified block for each element.
    public static func compare<Value: Comparable>(_ handler: @escaping (_ lhs: Compared)->Value, order: SortOrder = .forward) -> Self {
        Self(ComparisonComparator(order: order, handler: handler))
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(comparatorHash)
        hasher.combine(order)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue  == rhs.hashValue
    }
}

extension SortingComparator where Compared: Comparable {
    /// A comparator that compares types according to their conformance to the comparable protocol.
    public static var ascending: Self { Self(ComparisonComparator.ascending) }
    /// A comparator that compares types according to their conformance to the comparable protocol.
    public static var descending: Self { Self(ComparisonComparator.descending) }
}

extension SortingComparator where Compared: OptionalProtocol, Compared.Wrapped: Comparable {
    /// A comparator that compares types according to their conformance to the comparable protocol.
    public static var ascending: Self { Self(ComparisonComparator.ascending) }
    /// A comparator that compares types according to their conformance to the comparable protocol.
    public static var descending: Self { Self(ComparisonComparator.descending) }
}

extension SortingComparator where Compared == String {
    public static var lexical: Self { Self(.lexical) }
    ///  A comparator that compares a string using a localized comparison in the current locale.
    public static var localized: Self { Self(.localized) }
    ///  A comparator that compares a string using a localized comparison in the specified locale.
    public static func localized(using locale: Locale) -> Self { Self(.localized(using: locale)) }
    /// A comparator that compares a string using a localized, numeric comparison in the current locale.
    public static var localizedStandard: Self { Self(.localizedStandard) }
    /// A comparator that compares a string using a localized, numeric comparison in the specified locale.
    public static func localizedStandard(using locale: Locale) -> Self { Self(.localizedStandard(using: locale)) }
    ///  A comparator that compares a string using a case-insensitive comparison.
    public static var caseInsensitive: Self { Self(.caseInsensitive) }
    ///  A comparator that compares a string using a localized, case-insensitive comparison in the current locale.
    public static var localizedCaseInsensitive: Self { Self(.localizedCaseInsensitive) }
    ///  A comparator that compares a string using a localized, case-insensitive comparison in the specified locale.
    public static func localizedCaseInsensitive(using locale: Locale) -> Self { Self(.localizedCaseInsensitive(using: locale)) }
    public static func options(_ options: String.CompareOptions, locale: Locale? = nil, order: SortOrder = .forward) -> Self {
        Self(String.Comparator(options: options, locale: locale, order: order))
    }
}

extension SortingComparator where Compared: OptionalProtocol, Compared.Wrapped == String {
    public static var lexical: Self { Self(.lexical) }
    ///  A comparator that compares a string using a localized comparison in the current locale.
    public static var localized: Self { Self(.localized) }
    ///  A comparator that compares a string using a localized comparison in the specified locale.
    public static func localized(using locale: Locale) -> Self { Self(.localized(using: locale)) }
    /// A comparator that compares a string using a localized, numeric comparison in the current locale.
    public static var localizedStandard: Self { Self(.localizedStandard) }
    /// A comparator that compares a string using a localized, numeric comparison in the specified locale.
    public static func localizedStandard(using locale: Locale) -> Self { Self(.localizedStandard(using: locale)) }
    ///  A comparator that compares a string using a case-insensitive comparison.
    public static var caseInsensitive: Self { Self(.caseInsensitive) }
    ///  A comparator that compares a string using a localized, case-insensitive comparison in the current locale.
    public static var localizedCaseInsensitive: Self { Self(.localizedCaseInsensitive) }
    ///  A comparator that compares a string using a localized, case-insensitive comparison in the specified locale.
    public static func localizedCaseInsensitive(using locale: Locale) -> Self { Self(.localizedCaseInsensitive(using: locale)) }
    public static func options(_ options: String.CompareOptions, locale: Locale? = nil, order: SortOrder = .forward) -> Self {
        Self(String.Comparator(options: options, locale: locale, order: order))
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

/*
/**
 A comparison algorithm for a specified type.
 
 To sort a sequence, use ``Swift/Sequence/sorted(by:order:)-([SortingComparator<Element>],_)``.
 */
public struct SortingComparator<Compared> {
    private let typeID: String
    private let comparator: (_ lhs: Compared, _ rhs: Compared) -> ComparisonResult
    
    /// The sort order that the comparator uses to compare.
    public var order: SortOrder

    /// Provides the relative ordering of two elements based on the sort order of the comparator.
    public func compare(_ lhs: Compared, _ rhs: Compared) -> ComparisonResult {
        switch comparator(lhs, rhs) {
        case .orderedSame: return .orderedSame
        case .orderedAscending: return order == .ascending ? .orderedAscending : .orderedDescending
        case .orderedDescending: return order == .ascending ? .orderedDescending : .orderedAscending
        }
    }

    // MARK: - Initializers

    init(typeID: String, order: SortOrder = .ascending, comparator: @escaping (_ lhs: Compared, _ rhs: Compared) -> ComparisonResult) {
        self.comparator = comparator
        self.order = order
        self.typeID = typeID
    }

    init<Value>(typeID: String, order: SortOrder = .ascending, compare: @escaping (Compared) -> Value) where Value: Comparable {
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

    init<Value>(typeID: String, order: SortOrder = .ascending, compare: @escaping (Compared) -> Value?) where Value: Comparable {
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
    
    public static func ascending(_ keyPath: KeyPath<Compared, String>, using comparator: String.Comparator) -> Self {
        .init(typeID: "KeyPathComparator(\(keyPath.stringValue))", comparator: { comparator.compare($0[keyPath: keyPath], $1[keyPath: keyPath]) })
    }
    
    public static func descending(_ keyPath: KeyPath<Compared, String>, using comparator: String.Comparator) -> Self {
        .init(typeID: "KeyPathComparator(\(keyPath.stringValue))", order: .descending, comparator: { comparator.compare($0[keyPath: keyPath], $1[keyPath: keyPath]) })
    }
    
    public static func ascending(_ keyPath: KeyPath<Compared, String>, options: String.CompareOptions, locale: Locale? = nil) -> Self {
        .init(typeID: "KeyPathComparator(\(keyPath.stringValue))", comparator: { $0[keyPath: keyPath].compare($1[keyPath: keyPath], options: options, locale: locale) })
    }
    
    public static func descending(_ keyPath: KeyPath<Compared, String>, options: String.CompareOptions, locale: Locale? = nil) -> Self {
        .init(typeID: "KeyPathComparator(\(keyPath.stringValue))", order: .descending, comparator: { $0[keyPath: keyPath].compare($1[keyPath: keyPath], options: options, locale: locale) })
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

extension SortingComparator where Compared == String {
    ///  A comparator that compares a string using a case-insensitive comparison.
    public static let caseInsensitive = Self(typeID: "caseInsensitive") { $0.compare($1, options: .caseInsensitive) }
    ///  A comparator that compares a string using a localized comparison in the current locale.
    public static let localized = Self(typeID: "localized") { $0.localizedCompare($1) }
    /// A comparator that compares a string using a localized, numeric comparison in the current locale.
    public static let localizedStandard = Self(typeID: "localizedStandard") { $0.localizedStandardCompare($1) }
    ///  A comparator that compares a string using a localized, case-insensitive comparison in the current locale.
    public static let localizedCaseInsensitive = Self(typeID: "localizedCaseInsensitive") { $0.localizedCaseInsensitiveCompare($1) }
    ///  A comparator that compares a string using a localized comparison in the specified locale.
    public static func localized(using locale: Locale) -> Self {
        Self(typeID: "localized: \(locale.identifier)") { $0.compare($1, options: [], locale: locale) }
    }
    ///  A comparator that compares a string using a localized, case-insensitive comparison in the specified locale.
    public static func localizedCaseInsensitive(using locale: Locale) -> Self {
        Self(typeID: "localizedCaseInsensitive: \(locale.identifier)") { $0.compare($1, options: .caseInsensitive, locale: locale) }
    }
    /// A comparator that compares a string using a localized, numeric comparison in the specified locale.
    public static func localizedStandard(using locale: Locale) -> Self {
        Self(typeID: "localizedStandard: \(locale.identifier)") { $0.compare($1, options: .localizedStandard, locale: locale) }
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
 */
