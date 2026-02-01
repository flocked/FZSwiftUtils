//
//  HTTPCookie+.swift
//
//
//  Created by Florian Zand on 09.01.26.
//

import Foundation

extension Decodable where Self: HTTPCookie {
    public init(from decoder: any Decoder) throws {
        let rootObject = try NSKeyedUnarchiver.unarchivedObject(from: try decoder.decodeSingle())
        guard let cookie = rootObject as? Self else {
            throw DecodingError.typeMismatch(type(of: rootObject), .init("Expected object of type \(Self.self), but decoded object was of type \(type(of: rootObject))."))
        }
        self = cookie
    }
}

extension HTTPCookie: Swift.Decodable, Swift.Encodable {
    public func encode(to encoder: any Encoder) throws {
        try encoder.encodeSingle(NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false))
    }
}

extension HTTPCookie {
    /// A Boolean value indicating whether the cookie is expired.
    public var isExpired: Bool {
        guard let expiresDate = self.expiresDate else { return false }
        return expiresDate < Date()
    }
    
    /**
     Creates an array of HTTP cookies form the specified JSON-serializable array of dictionaries.
     
     - Parameter jsonObject: The JSON-serializable array of dictionaries.
     - Returns: The array of created cookies.
     */
    public static func cookies(fromJSONObject jsonObject: [[String:Any]]) -> [HTTPCookie] {
        jsonObject.compactMap({ HTTPCookie(jsonObject: $0) })
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
        return try cookies(fromJsonData: data)
    }
    
    /**
     Creates an array of HTTP cookies that corresponds to the cookies specified in the given Netscape-format cookies string.
     
     - Parameter netscapeString:The Netscape-format cookies string.
     - Returns: The array of created cookies.
     */
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
            return try cookies(fromJsonData: try Data(contentsOf: cookiesFile))
        } else {
            return cookies(fromNetscapeString: try String(contentsOf: cookiesFile, encoding: .utf8))
        }
    }
    
    /**
     Returns a JSON-serializable array of dictionaries for the specified HTTP cookies.
     
     - Parameter cookies: The cookies to convert.
     */
    public static func jsonObject(for cookies: [HTTPCookie]) -> [[String: Any]] {
        cookies.map({ $0.toJSONObject() })
    }
    
    /**
     Returns a JSON string for the specified HTTP cookies.
     
     - Parameters:
       - cookies: The cookies to convert.
       - prettyPrinted: A Boolean value indicating whether the resulting JSON string should be pretty-printed. Defaults to `true`.
     */
    public static func jsonString(for cookies: [HTTPCookie], prettyPrinted: Bool = true) -> String {
        do {
            let data = try JSONSerialization.data(
                withJSONObject: jsonObject(for: cookies),
                options: prettyPrinted ? .prettyPrinted : []
            )
            guard let string = String(data: data, encoding: .utf8) else {
                fatalError("Failed to convert JSON data to UTF-8 string")
            }
            return string
        } catch {
            fatalError("Failed to serialize cookies to JSON: \(error)")
        }
    }
    
    /**
     Returns a Netscape-format cookies string for the specified HTTP cookies.
     
     - Parameter cookies: The cookies to convert.
     */
    public static func netscapeString(for cookies: [HTTPCookie], includeComments: Bool = true) -> String {
        var lines = includeComments ? ["# Netscape HTTP Cookie File", "# https://curl.haxx.se/rfc/cookie_spec.html", "# This is a generated file! Do not edit.", ""] : []
        lines += cookies.map({$0.toNetscapeString()})
        return lines.joined(separator: "\n")
    }
    
    fileprivate static func cookies(fromJsonData jsonData: Data) throws -> [HTTPCookie] {
        guard let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as? [[String:Any]] else {
            throw DecodingError.typeMismatch([[String:Any]].self, .init(codingPath: [], debugDescription: "JSON type isn't matching."))
        }
        return cookies(fromJSONObject: jsonObject)
    }
    
    fileprivate static let keyMappingFromJSON = ["expirationDate": "Expires", "name":"Name","value":"Value","path":"Path","secure":"Secure","domain":"Domain","sameSite":"SameSite", "session" : "Discard"]
    fileprivate static let keyMappingToJSON = Dictionary(uniqueKeysWithValues: keyMappingFromJSON.map({($0.value,$0.key) }))
    
    /// Returns a JSON-serializable dictionary representing the cookie.
    public func toJSONObject() -> [String: String] {
        properties?.mapValues({ "\($0)" }).mapKeys({$0.rawValue}) ?? [:]
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
    convenience init?(jsonString: String) {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        self.init(jsonObject: jsonObject)
    }
    
    convenience init?(jsonObject: [String: Any]) {
        var properties = jsonObject.mapKeys({ HTTPCookiePropertyKey(Self.keyMappingFromJSON[$0] ?? $0) })
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

extension Collection where Element == HTTPCookie {
    /// Returns a JSON-serializable array representing the cookies.
    public func toJSONObject() -> [[String: String]] {
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

extension HTTPCookiePropertyKey: Swift.ExpressibleByStringLiteral, Swift.ExpressibleByUnicodeScalarLiteral, Swift.ExpressibleByExtendedGraphemeClusterLiteral, Swift.Encodable, Swift.Decodable {
    /// A String value that indicates whether the cookie should only be sent to HTTP servers.
    public static let httpOnly = Self("httpOnly")
    
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

fileprivate extension String {
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
