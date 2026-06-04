//
//  HTTPRequestHeaderField.swift
//  
//
//  Created by Florian Zand on 04.06.26.
//

import Foundation

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
    /// Directives for caching mechanisms.
    public static let cacheControl: Self = "Cache-Control"
    /// Cookies previously sent by the server.
    public static let cookie: Self = "Cookie"
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
    /*
     /// Credentials for authenticating the client with the server.
     public static let authorization: Self = "Authorization"
     /// Options for the connection (e.g., keep-alive).
     public static let connection: Self = "Connection"
     /// The size of the request body in octets (8-bit bytes).
     public static let contentLength: Self = "Content-Length"
     /// The domain name of the server and optionally the port number.
     public static let host: Self = "Host"
     /// Credentials for authenticating with a proxy.
     public static let proxyAuthorization: Self = "Proxy-Authorization"
      */
}
