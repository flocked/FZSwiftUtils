//
//  Codable+.swift
//
//
//  Created by Florian Zand on 05.02.23.
//

import Foundation

extension Decodable where Self: NSCoding & NSObject {
    public init(from decoder: any Decoder) throws {
        guard let value = try NSKeyedUnarchiver.unarchivedObject(ofClass: Self.self, from: decoder.decodeSingle()) else {
            throw DecodingError.dataCorrupted("The encoded data is corrupt.")
        }
        self = value
    }
}

extension Encodable where Self: NSCoding & NSObject {
    public func encode(to encoder: any Encoder) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
        try encoder.encodeSingle(data)
    }
}

extension Encodable where Self: NSSecureCoding & NSObject {
    public func encode(to encoder: any Encoder) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: Self.supportsSecureCoding)
        try encoder.encodeSingle(data)
    }
}
