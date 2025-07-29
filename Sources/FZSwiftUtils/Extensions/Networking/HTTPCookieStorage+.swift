//
//  HTTPCookieStorage+.swift
//
//
//  Created by Florian Zand on 24.02.23.
//

import Foundation

public extension HTTPCookieStorage {
    /// Removes all cookies stored in the `HTTPCookieStorage`.
    func removeAllCookies() {
        cookies?.forEach { deleteCookie($0) }
    }
}
