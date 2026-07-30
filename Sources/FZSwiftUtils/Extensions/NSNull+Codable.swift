//
//  NSNull+Codable.swift
//  
//
//  Created by Florian Zand on 30.07.26.
//

import Foundation

extension NSNull: Swift.Encodable, Swift.Decodable {
    public func encode(to encoder: any Encoder) throws {
        try encoder.encodeNil()
    }
}

public extension Decodable where Self: NSNull {
    init(from decoder: any Decoder) throws {
        try decoder.decodeNil()
        self.init()
    }
}
