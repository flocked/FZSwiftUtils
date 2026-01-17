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
        Self.keyedCookies[key] = cookies ?? []
    }
    
    /**
     Loads the cookies for the specific key from a global storage.
     
     - Parameters key: The key at which the ccokies are stored.
     */
    public func loadCookies(_ key: String, removeCurrent: Bool = true) {
        if removeCurrent { removeAllCookies() }
        setCookies(Self.keyedCookies[key] ?? [])
    }
    
    private static var keyedCookies: [String: [HTTPCookie]] {
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
    public func loadCookies(fromJSONString jsonString: String) throws {
        setCookies(try HTTPCookie.cookies(fromJSONString: jsonString))
    }
    
    /**
     Sets the cookies specified in a Netscape cookies text file or cookies JSON file.
     
     - Parameter cookiesFile: The URL of the Netscape cookies text file or JSON cookies file.
     */
    public func loadCookies(fromFile cookiesFile: URL) throws {
        setCookies(try HTTPCookie.cookies(fromFile: cookiesFile))
    }
    
    /**
     Inserts cookies into the storage,
     
     - Parameter cookies: The cookies to insert. Expired cookies are ignored.
     */
    public func setCookies(_ cookies: [HTTPCookie]) {
        cookies.filter { !$0.isExpired }.forEach({ setCookie($0) })
    }
}
