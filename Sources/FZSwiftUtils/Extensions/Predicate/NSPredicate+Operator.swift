//
//  NSPredicate+Operator.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import Foundation

public extension NSComparisonPredicate.Options {
    /// The predicate option's format string.
    var predicateFormat: String {
        var value = ""
        if contains(.caseInsensitive) {
            value = value + "c"
        }
        if contains(.diacriticInsensitive) {
            value = value + "d"
        }
        if contains(.normalized) {
            value = value + "w"
        }
        return value
    }
}

public prefix func ! (lhs: NSPredicate) -> NSCompoundPredicate {
    NSCompoundPredicate(notPredicateWithSubpredicate: lhs)
}

public func && (lhs: NSPredicate, rhs: NSPredicate) -> NSCompoundPredicate {
    NSCompoundPredicate(andPredicateWithSubpredicates: [lhs, rhs])
}

public func || (lhs: NSPredicate, rhs: NSPredicate) -> NSCompoundPredicate {
    NSCompoundPredicate(orPredicateWithSubpredicates: [lhs, rhs])
}

public func == <C: Comparable, R>(lhs: KeyPath<R, C>, rhs: C) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs == rhs)
}

public func == <C: Comparable, R>(lhs: KeyPath<R, C?>, rhs: C) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs == rhs)
}

public func == <C: Comparable, R, V: Collection<C>>(lhs: KeyPath<R, C>, rhs: V) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs == rhs)
}

public func == <C: Comparable, R, V: Collection<C>>(lhs: KeyPath<R, C?>, rhs: V) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs == rhs)
}

public func === <C: Comparable, R, V: Collection<C>>(lhs: KeyPath<R, C>, rhs: V) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs === rhs)
}

public func === <C: Comparable, R, V: Collection<C>>(lhs: KeyPath<R, C?>, rhs: V) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs === rhs)
}

public func != <C: Comparable, R>(lhs: KeyPath<R, C>, rhs: C) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs != rhs)
}

public func != <C: Comparable, R>(lhs: KeyPath<R, C?>, rhs: C) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs != rhs)
}

public func !== <C: Comparable, R, V: Collection<C>>(lhs: KeyPath<R, C>, rhs: V) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs !== rhs)
}

public func !== <C: Comparable, R, V: Collection<C>>(lhs: KeyPath<R, C?>, rhs: V) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs !== rhs)
}

public func < <C: Comparable, R>(lhs: KeyPath<R, C>, rhs: C) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs < rhs)
}

public func < <C: Comparable, R>(lhs: KeyPath<R, C?>, rhs: C) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs < rhs)
}

public func <= <C: Comparable, R>(lhs: KeyPath<R, C>, rhs: C) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs <= rhs)
}

public func <= <C: Comparable, R>(lhs: KeyPath<R, C?>, rhs: C) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs <= rhs)
}

public func > <C: Comparable, R>(lhs: KeyPath<R, C>, rhs: C) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs > rhs)
}

public func > <C: Comparable, R>(lhs: KeyPath<R, C?>, rhs: C) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs > rhs)
}

public func >= <C: Comparable, R>(lhs: KeyPath<R, C>, rhs: C) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs >= rhs)
}

public func >= <C: Comparable, R>(lhs: KeyPath<R, C?>, rhs: C) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs >= rhs)
}

public func == <C: Comparable, R>(lhs: KeyPath<R, C>, rhs: ClosedRange<C>) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs == rhs)
}

public func == <C: Comparable, R>(lhs: KeyPath<R, C?>, rhs: ClosedRange<C>) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs == rhs)
}

public func *== <R>(lhs: KeyPath<R, String>, rhs: String) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs *== rhs)
}

public func *== <R>(lhs: KeyPath<R, String?>, rhs: String) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs *== rhs)
}

public func ==* <R>(lhs: KeyPath<R, String>, rhs: String) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs ==* rhs)
}

public func ==* <R>(lhs: KeyPath<R, String?>, rhs: String) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs ==* rhs)
}

public func *=* <R>(lhs: KeyPath<R, String>, rhs: String) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs *=* rhs)
}

public func *=* <R>(lhs: KeyPath<R, String?>, rhs: String) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs *=* rhs)
}

public func *== <R, C: Collection<String>>(lhs: KeyPath<R, String>, rhs: C) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs *== rhs)
}

public func *== <R, C: Collection<String>>(lhs: KeyPath<R, String?>, rhs: C) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs *== rhs)
}

public func ==* <R, C: Collection<String>>(lhs: KeyPath<R, String>, rhs: C) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs ==* rhs)
}

public func ==* <R, C: Collection<String>>(lhs: KeyPath<R, String?>, rhs: C) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs ==* rhs)
}

public func *=* <R, C: Collection<String>>(lhs: KeyPath<R, String>, rhs: C) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs *=* rhs)
}

public func *=* <R, C: Collection<String>>(lhs: KeyPath<R, String?>, rhs: C) -> NSComparisonPredicate {
    NSComparisonPredicate(lhs *=* rhs)
}
