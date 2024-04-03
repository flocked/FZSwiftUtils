//
//  Digest+.swift
//
//
//  Created by Florian Zand on 03.04.24.
//

import Foundation
import CryptoKit

extension Digest {
    
    /// The bytes of the digest.
    public var bytes: [UInt8] { Array(makeIterator()) }
    
    /// A data representation of the digest.
    public var data: Data { Data(bytes) }

    /// A hex string representation of the digest.
    public var hexString: String {
        bytes.map { String(format: "%02X", $0) }.joined()
    }
}
