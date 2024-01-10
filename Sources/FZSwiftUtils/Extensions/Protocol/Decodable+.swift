//
//  Decodable+.swift
//
//
//  Created by Florian Zand on 05.02.23.
//

import Foundation

struct _EmptyDecodable: Decodable {}

public extension UnkeyedDecodingContainer {
    /// Skips decoding.
    mutating func skip() throws {
        _ = try decode(_EmptyDecodable.self)
    }
}
