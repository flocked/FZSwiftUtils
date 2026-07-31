//
//  CodingError+.swift
//  
//
//  Created by Florian Zand on 11.01.26.
//

import Foundation

public extension DecodingError {
    /**
     An indication that the given value could not be decoded because it did not match the type of what was found in the encoded payload or is missing.
     
     - Parameters:
       - component: The value being decoded, or `nil` if absent.
       - codingPath: The full coding path at the point of failure.
       - expectation: The expected type of the value.
     */
    static func invalidComponent(_ component: Any?, at codingPath: [CodingKey], expectation: Any.Type) -> DecodingError {
        let componentDescription = component.map { "\(type(of: $0))" } ?? "nil"
        let context = Context(codingPath: codingPath, debugDescription: "Expected to decode \(expectation) but found \(componentDescription) instead.")
        return .typeMismatch(expectation, context)
    }
    
    /**
     An indication that a value for the given key in a keyed decoding container could not be decoded because it did not match the type of what was found in the encoded payload or is missing.
     
     - Parameters:
       - component: The value associated with the key, or `nil` if no value exists.
       - key: The coding key associated with the value.
       - codingPath: The full coding path at the point of failure.
       - expectation: The expected type of the value.
     */
    static func invalidComponent<Key: CodingKey>(_ component: Any?, forKey key: Key, at codingPath: [CodingKey], expectation: Any.Type) -> Self {
        switch component {
        case let component?:
            let context = Context(codingPath: codingPath, debugDescription: "Expected to decode \(expectation) but found \(type(of: component)) instead.")
            return .typeMismatch(expectation, context)
        case nil:
            let context = Context(codingPath: codingPath, debugDescription: "No value associated with key \(key.stringValue).")
            return .keyNotFound(key, context)
        }
    }
    
    /// An indication that the data is corrupted or otherwise invalid.
    static func dataCorrupted(at codingPath: [CodingKey], debugDescription: String, underlyingError: Error? = nil) -> Self {
        dataCorrupted(.init(codingPath: codingPath, debugDescription: debugDescription, underlyingError: underlyingError))
    }
    
    /// An indication that a keyed decoding container was asked for an entry for the given key, but did not contain one.
    static func keyNotFound(_ key: CodingKey, at codingPath: [CodingKey], debugDescription: String, underlyingError: Error? = nil) -> Self {
        keyNotFound(key, .init(codingPath: codingPath, debugDescription: debugDescription, underlyingError: underlyingError))
    }
    
    /// An indication that a value of the given type could not be decoded because it did not match the type of what was found in the encoded payload.
    static func typeMismatch(_ value: Any.Type, at codingPath: [CodingKey], debugDescription: String, underlyingError: Error? = nil) -> Self {
        typeMismatch(value, .init(codingPath: codingPath, debugDescription: debugDescription, underlyingError: underlyingError))
    }
    
    /// An indication that a non-optional value of the given type was expected, but a null value was found.
    static func valueNotFound(_ value: Any.Type, at codingPath: [CodingKey], debugDescription: String, underlyingError: Error? = nil) -> Self {
        valueNotFound(value, .init(codingPath: codingPath, debugDescription: debugDescription, underlyingError: underlyingError))
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
    /// An indication that an encoder or its containers could not encode the given value.
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
