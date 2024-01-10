//
//  String+Hash.swift
//
//
//  Created by Florian Zand on 19.02.23.
//

import CryptoKit
import Foundation

public extension String {
    /// The options for hash algorithms.
    enum HashOption {
        /// MD5 hashing algorithm.
        case MD5
        /// SHA1 hashing algorithm.
        case SHA1
    }

    /**
     Computes the hash value of the string using the specified hash algorithm.

     - Parameter option: The hash algorithm option to use.
     - Returns: The computed hash value as a string.
     */
    func hash(_ option: HashOption) -> String {
        switch option {
        case .MD5:
            let computed = Insecure.MD5.hash(data: data(using: .utf8)!)
            return computed.map { String(format: "%02hhx", $0) }.joined()
        case .SHA1:
            let computed = Insecure.SHA1.hash(data: data(using: .utf8)!)
            return computed.map { String(format: "%02hhx", $0) }.joined()
        }
    }
}
