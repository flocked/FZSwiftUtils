//
//  HTTPCookie+.swift
//
//
//  Created by Florian Zand on 09.01.26.
//

import Foundation

public extension HTTPCookie {
    /**
     Creates a new cookie using the specified name, value and domain.

     - Parameters:
        - name: The cookie name.
        - value: The cookie value.
        - domain: The domain for which the cookie is valid.
        - path: The path for which the cookie is valid.
        - expires: The date after which the cookie expires.
        - secure: A Boolean value indicating whether the cookie should only be sent over secure connections.
        - discard: A Boolean value indicating whether the cookie should be discarded at the end of the current session.
        - sameSitePolicy: The cookie's SameSite policy.
        - comment: An optional comment describing the purpose of the cookie.
        - commentURL: A URL providing additional information about the cookie.
        - ports: The ports to which the cookie is restricted, or `nil` for any port.
        - version: The version of the cookie.
     */
    convenience init?(name: String, value: String, domain: String, path: String = "/", expires: Date? = nil, secure: Bool = true, discard: Bool = false, sameSitePolicy: HTTPCookieStringPolicy? = nil, comment: String? = nil, commentURL: URL? = nil, ports: [Int]? = nil, version: Int = 0) {
        self.init(properties: [.name: name, .value: value, .domain: domain, .path: path, .sameSitePolicy: sameSitePolicy?.rawValue, .comment: comment, .commentURL: commentURL, .secure: secure ? "TRUE" : nil, .discard: discard ? "TRUE" : "FALSE", .expires: expires, .version: version == 1 ? "1" : nil, .port: ports?.portsString].nonNil)
    }
    
    /**
     Creates a new cookie using the specified name, value and domain.

     - Parameters:
        - name: The cookie name.
        - value: The cookie value.
        - domain: The domain for which the cookie is valid.
        - path: The path for which the cookie is valid.
        - maximumAge: The maximum lifetime of the cookie, in seconds.
        - secure: A Boolean value indicating whether the cookie should only be sent over secure connections.
        - sameSitePolicy: The cookie's SameSite policy.
        - comment: An optional comment describing the purpose of the cookie.
        - commentURL: A URL providing additional information about the cookie.
        - ports: The ports to which the cookie is restricted, or `nil` for any port.
     */
    convenience init?(name: String, value: String, domain: String, path: String = "/", maximumAge: Int, secure: Bool = true, sameSitePolicy: HTTPCookieStringPolicy? = nil, comment: String? = nil, commentURL: URL? = nil, ports: [Int]? = nil) {
        self.init(properties: [.name: name, .value: value, .domain: domain, .path: path, .sameSitePolicy: sameSitePolicy?.rawValue, .comment: comment, .commentURL: commentURL, .secure: secure ? "TRUE" : nil, .maximumAge: "\(maximumAge)", .version: "1", .port: ports?.portsString].nonNil)
    }
    
    /**
     Creates a new cookie using the specified name, value and origin URL.

     - Parameters:
        - name: The cookie name.
        - value: The cookie value.
        - originURL: The URL from which the cookie originates.
        - path: The path for which the cookie is valid.
        - expires: The date after which the cookie expires.
        - secure: A Boolean value indicating whether the cookie should only be sent over secure connections.
        - discard: A Boolean value indicating whether the cookie should be discarded at the end of the current session.
        - sameSitePolicy: The cookie's SameSite policy.
        - comment: An optional comment describing the purpose of the cookie.
        - commentURL: A URL providing additional information about the cookie.
        - ports: The ports to which the cookie is restricted, or `nil` for any port.
        - version: The version of the cookie.
     */
    convenience init?(name: String, value: String, originURL: URL, path: String = "/", expires: Date? = nil, secure: Bool = true, discard: Bool = false, sameSitePolicy: HTTPCookieStringPolicy? = nil, comment: String? = nil, commentURL: URL? = nil, ports: [Int]? = nil, version: Int = 0) {
        self.init(properties: [.name: name, .value: value, .originURL: originURL, .path: path, .sameSitePolicy: sameSitePolicy?.rawValue, .comment: comment, .commentURL: commentURL, .secure: secure ? "TRUE" : nil, .discard: discard ? "TRUE" : "FALSE", .expires: expires, .version: version == 1 ? "1" : nil, .port: ports?.portsString].nonNil)
    }
    
    /**
     Creates a new cookie using the specified name, value and origin URL.

     - Parameters:
        - name: The cookie name.
        - value: The cookie value.
        - originURL: The URL from which the cookie originates.
        - path: The path for which the cookie is valid.
        - maximumAge: The maximum lifetime of the cookie, in seconds.
        - secure: A Boolean value indicating whether the cookie should only be sent over secure connections.
        - sameSitePolicy: The cookie's SameSite policy.
        - comment: An optional comment describing the purpose of the cookie.
        - commentURL: A URL providing additional information about the cookie.
        - ports: The ports to which the cookie is restricted, or `nil` for any port.
     */
    convenience init?(name: String, value: String, originURL: URL, path: String = "/", maximumAge: Int, secure: Bool = true, sameSitePolicy: HTTPCookieStringPolicy? = nil, comment: String? = nil, commentURL: URL? = nil, ports: [Int]? = nil) {
        self.init(properties: [.name: name, .value: value, .originURL: originURL, .path: path, .sameSitePolicy: sameSitePolicy?.rawValue, .comment: comment, .commentURL: commentURL, .secure: secure ? "TRUE" : nil, .maximumAge: "\(maximumAge)", .version: "1", .port: ports?.portsString].nonNil)
    }
}

fileprivate extension [Int] {
    var portsString: String? {
        sorted().uniqued().nilIfEmpty?.map(String.init).joined(separator: ",")
    }
}

public extension HTTPCookie {
    /// A Boolean value indicating whether the cookie is expired.
    var isExpired: Bool {
        expiresDate ?? .distantFuture < Date()
    }
    
    /**
     Creates an array of HTTP cookies form the specified JSON-serializable array of dictionaries.
     
     - Parameter jsonObject: The JSON-serializable array of dictionaries.
     - Returns: The array of created cookies.
     */
    static func cookies(fromJSONObject jsonObject: [[String: Any]]) -> [HTTPCookie] {
        jsonObject.compactMap { HTTPCookie(jsonObject: $0) }
    }

    /**
     Creates an array of HTTP cookies that corresponds to the cookies specified in the given JSON string.
     
     - Parameter jsonString: The json string that specifies the cookies.
     - Returns: The array of created cookies.
     */
    static func cookies(fromJSONString jsonString: String) throws -> [HTTPCookie] {
        guard let data = jsonString.data(using: .utf8) else {
            throw DecodingError.dataCorrupted(at: [], debugDescription: "Failed to create data from the string.")
        }
        return try cookies(fromJsonData: data)
    }
    
    /**
     Creates an array of HTTP cookies that corresponds to the cookies specified in the given Netscape-format cookies string.
     
     - Parameter netscapeString:The Netscape-format cookies string.
     - Returns: The array of created cookies.
     */
    static func cookies(fromNetscapeString netscapeString: String) -> [HTTPCookie] {
        netscapeString.lines.compactMap { HTTPCookie(netscapeTextLine: $0) }
    }
    
    /**
     Creates an array of HTTP cookies that corresponds to the cookies specified in the given Netscape cookies text file or cookies JSON file.
     
     - Parameter cookiesFile: The URL of the Netscape cookies text file or JSON cookies file.
     - Returns: The array of created cookies.
     */
    static func cookies(fromFile cookiesFile: URL) throws -> [HTTPCookie] {
        if cookiesFile.pathExtension.lowercased() == "json" {
            return try cookies(fromJsonData: Data(contentsOf: cookiesFile))
        } else {
            return try cookies(fromNetscapeString: String(contentsOf: cookiesFile, encoding: .utf8))
        }
    }
    
    /**
     Creates cookies by parsing the value of an HTTP `Cookie` request header.

     The created cookies use the specified URL as their origin. Since a `Cookie` request header does not include metadata such as the path, domain, expiration date, or `HttpOnly` attribute, these values cannot be reconstructed and are assigned default values where required.

     - Parameters:
       - header: The value of the HTTP `Cookie` request header.
       - url: The URL associated with the request.
     - Returns: An array of cookies parsed from the header.
     */
    static func cookies(fromCookieHeader header: String, for url: URL) -> [HTTPCookie] {
        header.split(separator: ";").compactMap {
            let pair = $0.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            guard pair.count == 2 else { return nil }
            return HTTPCookie(properties: [
                .name: pair[0].trimmingCharacters(in: .whitespaces),
                .value: pair[1].trimmingCharacters(in: .whitespaces),
                .originURL: url,
                .path: "/",
                .secure: url.scheme?.lowercased() == "https" ? "TRUE" : "FALSE",
            ])
        }
    }
    
    /**
     Returns a JSON-serializable array of dictionaries for the specified HTTP cookies.
     
     - Parameter cookies: The cookies to convert.
     */
    static func jsonObject(for cookies: [HTTPCookie]) -> [[String: Any]] {
        cookies.map { $0.toJSONObject() }
    }
    
    /**
     Returns a JSON string for the specified HTTP cookies.
     
     - Parameters:
       - cookies: The cookies to convert.
       - prettyPrinted: A Boolean value indicating whether the resulting JSON string should be pretty-printed. Defaults to `true`.
     */
    static func jsonString(for cookies: [HTTPCookie], prettyPrinted: Bool = true) throws -> String {
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonObject(for: cookies), options: prettyPrinted ? .prettyPrinted : [])
            guard let string = String(data: data, encoding: .utf8) else {
                throw NetworkError(.missingData)
            }
            return string
        } catch {
            throw error
        }
    }
    
    /**
     Returns a Netscape-format cookies string for the specified HTTP cookies.
     
     - Parameter cookies: The cookies to convert.
     */
    static func netscapeString(for cookies: [HTTPCookie], includeComments: Bool = true) -> String {
        var lines = includeComments ? ["# Netscape HTTP Cookie File", "# https://curl.haxx.se/rfc/cookie_spec.html", "# This is a generated file! Do not edit.", ""] : []
        lines += cookies.map { $0.toNetscapeString() }
        return lines.joined(separator: "\n")
    }
    
    fileprivate static func cookies(fromJsonData jsonData: Data) throws -> [HTTPCookie] {
        guard let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] else {
            throw DecodingError.typeMismatch([[String: Any]].self, .init(codingPath: [], debugDescription: "JSON type isn't matching."))
        }
        return cookies(fromJSONObject: jsonObject)
    }
    
    fileprivate static let keyMappingFromJSON = ["expirationDate": "Expires", "name": "Name", "value": "Value", "path": "Path", "secure": "Secure", "domain": "Domain", "sameSite": "SameSite", "session": "Discard"]
    fileprivate static let keyMappingToJSON = Dictionary(uniqueKeysWithValues: keyMappingFromJSON.map { ($0.value, $0.key) })
    
    /// Returns a JSON-serializable dictionary representing the cookie.
    func toJSONObject() -> [String: String] {
        properties?.mapValues { "\($0)" }.mapKeys { $0.rawValue } ?? [:]
    }
    
    /// Returns a single-line string representation of the cookie in **Netscape cookie file format**.
    func toNetscapeString() -> String {
        let domain = (isHTTPOnly ? "HttpOnly_" : "") + (domain.hasPrefix(".") ? domain : ".\(domain)")
        let includeSubdomains = self.domain.hasPrefix(".") ? "TRUE" : "FALSE"
        let secure = isSecure ? "TRUE" : "FALSE"
        let expiration = String(Int(expiresDate?.timeIntervalSince1970 ?? 0))
        let httpOnly = isHTTPOnly ? "TRUE" : "FALSE"
        let sessionOnly = isSessionOnly ? "TRUE" : "FALSE"
        let sameSite = self.sameSitePolicy?.rawValue.capitalized ?? "Unspecified"
        return [domain, includeSubdomains, path, secure, expiration, name, value, httpOnly, sessionOnly, sameSite].joined(separator: "\t")
    }
}

extension HTTPCookie {
    convenience init?(jsonString: String) {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        self.init(jsonObject: jsonObject)
    }
    
    convenience init?(jsonObject: [String: Any]) {
        var properties = jsonObject.mapKeys { HTTPCookiePropertyKey(Self.keyMappingFromJSON[$0] ?? $0) }
        if let timestamp = properties[.expires] as? Int {
            properties[.expires] = timestamp != 0 ? Date(timeIntervalSince1970: TimeInterval(timestamp)) : nil
        }
        if let sameSitePolicy = properties[.sameSitePolicy] as? String {
            properties[.sameSitePolicy] = sameSitePolicy.normalizedSameSitePolicy
        }
        for key in [HTTPCookiePropertyKey.secure, .init("hostOnly"), .httpOnly] {
            if let value = properties[key] as? Int {
                properties[key] = value == 1 ? "TRUE" : "FALSE"
            }
        }
        self.init(properties: properties)
    }
    
    convenience init?(netscapeTextLine: String) {
        let trimmed = netscapeTextLine.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !trimmed.hasPrefix("#") else { return nil }
        let fields = trimmed.components(separatedBy: "\t")
        guard fields.count >= 7 else { return nil }
        let expires = TimeInterval(fields[4]) ?? 0
        var domain = fields[0]
        var httpOnly = false
        if domain.hasPrefix("HttpOnly_") {
            domain = domain.removingPrefix("HttpOnly_")
            httpOnly = true
        } else if fields[safe: 7] == "TRUE" {
            httpOnly = true
        }
        var properties: [HTTPCookiePropertyKey: Any] = [.domain: domain, .path: fields[2], .name: fields[5], .value: fields[6], .secure: fields[3] == "TRUE" ? "TRUE" : "FALSE", .discard: fields[safe: 8] == "TRUE" ? "TRUE" : "FALSE"]
        if expires > 0 {
            properties[.expires] = Date(timeIntervalSince1970: expires)
        }
        properties[.httpOnly] = httpOnly ? "TRUE" : nil
        properties[.sameSitePolicy] = fields[safe: 9]?.normalizedSameSitePolicy
        self.init(properties: properties)
    }
}

public extension Decodable where Self: HTTPCookie {
    init(from decoder: any Decoder) throws {
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: decoder.decodeSingle())
        guard let object = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) else {
            throw NSCodingArchiveError.missingRootObject
        }
        guard let cookie = object as? Self else {
            throw NSCodingArchiveError.typeMismatch(expected: HTTPCookie.self, actual: type(of: object))
        }
        self = cookie
    }
}

extension HTTPCookie: Swift.Decodable, Swift.Encodable {
    public func encode(to encoder: any Encoder) throws {
        try encoder.encodeSingle(NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false))
    }
}

public extension Collection where Element == HTTPCookie {
    /// Returns a JSON-serializable array representing the cookies.
    func toJSONObject() -> [[String: String]] {
        map { $0.toJSONObject() }
    }
    
    /**
     Returns a string representation of the cookies in **Netscape cookie file format**.
     
     - Parameter includeComments: A Boolean indicating whether to include the standard header comments describing the file format.
     */
    func toNetscapeString(includeComments: Bool = true) -> String {
        var lines = includeComments ? ["# Netscape HTTP Cookie File", "# https://curl.haxx.se/rfc/cookie_spec.html", "# This is a generated file! Do not edit.", ""] : []
        lines += map { $0.toNetscapeString() }
        return lines.joined(separator: "\n")
    }
}

extension HTTPCookiePropertyKey: Swift.ExpressibleByStringLiteral, Swift.ExpressibleByUnicodeScalarLiteral, Swift.ExpressibleByExtendedGraphemeClusterLiteral, Swift.Encodable, Swift.Decodable {
    /// A String value that indicates whether the cookie should only be sent to HTTP servers.
    public static let httpOnly = Self("httpOnly")
    
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

private extension String {
    var normalizedSameSitePolicy: String? {
        switch lowercased() {
        case "lax": return "Lax"
        case "strict": return "Strict"
        case "none", "no_restriction": return "None"
        case "unspecified": return nil
        default: return self
        }
    }
}

/*
 extension HTTPCookie: Swift.Encodable, Swift.Decodable {
     public func encode(to encoder: Encoder) throws {
         var container = encoder.singleValueContainer()
         try container.encode((properties ?? [:]).mapValues({"\($0)"}))
     }
 }

 extension Decodable where Self: HTTPCookie {
     public init(from decoder: Decoder) throws {
         let container = try decoder.singleValueContainer()
         let properties: [HTTPCookiePropertyKey: String] = try container.decode()
         guard let cookie = HTTPCookie(properties: properties) else {
             throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid cookie properties")
         }
         self = cookie as! Self
     }
 }
 */
