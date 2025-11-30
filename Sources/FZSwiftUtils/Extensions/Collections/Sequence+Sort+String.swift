//
//  Sequence+Sort+String.swift
//  
//
//  Created by Florian Zand on 07.11.25.
//

import Foundation

extension String {
    /// The sort order for sorting string values.
    public enum SortingOrder {
        ///  Sorts using a localized comparison in the current locale.
        case localized
        /// Sorts as compared by the Finder.
        case localizedStandard
    }
}

public extension Sequence {
    /// Returns the string values of the sequence sorted by the specified sort order.
    func sorted(by order: String.SortingOrder) -> [Element] where Element: StringProtocol {
        order == .localized ? sorted { $0.localizedCompare($1) == .orderedAscending } : sorted { $0.localizedStandardCompare($1) == .orderedAscending }
    }
    
    /// Returns the string values of the sequence sorted by the specified sort order.
    func sorted(by order: String.SortingOrder) -> [Element] where Element: OptionalProtocol, Element.Wrapped: StringProtocol {
        sorted() {
             switch ($0.optional, $1.optional) {
             case let (a?, b?): return order == .localized ? a.localizedCompare(b) == .orderedAscending : a.localizedStandardCompare(b) == .orderedAscending
             case (_?, nil): return true
             default: return false
             }
         }
    }
    
    /// Returns the elements of the sequence sorted by the string value of the specified property and sort order.
    func sorted<V: StringProtocol>(by keyPath: KeyPath<Element, V>, order: String.SortingOrder) -> [Element] {
        order == .localized ? sorted { $0[keyPath: keyPath].localizedCompare($1[keyPath: keyPath]) == .orderedAscending } : sorted { $0[keyPath: keyPath].localizedStandardCompare($1[keyPath: keyPath]) == .orderedAscending }
    }
    
    /// Returns the elements of the sequence sorted by the string value of the specified property and sort order.
    func sorted<V>(by keyPath: KeyPath<Element, V>, order: String.SortingOrder) -> [Element] where V: OptionalProtocol, V.Wrapped: StringProtocol {
        sorted() {
            switch ($0[keyPath: keyPath].optional, $1[keyPath: keyPath].optional) {
             case let (a?, b?): return order == .localized ? a.localizedCompare(b) == .orderedAscending : a.localizedStandardCompare(b) == .orderedAscending
             case (_?, nil): return true
             default: return false
             }
         }
    }
    
    /**
     Returns the elements of the sequence, sorted.
     
     - Parameters:
        - options: Options for comparing the strings.
        - range: The range of the string comparsion.
        - locale: The local of the string comparsion.
        - order: The order of sorting.
     */
    func sorted(by options: String.CompareOptions, range: Range<Element.Index>? = nil, locale: Locale? = nil, _ order: SortingOrder = .ascending) -> [Element] where Element: StringProtocol {
        sorted { $0.compare($1, options: options, range: range, locale: locale) == order.order }
    }
    
    /**
     Returns the elements of the sequence, sorted.
     
     - Parameters:
        - options: Options for comparing the strings.
        - range: The range of the string comparsion.
        - locale: The local of the string comparsion.
        - order: The order of sorting.
     */
    func sorted(by options: String.CompareOptions, range: Range<Element.Wrapped.Index>? = nil, locale: Locale? = nil, _ order: SortingOrder = .ascending) -> [Element] where Element: OptionalProtocol, Element.Wrapped: StringProtocol {
        sorted {
            switch ($0.optional, $1.optional) {
            case let (a?, b?): return a.compare(b, options: options, range: range, locale: locale) == order.order
            case (_?, nil): return true
            default: return false
            }
        }
    }
}

public extension MutableCollection where Self: RandomAccessCollection {
    /// Sorts the string values of the collection in place by the specified sort order.
    mutating func sort(by order: String.SortingOrder) where Element: StringProtocol {
        order == .localized ? sort { $0.localizedCompare($1) == .orderedAscending } : sort { $0.localizedStandardCompare($1) == .orderedAscending }
    }
    
    /// Sorts the string values of the collection in place by the specified sort order.
    mutating func sort(by order: String.SortingOrder) where Element: OptionalProtocol, Element.Wrapped: StringProtocol {
        sort() {
             switch ($0.optional, $1.optional) {
             case let (a?, b?): return order == .localized ? a.localizedCompare(b) == .orderedAscending : a.localizedStandardCompare(b) == .orderedAscending
             case (_?, nil): return true
             default: return false
             }
         }
    }
    
    /// Sorts the elements of the collection in place by the string value of the specified property and sort order.
    mutating func sort<V: StringProtocol>(by keyPath: KeyPath<Element, V>, order: String.SortingOrder) {
        order == .localized ? sort { $0[keyPath: keyPath].localizedCompare($1[keyPath: keyPath]) == .orderedAscending } : sort { $0[keyPath: keyPath].localizedStandardCompare($1[keyPath: keyPath]) == .orderedAscending }
    }
    
    /// Sorts the elements of the collection in place by the string value of the specified property and sort order.
    mutating func sort<V>(by keyPath: KeyPath<Element, V>, order: String.SortingOrder) where V: OptionalProtocol, V.Wrapped: StringProtocol {
        sort() {
            switch ($0[keyPath: keyPath].optional, $1[keyPath: keyPath].optional) {
             case let (a?, b?): return order == .localized ? a.localizedCompare(b) == .orderedAscending : a.localizedStandardCompare(b) == .orderedAscending
             case (_?, nil): return true
             default: return false
             }
         }
    }
    
    /**
     Sorts the collection in place by the specified order.
     
     - Parameters:
        - options: Options for comparing the strings.
        - range: The range of the string comparsion.
        - locale: The local of the string comparsion.
        - order: The order of sorting.
     */
    mutating func sort(by options: String.CompareOptions, range: Range<Element.Index>? = nil, locale: Locale? = nil, _ order: SortingOrder = .ascending) where Element: StringProtocol {
        sort { $0.compare($1, options: options, range: range, locale: locale) == order.order }
    }

    /**
     Sorts the collection in place by the specified order.
     
     - Parameters:
        - options: Options for comparing the strings.
        - range: The range of the string comparsion.
        - locale: The local of the string comparsion.
        - order: The order of sorting.
     */
    mutating func sort(by options: String.CompareOptions, range: Range<Element.Wrapped.Index>? = nil, locale: Locale? = nil, _ order: SortingOrder = .ascending) where Element: OptionalProtocol, Element.Wrapped: StringProtocol {
        sort {
            switch ($0.optional, $1.optional) {
            case let (a?, b?): return a.compare(b, options: options, range: range, locale: locale) == order.order
            case (_?, nil): return true
            default: return false
            }
        }
    }
}

/*
 @available(macOS, introduced: 10.0, obsoleted: 12.0)
 @available(iOS, introduced: 7.0, obsoleted: 15.0)
 @available(tvOS, introduced: 7.0, obsoleted: 15.0)
 @available(watchOS, introduced: 5.0, obsoleted: 8.0)
 extension String {
     /// A String comparison performed using the given comparison options and locale.
     public struct Comparator {
         /// The locale to use for comparison if the comparator is localized, otherwise `nil`.
         public let locale: Locale?
         
         /// The options to use for comparison.
         public let options: String.CompareOptions
         
         /// The sort order that the comparator uses to compare.
         public var order: FZSwiftUtils.SortingOrder
         
         private let comparator: (_ a: String, _ b: String) -> ComparisonResult

         
         /// Provides the relative ordering of two strings based on the sort order of the comparator.
         public func compare(_ lhs: String, _ rhs: String) -> ComparisonResult {
             order == .ascending ? comparator(lhs, rhs) : comparator(lhs, rhs).reversed
         }
         
         /**
          Creates a ``Comparator`` with the given `CompareOptions` and `Locale`.
          
          - Parameters:
             - options: The options to use for comparison.
             - locale: The locale to use for comparison. If `nil`, the comparison is unlocalized.
             - order: The initial order to use for ordered comparison.
          
          */
         public init(options: CompareOptions, locale: Locale? = Locale.current, order: FZSwiftUtils.SortingOrder = .ascending) {
             self.options = options
             self.locale = locale
             self.order = order
             self.comparator = { $0.compare($1, options: options, locale: locale) }
         }
         
         /**
          Creates a ``Comparator`` that represents the same comparison as the given ``StandardComparator``.
          
          - Parameter standardComparison: The ``StandardComparator`` to convert.
          */
         public init(_ standardComparison: StandardComparator) {
             self.order = standardComparison.order
             self.locale = .current
             self.options = standardComparison == .localizedStandard ? .localizedStandard  : []
             switch standardComparison {
             case .lexical:
                 self.comparator = { $0.compare($1, options: [], locale: .current) }
             case .localized:
                 self.comparator = { $0.localizedCompare($1) }
             default:
                 self.comparator = { $0.localizedStandardCompare($1) }
             }
         }
     }
     
     /// Compares Strings using one of a fixed set of standard comparison algorithms.
     public struct StandardComparator: Hashable {
         let comparator: Int
         let order: FZSwiftUtils.SortingOrder
         
         ///  Compares Strings lexically.
         public static let lexical = Self(0)
         ///  Compares Strings using a localized comparison in the current locale.
         public static let localized = Self(1)
         /// Compares Strings as compared by the Finder.
         public static let localizedStandard = Self(2)
         
         /**
          Create a ``StandardComparator`` from the given ``StandardComparator`` with the given new order.
          
          - Parameters:
             - base: The standard comparator to modify the order of.
             - order: The initial order of the new ``StandardComparator``.
          
          */
         public init(_ base: StandardComparator, order: FZSwiftUtils.SortingOrder = .ascending) {
             self.init(base.comparator, order)
         }
         
         private init(_ comparator: Int, _ order: FZSwiftUtils.SortingOrder = .ascending) {
             self.comparator = comparator
             self.order = order
         }
     }
 }
 */
