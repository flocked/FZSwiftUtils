//
//  DictionaryDecoder.swift
//
//
//  Created by Almaz Ibragimov
//

import Foundation

/// An object that decodes instances of a data type from dictionaries.
public final class DictionaryDecoder: Sendable {

    private let optionsMutex: Mutex<Options>
    private let userInfoMutex: Mutex<[CodingUserInfoKey: Sendable]>

    /// The strategy used when decoding dates from part of a dictionary.
    public var dateDecodingStrategy: DateDecodingStrategy {
        get { optionsMutex.withLock { $0.dateDecodingStrategy } }
        set { optionsMutex.withLock { $0.dateDecodingStrategy = newValue } }
    }

    /// The strategy that a decoder uses to decode raw data.
    public var dataDecodingStrategy: DataDecodingStrategy {
        get { optionsMutex.withLock { $0.dataDecodingStrategy } }
        set { optionsMutex.withLock { $0.dataDecodingStrategy = newValue } }
    }

    /// The strategy used by a decoder when it encounters exceptional floating-point values.
    public var nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy {
        get { optionsMutex.withLock { $0.nonConformingFloatDecodingStrategy } }
        set { optionsMutex.withLock { $0.nonConformingFloatDecodingStrategy = newValue } }
    }

    /// A value that determines how to decode a type’s coding keys from dictionary keys.
    public var keyDecodingStrategy: KeyDecodingStrategy {
        get { optionsMutex.withLock { $0.keyDecodingStrategy } }
        set { optionsMutex.withLock { $0.keyDecodingStrategy = newValue } }
    }

    /// A dictionary you use to customize the decoding process by providing contextual information.
    public var userInfo: [CodingUserInfoKey: Sendable] {
        get { userInfoMutex.withLock { $0 } }
        set { userInfoMutex.withLock { $0 = newValue } }
    }

    // MARK: - Initializers

    /**
     Creates a new, reusable dictionary decoder with the specified decoding strategies.
     
     - Parameters:
        - dateDecodingStrategy: The strategy used when decoding dates from part of a dictionary.
        - dataDecodingStrategy: The strategy that a decoder uses to decode raw data.
        - nonConformingFloatDecodingStrategy: The strategy used by a decoder when it encounters exceptional floating-point values.
        - keyDecodingStrategy: A value that determines how to decode a type’s coding keys from dictionary keys.
        - userInfo: A dictionary you use to customize the decoding process by providing contextual information.
     */
    public init(
        dateDecodingStrategy: DateDecodingStrategy = .deferredToDate,
        dataDecodingStrategy: DataDecodingStrategy = .base64,
        nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy = .throw,
        keyDecodingStrategy: KeyDecodingStrategy = .useDefaultKeys,
        userInfo: [CodingUserInfoKey: Sendable] = [:]
    ) {
        let options = Options(
            dateDecodingStrategy: dateDecodingStrategy,
            dataDecodingStrategy: dataDecodingStrategy,
            nonConformingFloatDecodingStrategy: nonConformingFloatDecodingStrategy,
            keyDecodingStrategy: keyDecodingStrategy
        )

        self.optionsMutex = Mutex(options)
        self.userInfoMutex = Mutex(userInfo)
    }

    /**
     Returns a value of the type you specify, decoded from a dictionary.
     
     If a value within the dictionary fails to decode, this method throws the corresponding error.
     
     - Parameters:
        - type: The type of the value to decode from the supplied dictionary.
        - dictionary: The dictionary to decode.
     - Returns: A value of the specified type, if the decoder can parse the data.
     */
    public func decode<T: Decodable>(_ type: T.Type = T.self, from dictionary: [String: Any]) throws -> T {
        let options = optionsMutex.withLock { $0 }
        let decoder = SingleValueDecoder(
            component: dictionary,
            options: options,
            userInfo: userInfo,
            codingPath: []
        )
        return try T(from: decoder)
    }

    /**
     Returns a value of the type you specify, decoded from a dictionary.
     
     If a value within the dictionary fails to decode, this method throws the corresponding error.
     
     - Parameter dictionary: The dictionary to decode.
     - Returns: A value of the specified type, if the decoder can parse the data.
     */
    public func decode<T: Decodable>(from dictionary: [String: Any]) throws -> T {
        try decode(T.self, from: dictionary)
    }

    public func decode<T: DecodableWithConfiguration>(
        _ type: T.Type = T.self,
        from dictionary: [String: Any],
        configuration: T.DecodingConfiguration
    ) throws -> T {
        let options = optionsMutex.withLock { $0 }

        let decoder = SingleValueDecoder(
            component: dictionary,
            options: options,
            userInfo: userInfo,
            codingPath: []
        )

        return try T(from: decoder, configuration: configuration)
    }
}
