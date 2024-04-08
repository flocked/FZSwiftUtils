//
//  NSTextCheckingResult+.swift
//
//
//  Created by Florian Zand on 08.04.24.
//

import Foundation

extension NSTextCheckingResult.CheckingType {
    public static var emailAddress = NSTextCheckingResult.CheckingType(rawValue: 1 << 64)
}

extension NSTextCheckingResult {
    /// The email address of a type checking result.
    public var emailAddress: String? {
        guard let url = url, url.scheme == "mailto" else { return nil }
        return  url.absoluteString.replacingOccurrences(of: "mailto:", with: "")
    }
    
    public func matches(in string: String) -> [StringMatch] {
        (0..<numberOfRanges).compactMap {
            let rangeBounds = range(at: $0)
            guard let range = Range(rangeBounds, in: string) else { return nil }
            return StringMatch(range: range, in: string)
        }
    }
}

public struct TextCheckingResult {
    /// The range of the matched string within the source string.
    public let range: Range<String.Index>
    /// The result type.
    public let type: ResultType
    
    public enum ResultType {
        case emailAddress(String)
        case url(URL)
        case phoneNumber(String)
        case address([NSTextCheckingKey : String])
        case date(Date)
        case orthography(NSOrthography)
    }
}
