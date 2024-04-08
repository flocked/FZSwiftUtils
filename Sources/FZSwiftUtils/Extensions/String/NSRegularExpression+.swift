//
//  NSRegularExpression+.swift
//
//
//  Created by Florian Zand on 08.04.24.
//

import Foundation

extension NSRegularExpression {
    /**
     Returns an array containing all the matches of the regular expression in the string.
     
     - Parameter string: The string to search.
     
     - Returns: An array of `NSTextCheckingResult` objects. Each result gives the overall matched range via its `range` property, and the range of each individual capture group via its `range(at:)` method. The range `{NSNotFound, 0}` is returned if one of the capture groups did not participate in this particular match.
     */
    public func matches(in string: String) -> [NSTextCheckingResult] {
        matches(in: string, range: string.nsRange)
    }
    
    /**
     Returns an array containing all the matches of the regular expression in the string.
     
     - Parameters:
        - string: The string to search.
        - options: The matching options to use. See `MatchingOptions` for possible values.
     
     - Returns: An array of `NSTextCheckingResult` objects. Each result gives the overall matched range via its `range` property, and the range of each individual capture group via its `range(at:)` method. The range `{NSNotFound, 0}` is returned if one of the capture groups did not participate in this particular match.
     */
    public func matches(in string: String, options: MatchingOptions) -> [NSTextCheckingResult] {
        matches(in: string, options: options, range: string.nsRange)
    }
}
