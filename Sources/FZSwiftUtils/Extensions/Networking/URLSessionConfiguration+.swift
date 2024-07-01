//
//  URLSessionConfiguration+.swift
//
//
//  Created by Florian Zand on 01.08.23.
//

import Foundation

public extension URLSessionConfiguration {
    /// A dictionary of additional headers to send with requests.
    var allHTTPHeaderFieldsMapped: [HTTPRequestHeaderFieldKey: Any] {
        get {
            guard let allHTTPHeaderFields = httpAdditionalHeaders else { return [:] }
            var mapped: [HTTPRequestHeaderFieldKey: Any] = [:]
            for value in allHTTPHeaderFields {
                if let rawValue = value.key as? String {
                    let key = HTTPRequestHeaderFieldKey(rawValue: rawValue)
                    mapped[key] = allHTTPHeaderFields[value.key]
                }
            }
            return mapped
        }
        set {
            guard !newValue.isEmpty else {
                httpAdditionalHeaders = nil
                return
            }
            httpAdditionalHeaders = [:]
            for key in newValue.keys {
                httpAdditionalHeaders?[key.rawValue] = newValue[key]
            }
        }
    }
}
