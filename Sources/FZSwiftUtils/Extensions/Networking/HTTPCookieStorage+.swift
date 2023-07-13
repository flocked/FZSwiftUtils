//
//  HTTPCookieStorage+.swift
//
//
//  Created by Florian Zand on 24.02.23.
//

import Foundation

public extension HTTPCookieStorage {
    /**
     Removes all cookies stored in the HTTPCookieStorage.

     This method removes all cookies currently stored in the HTTPCookieStorage instance.
     */
    func removeAllCookies() {
        cookies?.forEach { self.deleteCookie($0) }
    }
}
