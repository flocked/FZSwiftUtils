//
//  CodingError+.swift
//  
//
//  Created by Florian Zand on 11.01.26.
//

import Foundation

extension DecodingError.Context: Swift.ExpressibleByStringLiteral, Swift.ExpressibleByExtendedGraphemeClusterLiteral, Swift.ExpressibleByUnicodeScalarLiteral {
    public init(stringLiteral value: String) {
        self.init(codingPath: [], debugDescription: value)
    }
    
    public init(_ debugDescription: String) {
        self.init(codingPath: [], debugDescription: debugDescription)
    }
}

extension EncodingError.Context: Swift.ExpressibleByStringLiteral, Swift.ExpressibleByExtendedGraphemeClusterLiteral, Swift.ExpressibleByUnicodeScalarLiteral {
    public init(stringLiteral value: String) {
        self.init(codingPath: [], debugDescription: value)
    }
    
    public init(_ debugDescription: String) {
        self.init(codingPath: [], debugDescription: debugDescription)
    }
}

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
}
