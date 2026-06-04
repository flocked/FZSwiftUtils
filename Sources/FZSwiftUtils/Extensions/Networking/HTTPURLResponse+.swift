//
//  HTTPURLResponse+.swift
//
//
//  Created by Florian Zand on 01.08.23.
//

import Foundation
import UniformTypeIdentifiers

public extension HTTPURLResponse {
    /// Returns the value that corresponds to the given header field.
    @_disfavoredOverload
    func value(forHTTPHeaderField httpHeaderField: HTTPHeaderField) -> String? {
        value(forHTTPHeaderField: httpHeaderField.rawValue)
    }
    
    ///The cookies set by the response, parsed from the `Set-Cookie` response header fields.
    var cookies: [HTTPCookie] {
        guard let url else { return [] }
        return HTTPCookie.cookies(withResponseHeaderFields: allHeaderFields.mapKeyValues({ (String(describing: $0), String(describing: $1)) }), for: url)
    }
    
    /// The response’s HTTP status code.
    var status: HTTPStatusCode {
        HTTPStatusCode(rawValue: statusCode)
    }
    
    /// A localized string of the response’s HTTP status code.
    var localizedStatusCode: String {
        Self.localizedString(forStatusCode: statusCode)
    }
    
    /// A Boolean value indicating whether the response’s HTTP status code is in the informational (`1xx`) range.
    var isInformational: Bool {
        statusCode / 100 == 1
    }
    
    /// A Boolean value indicating whether the response’s HTTP status code is sucessful (`200`–`299`).
    var isSuccessful: Bool {
        statusCode / 200 == 1
    }

    /// A Boolean value indicating whether the response’s HTTP status code is in the redirection (`3xx`) range.
    var isRedirection: Bool {
        statusCode / 300 == 1
    }

    /// A Boolean value indicating whether the response’s HTTP status code is in the client error (`4xx`) range.
    var isClientError: Bool {
        statusCode / 400 == 1
    }

    /// A Boolean value indicating whether the response’s HTTP status code is in the server error (`5xx`) range.
    var isServerError: Bool {
        statusCode / 500 == 1
    }

    /**
     The parameters declared in the `Content-Type` response header field.
     */
    var contentTypeParameters: [String: String] {
        value(forHTTPHeaderField: "Content-Type")?.trimmingCharacters(in: .whitespacesAndNewlines).contentTypeParameters ?? [:]
    }
    
    /// The validator which identifies the current state of the resource on the server.
    var validator: String? {
        guard statusCode == 200 || statusCode == 206, value(forHTTPHeaderField: "Accept-Ranges")?.localizedCaseInsensitiveContains("bytes") == true else { return nil }
        return value(forHTTPHeaderField: "ETag") ?? value(forHTTPHeaderField: "Etag") ?? value(forHTTPHeaderField: "Last-Modified")
    }
    
    /// A Boolean value indicating whether the server advertises support for byte-range requests via the `Accept-Ranges: bytes` HTTP header.
    var acceptsByteRanges: Bool {
        value(forHTTPHeaderField: "Accept-Ranges")?.lowercased() == "bytes"
    }
    
    /// All HTTP header fields of the response.
    var headerFields: [HTTPHeaderField: String] {
        allHeaderFields.mapKeyValues({ (HTTPHeaderField(String(describing: $0)), String(describing: $1)) })
    }
    
    /// A representation of an HTTP response header field key.
    struct HTTPHeaderField: RawRepresentable, ExpressibleByStringLiteral, Hashable, Codable {
        /// The name of the HTTP header field as a string (e.g., `"Content-Type"`, `"User-Agent"`).
        public let rawValue: String
        
        /// Creates a HTTP response header field key.
        public init(stringLiteral value: String) {
            self.rawValue = value
        }

        /// Creates a HTTP response header field key.
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }

        /// Creates a HTTP response header field key.
        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        /// Indicates that the server supports range requests.
        public static let acceptRanges = Self("Accept-Ranges")
        /// The age of the object in a proxy cache in seconds.
        public static let age = Self("Age")
        /// Specifies the set of HTTP methods supported by the resource.
        public static let allow = Self("Allow")
        /// Directives for caching mechanisms in both requests and responses.
        public static let cacheControl = Self("Cache-Control")
        /// Controls whether the network connection stays open.
        public static let connection = Self("Connection")
        /// The encoding used to compress the response body.
        public static let contentEncoding = Self("Content-Encoding")
        /// The natural language(s) of the intended audience for the enclosed content.
        public static let contentLanguage = Self("Content-Language")
        /// The size of the response body in octets (8-bit bytes).
        public static let contentLength = Self("Content-Length")
        /// A URI reference that identifies the actual location of the returned content.
        public static let contentLocation = Self("Content-Location")
        /// A Base64-encoded MD5 digest of the response body.
        public static let contentMD5 = Self("Content-MD5")
        /// Indicates if the content is expected to be displayed inline or as an attachment.
        public static let contentDisposition = Self("Content-Disposition")
        /// Indicates where in a full body message this partial message belongs.
        public static let contentRange = Self("Content-Range")
        /// Specifies the Content Security Policy that applies to the resource.
        public static let contentSecurityPolicy = Self("Content-Security-Policy")
        /// The MIME type of the response body.
        public static let contentType = Self("Content-Type")
        /// A unique identifier for a specific version of a resource.
        public static let eTag = Self("ETag")
        /// The date/time after which the response is considered stale.
        public static let expires = Self("Expires")
        /// Controls how long a persistent connection should stay open.
        public static let keepAlive = Self("Keep-Alive")
        /// The date and time at which the resource was last modified.
        public static let lastModified = Self("Last-Modified")
        /// Indicates relationships between the current resource and other resources.
        public static let link = Self("Link")
        /// The URL to redirect a page to.
        public static let location = Self("Location")
        /// A now-defunct HTTP header used for the P3P privacy policy.
        public static let p3p = Self("P3P")
        /// Implementation-specific directives that might apply to any agent along the request-response chain.
        public static let pragma = Self("Pragma")
        /// Authorization credentials for a proxy server.
        public static let proxyAuthorization = Self("Proxy-Authorization")
        /// Requests authentication to access a proxy.
        public static let proxyAuthenticate = Self("Proxy-Authenticate")
        /// Used to specify the interval (in seconds) after which the client should refresh the resource.
        public static let refresh = Self("Refresh")
        /// Indicates how long the user agent should wait before making a follow-up request.
        public static let retryAfter = Self("Retry-After")
        /// A string identifying the server software.
        public static let server = Self("Server")
        /// Sends cookies from the server to the user agent.
        public static let setCookie = Self("Set-Cookie")
        /// Indicates tracking status under the Tracking Preference Expression (DNT).
        public static let tk = Self("TK")
        /// Specifies headers present in the trailer of a message encoded with chunked transfer encoding.
        public static let trailer = Self("Trailer")
        /// Lists the transfer encodings used to encode the response body.
        public static let transferEncoding = Self("Transfer-Encoding")
        /// Specifies the set of headers that can vary the response.
        public static let vary = Self("Vary")
        /// Informs the client of intermediate protocols and recipients.
        public static let via = Self("Via")
        /// Additional information about the status or transformation of a message.
        public static let warning = Self("Warning")
        /// Requests authentication to access the resource.
        public static let wwwAuthenticate = Self("WWW-Authenticate")
        /// The date and time at which the message was originated.
        public static let date = Self("Date")
        /// Enforces secure (HTTPS) connections to the server.
        public static let strictTransportSecurity = Self("Strict-Transport-Security")
        /// Prevents browsers from interpreting files as a different MIME type.
        public static let xContentTypeOptions = Self("X-Content-Type-Options")
        /// Controls whether a browser should allow the page to be displayed in a frame.
        public static let xFrameOptions = Self("X-Frame-Options")
        /// Enables cross-site scripting filters in the browser.
        public static let xXSSProtection = Self("X-XSS-Protection")
        /// Controls which browser features can be used in the document.
        public static let permissionsPolicy = Self("Permissions-Policy")
        /// Indicates which headers are safe to expose to the API of a CORS API specification.
        public static let accessControlExposeHeaders = Self("Access-Control-Expose-Headers")
        /// Instructs the browser to clear various types of stored data.
        public static let clearSiteData = Self("Clear-Site-Data")
        /// Indicates the technology used by the server.
        public static let xPoweredBy = Self("X-Powered-By")
        /// Identifies the request for tracing and debugging purposes.
        public static let xRequestID = Self("X-Request-ID")
        /// Indicates whether the response was served from cache.
        public static let xCache = Self("X-Cache")
        /// Reports server timing metrics back to the client.
        public static let serverTiming = Self("Server-Timing")
        /// Indicates which origins can see timing information via the Resource Timing API.
        public static let timingAllowOrigin = Self("Timing-Allow-Origin")
        /// Used for network error logging configuration.
        public static let nel = Self("NEL")
    }

    /// The response headers mapped to strongly typed values.
    var headers: Headers {
        .init(headerFields: headerFields)
    }
    
    /// A strongly typed representation of HTTP response header fields.
    struct Headers {
        /// The value of the Accept-Ranges header.
        public let acceptRanges: String?
        /// A Boolean value indicating whether the server supports byte-range requests.
        public let acceptsByteRanges: Bool
        /// The estimated age of the response in seconds.
        public let age: TimeInterval?
        /// The HTTP methods permitted for the target resource.
        public let allow: [String]
        /// The directives that control caching behavior for the response.
        public let cacheControl: String?
        /// The connection options specified for the current transport.
        public let connection: [String]
        /// The content codings applied to the response body.
        public let contentEncoding: String?
        /// The natural languages intended for the response content.
        public let contentLanguage: [String]
        /// The size of the response body in bytes.
        public let contentLength: Int64?
        /// The URI that identifies the location of the returned representation.
        public let contentLocation: URL?
        /// The Content-MD5 digest value for the response body.
        public let contentMD5: String?
        /// The presentation information for the response content.
        public let contentDisposition: String?
        /// The range of bytes contained in a partial response.
        public let contentRange: String?
        /// The Content Security Policy applied to the response.
        public let contentSecurityPolicy: String?
        /// The Uniform Type Identifier corresponding to the Content-Type header.
        public let contentType: UTType?
        /// The parameters associated with the Content-Type header.
        public let contentTypeParameters: [String: String]
        /// The entity tag that identifies a specific version of the resource.
        public let eTag: String?
        /// The date and time after which the response is considered stale.
        public let expires: Date?
        /// The parameters controlling persistent connection behavior.
        public let keepAlive: String?
        /// The date and time when the resource was last modified.
        public let lastModified: Date?
        /// The relationships between the resource and other resources.
        public let link: String?
        /// The URL to which the client should redirect.
        public let location: URL?
        /// The Platform for Privacy Preferences policy reference.
        public let p3p: String?
        /// Legacy cache-control directives for HTTP/1.0 clients.
        public let pragma: String?
        /// The credentials supplied for authenticating with a proxy.
        public let proxyAuthorization: String?
        /// The authentication challenge issued by a proxy.
        public let proxyAuthenticate: String?
        /// Instructions for automatically refreshing or redirecting the resource.
        public let refresh: String?
        /// The amount of time the client should wait before retrying the request.
        public let retryAfter: String?
        /// Information about the software handling the request.
        public let server: String?
        /// The raw Set-Cookie header value returned by the server.
        public let setCookie: String?
        /// The tracking status value reported by the server.
        public let tk: String?
        /// The header fields that will be included in trailing headers.
        public let trailer: [String]
        /// The transfer codings applied to the response message.
        public let transferEncoding: [String]
        /// The request header fields that affect representation selection.
        public let vary: [String]
        /// Information about intermediate protocols and recipients.
        public let via: String?
        /// Additional warning information associated with the response.
        public let warning: String?
        /// The authentication challenge issued by the origin server.
        public let wwwAuthenticate: String?
        /// The date and time at which the message originated.
        public let date: Date?
        /// The policy that enforces secure transport for future requests.
        public let strictTransportSecurity: String?
        /// The directives controlling MIME type sniffing behavior.
        public let xContentTypeOptions: String?
        /// The policy controlling whether the content may be embedded in frames.
        public let xFrameOptions: String?
        /// The legacy cross-site scripting protection configuration.
        public let xXSSProtection: String?
        /// The permissions policy that restricts browser features and APIs.
        public let permissionsPolicy: String?
        /// The response headers exposed to cross-origin requests.
        public let accessControlExposeHeaders: [String]
        /// The types of browsing data that should be cleared by the client.
        public let clearSiteData: [String]
        /// Information about the software framework used by the server.
        public let xPoweredBy: String?
        /// A unique identifier assigned to the request.
        public let xRequestID: String?
        /// Information about cache handling for the response.
        public let xCache: String?
        /// Performance metrics describing server-side request processing.
        public let serverTiming: String?
        /// The origins permitted to access server timing information.
        public let timingAllowOrigin: String?
        /// The Network Error Logging configuration for the client.
        public let nel: String?
        
        init(headerFields: [HTTPURLResponse.HTTPHeaderField: String]) {
            let headers = headerFields.mapValues({$0.trimmingCharacters(in: .whitespacesAndNewlines)})
            
            acceptRanges = headers[.acceptRanges]
            acceptsByteRanges = headers[.acceptRanges]?.commaSeperated.contains { $0.lowercased() == "bytes" } ?? false
            age = headers[.age].flatMap(TimeInterval.init)
            allow = headers[.allow]?.commaSeperated ?? []
            cacheControl = headers[.cacheControl]
            connection = headers[.connection]?.commaSeperated ?? []
            contentEncoding = headers[.contentEncoding]
            contentLanguage = headers[.contentLanguage]?.commaSeperated ?? []
            contentLength = headers[.contentLength].flatMap(Int64.init)
            contentLocation = headers[.contentLocation].flatMap(URL.init(string:))
            contentMD5 = headers[.contentMD5]
            contentDisposition = headers[.contentDisposition]
            contentRange = headers[.contentRange]
            contentSecurityPolicy = headers[.contentSecurityPolicy]
            
            if let rawContentType = headers[.contentType] {
                let parts = rawContentType.split(separator: ";", omittingEmptySubsequences: false)
                let mimeType = parts.first?.trimmingCharacters(in: .whitespacesAndNewlines)
                contentType = mimeType.flatMap { UTType(mimeType: $0) }
                contentTypeParameters = rawContentType.contentTypeParameters
            } else {
                contentType = nil
                contentTypeParameters = [:]
            }
            
            eTag = headers[.eTag]
            expires = headers[.expires]?.httpDate
            keepAlive = headers[.keepAlive]
            lastModified = headers[.lastModified]?.httpDate
            link = headers[.link]
            location = headers[.location].flatMap(URL.init(string:))
            p3p = headers[.p3p]
            pragma = headers[.pragma]
            proxyAuthorization = headers[.proxyAuthorization]
            proxyAuthenticate = headers[.proxyAuthenticate]
            refresh = headers[.refresh]
            retryAfter = headers[.retryAfter]
            server = headers[.server]
            setCookie = headers[.setCookie]
            tk = headers[.tk]
            trailer = headers[.trailer]?.commaSeperated ?? []
            transferEncoding = headers[.transferEncoding]?.commaSeperated ?? []
            vary = headers[.vary]?.commaSeperated ?? []
            via = headers[.via]
            warning = headers[.warning]
            wwwAuthenticate = headers[.wwwAuthenticate]
            date = headers[.date]?.httpDate
            strictTransportSecurity = headers[.strictTransportSecurity]
            xContentTypeOptions = headers[.xContentTypeOptions]
            xFrameOptions = headers[.xFrameOptions]
            xXSSProtection = headers[.xXSSProtection]
            permissionsPolicy = headers[.permissionsPolicy]
            accessControlExposeHeaders = headers[.accessControlExposeHeaders]?.commaSeperated ?? []
            clearSiteData = headers[.clearSiteData]?.commaSeperated ?? []
            xPoweredBy = headers[.xPoweredBy]
            xRequestID = headers[.xRequestID]
            xCache = headers[.xCache]
            serverTiming = headers[.serverTiming]
            timingAllowOrigin = headers[.timingAllowOrigin]
            nel = headers[.nel]
        }
    }
}

fileprivate extension String {
    static let httpDateFormatter = DateFormatter("EEE',' dd MMM yyyy HH':'mm':'ss z").locale(.init(identifier: "en_US_POSIX")).timeZone(TimeZone(secondsFromGMT: 0))
    
    var httpDate: Date? {
        Self.httpDateFormatter.date(from: self)
    }
    
    var commaSeperated: [String] {
        split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
    }
    
    var contentTypeParameters: [String: String] {
        var contentTypeParameters: [String: String] = [:]
        for match in matches(pattern: #";\s*([^=;]+)=("(?:\\.|[^"])*"|[^;]*)"#) {
            guard let key = match.groups.nonNil[safe: 0]?.string.trimmingCharacters(in: .whitespaces).lowercased(), var value = match.groups.nonNil[safe: 1]?.string else { continue }
            if value.hasPrefix("\""), value.hasSuffix("\"") {
                value.removeFirst()
                value.removeLast()
                value = value.replacingOccurrences(of: #"\\(.)"#, with: "$1", options: .regularExpression)
            }
            contentTypeParameters[key] = value.trimmingCharacters(in: .whitespaces)
        }
        return contentTypeParameters
    }
}
