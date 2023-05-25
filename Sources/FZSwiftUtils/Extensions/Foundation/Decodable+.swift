//
//  File.swift
//  
//
//  Created by Florian Zand on 05.02.23.
//

import Foundation

internal struct _EmptyDecodable: Decodable { }

extension UnkeyedDecodingContainer {
  public mutating func skip() throws {
    _ = try decode(_EmptyDecodable.self)
  }
}
