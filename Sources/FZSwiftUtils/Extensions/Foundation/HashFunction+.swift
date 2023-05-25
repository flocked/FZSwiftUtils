//
//  File.swift
//  
//
//  Created by Florian Zand on 22.09.22.
//

import Foundation
import CryptoKit

extension HashFunction {
    public static func hash(string: String) -> Digest? {
        if let data = string.data(using: .utf16) {
            return self.hash(data: data)
        }
        return nil
    }
}
