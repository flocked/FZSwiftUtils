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
            guard let matches = allHTTPHeaderFields?["Range"]?.matches(pattern: #"bytes=(\d+)-(\d*)"#).compactMap(\.string) else { return nil }
            guard matches.count == 2, let from = Int(matches[0]) else {
                return nil
            }
            if let to = Int(matches[1]), !matches[1].isEmpty {
                return from...to
            } else {
                return from...Int.max
            }
        }
        set {
            if let byteRange = newValue {
                let headerValue: String
                if byteRange.upperBound == Int.max {
                    headerValue = "bytes=\(byteRange.lowerBound)-"
                } else {
                    headerValue = "bytes=\(byteRange.lowerBound)-\(byteRange.upperBound)"
                }
                setValue(headerValue, forHTTPHeaderField: "Range")
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
        
        // Quote URL to handle spaces/special characters
        let escapedURL = "'\(url.absoluteString.replacingOccurrences(of: "'", with: "'\\''"))'"
        
        var baseCommand = "curl \(escapedURL)"
        
        if httpMethod == "HEAD" {
            baseCommand += " --head"
        }
        
        var command = [baseCommand]
        
        if let method = httpMethod, method != "GET", method != "HEAD" {
            command.append("-X \(method)")
        }
        
        if let headers = allHTTPHeaderFields {
            for (key, value) in headers where key.caseInsensitiveCompare("Cookie") != .orderedSame {
                let escapedKey = key.replacingOccurrences(of: "'", with: "'\\''")
                let escapedValue = value.replacingOccurrences(of: "'", with: "'\\''")
                command.append("-H '\(escapedKey): \(escapedValue)'")
            }
        }
        
        if let data = httpBody,
           let body = String(data: data, encoding: .utf8) {
            let escapedBody = body.replacingOccurrences(of: "'", with: "'\\''")
            command.append("-d '\(escapedBody)'")
        }
        
        return command.joined(separator: " \\\n\t")
    }

    /// A dictionary containing all of the HTTP header fields for a request.
    var httpHeaderFields: [HTTPRequestHeaderField: String] {
        get { allHTTPHeaderFields?.mapKeys({ HTTPRequestHeaderField($0) }) ?? [:] }
        set { allHTTPHeaderFields = newValue.mapKeys({$0.rawValue}) }
    }
}

/// A representation of HTTP request header fields.
public struct HTTPRequestHeaderField: RawRepresentable, ExpressibleByStringLiteral, Hashable {
    /// The name of the HTTP request header field as a string (e.g., `"Content-Type"`, `"User-Agent"`).
    public let rawValue: String

    /// Creates a HTTP request header field key.
    public init(stringLiteral value: String) {
        self.rawValue = value
    }

    /// Creates a HTTP request header field key.
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    /// Creates a HTTP request header field key.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    /// Media types that are acceptable for the response.
    public static let accept: Self = "Accept"
    /// Character sets that are acceptable.
    public static let acceptCharset: Self = "Accept-Charset"
    /// List of acceptable encodings.
    public static let acceptEncoding: Self = "Accept-Encoding"
    /// List of acceptable human languages.
    public static let acceptLanguage: Self = "Accept-Language"
    /// Indicates the patch document media types accepted by the server.
    public static let acceptPatch: Self = "Accept-Patch"
    /// Names of headers used in CORS preflight request indicating requested headers.
    public static let accessControlRequestHeaders: Self = "Access-Control-Request-Headers"
    /// Indicates the HTTP method to be used in a CORS request.
    public static let accessControlRequestMethod: Self = "Access-Control-Request-Method"
    /// Credentials for authenticating the client with the server.
    public static let authorization: Self = "Authorization"
    /// Directives for caching mechanisms.
    public static let cacheControl: Self = "Cache-Control"
    /// Options for the connection (e.g., keep-alive).
    public static let connection: Self = "Connection"
    /// Cookies previously sent by the server.
    public static let cookie: Self = "Cookie"
    /// The size of the request body in octets (8-bit bytes).
    public static let contentLength: Self = "Content-Length"
    /// Base64-encoded 128-bit MD5 digest of the message body.
    public static let contentMD5: Self = "Content-MD5"
    /// Indicates how content should be presented (e.g., inline, attachment).
    public static let contentDisposition: Self = "Content-Disposition"
    /// The media type of the request body.
    public static let contentType: Self = "Content-Type"
    /// Describes the natural language(s) of the intended audience for the enclosed content.
    public static let contentLanguage: Self = "Content-Language"
    /// The date and time at which the message was originated.
    public static let date: Self = "Date"
    /// Indicates the user’s tracking preference ("Do Not Track").
    public static let dnt: Self = "DNT"
    /// Entity tag for cache validation.
    public static let etag: Self = "ETag"
    /// Indicates that particular server behaviors are required by the client.
    public static let expect: Self = "Expect"
    /// Discloses the client’s original IP address and other forwarding information.
    public static let forwarded: Self = "Forwarded"
    /// The email address of the user making the request.
    public static let from: Self = "From"
    /// The domain name of the server and optionally the port number.
    public static let host: Self = "Host"
    /// A conditional request header matching the entity tag.
    public static let ifMatch: Self = "If-Match"
    /// A conditional request header checking the modification date.
    public static let ifModifiedSince: Self = "If-Modified-Since"
    /// A conditional request header checking if none match the given ETags.
    public static let ifNoneMatch: Self = "If-None-Match"
    /// A conditional request header used with range requests.
    public static let ifRange: Self = "If-Range"
    /// A conditional request header ensuring the resource hasn't changed.
    public static let ifUnmodifiedSince: Self = "If-Unmodified-Since"
    /// Used to describe relationships between resources.
    public static let link: Self = "Link"
    /// Limits the number of times a request can be forwarded.
    public static let maxForwards: Self = "Max-Forwards"
    /// Originating URI of the request initiating the fetch.
    public static let origin: Self = "Origin"
    /// Implementation-specific directives that might influence caching.
    public static let pragma: Self = "Pragma"
    /// Credentials for authenticating with a proxy.
    public static let proxyAuthorization: Self = "Proxy-Authorization"
    /// Specifies the part(s) of a document that the server should return.
    public static let range: Self = "Range"
    /// The address of the previous web page from which a link to the current page was followed.
    public static let referer: Self = "Referer"
    /// Indicates how long the client should wait before making a follow-up request.
    public static let retryAfter: Self = "Retry-After"
    /// Indicates the transfer codings the user agent is willing to accept.
    public static let te: Self = "TE"
    /// The form of encoding used to safely transfer the payload body.
    public static let transferEncoding: Self = "Transfer-Encoding"
    /// Allows the client to specify which protocol upgrades it supports.
    public static let upgrade: Self = "Upgrade"
    /// The user agent string of the client software.
    public static let userAgent: Self = "User-Agent"
    /// Informs the server of intermediate protocols and recipients.
    public static let via: Self = "Via"
    /// General warnings about possible problems with the request.
    public static let warning: Self = "Warning"
    /// Identifies Ajax requests, commonly set to "XMLHttpRequest".
    public static let xRequestedWith: Self = "X-Requested-With"
    /// Identifies the originating IP address of a client connecting through a proxy.
    public static let xForwardedFor: Self = "X-Forwarded-For"
    /// Identifies the protocol (HTTP or HTTPS) used by the client connecting through a proxy.
    public static let xForwardedProto: Self = "X-Forwarded-Proto"
    /// Indicates the client’s real IP address when behind a reverse proxy.
    public static let xRealIP: Self = "X-Real-IP"

    /// Returns all standard HTTP request header fields.
    public static let allCases: [Self] = [
        .accept, .acceptCharset, .acceptEncoding, .acceptLanguage, .acceptPatch,
        .accessControlRequestHeaders, .accessControlRequestMethod,
        .authorization, .cacheControl, .connection, .cookie,
        .contentLength, .contentMD5, .contentDisposition, .contentType, .contentLanguage,
        .date, .dnt, .etag, .expect, .forwarded, .from, .host,
        .ifMatch, .ifModifiedSince, .ifNoneMatch, .ifRange, .ifUnmodifiedSince,
        .link, .maxForwards, .origin, .pragma, .proxyAuthorization, .range,
        .referer, .retryAfter, .te, .transferEncoding, .upgrade,
        .userAgent, .via, .warning,
        .xRequestedWith, .xForwardedFor, .xForwardedProto, .xRealIP
    ]
}
