//
//  CodingError+.swift
//  
//
//  Created by Florian Zand on 11.01.26.
//

import Foundation

public extension DecodingError {
    /**
     An indication that the data is corrupted or otherwise invalid.
     
     - Parameters:
        - codingPath: The path of coding keys taken to reach the point where decoding failed.
     */
    static func dataCorrupted(at codingPath: [CodingKey]) -> Self {
        dataCorrupted(at: codingPath, debugDescription: "")
    }
    
    /**
     An indication that the data is corrupted or otherwise invalid.
     
     - Parameters:
        - codingPath: The path of coding keys taken to reach the point where decoding failed.
        - debugDescription: A description of what went wrong, for debugging purposes.
        - underlyingError: The underlying error which caused this error, if any.
     */
    static func dataCorrupted(at codingPath: [CodingKey], debugDescription: String, underlyingError: Error? = nil) -> Self {
        dataCorrupted(.init(codingPath: codingPath, debugDescription: debugDescription, underlyingError: underlyingError))
    }
    
    /**
     An indication that a keyed decoding container was asked for an entry for the given key, but did not contain one.
     
     - Parameters:
        - key: The key that was not found.
        - codingPath: The path of coding keys taken to reach the point where decoding failed.
     */
    static func keyNotFound(_ key: CodingKey, at codingPath: [CodingKey]) -> Self {
        keyNotFound(key, at: codingPath, debugDescription: "")
    }
    
    /**
     An indication that a keyed decoding container was asked for an entry for the given key, but did not contain one.
     
     - Parameters:
        - key: The key that was not found.
        - codingPath: The path of coding keys taken to reach the point where decoding failed.
        - debugDescription: A description of what went wrong, for debugging purposes.
        - underlyingError: The underlying error which caused this error, if any.
     */
    static func keyNotFound(_ key: CodingKey, at codingPath: [CodingKey], debugDescription: String, underlyingError: Error? = nil) -> Self {
        keyNotFound(key, .init(codingPath: codingPath, debugDescription: debugDescription, underlyingError: underlyingError))
    }
    
    /**
     An indication that a value of the given type could not be decoded because it did not match the type of what was found in the encoded payload.
     
     - Parameters:
        - type: The type of the value that was expected.
        - codingPath: The path of coding keys taken to reach the point where decoding failed.
     */
    static func typeMismatch(_ type: Any.Type, at codingPath: [CodingKey]) -> Self {
        typeMismatch(type, at: codingPath, debugDescription: "")
    }
    
    /**
     An indication that a value of the given type could not be decoded because it did not match the type of what was found in the encoded payload.
     
     - Parameters:
        - type: The type of the value that was expected.
        - codingPath: The path of coding keys taken to reach the point where decoding failed.
        - debugDescription: A description of what went wrong, for debugging purposes.
        - underlyingError: The underlying error which caused this error, if any.
     */
    static func typeMismatch(_ type: Any.Type, at codingPath: [CodingKey], debugDescription: String, underlyingError: Error? = nil) -> Self {
        typeMismatch(type, .init(codingPath: codingPath, debugDescription: debugDescription, underlyingError: underlyingError))
    }
    
    /**
     An indication that a value of the given type was found instead of the expected type.
     
     - Parameters:
        - foundType: The type of the value that was found.
        - expectedType: The type of the value that was expected.
        - codingPath: The path of coding keys taken to reach the point where decoding failed.
        - underlyingError: The underlying error which caused this error, if any.
     */
    static func typeMismatch(_ foundType: Any.Type, expected expectedType: Any.Type, at codingPath: [CodingKey], underlyingError: Error? = nil) -> Self {
        typeMismatch(expectedType, at: codingPath, debugDescription: "Found value of type \(foundType) instead.", underlyingError: underlyingError)
    }
    
    /**
     An indication that a non-optional value of the given type was expected, but a null value was found.
     
     - Parameters:
        - type: The type of the value that was expected.
        - codingPath: The path of coding keys taken to reach the point where decoding failed.
     */
    static func valueNotFound(_ type: Any.Type, at codingPath: [CodingKey]) -> Self {
        valueNotFound(type, at: codingPath, debugDescription: "")
    }
    
    /**
     An indication that a non-optional value of the given type was expected, but a null value was found.
     
     - Parameters:
        - type: The type of the value that was expected.
        - codingPath: The path of coding keys taken to reach the point where decoding failed.
        - debugDescription: A description of what went wrong, for debugging purposes.
        - underlyingError: The underlying error which caused this error, if any.
     */
    static func valueNotFound(_ type: Any.Type, at codingPath: [CodingKey], debugDescription: String, underlyingError: Error? = nil) -> Self {
        valueNotFound(type, .init(codingPath: codingPath, debugDescription: debugDescription, underlyingError: underlyingError))
    }
}

extension DecodingError.Context: Swift.ExpressibleByStringLiteral, Swift.ExpressibleByExtendedGraphemeClusterLiteral, Swift.ExpressibleByUnicodeScalarLiteral {
    public init(stringLiteral value: String) {
        self.init(codingPath: [], debugDescription: value)
    }
    
    /**
     Creates a new context with the given description of what went wrong.
     
     - Parameters:
        - debugDescription: A description of what went wrong, for debugging purposes.
        - underlyingError: The underlying error which caused this error, if any.
     */
    public init(debugDescription: String, underlyingError: Error? = nil) {
        self.init(codingPath: [], debugDescription: debugDescription, underlyingError: underlyingError)
    }
}

public extension EncodingError {
    /**
     An indication that an encoder or its containers could not encode the given value.
     
     - Parameters:
        - value: The value that could not be encoded.
        - codingPath: The path of coding keys taken to reach the point where encoding failed.
     */
    static func invalidValue(_ value: Any, at codingPath: [CodingKey]) -> Self {
        invalidValue(value, at: codingPath, debugDescription: "The value is not valid for encoding.")
    }
    
    /**
     An indication that an encoder or its containers could not encode the given value.
     
     - Parameters:
        - value: The value that could not be encoded.
        - codingPath: The path of coding keys taken to reach the point where encoding failed.
        - debugDescription: A description of what went wrong, for debugging purposes.
        - underlyingError: The underlying error which caused this error, if any.
     */
    static func invalidValue(_ value: Any, at codingPath: [CodingKey], debugDescription: String, underlyingError: Error? = nil) -> Self {
        invalidValue(value, .init(codingPath: codingPath, debugDescription: debugDescription, underlyingError: underlyingError))
    }
}

extension EncodingError.Context: Swift.ExpressibleByStringLiteral, Swift.ExpressibleByExtendedGraphemeClusterLiteral, Swift.ExpressibleByUnicodeScalarLiteral {
    public init(stringLiteral value: String) {
        self.init(codingPath: [], debugDescription: value)
    }
    
    /**
     Creates a new context with the given description of what went wrong.
     
     - Parameters:
        - debugDescription: A description of what went wrong, for debugging purposes.
        - underlyingError: The underlying error which caused this error, if any.
     */
    public init(debugDescription: String, underlyingError: Error? = nil) {
        self.init(codingPath: [], debugDescription: debugDescription, underlyingError: underlyingError)
    }
}
