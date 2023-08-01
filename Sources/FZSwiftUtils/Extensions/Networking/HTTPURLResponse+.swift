//
//  HTTPURLResponse+.swift
//  
//
//  Created by Florian Zand on 01.08.23.
//

import Foundation

public extension HTTPURLResponse {
    /// A boolean value indicating whether the response’s HTTP status code is sucessful (200-299).
    var statusIsSucess: Bool {
        let code = self.statusCode
        switch code {
        case 200..<300:
            return true
        default:
            return false
        }
    }
    
    /// A dictionary containing all of the HTTP header fields for a response.
    var allHTTPHeaderFields: [HTTPHeaderFieldKey: String] {
        var allHTTPHeaderFields: [HTTPHeaderFieldKey: String] = [:]
        for key in HTTPHeaderFieldKey.allCases {
            allHTTPHeaderFields[key] = value(forHTTPHeaderField: key.rawValue)
        }
        return allHTTPHeaderFields
    }
    
    /// Enumeration of all HTTP response header field keys.
    enum HTTPHeaderFieldKey: String, CaseIterable {
        case acceptRanges = "Accept-Ranges"
        case age = "Age"
        case allow = "Allow"
        case cacheControl = "Cache-Control"
        case connection = "Connection"
        case contentEncoding = "Content-Encoding"
        case contentLanguage = "Content-Language"
        case contentLength = "Content-Length"
        case contentLocation = "Content-Location"
        case contentMD5 = "Content-MD5"
        case contentDisposition = "Content-Disposition"
        case contentRange = "Content-Range"
        case contentSecurityPolicy = "Content-Security-Policy"
        case contentType = "Content-Type"
        case eTag = "ETag"
        case expires = "Expires"
        case LastModified = "Last-Modified"
        case link = "Link"
        case location = "Location"
        case P3P = "P3P"
        case pragma = "Pragma"
        case proxyAuthorization = "Proxy-Authorization"
        case refresh = "Refresh"
        case retryAfter = "Retry-After"
        case server = "Server"
        case setCookie = "Set-Cookie"
        case trailer = "Trailer"
        case transferEncoding = "Transfer-Encoding"
        case vary = "Vary"
        case via = "Via"
        case warning = "Warning"
        case wwwAuthenticate = "WWW-Authenticate"
    }
}
