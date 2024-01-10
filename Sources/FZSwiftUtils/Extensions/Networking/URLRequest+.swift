//
//  URLRequest+.swift
//
//
//  Created by Florian Zand on 06.03.23.
//

import Foundation

public extension URLRequest {
    /**
     Adds a range HTTP header for the specified data. This e.g. allows to resume a data download.

     - Parameter data: The data used for the HTTP header.
     - Parameter validator: A validator to ensure the requested data hasn't changed on the server since the last request. You can obtain the validator on previous url responses via `URLResponse` `validator`.
     */
    mutating func addRangeHeader(for data: Data, validator: String? = nil) {
        var headers = allHTTPHeaderFields ?? [:]
        headers["Range"] = "bytes=\(data.count)-"
        if let validator = validator {
            headers["If-Range"] = validator
        }
        allHTTPHeaderFields = headers
    }

    /**
     Adds a range HTTP header for the specified file. This e.g. allows to resume downloading the file.

     - Parameter file: A local file used for the HTTP header.
     - Parameter validator: A validator to ensure the requested data hasn't changed on the server since the last request. You can obtain the validator on previous url responses via `URLResponse` `validator`.
     */
    mutating func addRangeHeader(for file: URL, validator: String? = nil) {
        guard let fileSize = file.resources.fileSize, fileSize != .zero else { return }
        var headers = allHTTPHeaderFields ?? [:]
        headers["Range"] = "bytes=\(fileSize.bytes)-"
        if let validator = validator {
            headers["If-Range"] = validator
        }
        allHTTPHeaderFields = headers
    }

    /**
     Adds multiple HTTP headers to the URLRequest.

     - Parameter headerValues: A dictionary of header field-value pairs to add to the URLRequest.

     This method provides the ability to add multiple values to header fields. If a value was previously set for the specified field, the supplied value is appended to the existing value using the appropriate field delimiter (a comma).
     Certain header fields are reserved (see Reserved HTTP Headers). Do not use this method to change such headers.
     */
    mutating func addHTTPHeaders(_ headerValues: [String: String]) {
        headerValues.forEach { self.addValue($0.value, forHTTPHeaderField: $0.key) }
    }

    /**
     The range of bytes specified in the "Range" header field of the request.

     The range is represented as a closed range of integer values, indicating the start and end positions of the byte range.
     */
    var bytesRanges: ClosedRange<Int>? {
        get {
            if let string = allHTTPHeaderFields?["Range"] {
                let matches = string.matches(regex: "bytes=(\\d+)-(\\d+)").compactMap(\.string)
                if matches.count == 2, let from = Int(matches[0]), let to = Int(matches[1]) {
                    return from ... to
                }
            }
            return nil
        }
        set {
            if let byteRange = newValue {
                // bytes=345234-34555
                setValue("bytes=\(byteRange.lowerBound)-\(byteRange.upperBound)", forHTTPHeaderField: "Range")
            } else {
                setValue(nil, forHTTPHeaderField: "Range")
            }
        }
    }

    /**
     Returns the curl command equivalent of the URLRequest.

     The curl command string includes the URL, HTTP method, headers, and body (if present) of the URLRequest.

     - Important: The generated curl command may not accurately represent all aspects of the URLRequest, such as multipart form data.

     - Returns: A string representing the curl command equivalent of the URLRequest.
     */
    var curlString: String {
        guard let url = url else { return "" }

        var baseCommand = "curl \(url.absoluteString)"
        if httpMethod == "HEAD" {
            baseCommand += " --head"
        }

        var command = [baseCommand]
        if let method = httpMethod, method != "GET", method != "HEAD" {
            command.append("-X \(method)")
        }

        if let headers = allHTTPHeaderFields {
            for (key, value) in headers where key != "Cookie" {
                command.append("-H '\(key): \(value)'")
            }
        }

        if let data = httpBody,
           let body = String(data: data, encoding: .utf8)
        {
            command.append("-d '\(body)'")
        }

        return command.joined(separator: " \\\n\t")
    }

    /// A dictionary containing all of the HTTP header fields for a request.
    var allHTTPHeaderFieldsMapped: [HTTPRequestHeaderFieldKey: String]? {
        get {
            guard let allHTTPHeaderFields = allHTTPHeaderFields else { return nil }
            var dic: [HTTPRequestHeaderFieldKey: String] = [:]
            for key in allHTTPHeaderFields.keys.compactMap({ HTTPRequestHeaderFieldKey(rawValue: $0) }) {
                dic[key] = allHTTPHeaderFields[key.rawValue]
            }
            return dic
        }
        set {
            guard let newValue = newValue else {
                allHTTPHeaderFields = nil
                return
            }
            allHTTPHeaderFields = [:]
            for key in newValue.keys {
                allHTTPHeaderFields?[key.rawValue] = newValue[key]
            }
        }
    }
}

/// Enumeration of all HTTP request header field keys.
public enum HTTPRequestHeaderFieldKey: Hashable, CaseIterable, RawRepresentable, ExpressibleByStringLiteral {
    case accept
    case acceptCharset
    case acceptEncoding
    case acceptLanguage
    case authorization
    case cacheControl
    case connection
    case cookie
    case contentLength
    case contentMD5
    case contentType
    case date
    case expect
    case forwarded
    case from
    case host
    case ifMatch
    case ifModifiedSince
    case ifNoneMatch
    case ifRange
    case ifUnmodifiedSince
    case maxForwards
    case pragma
    case proxyAuthorization
    case range
    case referer
    case TE
    case transferEncoding
    case upgrade
    case userAgent
    case via
    case warning
    case custom(String)

    public init(stringLiteral value: String) {
        if let first = Self.allCases.first(where: { $0.rawValue == value }) {
            self = first
        } else {
            self = .custom(value)
        }
    }

    public init(rawValue: String) {
        if let first = Self.allCases.first(where: { $0.rawValue == rawValue }) {
            self = first
        } else {
            self = .custom(rawValue)
        }
    }

    public static var allCases: [Self] = [.accept, .acceptCharset, .acceptEncoding, .acceptLanguage, .authorization, .cacheControl, .connection, .cookie, .contentLength, .contentMD5, .contentType, .date, .expect, .forwarded, .from, .host, .ifMatch, .ifModifiedSince, .ifNoneMatch, .ifRange, .ifUnmodifiedSince, .maxForwards, .pragma, .proxyAuthorization, .range, .referer, .TE, .transferEncoding, .upgrade, .userAgent, .via, .warning]

    public var rawValue: String {
        switch self {
        case .accept: return "Accept"
        case .acceptCharset: return "Accept-Charset"
        case .acceptEncoding: return "Accept-Encoding"
        case .acceptLanguage: return "Accept-Language"
        case .authorization: return "Authorization"
        case .cacheControl: return "Cache-Control"
        case .connection: return "Connection"
        case .cookie: return "Cookie"
        case .contentLength: return "Content-Length"
        case .contentMD5: return "Content-MD5"
        case .contentType: return "Content-Type"
        case .date: return "Date"
        case .expect: return "Expect"
        case .forwarded: return "Forwarded"
        case .from: return "From"
        case .host: return "Host"
        case .ifMatch: return "If-Match"
        case .ifModifiedSince: return "If-Modified-Since"
        case .ifNoneMatch: return "If-None-Match"
        case .ifRange: return "If-Range"
        case .ifUnmodifiedSince: return "If-Unmodified-Since"
        case .maxForwards: return "Max-Forwards"
        case .pragma: return "Pragma"
        case .proxyAuthorization: return "Proxy-Authorization"
        case .range: return "Range"
        case .referer: return "Referer"
        case .TE: return "TE"
        case .transferEncoding: return "Transfer-Encoding"
        case .upgrade: return "Upgrade"
        case .userAgent: return "User-Agent"
        case .via: return "Via"
        case .warning: return "Warning"
        case let .custom(string): return string
        }
    }
}
