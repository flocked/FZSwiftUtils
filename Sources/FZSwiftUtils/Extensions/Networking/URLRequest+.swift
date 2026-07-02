//
//  URLRequest+.swift
//
//
//  Created by Florian Zand on 06.03.23.
//

import Foundation

public extension URLRequest {
    /**
     Creates and initializes a URL request with the given URL, cache policy, and timeout interval.
     
     - Parameters:
        - url: The URL for the request.
        - cachePolicy: The cache policy for the request.
        - timeoutInterval: The timeout interval for the request. See the commentary for the timeoutInterval for more information on timeout intervals.
     */
    @_disfavoredOverload
    init(url: URL, cachePolicy: CachePolicy = .useProtocolCachePolicy, timeoutInterval: TimeDuration) {
        self.init(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval.seconds)
    }
    
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
    @_disfavoredOverload
    func httpMethod(_ method: HTTPMethod) -> Self {
        var request = self
        request.httpMethod = method.rawValue
        return request
    }
    
    /// Sets the HTTP request method.
    func httpMethod(_ method: String?) -> Self {
        var request = self
        request.httpMethod = method
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
        
        /// Requests bytes between the specified start and end offsets, inclusive.
        @_disfavoredOverload
        public static func range(from: DataSize, to: DataSize) -> Self {
            .range(from: from.bytes, to: to.bytes)
        }
        
        /// Requests all bytes starting at the specified offset until the end of the resource.
        @_disfavoredOverload
        public static func from(_ from: DataSize) -> Self {
            .from(from.bytes)
        }
        
        /// Requests the specified number of bytes from the end of the resource.
        @_disfavoredOverload
        public static func last(_ last: DataSize) -> Self {
            .last(last.bytes)
        }
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
    
    /// Sets the HTTP byte range requested by the `Range` header field.
    func bytesRange(_ bytesRange: HTTPByteRange?) -> Self {
        var request = self
        request.bytesRange = bytesRange
        return self
    }
    
    /// The request headers mapped to strongly typed values.
    var httpHeaders: HTTPRequestHeaders {
        get { .init(headers: httpHeaderFields) }
        set { httpHeaderFields = newValue.headers }
    }

    /// A dictionary containing all of the HTTP header fields for a request.
    var httpHeaderFields: [HTTPRequestHeaderField: String] {
        get { allHTTPHeaderFields?.mapKeys { HTTPRequestHeaderField($0) } ?? [:] }
        set { allHTTPHeaderFields = newValue.isEmpty ? nil : newValue.mapKeys { $0.rawValue } }
    }
    
    /// Sets the dictionary containing all of the HTTP header fields for the request.
    func httpHeaderFields(_ httpHeaderFields: [HTTPRequestHeaderField: String]) -> Self {
        var request = self
        request.httpHeaderFields = httpHeaderFields
        return self
    }
    
    /// Sets the dictionary containing all of the HTTP header fields for the request.
    func httpHeaderFields(_ httpHeaderFields: [String: String]) -> Self {
        var request = self
        request.allHTTPHeaderFields = httpHeaderFields.isEmpty ? nil : httpHeaderFields
        return self
    }
    
    /// Sets the URL of the request.
    func url(_ url: URL?) -> Self {
        var request = self
        request.url = url
        return self
    }
    
    /// Sets the request’s cache policy.
    func cachePolicy(_ cachePolicy: CachePolicy) -> Self {
        var request = self
        request.cachePolicy = cachePolicy
        return self
    }
    
    /// Sets the timeout interval of the request.
    func timeoutInterval(_ timeoutInterval: TimeInterval) -> Self {
        var request = self
        request.timeoutInterval = timeoutInterval
        return self
    }
    
    /// Sets the timeout interval of the request.
    @_disfavoredOverload
    func timeoutInterval(_ timeoutInterval: TimeDuration) -> Self {
        var request = self
        request.timeoutInterval = timeoutInterval.seconds
        return self
    }
    
    /// Sets the data sent as the message body of a request, such as for an HTTP POST request.
    func httpBody(_ httpBody: Data?) -> Self {
        var request = self
        request.httpBody = httpBody
        return self
    }
    
    /// Sets the stream used to deliver the HTTP body.
    func httpBodyStream(_ httpBodyStream: InputStream?) -> Self {
        var request = self
        request.httpBodyStream = httpBodyStream
        return self
    }
    
    /// Sets the main document URL associated with this request.
    func mainDocumentURL(_ mainDocumentURL: URL?) -> Self {
        var request = self
        request.mainDocumentURL = mainDocumentURL
        return self
    }
    
    /// Sets the Boolean value indicating whether cookies will be sent with and set for this request.
    func httpShouldHandleCookies(_ httpShouldHandleCookies: Bool) -> Self {
        var request = self
        request.httpShouldHandleCookies = httpShouldHandleCookies
        return self
    }
    
    /// Sets the Boolean value indicating whether the request is allowed to use the built-in cellular radios to satisfy the request.
    func allowsCellularAccess(_ allows: Bool) -> Self {
        var request = self
        request.allowsCellularAccess = allows
        return self
    }
    
    /// Sets the Boolean value indicating whether the request is allowed to store and use DNS answers, potentially beyond TTL expiry, in a persistent per-process cache, false otherwise.
    @available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, *)
    func allowsPersistentDNS(_ allows: Bool) -> Self {
        var request = self
        request.allowsPersistentDNS = allows
        return self
    }
    
    /// Sets the Boolean value indicating whether the server endpoint is known to support HTTP/3.
    func assumesHTTP3Capable(_ assumesHTTP3Capable: Bool) -> Self {
        var request = self
        request.assumesHTTP3Capable = assumesHTTP3Capable
        return self
    }
    
    /// Sets the Boolean value indicating whether the request is required to do DNSSEC validation during DNS lookup.
    @available(macOS 13.0, iOS 16.1, tvOS 16.1, watchOS 9.1, *)
    func requiresDNSSECValidation(_ requires: Bool) -> Self {
        var request = self
        request.requiresDNSSECValidation = requires
        return self
    }
    
    /// Sets the Boolean value that indicates whether the request may use the network when the user has specified Low Data Mode.
    func allowsConstrainedNetworkAccess(_ allows: Bool) -> Self {
        var request = self
        request.allowsConstrainedNetworkAccess = allows
        return self
    }
    
    /// Sets the Boolean value that indicates whether connections may use a network interface that the system considers expensive.
    func allowsExpensiveNetworkAccess(_ allows: Bool) -> Self {
        var request = self
        request.allowsExpensiveNetworkAccess = allows
        return self
    }
    
    /// Sets the type of network service for all tasks within network sessions to enable Cellular Network Slicing.
    func networkServiceType(_ networkServiceType: NetworkServiceType) -> Self {
        var request = self
        request.networkServiceType = networkServiceType
        return self
    }
    
    /// Sets the entity that initiates the network request.
    func attribution(_ attribution: Attribution) -> Self {
        var request = self
        request.attribution = attribution
        return self
    }
    
    /// Sets the Boolean value that indicates whether the receiver is allowed to use an interface marked as ultra-constrained to satify the request.
    @available(macOS 26.1, iOS 26.1, tvOS 26.1, watchOS 26.1, *)
    func allowsUltraConstrainedNetworkAccess(_ allows: Bool) -> Self {
        var request = self
        request.allowsUltraConstrainedNetworkAccess = allows
        return self
    }
    
    /// Sets the cookie partition identifier.
    @available(macOS 15.2, iOS 18.2, tvOS 18.2, watchOS 11.2, *)
    func cookiePartitionIdentifier(_ cookiePartitionIdentifier: String?) -> Self {
        var request = self
        request.cookiePartitionIdentifier = cookiePartitionIdentifier
        return self
    }
    
    /**
     Adds a value to the specified header field.
     
     - Parameters:
        - value: The value for the header field.
        - field: The name of the header field. In keeping with the HTTP RFC, HTTP header field names are case insensitive.
     
     This method provides the ability to add values to header fields incrementally. If a value was previously set for the specified field, the supplied value is appended to the existing value using the appropriate field delimiter (a comma).
     
     Certain header fields are reserved (see [Reserved HTTP Headers](https://developer.apple.com/documentation/foundation/nsurlrequest)). Do not use this method to change such headers.
     */
    @_disfavoredOverload
    mutating func addValue(_ value: String, forHTTPHeaderField field: HTTPRequestHeaderField) {
        addValue(value, forHTTPHeaderField: field.rawValue)
    }
    
    /**
     Sets a value to the specified header field.
     
     - Parameters:
        - value: The new value for the header field. Any existing value for the field is replaced by the new value.
        - field: The name of the header field to set. In keeping with the HTTP RFC, HTTP header field names are case insensitive.
     
     Certain header fields are reserved. Do not use this method to set such headers. Specifically, there is no need for you to set the Content-Length header. See [Reserved HTTP Headers](https://developer.apple.com/documentation/foundation/nsurlrequest).

     */
    @_disfavoredOverload
    mutating func setValue(_ value: String?, forHTTPHeaderField field: HTTPRequestHeaderField) {
        setValue(value, forHTTPHeaderField: field.rawValue)
    }
    
    /**
     Adds multiple HTTP headers to the URLRequest.

     - Parameter headerValues: A dictionary of header field-value pairs to add to the URLRequest.

     This method provides the ability to add multiple values to header fields. If a value was previously set for the specified field, the supplied value is appended to the existing value using the appropriate field delimiter (a comma).
     
     Certain header fields are reserved (see [Reserved HTTP Headers](https://developer.apple.com/documentation/foundation/nsurlrequest)). Do not use this method to change such headers.
     */
    mutating func addHTTPHeaders(_ headerValues: [String: String]) {
        headerValues.forEach { addValue($0.value, forHTTPHeaderField: $0.key) }
    }
    
    /**
     Adds multiple HTTP headers to the URLRequest.

     - Parameter headerValues: A dictionary of header field-value pairs to add to the URLRequest.

     This method provides the ability to add multiple values to header fields. If a value was previously set for the specified field, the supplied value is appended to the existing value using the appropriate field delimiter (a comma).
     
     Certain header fields are reserved (see [Reserved HTTP Headers](https://developer.apple.com/documentation/foundation/nsurlrequest)). Do not use this method to change such headers.
     */
    @_disfavoredOverload
    mutating func addHTTPHeaders(_ headerValues: [HTTPRequestHeaderField: String]) {
        headerValues.forEach { addValue($0.value, forHTTPHeaderField: $0.key) }
    }
    
    /**
     Sets multiple HTTP headers.

     - Parameter headerValues: A dictionary of header field-value pairs to set.
     
     Certain header fields are reserved. Do not use this method to set such headers. Specifically, there is no need for you to set the Content-Length header. See [Reserved HTTP Headers](https://developer.apple.com/documentation/foundation/nsurlrequest).
     */
    mutating func setHTTPHeaders(_ headerValues: [String: String]) {
        headerValues.forEach { setValue($0.value, forHTTPHeaderField: $0.key) }
    }
    
    /**
     Sets multiple HTTP headers.

     - Parameter headerValues: A dictionary of header field-value pairs to set.
     
     Certain header fields are reserved. Do not use this method to set such headers. Specifically, there is no need for you to set the Content-Length header. See [Reserved HTTP Headers](https://developer.apple.com/documentation/foundation/nsurlrequest).
     */
    @_disfavoredOverload
    mutating func setHTTPHeaders(_ headerValues: [HTTPRequestHeaderField: String]) {
        headerValues.forEach { setValue($0.value, forHTTPHeaderField: $0.key) }
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

public extension URLRequest {
    /**
     Generates Swift source code that recreates this `URLRequest`.

     The generated code includes the request URL, cache policy, timeout interval, HTTP method,
     main document URL, cookie handling flag, HTTP headers, and HTTP body when present.
     Optionally, it also includes example `URLSession` code that executes the request.

     - Parameter includeTask: A Boolean value indicating whether to include example
       `URLSession.shared.dataTask(with:)` code that performs the request. The default is `true`.

     - Returns: Swift source code that recreates this `URLRequest`, or `nil` if the request
       does not contain a valid URL.
     */
    func swiftCode(includeTask: Bool = true) -> String? {
        guard let url = url?.absoluteString else { return nil }
        var mainParts = ["url: URL(string: \(url.swiftStringLiteral))!"]
        
        if cachePolicy != .useProtocolCachePolicy {
            mainParts += "cachePolicy: \(cachePolicy.swiftCode)"
        }
        
        if timeoutInterval != 60.0 {
            mainParts += "timeoutInterval: \(timeoutInterval.swiftCode)"
        }
        
        var strings = [
            "var request = URLRequest(\(mainParts.joined(separator: ", ")))"
        ]
        
        if let httpMethod, httpMethod != "GET" {
            strings += "request.httpMethod = \(httpMethod.swiftStringLiteral)"
        }
        
        if let mainDocumentURL = mainDocumentURL?.absoluteString {
            strings += "request.mainDocumentURL = URL(string: \(mainDocumentURL.swiftStringLiteral))"
        }
        
        if !httpShouldHandleCookies {
            strings += "request.httpShouldHandleCookies = false"
        }
        for (field, value) in (allHTTPHeaderFields ?? [:])
            .sorted(by: { $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending }) {
            strings += "request.setValue(\(value.swiftStringLiteral), forHTTPHeaderField: \(field.swiftStringLiteral))"
        }
        
        if let httpBody, !httpBody.isEmpty {
            if let body = String(data: httpBody, encoding: .utf8) {
                strings += "request.httpBody = \(body.swiftStringLiteral).data(using: .utf8)"
            } else {
                strings += "request.httpBody = Data(base64Encoded: \(httpBody.base64EncodedString().swiftStringLiteral))"
            }
        }
        
        if includeTask {
            strings += """
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
              guard let data = data else {
                print(String(describing: error))
                return
              }
              print(String(data: data, encoding: .utf8)!)
            }
            
            task.resume()
            """
        }
        return strings.joined(separator: "\n")
    }
}

private extension String {
    var swiftStringLiteral: String {
        var result = "\""
        for character in self {
            switch character {
            case "\\":
                result += "\\\\"
            case "\"":
                result += "\\\""
            case "\n":
                result += "\\n"
            case "\r":
                result += "\\r"
            case "\t":
                result += "\\t"
            default:
                result += character
            }
        }
        result += "\""
        return result
    }
}

private extension URLRequest.CachePolicy {
    var swiftCode: String {
        switch self {
        case .useProtocolCachePolicy:
            ".useProtocolCachePolicy"
        case .reloadIgnoringLocalCacheData:
            ".reloadIgnoringLocalCacheData"
        case .reloadIgnoringLocalAndRemoteCacheData:
            ".reloadIgnoringLocalAndRemoteCacheData"
        case .returnCacheDataElseLoad:
            ".returnCacheDataElseLoad"
        case .returnCacheDataDontLoad:
            ".returnCacheDataDontLoad"
        case .reloadRevalidatingCacheData:
            ".reloadRevalidatingCacheData"
        @unknown default:
            ".init(rawValue: \(rawValue)) ?? .useProtocolCachePolicy"
        }
    }
}
