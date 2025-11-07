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
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
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
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
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
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
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
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
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
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public struct SortingComparator<Element>: Hashable, SortComparator {
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
    
    /// A key path comparator that sorts in an ascending order.
    public static func ascending<T: Comparable>(_ keyPath: KeyPath<Element, T>) -> SortingComparator {
        .init(KeyPathComparator(keyPath, order: .forward))
    }
    
    /// A key path comparator that sorts in an ascending order.
    public static func ascending<T: Comparable>(_ keyPath: KeyPath<Element, T?>) -> SortingComparator {
        .init(KeyPathComparator(keyPath, order: .forward))
    }
    
    /// A key path comparator that sorts in an ascending order.
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    public static func ascending(_ keyPath: KeyPath<Element, String>, comparator: String.StandardComparator) -> SortingComparator {
        .init(SortDescriptor(keyPath, comparator: comparator, order: .ascending))
    }
    
    /// A key path comparator that sorts in an ascending order.
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    public static func ascending(_ keyPath: KeyPath<Element, String?>, comparator: String.StandardComparator) -> SortingComparator {
        .init(SortDescriptor(keyPath, comparator: comparator, order: .ascending))
    }
    
    /// A key path comparator that sorts in a descending order.
    public static func descending<T: Comparable>(_ keyPath: KeyPath<Element, T>) -> SortingComparator {
        .init(KeyPathComparator(keyPath, order: .reverse))
    }
    
    /// A key path comparator that sorts in a descending order.
    public static func descending<T: Comparable>(_ keyPath: KeyPath<Element, T?>) -> SortingComparator {
        .init(KeyPathComparator(keyPath, order: .reverse))
    }
    
    /// A key path comparator that sorts in a descending order.
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    public static func descending(_ keyPath: KeyPath<Element, String>, comparator: String.StandardComparator) -> SortingComparator {
        .init(SortDescriptor(keyPath, comparator: comparator, order: .reverse))
    }
    
    /// A key path comparator that sorts in a descending order.
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    public static func descending(_ keyPath: KeyPath<Element, String?>, comparator: String.StandardComparator) -> SortingComparator {
        .init(SortDescriptor(keyPath, comparator: comparator, order: .reverse))
    }
    
    /// A comparator that sorts by the specified compare block.
    public static func compare(order: SortOrder = .forward, compare: @escaping ((Element, Element) -> ComparisonResult)) -> SortingComparator {
        .init(ComparisonComparator(order: order, handler: compare))
    }
    
    /// A comparator that sorts by the specified compare block.
    public static func compare<Value: Comparable>(order: SortOrder = .forward, compare: @escaping ((Element) -> Value)) -> SortingComparator {
        .init(ComparisonComparator(order: order, handler: compare))
    }
    
    /// A comparator that sorts by the specified compare block.
    public static func compare<Value: Comparable>(order: SortOrder = .forward, compare: @escaping ((Element) -> Value?)) -> SortingComparator {
        .init(ComparisonComparator(order: order, handler: compare))
    }
    
    /**
     A comparator that sorts by the string value.
     
     - Parameters:
       - options: Options for string comparison.
       - range: The range of the string to compare.
       - locale: The locale to use for comparison.
       - order: The sorting order.
     */
    public static func compareString(options: String.CompareOptions = [], range: Range<String.Index>? = nil, locale: Locale? = nil, order: SortOrder = .forward) -> SortingComparator where Element: StringProtocol {
        .init(StringComparator(options: options, range: range, locale: locale, order: order))
    }
    
    /**
     A comparator that sorts by the string value.
     
     - Parameters:
       - options: Options for string comparison.
       - range: The range of the string to compare.
       - locale: The locale to use for comparison.
       - order: The sorting order.
     */
    public static func compareString(options: String.CompareOptions = [], range: Range<String.Index>? = nil, locale: Locale? = nil, order: SortOrder = .forward) -> SortingComparator where Element: OptionalProtocol, Element.Wrapped: StringProtocol {
        .init(StringComparator(options: options, range: range, locale: locale, order: order))
    }
    
    /**
     A comparator that sorts by the string value of the specified property.
     
     - Parameters:
       - keyPath: The key path to the string property to compare.
       - options: Options for string comparison.
       - range: The range of the string to compare.
       - locale: The locale to use for comparison.
       - order: The sorting order.
     */
    public static func compareString<V>(_ keyPath: KeyPath<Element, V>, options: String.CompareOptions = [], range: Range<String.Index>? = nil, locale: Locale? = nil, order: SortOrder = .forward) -> SortingComparator where V: StringProtocol {
        .init(StringComparator(keyPath: keyPath, options: options, range: range, locale: locale, order: order))
    }
    
    /**
     A comparator that sorts by the string value of the specified property.
     
     - Parameters:
       - keyPath: The key path to the string property to compare.
       - options: Options for string comparison.
       - range: The range of the string to compare.
       - locale: The locale to use for comparison.
       - order: The sorting order.
     */
    public static func compareString<V>(_ keyPath: KeyPath<Element, V>, options: String.CompareOptions = [], range: Range<String.Index>? = nil, locale: Locale? = nil, order: SortOrder = .forward) -> SortingComparator where V: OptionalProtocol, V.Wrapped: StringProtocol {
        .init(StringComparator(keyPath: keyPath, options: options, range: range, locale: locale, order: order))
    }

    private var comperator: any SortComparator<Element>
    
    private init(_ comperator: some SortComparator<Element>) {
        self.comperator = comperator
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

/*
 public struct SortingComparatoAltr<Element> {
     private let _compare: ((_ lhs: Element, _ rhs: Element) -> ComparisonResult)
     public var order: SortingOrder
     
     public func compare(_ lhs: Element, _ rhs: Element) -> ComparisonResult {
         switch _compare(lhs, rhs) {
         case .orderedSame: return .orderedSame
         case .orderedAscending: return order == .ascending ? .orderedAscending : .orderedDescending
         case .orderedDescending: return order == .ascending ? .orderedDescending : .orderedAscending
         }
         
     }
     
     init(order: SortingOrder = .ascending, compare: @escaping ((_: Element, _: Element) -> ComparisonResult)) {
         self._compare = compare
         self.order = order
     }
     
     init<Value>(order: SortingOrder = .ascending, compare: @escaping (Element) -> Value) where Value: Comparable {
         self.order = order
         self._compare = { lhs, rhs in
             let lhsValue = compare(lhs)
             let rhsValue = compare(rhs)
             if lhsValue < rhsValue { return .orderedAscending }
             if lhsValue > rhsValue { return .orderedDescending }
             return .orderedSame
         }
     }

     init<Value>(order: SortingOrder = .ascending, compare: @escaping (Element) -> Value?) where Value: Comparable {
         self.order = order
         self._compare = { lhs, rhs in
             let lhsValue = compare(lhs)
             let rhsValue = compare(rhs)
             switch (lhsValue, rhsValue) {
             case let (l?, r?):
                 if l < r { return .orderedAscending }
                 if l > r { return .orderedDescending }
                 return .orderedSame
             case (nil, nil): return .orderedSame
             case (nil, _): return .orderedAscending
             case (_, nil): return  .orderedDescending
             }
         }
     }
     
     /// A key path comparator that sorts in an ascending order.
     public static func ascending<T: Comparable>(_ keyPath: KeyPath<Element, T>) -> Self {
         .init(compare: { $0[keyPath: keyPath] })
     }

     /// A key path comparator that sorts in an descending order.
     public static func descending<T: Comparable>(_ keyPath: KeyPath<Element, T>) -> Self {
         .init(order: .descending) { $0[keyPath: keyPath] }
     }
     
     /// A key path comparator that sorts in an ascending order.
     public static func ascending<T: Comparable>(_ keyPath: KeyPath<Element, T?>) -> Self {
         .init(compare: { $0[keyPath: keyPath] })
     }

     /// A key path comparator that sorts in an descending order.
     public static func descending<T: Comparable>(_ keyPath: KeyPath<Element, T?>) -> Self {
         .init(order: .descending) { $0[keyPath: keyPath] }
     }
     
     /// A comparator that compares two elements.
     public static func compare(_ compare: @escaping ((Element, Element) -> ComparisonResult)) -> Self {
         .init(compare: compare)
     }
     
     /// A comparator that compares two elements.
     public static func compare<Value: Comparable>(_ compare: @escaping ((Element) -> Value)) -> Self {
         .init(compare: compare)
     }
     
     /// A comparator that compares two elements.
     public static func compare<Value: Comparable>(_ compare: @escaping ((Element) -> Value?)) -> Self {
         .init(compare: compare)
     }
     
     /// A key path comparator that sorts in an descending order.
     public static func stringCompare<T>(_ keyPath: KeyPath<Element, T>, options: String.CompareOptions, range: Range<T.Index>? = nil, locale: Locale? = nil) -> Self where T: StringProtocol {
         .init {
             $0[keyPath: keyPath].compare($1[keyPath: keyPath], options: options, range: range, locale: locale)
         }
     }
     
     public static func stringCompare<T>(_ keyPath: KeyPath<Element, T>, options: String.CompareOptions, range: Range<T.Wrapped.Index>? = nil, locale: Locale? = nil) -> Self where T: OptionalProtocol, T.Wrapped: StringProtocol {
         .init() {
             switch ($0[keyPath: keyPath].optional, $1[keyPath: keyPath].optional) {
             case let (a?, b?): return a.compare(b, options: options, range: range, locale: locale)
             case (nil, nil): return .orderedSame
             case (nil, _): return .orderedAscending
             case (_, nil): return .orderedDescending
             }
         }
     }
 }

 extension SortingComparatoAltr where Element: Comparable {
     /// A comparator that sorts in an ascending order.
     public static var ascending: Self { .init(compare: { $0 }) }
     
     /// A comparator that sorts in an descending order.
     public static var descending: Self { .init(order: .descending) { $0 } }
 }

 extension SortingComparatoAltr where Element: StringProtocol {
     public static func stringCompare(options: String.CompareOptions = [], range: Range<Element.Index>? = nil, locale: Locale? = nil) -> Self {
         .init() { $0.compare($1, options: options, range: range, locale: locale) }
     }
 }

 extension SortingComparatoAltr where Element: OptionalProtocol, Element.Wrapped: StringProtocol {
     public static func stringCompare(options: String.CompareOptions = [], range: Range<Element.Wrapped.Index>? = nil, locale: Locale? = nil) -> Self {
         .init() {
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
