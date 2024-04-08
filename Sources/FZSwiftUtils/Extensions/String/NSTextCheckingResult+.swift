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
        guard let url = url, url.scheme == "mailto" else { return nil }
        return  url.absoluteString.replacingOccurrences(of: "mailto:", with: "")
    }
}

extension NSTextCheckingResult.CheckingType {
    static var emailAddress = NSTextCheckingResult.CheckingType(rawValue: 1 << 64)
}
