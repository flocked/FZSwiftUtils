//
//  HashFunction+.swift
//
//
//  Created by Florian Zand on 22.09.22.
//

import CryptoKit
import Foundation

public extension HashFunction {
    static func hash(string: String) -> Digest? {
        if let data = string.data(using: .utf16) {
            return hash(data: data)
        }
        return nil
    }
}
