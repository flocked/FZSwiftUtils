//
//  SortComparator+.swift
//  
//
//  Created by Florian Zand on 14.08.24.
//

import Foundation

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension MutableCollection where Element: SortComparator {
    /// Sets the order of all sort comparators.
    @discardableResult
    mutating func order(_ order: SortOrder) -> Self {
        editEach({$0.order = order})
        return self
    }
}

/// A comparator that compares types according to a provided handler.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public struct ComparisonComparator<Compared>: SortComparator {
    public var order: SortOrder
    let handler: (_ lhs: Compared, _ rhs: Compared, _ order: SortOrder)->ComparisonResult
    let id = UUID()
    
    public init(order: SortOrder = .forward, handler: @escaping (_ lhs: Compared, _ rhs: Compared)->ComparisonResult) {
        self.order = order
        self.handler = { $2 == .forward ? handler($0, $1) : handler($0, $1).reversed }
    }
    
    public init<Value: Comparable>(order: SortOrder = .forward, handler: @escaping (_ lhs: Compared)->Value) {
        self.order = order
        self.handler = { lhs, rhs, order in
            order == .forward ? handler(lhs).comparisonResult(to: handler(rhs)) : handler(lhs).comparisonResult(to: handler(rhs)).reversed
        }
    }
    
    public init<Value: Comparable>(order: SortOrder = .forward, handler: @escaping (_ lhs: Compared)->Value?) {
        self.order = order
        self.handler = { lhs, rhs, order in
            switch (handler(lhs).optional, handler(rhs).optional) {
            case let (a?, b?): return order == .ascending ? a.comparisonResult(to: b) : a.comparisonResult(to: b).reversed
            case (nil, nil): return .orderedSame
            case (nil, _): return order == .forward ? .orderedAscending : .orderedDescending
            case (_, nil): return order == .reverse ? .orderedDescending : .orderedAscending
            }
        }
    }
    
    public func compare(_ lhs: Compared, _ rhs: Compared) -> ComparisonResult {
        handler(lhs, rhs, order)
    }
    
    public static func == (lhs: ComparisonComparator<Compared>, rhs: ComparisonComparator<Compared>) -> Bool {
        lhs.id == rhs.id && lhs.order == rhs.order
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(order)
        hasher.combine(id)
    }
}

/// A comparator that compares string values.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public struct StringComparator<Compared>: SortComparator, Hashable {
    private let _compare: ((Compared, Compared, SortOrder, String.CompareOptions, Range<String.Index>?, Locale?) -> ComparisonResult)
    private let keyPath: PartialKeyPath<Compared>?
    
    /// The string comparison options the comparator uses to compare.
    public var options: String.CompareOptions
    
    /// The locale that the comparator uses to compare.
    public var locale: Locale?
    
    /// The string range that the comparator uses to compare.
    public var range: Range<String.Index>?
    
    /// The sort order that the comparator uses to compare.
    public var order: SortOrder = .forward
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(keyPath)
        hasher.combine(locale)
        hasher.combine(options)
        hasher.combine(range)
        hasher.combine(order)
    }
    
    /**
     Creates a comparator for comparing string values.

     - Parameters:
       - options: Options for string comparison.
       - range: The range of the string to compare.
       - locale: The locale to use for comparison.
       - order: The sorting order.
     */
    public init(options: String.CompareOptions = [], range: Range<String.Index>? = nil, locale: Locale? = nil, order: SortOrder = .forward) where Compared: StringProtocol {
        self.order = order
        self.keyPath = nil
        self.options = options
        self.locale = locale
        self.range = range
        self._compare = { lhs, rhs, order, options, range, locale in
            switch lhs.compare(rhs, options: options, range: range, locale: locale) {
            case .orderedSame: return .orderedSame
            case .orderedAscending: return order == .forward ? .orderedAscending : .orderedDescending
            case .orderedDescending: return order == .forward ? .orderedDescending : .orderedAscending
            }
        }
    }
    
    /**
     Creates a comparator for comparing string values.
     
     - Parameters:
       - options: Options for string comparison.
       - range: The range of the string to compare.
       - locale: The locale to use for comparison. Defaults to `nil`.
       - order: The sorting order.
     */
    public init(options: String.CompareOptions = [], range: Range<String.Index>? = nil, locale: Locale? = nil, order: SortOrder = .forward) where Compared: OptionalProtocol, Compared.Wrapped: StringProtocol {
        self.order = order
        self.keyPath = nil
        self.options = options
        self.locale = locale
        self.range = range
        self._compare = { lhs, rhs, order, options, range, locale in
            switch (lhs.optional, rhs.optional) {
            case let (a?, b?): return a.compare(b, options: options, range: range, locale: locale)
            case (nil, nil): return .orderedSame
            case (nil, _): return .orderedAscending
            case (_, nil): return .orderedDescending
            }
        }
    }
    
    /**
     Creates a comparator for comparing string values of the specified propertiy.
     
     - Parameters:
       - keyPath: The key path to the string property to compare.
       - options: Options for string comparison.
       - range: The range of the string to compare.
       - locale: The locale to use for comparison.
       - order: The sorting order.
     */
    public init<V: StringProtocol>(keyPath: KeyPath<Compared, V>, options: String.CompareOptions = [], range: Range<String.Index>? = nil, locale: Locale? = nil, order: SortOrder = .forward) {
        self.order = order
        self.keyPath = keyPath
        self.options = options
        self.locale = locale
        self.range = range
        self._compare = { lhs, rhs, order, options, range, locale in
            switch lhs[keyPath: keyPath].compare(rhs[keyPath: keyPath], options: options, range: range, locale: locale) {
            case .orderedSame: return .orderedSame
            case .orderedAscending: return order == .forward ? .orderedAscending : .orderedDescending
            case .orderedDescending: return order == .forward ? .orderedDescending : .orderedAscending
            }
        }
    }
    
    /**
     Creates a comparator for comparing string values of the specified propertiy.
     
     - Parameters:
       - keyPath: The key path to the string property to compare.
       - options: Options for string comparison.
       - range: The range of the string to compare.
       - locale: The locale to use for comparison.
       - order: The sorting order.
     */
    public init<V>(keyPath: KeyPath<Compared, V>, options: String.CompareOptions = [], range: Range<String.Index>? = nil, locale: Locale? = nil, order: SortOrder = .forward) where V: OptionalProtocol, V.Wrapped: StringProtocol {
        self.order = order
        self.keyPath = keyPath
        self.options = options
        self.locale = locale
        self.range = range
        self._compare = { lhs, rhs, order, options, range, locale in
            switch (lhs[keyPath: keyPath].optional, rhs[keyPath: keyPath].optional) {
            case let (a?, b?):
                switch a.compare(b, options: options, range: range, locale: locale) {
                case .orderedSame: return .orderedSame
                case .orderedAscending: return order == .forward ? .orderedAscending : .orderedDescending
                case .orderedDescending: return order == .forward ? .orderedDescending : .orderedAscending
                }
            case (nil, nil): return .orderedSame
            case (nil, _): return order == .forward ? .orderedAscending : .orderedDescending
            case (_, nil): return order == .forward ? .orderedDescending : .orderedAscending
            }
        }
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.order == rhs.order && lhs.keyPath == rhs.keyPath && lhs.locale == rhs.locale && lhs.options == rhs.options && lhs.range == rhs.range
    }
    
    public func compare(_ lhs: Compared, _ rhs: Compared) -> ComparisonResult {
        _compare(lhs, rhs, order, options, range, locale)
    }
}

/// A comparator that compares types according to their conformance to the `Comparable` protocol.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
struct _ComparableComparator<Compared>: SortComparator where Compared : Comparable {
    var order: SortOrder
    
    init(order: SortOrder = .forward) {
        self.order = order
    }
    
    func compare(_ lhs: Compared, _ rhs: Compared) -> ComparisonResult {
        order == .forward ? lhs.comparisonResult(to: rhs) : lhs.comparisonResult(to: rhs).reversed
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension SortOrder {
    /// Toggles the sort order.
    mutating func toggle() {
        self = (self == .ascending) ? .descending : .ascending
    }
    
    /// An ascending sorting order.
    static let ascending = SortOrder.forward
    /// A descending sorting order.
    static let descending = SortOrder.reverse

    /// An ascending sorting order.
    static let oldestFirst = SortingOrder.ascending
    /// A descending sorting order.
    static let newestFirst = SortingOrder.descending

    /// An ascending sorting order.
    static let smallestFirst = SortingOrder.ascending
    /// A descending sorting order.
    static let largestFirst = SortingOrder.descending

    /// An ascending sorting order.
    static let shortestFirst = SortingOrder.ascending
    /// A descending sorting order.
    static let longestFirst = SortingOrder.descending
}

extension ComparisonResult {
    /// Returns the reversed result.
    var reversed: ComparisonResult {
        switch self {
        case .orderedDescending: return .orderedAscending
        case .orderedAscending: return .orderedDescending
        case .orderedSame: return .orderedSame
        }
    }
}
