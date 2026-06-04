//
//  URLRequest+.swift
//
//
//  Created by Florian Zand on 06.03.23.
//

import Foundation

public extension URLRequest {
    /**
     The cookies attached to the request.
     
     Setting this value updates the request's `Cookie` header field.
     */
    var cookies: [HTTPCookie] {
        get {
            guard let url = url else { return [] }
            return HTTPCookie.cookies(withResponseHeaderFields: allHTTPHeaderFields ?? [:], for: url)
        }
        set {
            guard !newValue.isEmpty else {
                setValue(nil, forHTTPHeaderField: "Cookie")
                return
            }
            for (field, value) in HTTPCookie.requestHeaderFields(with: newValue) {
                setValue(value, forHTTPHeaderField: field)
            }
        }
    }
    
    /// Sets the cookies attached to the request by replacing the `Cookie` header field.
    func cookies(_ cookies: [HTTPCookie]) -> Self {
        var request = self
        request.cookies = cookies
        return request
    }
    
    /// Sets the HTTP request method.
    func httpMethod(_ method: HTTPMethod) -> Self {
        var request = self
        request.httpMethod = method.rawValue
        return request
    }
    
    /**
     Adds a `Range` HTTP header to the request, specifying that the request should continue from the end of the given `Data` object.

     This is useful for resuming interrupted downloads or uploads, allowing the server to send only the remaining bytes.

     - Parameters:
       - data: The existing partial `Data` to determine the starting byte for the range.
       - validator: A validator (e.g. `ETag` or `last-modified date`). If provided, it will be added as the `If-Range` header to ensure the requested range is only served if the validator still matches.
     */
    mutating func addRangeHeader(for data: Data, validator: String? = nil) {
        bytesRange = .from(UInt64(data.count))
        setValue(validator, forHTTPHeaderField: "If-Range")
    }


    /**
     Adds a `Range` HTTP header to the request, specifying that the request should continue from the end of the given file.

     This is useful for resuming file downloads or uploads from disk, allowing the server to send only the remaining bytes.

     - Parameters:
       - file: The file `URL` pointing to the partially downloaded file. It's current size is used to calculate the starting byte for the range.
       - validator: A validator (e.g. `ETag` or `last-modified date`). If provided, it will be added as the `If-Range` header to ensure the requested range is only served if the validator still matches.

     - Note: The file must be a local file `URL` with a valid file size.. If the file doesn't exist or the size is 'zero', this method does nothing.
     */
    mutating func addRangeHeader(for file: URL, validator: String? = nil) {
        guard let fileSize = file.resources.fileSize, fileSize != .zero else { return }
        bytesRange = .from(fileSize.bytes)
        setValue(validator, forHTTPHeaderField: "If-Range")
    }

    /**
     Adds multiple HTTP headers to the URLRequest.

     - Parameter headerValues: A dictionary of header field-value pairs to add to the URLRequest.

     This method provides the ability to add multiple values to header fields. If a value was previously set for the specified field, the supplied value is appended to the existing value using the appropriate field delimiter (a comma).
     Certain header fields are reserved (see Reserved HTTP Headers). Do not use this method to change such headers.
     */
    mutating func addHTTPHeaders(_ headerValues: [String: String]) {
        headerValues.forEach { addValue($0.value, forHTTPHeaderField: $0.key) }
    }
    
    /**
     Represents an HTTP byte range used by the `Range`  request header field.

     The `Range` header field allows a client to request only a portion of a resource instead of the entire body.
     */
    enum HTTPByteRange {
        /// Requests bytes between the specified start and end offsets, inclusive.
        case range(from: UInt64, to: UInt64)
        /// Requests all bytes starting at the specified offset until the end of the resource.
        case from(UInt64)
        /// Requests the specified number of bytes from the end of the resource.
        case last(UInt64)
    }
    
    /**
     The HTTP byte range requested by the `Range` header field.
     
     Setting this value updates the request's `Range` header field.
     */
    var bytesRange: HTTPByteRange? {
        get {
            guard let value = value(forHTTPHeaderField: "Range"), value.hasPrefix("bytes=") else { return nil }
            let parts = value.dropFirst("bytes=".count).split(separator: "-", maxSplits: 1, omittingEmptySubsequences: false)
            switch (UInt64(parts[safe: 0] ?? ""), UInt64(parts[safe: 1] ?? "")) {
            case let (start?, end?):
                return .range(from: start, to: end)
            case let (start?, nil):
                return .from(start)
            case let (nil, end?):
                return .last(end)
            case (nil, nil):
                return nil
            }
        }
        set {
            switch newValue {
            case let .range(start, end):
                setValue("bytes=\(start)-\(end)", forHTTPHeaderField: "Range")
            case let .from(start):
                setValue("bytes=\(start)-", forHTTPHeaderField: "Range")
            case let .last(length):
                setValue("bytes=-\(length)", forHTTPHeaderField: "Range")
            case nil:
                setValue(nil, forHTTPHeaderField: "Range")
            }
        }
    }

    /// A dictionary containing all of the HTTP header fields for a request.
    var httpHeaderFields: [HTTPRequestHeaderField: String] {
        get { allHTTPHeaderFields?.mapKeys({ HTTPRequestHeaderField($0) }) ?? [:] }
        set { allHTTPHeaderFields =  newValue.mapKeys({$0.rawValue}) }
    }
    
    /// The request headers mapped to strongly typed values.
    var httpHeaders: HTTPRequestHeaders {
        get { .init(headers: httpHeaderFields) }
        set { httpHeaderFields = newValue.headers }
    }
    
    internal func copy(as httpMethod: HTTPMethod) -> Self {
        var request = self
        request.httpMethod = httpMethod.rawValue
        request.httpBody = nil
        request.httpBodyStream = nil
        return request
    }
}

extension URLRequest: Swift.Encodable, Swift.Decodable {
    public init(from decoder: any Decoder) throws {
        self = try NSURLRequest.unarchive(decoder.decodeSingle()) as URLRequest
    }
    
    public func encode(to encoder: any Encoder) throws {
        try encoder.encodeSingle((self as NSURLRequest).archivedData())
    }
}

extension URLRequest {
    func swiftCode() -> String? {
        guard let url = url?.absoluteString else { return nil }
        var mainParts = ["url: URL(string: \(url.swiftStringLiteral))!"]
        if cachePolicy != .useProtocolCachePolicy {
            mainParts += "cachePolicy: \(cachePolicy.string)"
        }
        if timeoutInterval != 60.0 {
            mainParts += "timeoutInterval: \(timeoutInterval)"
        }
        
        var strings = ["var request = URLRequest(\(mainParts.joined(separator: ", ")))"]
        if let httpMethod, httpMethod != "GET" {
            strings += "request.httpMethod = \(httpMethod.swiftStringLiteral)"
        }
        if let mainDocumentURL = mainDocumentURL?.absoluteString {
            strings += "request.mainDocumentURL = URL(string: \(mainDocumentURL.swiftStringLiteral))"
        }
        if !httpShouldHandleCookies {
            strings += "request.httpShouldHandleCookies = false"
        }
        strings += (allHTTPHeaderFields ?? [:]).map({ "request.addValue(\($0.value.swiftStringLiteral), forHTTPHeaderField: \($0.key.swiftStringLiteral))" })

        return strings.joined(separator: "\n")
    }
}

fileprivate extension URLRequest.CachePolicy {
    var string: String {
        switch self {
        case .useProtocolCachePolicy: ".useProtocolCachePolicy"
        case .reloadIgnoringLocalAndRemoteCacheData: ".reloadIgnoringLocalAndRemoteCacheData"
        case .reloadIgnoringLocalCacheData: ".reloadIgnoringLocalCacheData"
        case .reloadRevalidatingCacheData: ".reloadRevalidatingCacheData"
        case .returnCacheDataDontLoad: ".returnCacheDataDontLoad"
        case .reloadIgnoringCacheData: ".reloadIgnoringCacheData"
        case .returnCacheDataElseLoad: ".returnCacheDataElseLoad"
        default: ".init(rawValue: \(rawValue))!"
        }
    }
}
