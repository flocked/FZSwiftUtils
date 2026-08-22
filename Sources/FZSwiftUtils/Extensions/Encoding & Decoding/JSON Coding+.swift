//
//  JSONEncoderDecoder+.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation

public extension JSONEncoder {
    /**
     Initializes a JSON encoder with the specified encoding strategies and output formatting options.

     - Parameters:
        - dateEncodingStrategy: The strategy to use for encoding dates.
        - keyEncodingStrategy: The strategy to use for encoding keys.
        - dataEncodingStrategy: The strategy that an encoder uses to encode raw data.
        - nonConformingFloatEncodingStrategy: The strategy used by an encoder when it encounters exceptional floating-point values.
        - outputFormatting: The formatting options to apply to the encoded JSON data.
     */
    @_disfavoredOverload
    convenience init(dateEncodingStrategy: DateEncodingStrategy = .deferredToDate,
                     keyEncodingStrategy: KeyEncodingStrategy = .useDefaultKeys,
                     dataEncodingStrategy: DataEncodingStrategy = .base64,
                     nonConformingFloatEncodingStrategy: NonConformingFloatEncodingStrategy = .throw,
                     outputFormatting: OutputFormatting = [])
    {
        self.init()
        self.dateEncodingStrategy = dateEncodingStrategy
        self.keyEncodingStrategy = keyEncodingStrategy
        self.dataEncodingStrategy = dataEncodingStrategy
        self.nonConformingFloatEncodingStrategy = nonConformingFloatEncodingStrategy
        self.outputFormatting = outputFormatting
    }
    

    /// Sets the dictionary you use to customize the encoding process by providing contextual information.
    func userInfo(_ userInfo:  [CodingUserInfoKey : any Sendable]) -> Self {
        self.userInfo = userInfo
        return self
    }
    
    /// Sets the strategy used when encoding dates as part of a JSON object.
    func dateStrategy(_ strategy: DateEncodingStrategy) -> Self {
        dateEncodingStrategy = strategy
        return self
    }
    
    /// Sets the strategy used by an encoder when it encounters exceptional floating-point values.
    func nonConformingFloatStrategy(_ strategy: NonConformingFloatEncodingStrategy) -> Self {
        nonConformingFloatEncodingStrategy = strategy
        return self
    }
    
    /// Sets the strategy that an encoder uses to encode raw data.
    func dataStrategy(_ strategy: DataEncodingStrategy) -> Self {
        dataEncodingStrategy = strategy
        return self
    }
    
    /// Sets the strategy that determines how to encode a type’s coding keys as JSON keys.
    func keyStrategy(_ strategy: KeyEncodingStrategy) -> Self {
        keyEncodingStrategy = strategy
        return self
    }
    
    /// Sets the value that determines the readability, size, and element order of the encoded JSON object.
    func outputFormatting(_ outputFormatting: OutputFormatting) -> Self {
        self.outputFormatting = outputFormatting
        return self
    }
    
    /**
     Encodes the specified encodable object to a JSON object.

     - Parameters:
        - value: The encodable object to encode.
        - options: The reading options for deserializing the JSON data.
     - Returns: The encoded JSON object.
     - Throws: An error if encoding fails.
     */
    func encodeJSONObject<V: Encodable>(_ value: V, options: JSONSerialization.ReadingOptions = []) throws -> Any {
        let data = try encode(value)
        return try JSONSerialization.jsonObject(with: data, options: options)
    }
}

public extension JSONEncoder.DateEncodingStrategy {
    /// The strategy that defers formatting settings to a supplied date format.
    static func formatted(_ format: String) -> Self {
        .formatted(DateFormatter(format))
    }
}

public extension JSONDecoder {
    /**
     Initializes a JSON decoder with the specified decoding strategies.

     - Parameters:
        - dateDecodingStrategy: The strategy to use for decoding dates.
        - keyDecodingStrategy: The strategy to use for decoding keys.
        - dataDecodingStrategy: The strategy tto use for decoding raw data.
        - nonConformingFloatDecodingStrategy: The strategy used by a decoder when it encounters exceptional floating-point values.
        - assumesTopLevelDictionary: A Boolean value that indicates whether the decoding assumes the top level of the `JSON` data is a dictionary, even if it doesn’t begin and end with braces.
     */
    @_disfavoredOverload
    convenience init(dateDecodingStrategy: DateDecodingStrategy = .deferredToDate,
                     keyDecodingStrategy: KeyDecodingStrategy = .useDefaultKeys,
                     dataDecodingStrategy: DataDecodingStrategy = .base64,
                     nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy = .throw,
                     assumesTopLevelDictionary: Bool = false) {
        self.init()
        self.dateDecodingStrategy = dateDecodingStrategy
        self.keyDecodingStrategy = keyDecodingStrategy
        self.dataDecodingStrategy = dataDecodingStrategy
        self.nonConformingFloatDecodingStrategy = nonConformingFloatDecodingStrategy
        self.assumesTopLevelDictionary = assumesTopLevelDictionary
    }
    
    /// Sets the Boolean value indicating whether decoding assumes the top level of the JSON data is a dictionary, even if it doesn’t begin and end with braces.
    @discardableResult
    func assumesTopLevelDictionary(_ assumes: Bool) -> Self {
        assumesTopLevelDictionary = assumes
        return self
    }
    
    /// Sets the Boolean value indicating whether decoding supports the JSON5 syntax.
    @discardableResult
    func allowsJSON5(_ allowsJSON5: Bool) -> Self {
        self.allowsJSON5 = allowsJSON5
        return self
    }
    
    /// Sets the dictionary you use to customize the decoding process by providing contextual information.
    @discardableResult
    func userInfo(_ userInfo:  [CodingUserInfoKey : any Sendable]) -> Self {
        self.userInfo = userInfo
        return self
    }
    
    /// Sets the strategy used when decoding dates from part of a JSON object.
    @discardableResult
    func dateStrategy(_ strategy: DateDecodingStrategy) -> Self {
        dateDecodingStrategy = strategy
        return self
    }
    
    /// Sets the strategy used by a decoder when it encounters exceptional floating-point values.
    @discardableResult
    func nonConformingFloatStrategy(_ strategy: NonConformingFloatDecodingStrategy) -> Self {
        nonConformingFloatDecodingStrategy = strategy
        return self
    }
    
    /// Sets the strategy that a decoder uses to decode raw data.
    @discardableResult
    func dataStrategy(_ strategy: DataDecodingStrategy) -> Self {
        dataDecodingStrategy = strategy
        return self
    }
    
    /// Sets the strategy that determines how to decode a type’s coding keys from JSON keys.
    @discardableResult
    func keyStrategy(_ strategy: KeyDecodingStrategy) -> Self {
        keyDecodingStrategy = strategy
        return self
    }

    /**
     Decodes a JSON object to a model object of the specified type.

     - Parameters:
        - type: The type of the model object to decode.
        - object: The JSON object to decode.
        - options: The writing options for serializing the JSON data.
     - Returns: A model object of the specified type.
     - Throws: An error if decoding fails.
     */
    @_disfavoredOverload
    func decode<T: Decodable>(_: T.Type, withJSONObject object: Any, options: JSONSerialization.WritingOptions = []) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: object, options: options)
        return try decode(T.self, from: data)
    }
    
    /**
     Decodes a JSON object to a model object of the specified type.

     - Parameters:
        - object: The JSON object to decode.
        - options: The writing options for serializing the JSON data.
     - Returns: A model object of the specified type.
     - Throws: An error if decoding fails.
     */
    @_disfavoredOverload
    func decode<T: Decodable>(_ object: Any, options: JSONSerialization.WritingOptions = []) throws -> T {
        try decode(T.self, withJSONObject: object, options: options)
    }
    
    /**
     Returns a value of the type you specify, decoded from a `JSON` object.
     
     If the data isn’t valid `JSON`, this method throws the [DecodingError.dataCorrupted(_:)](https://developer.apple.com/documentation/swift/decodingerror/datacorrupted(_:)) error. If a value within the JSON fails to decode, this method throws the corresponding error.
     
     - Parameter data: The `JSON` object to decode.
     - Returns: A value of the specified type.
     */
    func decode<T: Decodable>(_ data: Data) throws -> T {
        try decode(T.self, from: data)
    }
}

public extension JSONDecoder.DateDecodingStrategy {
    /// The strategy that defers formatting settings to a supplied date format.
    static func formatted(_ format: String) -> Self {
        .formatted(DateFormatter(format))
    }
}

extension JSONDecoder {
    /// The strategy to use when an element of a sequence fails to decode.
    public enum InvalidElementDecodingStrategy {
        /// Throws upon encountering an element that fails to decode. This is the default strategy.
        case `throw`
        /// Ignores elements that fail to decode.
        case lenient
    }
    
    public func decode<T>(_ type: T.Type, from data: Data, invalidElementDecodingStrategy: InvalidElementDecodingStrategy) throws -> T where T: Decodable & RangeReplaceableCollection, T.Element: Decodable {
        switch invalidElementDecodingStrategy {
        case .throw:
            return try decode(type, from: data)
        case .lenient:
            return T(try decode([FailableDecodable<T.Element>].self, from: data).compactMap({$0.value}))
        }
    }
}

/// A container that stores a decoded value, or `nil` if the value fails to decode.
public struct FailableDecodable<Value: Decodable>: Decodable {
    /// The decoded value, or `nil` if decoding failed.
    public let value: Value?

    /// Creates a new instance by decoding a value, storing `nil` if the value fails to decode.
    public init(from decoder: Decoder) throws {
        value = try? decoder.decodeSingle()
    }
}

extension FailableDecodable: Encodable where Value: Encodable {
    public func encode(to encoder: Encoder) throws {
       try encoder.encodeSingle(value)
    }
}

extension FailableDecodable: Equatable where Value: Equatable { }
extension FailableDecodable: Hashable where Value: Hashable { }
extension FailableDecodable: Sendable where Value: Sendable { }
