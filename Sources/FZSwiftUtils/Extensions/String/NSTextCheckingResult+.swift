//
//  NSTextCheckingResult+.swift
//
//
//  Created by Florian Zand on 08.04.24.
//

import Foundation

extension NSTextCheckingResult {
    /// The email address of a type checking result.
    public var emailAddress: String? {
        guard let url = url, url.absoluteString.hasPrefix("mailto:") else { return nil }
        return  url.absoluteString.replacingOccurrences(of: "mailto:", with: "")
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
