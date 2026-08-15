//
//  DictionaryDecoder.swift
//
//
//  Created by Almaz Ibragimov
//

import Foundation

/// An object that decodes instances of a data type from dictionaries.
public final class DictionaryDecoder: Sendable {

    private let strategiesMutex: Mutex<Strategies>
    private let userInfoMutex: Mutex<[CodingUserInfoKey: Sendable]>

    private var strategies: Strategies {
        get { strategiesMutex.withLock { $0 } }
        set { strategiesMutex.withLock { $0 = newValue } }
    }
    
    /// The strategy used when decoding dates from part of a dictionary.
    public var dateDecodingStrategy: DateDecodingStrategy {
        get { strategies.date }
        set { strategies.date = newValue }
    }

    /// The strategy that a decoder uses to decode raw data.
    public var dataDecodingStrategy: DataDecodingStrategy {
        get { strategies.data }
        set { strategies.data = newValue }
    }

    /// The strategy used by a decoder when it encounters exceptional floating-point values.
    public var nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy {
        get { strategies.nonConformingFloat }
        set { strategies.nonConformingFloat = newValue }
    }

    /// A value that determines how to decode a type’s coding keys from dictionary keys.
    public var keyDecodingStrategy: KeyDecodingStrategy {
        get { strategies.key }
        set { strategies.key = newValue }
    }

    /// A dictionary you use to customize the decoding process by providing contextual information.
    public var userInfo: [CodingUserInfoKey: Sendable] {
        get { userInfoMutex.withLock { $0 } }
        set { userInfoMutex.withLock { $0 = newValue } }
    }
    
    /**
     Creates a new, reusable dictionary decoder with the specified decoding strategies.
     
     - Parameters:
        - dateDecodingStrategy: The strategy used when decoding dates from part of a dictionary.
        - dataDecodingStrategy: The strategy that a decoder uses to decode raw data.
        - nonConformingFloatDecodingStrategy: The strategy used by a decoder when it encounters exceptional floating-point values.
        - keyDecodingStrategy: A value that determines how to decode a type’s coding keys from dictionary keys.
        - userInfo: A dictionary you use to customize the decoding process by providing contextual information.
     */
    public init(dateDecodingStrategy: DateDecodingStrategy = .deferredToDate,
        dataDecodingStrategy: DataDecodingStrategy = .base64,
        nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy = .throw,
        keyDecodingStrategy: KeyDecodingStrategy = .useDefaultKeys,
        userInfo: [CodingUserInfoKey: Sendable] = [:]) {
        self.strategiesMutex = Mutex(Strategies(date: dateDecodingStrategy, data: dataDecodingStrategy, nonConformingFloat: nonConformingFloatDecodingStrategy, key: keyDecodingStrategy))
        self.userInfoMutex = Mutex(userInfo)
    }

    /**
     Returns a value of the specified type decoded from the given dictionary.
     
     If a value within the dictionary fails to decode, this method throws the corresponding error.
     
     - Parameters:
        - type: The type of the value to decode.
        - dictionary: The dictionary to decode from.
     - Returns: A value of the specified type.
     */
    public func decode<T: Decodable>(_ type: T.Type = T.self, from dictionary: [String: Any]) throws -> T {
        try T(from: Single(component: dictionary, strategies: strategies, userInfo: userInfo))
    }

    /**
     Returns a value of the specified type decoded from the given dictionary using the provided decoding configuration.
     
     If a value within the dictionary fails to decode, this method throws the corresponding error.
     
     - Parameters:
        - type: The type of the value to decode.
        - dictionary: The dictionary to decode from.
        - configuration: The configuration to use when decoding the value.
     - Returns: A value of the specified type.
     */
    public func decode<T: DecodableWithConfiguration>(_ type: T.Type = T.self, from dictionary: [String: Any], configuration: T.DecodingConfiguration) throws -> T {
        try T(from: Single(component: dictionary, strategies: strategies, userInfo: userInfo), configuration: configuration)
    }
    
    /**
     Returns a value of the specified type decoded from the given dictionary using the provided decoding configuration.
     
     If a value within the dictionary fails to decode, this method throws the corresponding error.
     
     - Parameters:
        - type: The type of the value to decode.
        - dictionary: The dictionary to decode from.
        - configuration: The configuration to use when decoding the value.
     - Returns: A value of the specified type.
     */
    public func decode<T, C>(_ type: T.Type, from dictionary: [String: Any], configuration: C.Type) throws -> T where T: DecodableWithConfiguration, C: DecodingConfigurationProviding, T.DecodingConfiguration == C.DecodingConfiguration {
        try decode(type, from: dictionary, configuration: C.decodingConfiguration)
    }
}
