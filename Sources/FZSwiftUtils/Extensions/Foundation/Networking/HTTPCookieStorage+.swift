//
//  File.swift
//  
//
//  Created by Florian Zand on 24.02.23.
//

import Foundation

public extension HTTPCookieStorage {
    func removeAllCookies() {
        self.cookies?.forEach({self.deleteCookie($0)})
    }
}
