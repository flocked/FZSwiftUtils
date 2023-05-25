//
//  String+Hash.swift
//
//
//  Created by Florian Zand on 19.02.23.
//

import CryptoKit
import Foundation

public extension String {
    enum HashOption {
        case MD5
        case SHA1
    }

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
