//
//  NSPredicate+NSComparisonPredicate.Expression.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import Foundation

extension NSComparisonPredicate {
    public struct Expression {
        let left: NSExpression
        let right: NSExpression
        let type: Operator
        let modifier: Modifier
        let options:Options
        
        init(left: NSExpression, right: NSExpression, type: Operator, modifier: Modifier = .direct, options: Options = []) {
            self.left = left
            self.right = right
            self.type = type
            self.modifier = modifier
            self.options = options
        }
    }
}


public extension NSComparisonPredicate {
    convenience init(_ expression: NSComparisonPredicate.Expression, options: Options = []) {
        self.init(leftExpression: expression.left, rightExpression: expression.right, modifier: expression.modifier, type: expression.type, options: options)
    }

    convenience init<R>(_ keyPath: KeyPath<R, String>, _ type: Operator, value: String, options: Options = []) {
        self.init(leftExpression: NSExpression(forKeyPath: keyPath), rightExpression: NSExpression(forConstantValue: value), modifier: .direct, type: type, options: options)
    }

    convenience init<R>(_ keyPath: KeyPath<R, String?>, _ type: Operator, value: String, options: Options = []) {
        self.init(leftExpression: NSExpression(forKeyPath: keyPath), rightExpression: NSExpression(forConstantValue: value), modifier: .direct, type: type, options: options)
    }

    convenience init<R>(_ keyPath: KeyPath<R, String>, _ type: Operator, values: [String], options: Options = []) {
        self.init(leftExpression: NSExpression(forKeyPath: keyPath), rightExpression: NSExpression(forConstantValue: values), modifier: (type == .in) ? .direct : .any, type: type, options: options)
    }

    convenience init<R>(_ keyPath: KeyPath<R, String?>, _ type: Operator, values: [String], options: Options = []) {
        self.init(leftExpression: NSExpression(forKeyPath: keyPath), rightExpression: NSExpression(forConstantValue: values), modifier: (type == .in) ? .direct : .any, type: type, options: options)
    }

    // -----

    convenience init<R, C: Comparable>(_ keyPath: KeyPath<R, C>, _ type: Operator, value: C) {
        self.init(leftExpression: NSExpression(forKeyPath: keyPath), rightExpression: NSExpression(forConstantValue: value), modifier: .direct, type: type)
    }

    convenience init<R, C: Comparable>(_ keyPath: KeyPath<R, C?>, _ type: Operator, value: C) {
        self.init(leftExpression: NSExpression(forKeyPath: keyPath), rightExpression: NSExpression(forConstantValue: value), modifier: .direct, type: type)
    }

    convenience init<R, C: Comparable>(_ keyPath: KeyPath<R, C>, _ type: Operator, values: [C]) {
        self.init(leftExpression: NSExpression(forKeyPath: keyPath), rightExpression: NSExpression(forConstantValue: values), modifier: (type == .in) ? .direct : .any, type: type)
    }

    convenience init<R, C: Comparable>(_ keyPath: KeyPath<R, C?>, _ type: Operator, values: [C]) {
        self.init(leftExpression: NSExpression(forKeyPath: keyPath), rightExpression: NSExpression(forConstantValue: values), modifier: (type == .in) ? .direct : .any, type: type)
    }
}

public func == (lhs: NSExpression, rhs: NSExpression) -> NSComparisonPredicate.Expression {
    NSComparisonPredicate.Expression(left: lhs, right: rhs, type: .equalTo)
}

public func === (lhs: NSExpression, rhs: NSExpression) -> NSComparisonPredicate.Expression {
    NSComparisonPredicate.Expression(left: lhs, right: rhs, type: .equalTo, modifier: .all)
}

public func !== (lhs: NSExpression, rhs: NSExpression) -> NSComparisonPredicate.Expression {
    NSComparisonPredicate.Expression(left: lhs, right: rhs, type: .notEqualTo, modifier: .all)
}

public func != (lhs: NSExpression, rhs: NSExpression) -> NSComparisonPredicate.Expression {
    NSComparisonPredicate.Expression(left: lhs, right: rhs, type: .notEqualTo)
}

public func < (lhs: NSExpression, rhs: NSExpression) -> NSComparisonPredicate.Expression {
    NSComparisonPredicate.Expression(left: lhs, right: rhs, type: .lessThan)
}

public func <= (lhs: NSExpression, rhs: NSExpression) -> NSComparisonPredicate.Expression {
    NSComparisonPredicate.Expression(left: lhs, right: rhs, type: .lessThanOrEqualTo)
}

public func > (lhs: NSExpression, rhs: NSExpression) -> NSComparisonPredicate.Expression {
    NSComparisonPredicate.Expression(left: lhs, right: rhs, type: .greaterThan)
}

public func >= (lhs: NSExpression, rhs: NSExpression) -> NSComparisonPredicate.Expression {
    NSComparisonPredicate.Expression(left: lhs, right: rhs, type: .greaterThanOrEqualTo)
}

public func >< (lhs: NSExpression, rhs: NSExpression) -> NSComparisonPredicate.Expression {
    NSComparisonPredicate.Expression(left: lhs, right: rhs, type: .between)
}

public func *== (lhs: NSExpression, rhs: NSExpression) -> NSComparisonPredicate.Expression {
    NSComparisonPredicate.Expression(left: lhs, right: rhs, type: .beginsWith)
}

public func ==* (lhs: NSExpression, rhs: NSExpression) -> NSComparisonPredicate.Expression {
    NSComparisonPredicate.Expression(left: lhs, right: rhs, type: .endsWith)
}

public func *=* (lhs: NSExpression, rhs: NSExpression) -> NSComparisonPredicate.Expression {
    NSComparisonPredicate.Expression(left: lhs, right: rhs, type: .contains)
}

// -------------

//

public func == <C: Comparable, R>(lhs: KeyPath<R, C>, rhs: C) -> NSComparisonPredicate.Expression {
    NSExpression(forKeyPath: lhs) == NSExpression(forConstantValue: rhs)
}

public func == <C: Comparable, R>(lhs: KeyPath<R, C?>, rhs: C) -> NSComparisonPredicate.Expression {
    NSExpression(forKeyPath: lhs) == NSExpression(forConstantValue: rhs)
}

public func == <C: Comparable, R, V: Collection<C>>(lhs: KeyPath<R, C>, rhs: V) -> NSComparisonPredicate.Expression {
    NSComparisonPredicate.Expression(left: NSExpression(forKeyPath: lhs), right: NSExpression(forConstantValue: rhs), type: .in)
}

public func == <C: Comparable, R, V: Collection<C>>(lhs: KeyPath<R, C?>, rhs: V) -> NSComparisonPredicate.Expression {
    NSComparisonPredicate.Expression(left: NSExpression(forKeyPath: lhs), right: NSExpression(forConstantValue: rhs), type: .in)
}

public func === <C: Comparable, R, V: Collection<C>>(lhs: KeyPath<R, C>, rhs: V) -> NSComparisonPredicate.Expression {
    NSComparisonPredicate.Expression(left: NSExpression(forKeyPath: lhs), right: NSExpression(forConstantValue: rhs), type: .equalTo, modifier: .all)
}

public func === <C: Comparable, R, V: Collection<C>>(lhs: KeyPath<R, C?>, rhs: V) -> NSComparisonPredicate.Expression {
    NSComparisonPredicate.Expression(left: NSExpression(forKeyPath: lhs), right: NSExpression(forConstantValue: rhs), type: .equalTo, modifier: .all)
}

public func !== <C: Comparable, R, V: Collection<C>>(lhs: KeyPath<R, C>, rhs: V) -> NSComparisonPredicate.Expression {
    NSComparisonPredicate.Expression(left: NSExpression(forKeyPath: lhs), right: NSExpression(forConstantValue: rhs), type: .notEqualTo, modifier: .all)
}

public func !== <C: Comparable, R, V: Collection<C>>(lhs: KeyPath<R, C?>, rhs: V) -> NSComparisonPredicate.Expression {
    NSComparisonPredicate.Expression(left: NSExpression(forKeyPath: lhs), right: NSExpression(forConstantValue: rhs), type: .notEqualTo, modifier: .all)
}

public func != <C: Comparable, R>(lhs: KeyPath<R, C>, rhs: C) -> NSComparisonPredicate.Expression {
    NSExpression(forKeyPath: lhs) != NSExpression(forConstantValue: rhs)
}

public func != <C: Comparable, R>(lhs: KeyPath<R, C?>, rhs: C) -> NSComparisonPredicate.Expression {
    NSExpression(forKeyPath: lhs) != NSExpression(forConstantValue: rhs)
}

public func < <C: Comparable, R>(lhs: KeyPath<R, C>, rhs: C) -> NSComparisonPredicate.Expression {
    NSExpression(forKeyPath: lhs) < NSExpression(forConstantValue: rhs)
}

public func < <C: Comparable, R>(lhs: KeyPath<R, C?>, rhs: C) -> NSComparisonPredicate.Expression {
    NSExpression(forKeyPath: lhs) < NSExpression(forConstantValue: rhs)
}

public func <= <C: Comparable, R>(lhs: KeyPath<R, C>, rhs: C) -> NSComparisonPredicate.Expression {
    NSExpression(forKeyPath: lhs) <= NSExpression(forConstantValue: rhs)
}

public func <= <C: Comparable, R>(lhs: KeyPath<R, C?>, rhs: C) -> NSComparisonPredicate.Expression {
    NSExpression(forKeyPath: lhs) <= NSExpression(forConstantValue: rhs)
}

public func > <C: Comparable, R>(lhs: KeyPath<R, C>, rhs: C) -> NSComparisonPredicate.Expression {
    NSExpression(forKeyPath: lhs) > NSExpression(forConstantValue: rhs)
}

public func > <C: Comparable, R>(lhs: KeyPath<R, C?>, rhs: C) -> NSComparisonPredicate.Expression {
    NSExpression(forKeyPath: lhs) > NSExpression(forConstantValue: rhs)
}

public func >= <C: Comparable, R>(lhs: KeyPath<R, C>, rhs: C) -> NSComparisonPredicate.Expression {
    NSExpression(forKeyPath: lhs) >= NSExpression(forConstantValue: rhs)
}

public func >= <C: Comparable, R>(lhs: KeyPath<R, C?>, rhs: C) -> NSComparisonPredicate.Expression {
    NSExpression(forKeyPath: lhs) >= NSExpression(forConstantValue: rhs)
}

public func == <C: Comparable, R>(lhs: KeyPath<R, C>, rhs: ClosedRange<C>) -> NSComparisonPredicate.Expression {
    NSExpression(forKeyPath: lhs) >< NSExpression(forConstantValue: [rhs.lowerBound, rhs.upperBound])
}

public func == <C: Comparable, R>(lhs: KeyPath<R, C?>, rhs: ClosedRange<C>) -> NSComparisonPredicate.Expression {
    NSExpression(forKeyPath: lhs) >< NSExpression(forConstantValue: [rhs.lowerBound, rhs.upperBound])
}

public func *== <R>(lhs: KeyPath<R, String>, rhs: String) -> NSComparisonPredicate.Expression {
    NSExpression(forKeyPath: lhs) *== NSExpression(forConstantValue: rhs)
}

public func *== <R>(lhs: KeyPath<R, String?>, rhs: String) -> NSComparisonPredicate.Expression {
    NSExpression(forKeyPath: lhs) *== NSExpression(forConstantValue: rhs)
}

public func ==* <R>(lhs: KeyPath<R, String>, rhs: String) -> NSComparisonPredicate.Expression {
    NSExpression(forKeyPath: lhs) ==* NSExpression(forConstantValue: rhs)
}

public func ==* <R>(lhs: KeyPath<R, String?>, rhs: String) -> NSComparisonPredicate.Expression {
    NSExpression(forKeyPath: lhs) ==* NSExpression(forConstantValue: rhs)
}

public func *=* <R>(lhs: KeyPath<R, String>, rhs: String) -> NSComparisonPredicate.Expression {
    NSExpression(forKeyPath: lhs) *=* NSExpression(forConstantValue: rhs)
}

public func *=* <R>(lhs: KeyPath<R, String?>, rhs: String) -> NSComparisonPredicate.Expression {
    NSExpression(forKeyPath: lhs) *=* NSExpression(forConstantValue: rhs)
}

public func *== <R, C: Collection<String>>(lhs: KeyPath<R, String>, rhs: C) -> NSComparisonPredicate.Expression {
    NSComparisonPredicate.Expression(left: NSExpression(forKeyPath: lhs), right: NSExpression(forConstantValue: rhs), type: .beginsWith, modifier: .any)
}

public func *== <R, C: Collection<String>>(lhs: KeyPath<R, String?>, rhs: C) -> NSComparisonPredicate.Expression {
    NSComparisonPredicate.Expression(left: NSExpression(forKeyPath: lhs), right: NSExpression(forConstantValue: rhs), type: .beginsWith, modifier: .any)
}

public func ==* <R, C: Collection<String>>(lhs: KeyPath<R, String>, rhs: C) -> NSComparisonPredicate.Expression {
    NSComparisonPredicate.Expression(left: NSExpression(forKeyPath: lhs), right: NSExpression(forConstantValue: rhs), type: .endsWith, modifier: .any)
}

public func ==* <R, C: Collection<String>>(lhs: KeyPath<R, String?>, rhs: C) -> NSComparisonPredicate.Expression {
    NSComparisonPredicate.Expression(left: NSExpression(forKeyPath: lhs), right: NSExpression(forConstantValue: rhs), type: .endsWith, modifier: .any)
}

public func *=* <R, C: Collection<String>>(lhs: KeyPath<R, String>, rhs: C) -> NSComparisonPredicate.Expression {
    NSComparisonPredicate.Expression(left: NSExpression(forKeyPath: lhs), right: NSExpression(forConstantValue: rhs), type: .contains, modifier: .any)
}

public func *=* <R, C: Collection<String>>(lhs: KeyPath<R, String?>, rhs: C) -> NSComparisonPredicate.Expression {
    NSComparisonPredicate.Expression(left: NSExpression(forKeyPath: lhs), right: NSExpression(forConstantValue: rhs), type: .contains, modifier: .any)
}
