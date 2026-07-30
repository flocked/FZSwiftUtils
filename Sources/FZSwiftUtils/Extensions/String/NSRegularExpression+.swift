//
//  NSRegularExpression+.swift
//
//
//  Created by Florian Zand on 08.04.24.
//

import Foundation

public extension NSRegularExpression {
    /**
     Returns an array containing all the matches of the regular expression in the string.

     - Parameters:
        - string: The string to search.
        - options: The matching options to use. See `MatchingOptions` for possible values.

     - Returns: An array of `NSTextCheckingResult` objects. Each result gives the overall matched range via its `range` property, and the range of each individual capture group via its `range(at:)` method. The range `{NSNotFound, 0}` is returned if one of the capture groups did not participate in this particular match.
     */
    func matches(in string: String, options: MatchingOptions = []) -> [NSTextCheckingResult] {
        matches(in: string, options: options, range: string.nsRange)
    }
    
    /**
     Returns an array containing all the matches of the regular expression in the string.

     - Parameters:
        - string: The string to search.
        - options: The matching options to use. See `MatchingOptions` for possible values.

     - Returns: An array of `NSTextCheckingResult` objects. Each result gives the overall matched range via its `range` property, and the range of each individual capture group via its `range(at:)` method. The range `{NSNotFound, 0}` is returned if one of the capture groups did not participate in this particular match.
     */
    func matches(in string: String, options: MatchingOptions, range: Range<String.Index>? = nil) -> [NSTextCheckingResult] {
        matches(in: string, options: options, range: range?.nsRange(in: string) ?? string.nsRange)
    }
    
    func firstMatch(in string: String, options: MatchingOptions, range: Range<String.Index>? = nil) -> NSTextCheckingResult? {
        firstMatch(in: string, options: options, range: range?.nsRange(in: string) ?? string.nsRange)
    }
    
    func rangeOfFirstMatch(in string: String, options: NSRegularExpression.MatchingOptions = [], range: Range<String.Index>? = nil) -> Range<String.Index>? {
        Range(rangeOfFirstMatch(in: string, options: options, range: range?.nsRange(in: string) ?? string.nsRange), in: string)
    }
    
    func enumerateMatches(in string: String, options: NSRegularExpression.MatchingOptions = [], range: Range<String.Index>? = nil, using block: (NSTextCheckingResult?, NSRegularExpression.MatchingFlags, inout Bool) -> Void) {
        var shouldStop = false
        enumerateMatches(in: string, options: options, range: range?.nsRange(in: string) ?? string.nsRange) { result, options, stop in
            block(result, options, &shouldStop)
            if shouldStop {
                stop.pointee = true
            }
        }
    }
    
    func stringByReplacingMatches(in string: String, options: NSRegularExpression.MatchingOptions = [], range: Range<String.Index>? = nil, withTemplate template: String) -> String {
        stringByReplacingMatches(in: string, options: options, range: range?.nsRange(in: string) ?? string.nsRange, withTemplate: template)
    }
    
    /*
     func rangeOfFirstMatch(
         in string: String,
         options: NSRegularExpression.MatchingOptions = [],
         range: Range<String.Index>
     ) -> Range<String.Index>? {
         rangeOfFirstMatch(in: string, options: options, range: NSRange(range, in: string))
     }
      */
}

/*
public extension NSRegularExpression {
    func stringByReplacingMatches(in string: String, options: NSRegularExpression.MatchingOptions = [], range: Range<String.Index>? = nil, withTemplate template: Template) -> String {
        stringByReplacingMatches(in: string, options: options, range: range?.nsRange(in: string) ?? string.nsRange, withTemplate: template.string(for: self))
    }
    
    struct Template: Equatable, ExpressibleByStringLiteral, ExpressibleByStringInterpolation, CustomStringConvertible {
        private let parts: [Part]
        
        public static func group(_ index: Int) -> Self {
            .init([.group(index)])
        }
        
        public static func group(_ name: String) -> Self {
            .init([.namedGroup(name)])
        }
        
        public static var match: Self {
            .init([.match])
        }
        
        public static func +(lhs: Self, rhs: Self) -> Self {
            .init(lhs.parts + rhs.parts)
        }
        
        private init(_ parts: [Part]) {
            self.parts = parts
        }
        
        fileprivate enum Part: Equatable {
            case literal(String)
            case group(Int)
            case namedGroup(String)
            case match
            var string: String {
                switch self {
                case .match: "$0"
                case .literal(let string): ""
                case .group(let index): "$\(index + 1)"
                case .namedGroup(let name): "$\(name)"
                }
            }
        }
        
        func string(for expression: NSRegularExpression) -> String {
            var string = ""
            for part in parts {
                switch part {
                case .match: string += "$0"
                case .literal(let literal):
                    string += literal
                case .group(let index):
                    let index = index + 1
                    guard index >= 1, index < expression.numberOfCaptureGroups + 1 else { continue }
                    string += "$\(index)"
                case .namedGroup(let name):
                    guard let index = expression.captureGroupIndex(withName: name) else { continue }
                    string += "$\(index + 1)"
                }
            }
            return string
        }
        
        public init(stringLiteral value: String) {
            parts = [.literal(value)]
        }
        
        public init(stringInterpolation: StringInterpolation) {
            parts = stringInterpolation.parts
        }
        
        public var description: String {
            parts.map { $0.string }.joined()
        }
        
        public struct StringInterpolation: StringInterpolationProtocol {
            fileprivate var parts: [Part] = []
                        
            public init(literalCapacity: Int, interpolationCount: Int) {}
            
            public mutating func appendLiteral(_ literal: String) {
                guard literal != "" else { return }
                parts.append(.literal(literal))
            }
            
            public mutating func appendInterpolation(group: Int) {
                parts.append(.group(group))
            }
            
            public mutating func appendInterpolation(group groupName: String) {
                parts.append(.namedGroup(groupName))
            }
            
            public mutating func appendInterpolation(_ template: Template) {
                parts.append(contentsOf: template.parts)
            }
        }
    }
}
*/
