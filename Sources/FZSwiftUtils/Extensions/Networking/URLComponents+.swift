//
//  URLComponents+.swift
//
//
//  Created by Florian Zand on 01.07.24.
//

import Foundation

extension URLComponents {
    /**
     Creates `URL` components from the provided string and query items.

     - Parameters:
        - string: The URL location.
        - queryItems: The query items.

     - Returns: The `URL` components, or `nil` if the string is not a valid a url.

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
     Creates `URL` components from the provided `URL` and query items.

     - Parameters:
        - url: The `URL` to parse.
        - resolve: A Boolean value indicating whether the initializer resolves the URL against its base URL before parsing. If `url` is a relative URL, setting resolve to `true` creates components using the `absoluteURL` property.
        - queryItems: The query items.
     
     - Returns: The `URL` components, or `nil` if the url is not a valid a url.
     */
    public init?(url: URL, resolvingAgainstBaseURL resolve: Bool, @Builder queryItems: () -> [URLQueryItem]) {
        self.init(url: url, resolvingAgainstBaseURL: resolve)
        self.queryItems = queryItems()
    }
    
    /// Sets the host subcomponent.
    public func host(_ host: String?) -> Self {
        var components = self
        components.host = host
        return components
    }
    
    /// Sets the fragment subcomponent.
    public func fragment(_ fragment: String?) -> Self {
        var components = self
        components.fragment = fragment
        return components
    }
    
    /// Sets the password subcomponent.
    public func password(_ password: String?) -> Self {
        var components = self
        components.password = password
        return components
    }
    
    /// Sets the path subcomponent.
    public func path(_ path: String) -> Self {
        var components = self
        components.path = path
        return components
    }
    
    /// Sets the port subcomponent.
    public func port(_ port: Int?) -> Self {
        var components = self
        components.port = port
        return components
    }
    
    /// Sets the query subcomponent.
    public func query(_ query: String?) -> Self {
        var components = self
        components.query = query
        return components
    }
    
    /// Sets the query items for the URL in the order in which they appear in the original query string.
    public func queryItems(_ items: [URLQueryItem]) -> Self {
        var components = self
        components.queryItems = items
        return components
    }
    
    /// Sets the query items for the URL in the order in which they appear in the original query string.
    public func queryItems(_ items: [String:String?]) -> Self {
        var components = self
        components.queryItems = items.map({ URLQueryItem(name: $0, value: $1) })
        return components
    }
    
    /// Sets the query items for the URL in the order in which they appear in the original query string.
    public func queryItems(@Builder _ items: () -> [URLQueryItem]) -> Self {
        var components = self
        components.queryItems = items()
        return components
    }
    
    /// Sets the scheme subcomponent.
    public func scheme(_ scheme: String?) -> Self {
        var components = self
        components.scheme = scheme
        return components
    }
    
    /// Sets the user subcomponent.
    public func user(_ user: String?) -> Self {
        var components = self
        components.user = user
        return components
    }
    
    /// Sets the host subcomponent, encoded.
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public func encodedHost(_ host: String?) -> Self {
        var components = self
        components.encodedHost = host
        return components
    }
    
    /// Sets the fragment subcomponent, percent-encoded.
    public func percentEncodedFragment(_ fragment: String?) -> Self {
        var components = self
        components.percentEncodedFragment = fragment
        return components
    }
    
    /// Sets the password subcomponent, percent-encoded.
    public func percentEncodedPassword(_ password: String?) -> Self {
        var components = self
        components.percentEncodedPassword = password
        return components
    }
    
    /// Sets the path subcomponent, percent-encoded.
    public func percentEncodedPath(_ path: String) -> Self {
        var components = self
        components.percentEncodedPath = path
        return components
    }
    
    /// Sets the query subcomponent, percent-encoded.
    public func percentEncodedQuery(_ query: String?) -> Self {
        var components = self
        components.percentEncodedQuery = query
        return components
    }
    
    /// Sets the percent-encoded query items for the URL in the order in which they appear in the original query string.
    public func percentEncodedQueryItems(_ items: [URLQueryItem]) -> Self {
        var components = self
        components.percentEncodedQueryItems = items
        return components
    }
    
    /// Sets the percent-encoded query items for the URL in the order in which they appear in the original query string.
    public func percentEncodedQueryItems(@Builder _ items: () -> [URLQueryItem]) -> Self {
        var components = self
        components.percentEncodedQueryItems = items()
        return components
    }
    
    /// Sets the user subcomponent, percent-encoded.
    public func percentEncodedUser(_ user: String?) -> Self {
        var components = self
        components.percentEncodedUser = user
        return components
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
