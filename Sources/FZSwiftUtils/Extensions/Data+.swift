//
//  Data+.swift
//
//
//  Created by Florian Zand on 25.11.25.
//

import Foundation

extension Data {
    /// Returns a String initialized by converting the data into Unicode characters using the specified encoding.
    public func string(encoding: String.Encoding = .utf8) -> String? {
        String(data: self, encoding: encoding)
    }
    
    /// Decodes the data as the specified type.
    public func decoded<V: Decodable>(as type: V.Type = V.self, decoder: JSONDecoder = .init()) throws -> V {
        try decoder.decode(self)
    }
}
