//
//  NSComparisonPredicate+.swift
//  
//
//  Created by Florian Zand on 17.04.25.
//

import Foundation

extension NSComparisonPredicate {
    /**
     Creates a predicate to a specified type that you form by combining specified left and right expressions using a specified modifier and options.
     
     - Parameters:
        - left: The left hand expression.
        - right: The right hand expression.
        - modifier: The modifier to apply.
        - type: The operator type.
        - options: The options to apply.
     - Returns: The receiver, initialized to a predicate of type type formed by combining the left and right expressions using the modifier and options.
     */
    public convenience init(left: NSExpression, right: NSExpression, modifier: Modifier = .direct, type: Operator, options: Options = []) {
        self.init(leftExpression: left, rightExpression: right, modifier: modifier, type: type, options: options)
    }
}

extension NSComparisonPredicate.Options: CustomStringConvertible {
    /// A word-based predicate.
    public static let wordBased = NSComparisonPredicate.Options(rawValue: 16)
    
    /// The predicate option's format string.
    public var predicateFormat: String {
        if self == [] { return "" }
        var strings: [String] = []
        if contains(.caseInsensitive) { strings += "c" }
        if contains(.diacriticInsensitive) { strings += "d" }
        if contains(.init(rawValue: 8)) { strings += "l" }
        if contains(.normalized) { strings += "n" }
        if contains(.wordBased) { strings += "w" }
        return "[\(strings.joined(separator: ""))]"
    }
    
    public var description: String {
        var strings: [String] = []
        if contains(.caseInsensitive) { strings += "c" }
        if contains(.diacriticInsensitive) { strings += "d" }
        if contains(.init(rawValue: 8)) { strings += "l" }
        if contains(.normalized) { strings += "n" }
        if contains(.wordBased) { strings += "w" }
        return "[\(strings.joined(separator: ""))]"
    }
}
