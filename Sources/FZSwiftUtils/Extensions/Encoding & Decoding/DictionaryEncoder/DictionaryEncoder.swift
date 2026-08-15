//
//  DictionaryEncoder.swift
//
//
//  Created by Almaz Ibragimov
//

import Foundation

/// An object that encodes instances of a data type as dictionary.
public final class DictionaryEncoder: Sendable {

    private let strategiesMutex: Mutex<Strategies>
    private let userInfoMutex: Mutex<[CodingUserInfoKey: Sendable]>

    /// The strategy used when encoding dates as part of a dictionary.
    public var dateEncodingStrategy: DateEncodingStrategy {
        get { strategies.date }
        set { strategies.date = newValue }
    }

    /// The strategy that an encoder uses to encode raw data.
    public var dataEncodingStrategy: DataEncodingStrategy {
        get { strategies.data }
        set { strategies.data = newValue }
    }

    /// The strategy used by an encoder when it encounters exceptional floating-point values.
    public var nonConformingFloatEncodingStrategy: NonConformingFloatEncodingStrategy {
        get { strategies.nonConformingFloat }
        set { strategies.nonConformingFloat = newValue }
    }

    /// The strategy that an encoder uses to encode `nil` values.
    public var nilEncodingStrategy: NilEncodingStrategy {
        get { strategies.nil }
        set { strategies.nil = newValue }
    }

    /// A value that determines how to encode a type’s coding keys as dictionary keys.
    public var keyEncodingStrategy: KeyEncodingStrategy {
        get { strategies.key }
        set { strategies.key = newValue }
    }

    /// A dictionary you use to customize the encoding process by providing contextual information.
    public var userInfo: [CodingUserInfoKey: Sendable] {
        get { userInfoMutex.withLock { $0 } }
        set { userInfoMutex.withLock { $0 = newValue } }
    }
    
    private var strategies: Strategies {
        get { strategiesMutex.withLock { $0 } }
        set { strategiesMutex.withLock { $0 = newValue } }
    }

    /**
     Creates a new, reusable dictionary encoder with the specified encoding strategies.
     
     - Parameters:
        -  dateEncodingStrategy: The strategy used when encoding dates as part of a dictionary.
        - dataEncodingStrategy: The strategy that an encoder uses to encode raw data.
        - nonConformingFloatEncodingStrategy: The strategy used by an encoder when it encounters exceptional floating-point values.
        - nilEncodingStrategy: The strategy that an encoder uses to encode `nil` values.
        - keyEncodingStrategy: A value that determines how to encode a type’s coding keys as dictionary keys.
        - userInfo: A dictionary you use to customize the encoding process by providing contextual information.
     */
    public init(dateEncodingStrategy: DateEncodingStrategy = .deferredToDate,
                dataEncodingStrategy: DataEncodingStrategy = .base64,
                nonConformingFloatEncodingStrategy: NonConformingFloatEncodingStrategy = .throw,
                nilEncodingStrategy: NilEncodingStrategy = .useNil,
                keyEncodingStrategy: KeyEncodingStrategy = .useDefaultKeys,
                userInfo: [CodingUserInfoKey: Sendable] = [:]) {
        self.strategiesMutex = Mutex(Strategies(date: dateEncodingStrategy, data: dataEncodingStrategy, nonConformingFloat: nonConformingFloatEncodingStrategy, nil: nilEncodingStrategy, key: keyEncodingStrategy))
        self.userInfoMutex = Mutex(userInfo)
    }

    /**
     Returns a dictionary representation of the specified value.
     
     - Parameter value: The value to encode as dictionary.
     - Returns: The encoded dictionary.
     - Throws:
        - The value fails to encode, or contains a nested value that fails to encode.
        - The value contains an exceptional floating-point number (such as [infinity](https://developer.apple.com/documentation/swift/floatingpoint/infinity) or [nan](https://developer.apple.com/documentation/swift/floatingpoint/nan)) and you’re using the default ``NonConformingFloatEncodingStrategy/throw`.
     */
    public func encode<T: Encodable>(_ value: T) throws -> [String: Sendable] {
        let encoder = Single(strategies: strategies, userInfo: userInfo)
        try value.encode(to: encoder)
        return try (encoder.resolveValue() as? [String: Sendable]).unwrap(or: EncodingError.invalidValue(value, at: [], debugDescription: "Root component cannot be encoded in Dictionary"))
    }

    /**
     Returns a dictionary representation of the specified value using the provided encoding configuration.
     
     - Parameters:
        - value: The value to encode as dictionary.
        - configuration: The configuration to use when encoding the value.
     - Returns: The encoded dictionary.
     */
    public func encode<T: EncodableWithConfiguration>(_ value: T, configuration: T.EncodingConfiguration) throws -> [String: Sendable] {
        let encoder = Single(strategies: strategies, userInfo: userInfo)
        try value.encode(to: encoder, configuration: configuration)
        return try (encoder.resolveValue() as? [String: Sendable]).unwrap(or: EncodingError.invalidValue(value, at: [], debugDescription: "Root component cannot be encoded in Dictionary"))
    }
    
    /**
     Returns a dictionary representation of the specified value using the provided encoding configuration.
     
     - Parameters:
        - value: The value to encode as dictionary.
        - configuration: The configuration to use when encoding the value.
     - Returns: The encoded dictionary.
     */
    public func encode<T, C>(_ value: T, configuration: C.Type) throws -> [String: Sendable] where T: EncodableWithConfiguration, C: EncodingConfigurationProviding, T.EncodingConfiguration == C.EncodingConfiguration {
        try encode(value, configuration: C.encodingConfiguration)
    }
}
