//
//  Decoder+.swift
//
//
//  Created by Florian Zand on 16.07.25.
//

public extension Decoder {
    /**
     Decodes a single value from the decoder's single value container.

     - Parameter type: The type of the value to decode.
     - Returns: A decoded value of the specified type.
     - Throws: An error if decoding fails, or if the container does not contain a single value of the expected type.

     This is a convenience method to simplify decoding a single value without manually creating the container.
     */
    func decodeSingle<T: Decodable>(_ type: T.Type) throws -> T {
        try singleValueContainer().decode(type)
    }
}
