//
//  URLSessionConfiguration+.swift
//
//
//  Created by Florian Zand on 01.08.23.
//

import Foundation

public extension URLSessionConfiguration {
    /// A dictionary of additional headers to send with requests.
    var httpAdditionalHeadersMapped: [HTTPRequestHeaderFieldKey: Any] {
        get {
            httpAdditionalHeaders?.reduce(into: [HTTPRequestHeaderFieldKey:Any](), { partialResult, value in
                guard let key = value.key as? String else { return }
                partialResult[HTTPRequestHeaderFieldKey(rawValue: key)] = value.value
            }) ?? [:]
        }
        set { httpAdditionalHeaders = newValue.mapKeys({ $0.rawValue as AnyHashable }) }
    }
}
