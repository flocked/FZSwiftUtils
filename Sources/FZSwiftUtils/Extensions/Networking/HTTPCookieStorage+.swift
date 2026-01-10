//
//  HTTPCookieStorage+.swift
//
//
//  Created by Florian Zand on 24.02.23.
//

import Foundation

extension HTTPCookieStorage {
    /// Removes all cookies stored in the `HTTPCookieStorage`.
    public func removeAllCookies() {
        cookies?.forEach { deleteCookie($0) }
    }
    
    /// Saves the current HTTP cookies globally using the specified key.
    public func saveCookies(_ key: String) {
        Self.keyedCookies[key] =  (cookies ?? []).map({ $0.asCodable })
    }
    
    /**
     Loads the cookies for the specific key from a global storage.
     
     - Parameters:
        - key: The key at which the ccokies are stored.
        - removeCurrent: A Boolean value indicating whether the current ccokies should be removed.
     */
    public func loadCookies(_ key: String, removeCurrent: Bool = true, bindToURLs: Bool = true) {
        if removeCurrent { removeAllCookies() }
        let cookies = (Self.keyedCookies[key] ?? []).map({ $0.cookie })
        if bindToURLs { setCookies(cookies, bindToURLs: bindToURLs) }
    }
    
    private static var keyedCookies: [String: [HTTPCookie.CodableCookie]] {
        get { Defaults.shared["keyedCookies"] ?? [:] }
        set { Defaults.shared["keyedCookies"] = newValue }
    }
    
    /**
     Creates a HTTP cookies storage with the cookies specified in the given JSON string.
     
     - Parameter jsonString: The json string that specifies the cookies.
     */
    public convenience init(jsonString: String) throws {
        self.init()
        try loadCookies(fromJSONString: jsonString)
    }
    
    /**
     Creates a HTTP cookies storage with the cookies specified in the given Netscape cookies text file or JSON cookies file.
     
     - Parameter cookiesFile: The URL of the Netscape cookies text file or cookies JSON file.
     */
    public convenience init(cookiesFile: URL) throws {
        self.init()
        try loadCookies(fromFile: cookiesFile)
    }
    
    /**
     Sets the cookies specified in the given JSON string.
     
     - Parameter jsonString: The json string that specifies the cookies.
     */
    public func loadCookies(fromJSONString jsonString: String, bindToURLs: Bool = true) throws {
        setCookies(try HTTPCookie.cookies(fromJSONString: jsonString), bindToURLs: bindToURLs)
    }
    
    /**
     Sets the cookies specified in a Netscape cookies text file or cookies JSON file.
     
     - Parameter cookiesFile: The URL of the Netscape cookies text file or JSON cookies file.
     */
    public func loadCookies(fromFile cookiesFile: URL, bindToURLs: Bool = true) throws {
        setCookies(try HTTPCookie.cookies(fromFile: cookiesFile), bindToURLs: bindToURLs)
    }
    
    /**
     Sets multiple cookies in the storage, optionally binding them to URLs based on their domains.

     - Parameters:
       - cookies: An array of `HTTPCookie` objects to be stored. Expired cookies will be automatically filtered out.
       - bindToURLs: A Boolean indicating whether the cookies should be bound to URLs derived from their domains.
         If `true`, cookies are grouped by domain and associated with either `http` or `https` URLs depending on the presence of secure cookies.
         If `false`, cookies are added directly to the storage without binding to URLs.

     This method ensures that expired cookies are not set. When `bindToURLs` is enabled, cookies with domains starting with a dot (`.`) will have the dot removed when constructing the URL. Secure cookies will use `https`, while others will use `http`.
     */
    public func setCookies(_ cookies: [HTTPCookie], bindToURLs: Bool = false) {
        let cookies = cookies.filter { !$0.isExpired }
        if bindToURLs {
            let grouped = Dictionary(grouping: cookies) { cookie in
                cookie.domain.hasPrefix(".")
                    ? String(cookie.domain.dropFirst())
                    : cookie.domain
            }
            for (domain, cookies) in grouped {
                let usesSecure = cookies.contains { $0.isSecure }
                let scheme = usesSecure ? "https" : "http"
                guard let url = URL(string: "\(scheme)://\(domain)/") else {
                    continue
                }
                setCookies(cookies, for: url, mainDocumentURL: nil)
            }
        } else {
            cookies.forEach({ setCookie($0) })
        }
    }
}
