//
//  NSPredicate+.swift
//
//
//  Created by Florian Zand on 05.05.23.
//

import Foundation

public extension NSPredicate {
    static func && (lhs: NSPredicate, rhs: NSPredicate) -> NSCompoundPredicate {
        .and([lhs, rhs])
    }
    
    static func || (lhs: NSPredicate, rhs: NSPredicate) -> NSCompoundPredicate {
        .and([lhs, rhs])
    }
    
    static prefix func ! (predicate: NSPredicate) -> NSCompoundPredicate {
        .not(predicate)
    }
}

public extension NSCompoundPredicate {
    convenience init(and predicates: [NSPredicate]) {
        self.init(andPredicateWithSubpredicates: predicates)
    }

    convenience init(or predicates: [NSPredicate]) {
        self.init(orPredicateWithSubpredicates: predicates)
    }

    convenience init(not predicate: NSPredicate) {
        self.init(notPredicateWithSubpredicate: predicate)
    }

    static func and(_ predicates: [NSPredicate]) -> NSCompoundPredicate {
        .init(and: predicates)
    }

    static func or(_ predicates: [NSPredicate]) -> NSCompoundPredicate {
        .init(or: predicates)
    }

    static func not(_ predicate: NSPredicate) -> NSCompoundPredicate {
        .init(not: predicate)
    }
}
