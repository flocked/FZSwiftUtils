//
//  URLSessionConfiguration+.swift
//
//
//  Created by Florian Zand on 01.08.23.
//

import Foundation

public extension URLSessionConfiguration {
    /// A dictionary of additional headers to send with requests.
    var allHTTPHeaderFieldsMapped: [HTTPRequestHeaderFieldKey: String]? {
        get {
            guard let allHTTPHeaderFields = httpAdditionalHeaders else { return nil }
            var dic: [HTTPRequestHeaderFieldKey: String] = [:]
            for value in allHTTPHeaderFields {
                if let rawValue = value.key as? String {
                    let key = HTTPRequestHeaderFieldKey(rawValue: rawValue)
                    dic[key] = allHTTPHeaderFields[value.key] as? String
                }
            }
            return dic
        }
        set {
            guard let newValue = newValue else {
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
