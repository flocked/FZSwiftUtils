//
//  Codable+.swift
//
//
//  Created by Florian Zand on 05.02.23.
//

import Foundation

extension Decodable where Self: NSCoding & NSObject {
    public init(from decoder: any Decoder) throws {
        let data = try decoder.singleValueContainer().decode(Data.self)
        guard let value = try NSKeyedUnarchiver.unarchivedObject(ofClass: Self.self, from: data) else {
            throw DecodingError.dataCorrupted("The encoded data is corrupt.")
        }
        self = value
    }
}

extension Encodable where Self: NSCoding & NSObject {
    public func encode(to encoder: any Encoder) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
        var container = encoder.singleValueContainer()
        try container.encode(data)
    }
}

extension Encodable where Self: NSSecureCoding & NSObject {
    public func encode(to encoder: any Encoder) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: Self.supportsSecureCoding)
        var container = encoder.singleValueContainer()
        try container.encode(data)
    }
}
