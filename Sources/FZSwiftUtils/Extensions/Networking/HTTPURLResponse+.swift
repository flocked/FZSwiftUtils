//
//  HTTPURLResponse+.swift
//
//
//  Created by Florian Zand on 01.08.23.
//

import Foundation

public extension HTTPURLResponse {
    /// A Boolean value indicating whether the response’s HTTP status code is sucessful (200-299).
    var statusIsSucess: Bool {
        let code = statusCode
        switch code {
        case 200 ..< 300:
            return true
        default:
            return false
        }
    }

    /// All HTTP header fields of the response.
    var allHeaderFieldsMapped: [HTTPHeaderFieldKey: String]? {
        var dic: [HTTPHeaderFieldKey: String] = [:]
        for value in allHeaderFields {
            if let rawValue = value.key as? String {
                let key = HTTPHeaderFieldKey(rawValue: rawValue)
                dic[key] = allHeaderFields[value.key] as? String
            }
        }
        return dic
    }

    /// Enumeration of all HTTP response header field keys.
    enum HTTPHeaderFieldKey: CaseIterable, Hashable, RawRepresentable, ExpressibleByStringLiteral {
        case acceptRanges
        case age
        case allow
        case cacheControl
        case connection
        case contentEncoding
        case contentLanguage
        case contentLength
        case contentLocation
        case contentMD5
        case contentDisposition
        case contentRange
        case contentSecurityPolicy
        case contentType
        case eTag
        case expires
        case keepAlive
        case LastModified
        case link
        case location
        case P3P
        case pragma
        case proxyAuthorization
        case proxyAuthenticate
        case refresh
        case retryAfter
        case server
        case setCookie
        case tk
        case trailer
        case transferEncoding
        case vary
        case via
        case warning
        case wwwAuthenticate
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

        public static var allCases: [HTTPURLResponse.HTTPHeaderFieldKey] = [.acceptRanges, .age, .allow, .cacheControl, .connection, .contentEncoding, .contentLanguage, .contentLength, .contentLocation, .contentMD5, .contentDisposition, .contentRange, .contentSecurityPolicy, .contentType, .eTag, .expires, .keepAlive, .LastModified, .link, .location, .P3P, .pragma, .proxyAuthorization, .proxyAuthenticate, .refresh, .retryAfter, .server, .setCookie, .trailer, .transferEncoding, .vary, .via, .warning, .wwwAuthenticate]

        public var rawValue: String {
            switch self {
            case .acceptRanges: return "Accept-Ranges"
            case .age: return "Age"
            case .allow: return "Allow"
            case .cacheControl: return "Cache-Control"
            case .connection: return "Connection"
            case .contentEncoding: return "Content-Encoding"
            case .contentLanguage: return "Content-Language"
            case .contentLength: return "Content-Length"
            case .contentLocation: return "Content-Location"
            case .contentMD5: return "Content-MD5"
            case .contentDisposition: return "Content-Disposition"
            case .contentRange: return "Content-Range"
            case .contentSecurityPolicy: return "Content-Security-Policy"
            case .contentType: return "Content-Type"
            case .eTag: return "ETag"
            case .expires: return "Expires"
            case .keepAlive: return "Keep-Alive"
            case .LastModified: return "Last-Modified"
            case .link: return "Link"
            case .location: return "Location"
            case .P3P: return "P3P"
            case .pragma: return "Pragma"
            case .proxyAuthorization: return "Proxy-Authorization"
            case .proxyAuthenticate: return "Proxy-Authenticate"
            case .refresh: return "Refresh"
            case .retryAfter: return "Retry-After"
            case .server: return "Server"
            case .setCookie: return "Set-Cookie"
            case .tk: return "TK"
            case .trailer: return "Trailer"
            case .transferEncoding: return "Transfer-Encoding"
            case .vary: return "Vary"
            case .via: return "Via"
            case .warning: return "Warning"
            case .wwwAuthenticate: return "WWW-Authenticate"
            case let .custom(string): return string
            }
        }
    }
}
