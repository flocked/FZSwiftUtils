//
//  Data+.swift
//
//
//  Created by Florian Zand on 25.11.25.
//

import Foundation

extension Data {
    /// Returns a String by converting the data into Unicode characters using the [utf8](https://developer.apple.com/documentation/swift/string/encoding/utf8) String encoding.
    public var string: String? {
        String(data: self, encoding: .utf8)
    }
    
    /// Returns a String by converting the data into Unicode characters using the specified String encoding.
    public func string(encoding: String.Encoding) -> String? {
        String(data: self, encoding: encoding)
    }
    
    /// Decodes the data as the specified type.
    public func decoded<V: Decodable>(as type: V.Type = V.self, decoder: JSONDecoder = .init()) throws -> V {
        try decoder.decode(self)
    }
}
