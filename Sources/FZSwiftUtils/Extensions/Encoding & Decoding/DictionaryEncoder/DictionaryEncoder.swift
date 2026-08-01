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
        get { strategiesMutex.withLock { $0.date } }
        set { strategiesMutex.withLock { $0.date = newValue } }
    }

    /// The strategy that an encoder uses to encode raw data.
    public var dataEncodingStrategy: DataEncodingStrategy {
        get { strategiesMutex.withLock { $0.data } }
        set { strategiesMutex.withLock { $0.data = newValue } }
    }

    /// The strategy used by an encoder when it encounters exceptional floating-point values.
    public var nonConformingFloatEncodingStrategy: NonConformingFloatEncodingStrategy {
        get { strategiesMutex.withLock { $0.nonConformingFloat } }
        set { strategiesMutex.withLock { $0.nonConformingFloat = newValue } }
    }

    /// The strategy that an encoder uses to encode `nil` values.
    public var nilEncodingStrategy: NilEncodingStrategy {
        get { strategiesMutex.withLock { $0.nil } }
        set { strategiesMutex.withLock { $0.nil = newValue } }
    }

    /// A value that determines how to encode a type’s coding keys as dictionary keys.
    public var keyEncodingStrategy: KeyEncodingStrategy {
        get { strategiesMutex.withLock { $0.key } }
        set { strategiesMutex.withLock { $0.key = newValue } }
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
        let strategies = Strategies(date: dateEncodingStrategy, data: dataEncodingStrategy, nonConformingFloat: nonConformingFloatEncodingStrategy, nil: nilEncodingStrategy, key: keyEncodingStrategy)
        self.strategiesMutex = Mutex(strategies)
        self.userInfoMutex = Mutex(userInfo)
    }

    /**
     Returns a dictionary representation of the value you supply.
     
     - Parameter value: The value to encode as dictionary.
     - Returns: The encoded dictionary.
     - Throws:
        - The value fails to encode, or contains a nested value that fails to encode.
        - The value contains an exceptional floating-point number (such as [infinity](https://developer.apple.com/documentation/swift/floatingpoint/infinity) or [nan](https://developer.apple.com/documentation/swift/floatingpoint/nan)) and you’re using the default ``NonConformingFloatEncodingStrategy/throw`.
     */
    public func encode<T: Encodable>(_ value: T) throws -> [String: Sendable] {
        let encoder = Single(strategies: strategies, userInfo: userInfo, codingPath: [])
        try value.encode(to: encoder)
        guard let dictionary = encoder.resolveValue() as? [String: Sendable] else {
            throw EncodingError.invalidValue(value, at: [], debugDescription: "Root component cannot be encoded in Dictionary")
        }
        return dictionary
    }

    public func encode<T: EncodableWithConfiguration>(_ value: T, configuration: T.EncodingConfiguration) throws -> [String: Sendable] {
        let encoder = Single(strategies: strategies, userInfo: userInfo, codingPath: [])
        try value.encode(to: encoder, configuration: configuration)
        guard let dictionary = encoder.resolveValue() as? [String: Sendable] else {
            throw EncodingError.invalidValue(value, at: [], debugDescription: "Root component cannot be encoded in Dictionary")
        }
        return dictionary
    }
}
