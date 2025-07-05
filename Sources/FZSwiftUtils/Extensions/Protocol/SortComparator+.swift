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

/// A comparator that compares types according to their conformance to the `Comparable` protocol.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
struct _ComparableComparator<Compared>: SortComparator where Compared : Comparable {
    var order: SortOrder
    
    init(order: SortOrder = .forward) {
        self.order = order
    }
    
    func compare(_ lhs: Compared, _ rhs: Compared) -> ComparisonResult {
        if lhs == rhs {
            return .orderedSame
        } else if lhs < rhs {
            return order == .forward ? .orderedAscending : .orderedDescending
        }
        return order == .forward ? .orderedDescending : .orderedAscending
    }
}

/// A comparator that compares types according to a provided comparison handler.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
struct HandlerComparator<Compared>: SortComparator {
    var order: SortOrder
    let handler: (_ lhs: Compared, _ rhs: Compared)->ComparisonResult
    let id = UUID()
    
    init(order: SortOrder = .forward, handler: @escaping (_ lhs: Compared, _ rhs: Compared)->ComparisonResult) {
        self.order = order
        self.handler = handler
    }
    
    func compare(_ lhs: Compared, _ rhs: Compared) -> ComparisonResult {
        let result = handler(lhs, rhs)
        return order == .reverse ? result.reversed : result
    }
    
    static func == (lhs: HandlerComparator<Compared>, rhs: HandlerComparator<Compared>) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(order)
        hasher.combine(id)
    }
}

/// A comparator that uses another sort comparator to provide the comparison of values at a key path.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
struct PartialKeyPathComparator<Compared>: SortComparator {
    /// The sort order that the comparator uses to compare properties.
    public var order: SortOrder
    
    /// The key path that the comparator uses to compare properties.
    public let keyPath: PartialKeyPath<Compared>
    
    /// Creates a comparator using a key path.
    public init(_ keyPath: PartialKeyPath<Compared>, order: SortOrder) {
        self.order = order
        self.keyPath = keyPath
    }
    
    /**
     Provides the relative ordering of two items according to the ordering of the properties that the comparator’s key path references.
     
     - Parameters:
        - lhs: The first property to compare.
        - rhs: The second property to compare.
     
     - Returns: The method returns flipped comparisons if the sort order is `reverse.
     */
    public func compare(_ lhs: Compared, _ rhs: Compared) -> ComparisonResult {
        let aValue = lhs[keyPath: keyPath] as? any Comparable
        let bValue = rhs[keyPath: keyPath] as? any Comparable
        switch (aValue, bValue) {
        case let (lhs?, rhs?):
            if lhs.isEqual(rhs) {
                return .orderedSame
            }
            let result: ComparisonResult = lhs.isLessThan(rhs) ? .orderedAscending : .orderedDescending
            return order == .forward ? result : result.reversed
        case (nil, nil):
            return .orderedSame
        case (nil, _):
            return .orderedAscending
        case (_, nil):
            return .orderedDescending
        }
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
    static let oldestFirst = SequenceSortOrder.ascending
    /// A descending sorting order.
    static let newestFirst = SequenceSortOrder.descending

    /// An ascending sorting order.
    static let smallestFirst = SequenceSortOrder.ascending
    /// A descending sorting order.
    static let largestFirst = SequenceSortOrder.descending

    /// An ascending sorting order.
    static let shortestFirst = SequenceSortOrder.ascending
    /// A descending sorting order.
    static let longestFirst = SequenceSortOrder.descending
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
