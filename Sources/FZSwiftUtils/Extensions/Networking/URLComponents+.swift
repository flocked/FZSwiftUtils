//
//  URLComponents+.swift
//
//
//  Created by Florian Zand on 01.07.24.
//

import Foundation

extension URLComponents {
    /**
     Creates a URL components instance from a URL string and query items.

     - Parameters:
        - string: The URL location.
        - queryItems: The query items.

     - Returns: The `URLComponents` instance, or `nil` if the string is not a valid a url.

     - Example:
     ```
     let components = URLComponents(string: "https://example.com") {
         URLQueryItem(name: "q", value: "search")
         URLQueryItem(name: "page", value: "1")
     }
     ```
     */
    public init?(string: String, @Builder queryItems: () -> [URLQueryItem]) {
        self.init(string: string)
        self.queryItems = queryItems()
    }
    
    /**
     Creates a URL components instance from a `URL` and query items.
     
     - Parameters:
        - url: The `URL` to parse.
        - resolve: A Boolean value indicating whether the initializer resolves the URL against its base URL before parsing. If `url` is a relative URL, setting resolve to `true` creates components using the `absoluteURL` property.
        - queryItems: The query items.
     
     - Returns: The `URLComponents` instance, or `nil` if the url is not a valid a url.
     
     */
    public init?(url: URL, resolvingAgainstBaseURL resolve: Bool, @Builder queryItems: () -> [URLQueryItem]) {
        self.init(url: url, resolvingAgainstBaseURL: resolve)
        self.queryItems = queryItems()
    }
    
    /// Sets the host subcomponent.
    @discardableResult
    public mutating func host(_ host: String?) -> Self {
        self.host = host
        return self
    }
    
    /// Sets the fragment subcomponent.
    @discardableResult
    public mutating func fragment(_ fragment: String?) -> Self {
        self.fragment = fragment
        return self
    }
    
    /// Sets the password subcomponent.
    @discardableResult
    public mutating func password(_ password: String?) -> Self {
        self.password = password
        return self
    }
    
    /// Sets the path subcomponent.
    @discardableResult
    public mutating func path(_ path: String) -> Self {
        self.path = path
        return self
    }
    
    /// Sets the port subcomponent.
    @discardableResult
    public mutating func port(_ port: Int?) -> Self {
        self.port = port
        return self
    }
    
    /// Sets the query subcomponent.
    @discardableResult
    public mutating func query(_ query: String?) -> Self {
        self.query = query
        return self
    }
    
    /// Sets the query items for the URL in the order in which they appear in the original query string.
    @discardableResult
    public mutating func queryItems(_ items: [URLQueryItem]) -> Self {
        self.queryItems = items
        return self
    }
    
    /// Sets the query items for the URL in the order in which they appear in the original query string.
    @discardableResult
    public mutating func queryItems(_ items: [String:String?]) -> Self {
        self.queryItems = items.map({ URLQueryItem(name: $0, value: $1) })
        return self
    }
    
    /// Sets the query items for the URL in the order in which they appear in the original query string.
    @discardableResult
    public mutating func queryItems(@Builder _ items: () -> [URLQueryItem]) -> Self {
        self.queryItems = items()
        return self
    }
    
    /// Sets the scheme subcomponent.
    @discardableResult
    public mutating func scheme(_ scheme: String?) -> Self {
        self.scheme = scheme
        return self
    }
    
    /// Sets the user subcomponent.
    @discardableResult
    public mutating func user(_ user: String?) -> Self {
        self.user = user
        return self
    }
    
    /// Sets the host subcomponent, encoded.
    @discardableResult
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public mutating func encodedHost(_ host: String?) -> Self {
        self.encodedHost = host
        return self
    }
    
    /// Sets the fragment subcomponent, percent-encoded.
    @discardableResult
    public mutating func percentEncodedFragment(_ fragment: String?) -> Self {
        self.percentEncodedFragment = fragment
        return self
    }
    
    /// Sets the password subcomponent, percent-encoded.
    @discardableResult
    public mutating func percentEncodedPassword(_ password: String?) -> Self {
        self.percentEncodedPassword = password
        return self
    }
    
    /// Sets the path subcomponent, percent-encoded.
    @discardableResult
    public mutating func percentEncodedPath(_ path: String) -> Self {
        self.percentEncodedPath = path
        return self
    }
    
    /// Sets the query subcomponent, percent-encoded.
    @discardableResult
    public mutating func percentEncodedQuery(_ query: String?) -> Self {
        self.percentEncodedQuery = query
        return self
    }
    
    /// Sets the percent-encoded query items for the URL in the order in which they appear in the original query string.
    @discardableResult
    public mutating func percentEncodedQueryItems(_ items: [URLQueryItem]) -> Self {
        self.percentEncodedQueryItems = items
        return self
    }
    
    /// Sets the percent-encoded query items for the URL in the order in which they appear in the original query string.
    @discardableResult
    public mutating func percentEncodedQueryItems(@Builder _ items: () -> [URLQueryItem]) -> Self {
        self.percentEncodedQueryItems = items()
        return self
    }
    
    /// Sets the user subcomponent, percent-encoded.
    @discardableResult
    public mutating func percentEncodedUser(_ user: String?) -> Self {
        self.percentEncodedUser = user
        return self
    }
    
    /// A function builder type that produces an array of [URLQueryItem](https://developer.apple.com/documentation/foundation/urlqueryitem).
    @resultBuilder
    public enum Builder {
        public static func buildBlock(_ components: [URLQueryItem]...) -> [URLQueryItem] {
            components.flatMap { $0 }
        }
        
        public static func buildExpression(_ expression: URLQueryItem) -> [URLQueryItem] {
            [expression]
        }
        
        public static func buildExpression(_ expression: [String : String]) -> [URLQueryItem] {
            expression.map({ URLQueryItem(name: $0, value: $1) })
        }

        public static func buildExpression(_ expression: [URLQueryItem]) -> [URLQueryItem] {
            expression
        }

        public static func buildOptional(_ components: [URLQueryItem]?) -> [URLQueryItem] {
            components ?? []
        }
        
        public static func buildEither(first: [URLQueryItem]?) -> [URLQueryItem] {
            first ?? []
        }

        public static func buildEither(second: [URLQueryItem]?) -> [URLQueryItem] {
            second ?? []
        }
    }
}
