//
//  URLRequest+.swift
//
//
//  Created by Florian Zand on 06.03.23.
//

import Foundation

public extension URLRequest {
    /**
     Adds a `Range` HTTP header to the request, specifying that the request should continue from the end of the given `Data` object.

     This is useful for resuming interrupted downloads or uploads, allowing the server to send only the remaining bytes.

     - Parameters:
       - data: The existing partial `Data` to determine the starting byte for the range.
       - validator: A validator (e.g. `ETag` or `last-modified date`). If provided, it will be added as the `If-Range` header to ensure the requested range is only served if the validator still matches.
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
     Adds a `Range` HTTP header to the request, specifying that the request should continue from the end of the given file.

     This is useful for resuming file downloads or uploads from disk, allowing the server to send only the remaining bytes.

     - Parameters:
       - file: The file `URL` pointing to the partially downloaded file. It's current size is used to calculate the starting byte for the range.
       - validator: A validator (e.g. `ETag` or `last-modified date`). If provided, it will be added as the `If-Range` header to ensure the requested range is only served if the validator still matches.

     - Note: The file must be a local file `URL` with a valid file size.. If the file doesn't exist or the size is 'zero', this method does nothing.
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
                let matches = string.matches(pattern: "bytes=(\\d+)-(\\d+)").compactMap(\.string)
                if matches.count == 2, let from = Int(matches[0]), let to = Int(matches[1]) {
                    return from ... to
                }
            }
            return nil
        }
        set {
            if let byteRange = newValue {
                setValue("bytes=\(byteRange.lowerBound)-\(byteRange.upperBound)", forHTTPHeaderField: "Range")
            } else {
                setValue(nil, forHTTPHeaderField: "Range")
            }
        }
    }

    /**
     Returns the curl command equivalent of the request.

     The curl command string includes the URL, HTTP method, headers, and body (if present) of the request.

     - Important: The generated curl command may not accurately represent all aspects of the request, such as multipart form data.

     - Returns: A string representing the curl command equivalent of the request.
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
    var httpHeaderFields: [HTTPRequestHeaderFieldKey: String] {
        get { allHTTPHeaderFields?.mapKeys({ HTTPRequestHeaderFieldKey(rawValue: $0) }) ?? [:] }
        set { allHTTPHeaderFields = newValue.mapKeys({$0.rawValue}) }
    }
}

/// Enumeration of all HTTP request header field keys.
public enum HTTPRequestHeaderFieldKey: Hashable, CaseIterable, RawRepresentable, ExpressibleByStringLiteral, CustomStringConvertible {
    /// Media types that are acceptable for the response.
    case accept
    /// Character sets that are acceptable.
    case acceptCharset
    /// List of acceptable encodings.
    case acceptEncoding
    /// List of acceptable human languages.
    case acceptLanguage
    /// Credentials for authenticating the client with the server.
    case authorization
    /// Directives for caching mechanisms.
    case cacheControl
    /// Options for the connection (e.g., keep-alive).
    case connection
    /// Cookies previously sent by the server.
    case cookie
    /// The size of the request body in octets (8-bit bytes).
    case contentLength
    /// Base64-encoded 128-bit MD5 digest of the message body.
    case contentMD5
    /// The media type of the request body.
    case contentType
    /// The date and time at which the message was originated.
    case date
    /// Indicates that particular server behaviors are required by the client.
    case expect
    /// Discloses the client’s original IP address and other forwarding information.
    case forwarded
    /// The email address of the user making the request.
    case from
    /// The domain name of the server and optionally the port number.
    case host
    /// A conditional request header matching the entity tag.
    case ifMatch
    /// A conditional request header checking the modification date.
    case ifModifiedSince
    /// A conditional request header checking if none match the given ETags.
    case ifNoneMatch
    /// A conditional request header used with range requests.
    case ifRange
    /// A conditional request header ensuring the resource hasn't changed.
    case ifUnmodifiedSince
    /// Limits the number of times a request can be forwarded.
    case maxForwards
    /// Implementation-specific directives that might influence caching.
    case pragma
    /// Credentials for authenticating with a proxy.
    case proxyAuthorization
    /// Specifies the part(s) of a document that the server should return.
    case range
    /// The address of the previous web page from which a link to the current page was followed.
    case referer
    /// Indicates the transfer codings the user agent is willing to accept.
    case TE
    /// The form of encoding used to safely transfer the payload body.
    case transferEncoding
    /// Allows the client to specify which protocol upgrades it supports.
    case upgrade
    /// The user agent string of the client software.
    case userAgent
    /// Informs the server of intermediate protocols and recipients.
    case via
    /// General warnings about possible problems with the request.
    case warning
    /// Names of headers used in CORS preflight request indicating requested headers.
    case accessControlRequestHeaders
    /// Indicates the HTTP method to be used in a CORS request.
    case accessControlRequestMethod
    /// Originating URI of the request initiating the fetch.
    case origin
    /// Identifies Ajax requests, commonly set to "XMLHttpRequest".
    case xRequestedWith
    /// Identifies the originating IP address of a client connecting through a proxy.
    case xForwardedFor
    /// Identifies the protocol (HTTP or HTTPS) used by the client connecting through a proxy.
    case xForwardedProto
    /// Indicates the client’s real IP address when behind a reverse proxy.
    case xRealIP
    /// Indicates the user’s tracking preference ("Do Not Track").
    case dnt
    /// Entity tag for cache validation.
    case etag
    /// Indicates the patch document media types accepted by the server.
    case acceptPatch
    /// Indicates how content should be presented (e.g., inline, attachment).
    case contentDisposition
    /// Describes the natural language(s) of the intended audience for the enclosed content.
    case contentLanguage
    /// Used to describe relationships between resources.
    case link
    /// Indicates how long the client should wait before making a follow-up request.
    case retryAfter
    /// A custom or non-standard HTTP header.
    case custom(String)
    
    public init(stringLiteral value: String) {
        self = .init(rawValue: value)
    }

    public init(rawValue: String) {
        let normalized = rawValue.lowercased()
        if let match = Self.allCases.first(where: { $0.rawValue.lowercased() == normalized }) {
            self = match
        } else {
            self = .custom(rawValue)
        }
    }
    
    public var description: String {
        rawValue
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
        case .accessControlRequestHeaders: return "Access-Control-Request-Headers"
        case .accessControlRequestMethod: return "Access-Control-Request-Method"
        case .origin: return "Origin"
        case .xRequestedWith: return "X-Requested-With"
        case .xForwardedFor: return "X-Forwarded-For"
        case .xForwardedProto: return "X-Forwarded-Proto"
        case .xRealIP: return "X-Real-IP"
        case .dnt: return "DNT"
        case .etag: return "ETag"
        case .acceptPatch: return "Accept-Patch"
        case .contentDisposition: return "Content-Disposition"
        case .contentLanguage: return "Content-Language"
        case .link: return "Link"
        case .retryAfter: return "Retry-After"
        case let .custom(string): return string
        }
    }
}
