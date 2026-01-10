//
//  HTTPCookie+.swift
//  FZSwiftUtils
//
//  Created by Florian Zand on 09.01.26.
//

import Foundation

extension HTTPCookie {
    /// A Boolean value indicating whether the cookie is expired.
    public var isExpired: Bool {
        guard let expiresDate = self.expiresDate else { return false }
        return expiresDate < Date()
    }
    
    /// A codable container for the cookie.
    public var asCodable: CodableCookie {
        CodableCookie(self)
    }
    
    /// A codable representation of an HTTP cookie.
    public struct CodableCookie: Codable {
        /// The HTTP cookie.
        public let cookie: HTTPCookie

        /// Creates a codable representation of an HTTP cookie.
        public init(_ cookie: HTTPCookie) {
            self.cookie = cookie
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let data = try container.decode(Data.self)
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
            unarchiver.requiresSecureCoding = false
            guard let cookie = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? HTTPCookie else {
                throw DecodingError.typeMismatch(HTTPCookie.self, .init(codingPath: [], debugDescription: "Decoding failed"))
            }
            self.cookie = cookie
        }

        public func encode(to encoder: Encoder) throws {
            let data = try NSKeyedArchiver.archivedData(withRootObject: cookie, requiringSecureCoding: false)
            var container = encoder.singleValueContainer()
            try container.encode(data)
        }
    }

    /**
     Creates an array of HTTP cookies that corresponds to the cookies specified in the given JSON string.
     
     - Parameter jsonString: The json string that specifies the cookies.
     - Returns: The array of created cookies.
     */
    public static func cookies(fromJSONString jsonString: String) throws -> [HTTPCookie] {
        guard let data = jsonString.data(using: .utf8) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Failed to create data from the string."))
        }
        return try parse(jsonData: data)
    }
    
    public static func cookies(fromNetscapeString netscapeString: String) -> [HTTPCookie] {
        netscapeString.lines.compactMap({ HTTPCookie(netscapeTextLine: $0) })
    }
    
    /**
     Creates an array of HTTP cookies that corresponds to the cookies specified in the given Netscape cookies text file or cookies JSON file.
     
     - Parameter cookiesFile: The URL of the Netscape cookies text file or JSON cookies file.
     - Returns: The array of created cookies.
     */
    public static func cookies(fromFile cookiesFile: URL) throws -> [HTTPCookie] {
        if cookiesFile.pathExtension.lowercased() == "json" {
            return try parse(jsonData: try Data(contentsOf: cookiesFile))
        } else {
            return cookies(fromNetscapeString: try String(contentsOf: cookiesFile, encoding: .utf8))
        }
    }
    
    fileprivate static func parse(jsonData: Data) throws -> [HTTPCookie] {
        guard let values = try JSONSerialization.jsonObject(with: jsonData) as? [[String:Any]] else {
            throw DecodingError.typeMismatch([[String:Any]].self, .init(codingPath: [], debugDescription: "JSON type isn't matching."))
        }
        return values.compactMap({ HTTPCookie(json: $0) })
    }
    
    fileprivate static let keyMappingFromJSON = ["expirationDate": "Expires", "name":"Name","value":"Value","path":"Path","secure":"Secure","domain":"Domain","sameSite":"SameSite", "session" : "Discard"]
    fileprivate static let keyMappingToJSON = Dictionary(uniqueKeysWithValues: keyMappingFromJSON.map({($0.value,$0.key) }))
    
    /// Returns a JSON-serializable dictionary representing the cookie.
    public func toJSONObject() -> [String: Any] {
        var properties = (properties ?? [:])
        properties[.expires] = Int((properties[.expires] as? Date)?.timeIntervalSince1970 ?? 0)
        for key in [HTTPCookiePropertyKey.secure, .init("hostOnly"), .httpOnly, .discard] {
            if let value = properties[key] as? String {
                properties[key] = value == "TRUE"
            }
        }
        if let commentURL = properties[.commentURL] as? URL {
            properties[.commentURL] = commentURL.absoluteString
        }
        if let originURL = properties[.originURL] as? URL {
            properties[.originURL] = originURL.absoluteString
        }
        if let sameSitePolicy = properties[.sameSitePolicy] as? String {
            properties[.sameSitePolicy] = sameSitePolicy.lowercasedFirst()
        }
        return properties.mapKeys({ Self.keyMappingToJSON[$0.rawValue] ?? $0.rawValue })
    }
    
    /// Returns a single-line string representation of the cookie in **Netscape cookie file format**.
    public func toNetscapeString() -> String {
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
    convenience init?(json: [String: Any]) {
        var properties = json.mapKeys({ HTTPCookiePropertyKey(Self.keyMappingFromJSON[$0] ?? $0) })
        if let timestamp = properties[.expires] as? Int {
            properties[.expires] = timestamp != 0 ? Date(timeIntervalSince1970: TimeInterval(timestamp)) : nil
        }
        if let originURL = properties[.originURL] as? String {
            properties[.originURL] = URL(string: originURL)
        }
        if let commentURL = properties[.commentURL] as? String {
            properties[.commentURL] = URL(string: commentURL)
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

extension Collection where Element == HTTPCookie {
    /// Returns a JSON-serializable array representing the cookies.
    public func toJSONObject() -> [[String: Any]] {
        map({ $0.toJSONObject() })
    }
    
    /**
     Returns a string representation of the cookies in **Netscape cookie file format**.
     
     - Parameter includeComments: A Boolean indicating whether to include the standard header comments describing the file format.
     */
    public func toNetscapeString(includeComments: Bool = true) -> String {
        var lines = includeComments ? ["# Netscape HTTP Cookie File", "# https://curl.haxx.se/rfc/cookie_spec.html", "# This is a generated file! Do not edit.", ""] : []
        lines += map({$0.toNetscapeString()})
        return lines.joined(separator: "\n")
    }
}

extension String {
    var normalizedSameSitePolicy: String? {
        switch lowercased() {
        case "lax":
            return "Lax"
        case "strict":
            return "Strict"
        case "none", "no_restriction":
            return "None"
        case "unspecified":
            return nil
        default:
            return self
        }
    }
}

extension HTTPCookiePropertyKey: Swift.ExpressibleByStringLiteral, Swift.ExpressibleByUnicodeScalarLiteral, Swift.ExpressibleByExtendedGraphemeClusterLiteral {
    /// A String value that indicates whether the cookie should only be sent to HTTP servers.
    public static let httpOnly = Self("httpOnly")
    
    public init(stringLiteral value: String) {
        self.init(value)
    }
}
