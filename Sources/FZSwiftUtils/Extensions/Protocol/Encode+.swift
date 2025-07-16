//
//  Encode+.swift
//  
//
//  Created by Florian Zand on 16.07.25.
//

public extension Encoder {
    /**
     Encodes a single value into the encoder's single value container.

     - Parameter value: The value to encode.
     - Throws: An error if encoding fails.

     This is a convenience method to simplify encoding a single value without manually creating the container.
     */
    func encodeSingle<T: Encodable>(_ value: T) throws {
        var container = singleValueContainer()
        try container.encode(value)
    }
}
