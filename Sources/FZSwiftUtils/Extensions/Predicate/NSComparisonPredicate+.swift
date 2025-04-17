//
//  NSComparisonPredicate+.swift
//  
//
//  Created by Florian Zand on 17.04.25.
//

import Foundation

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
