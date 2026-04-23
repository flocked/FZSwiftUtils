//
//  DictionaryEncoder.swift
//
//
//  Created by Almaz Ibragimov
//

import Foundation

/// An object that encodes instances of a data type as dictionary.
public final class DictionaryEncoder: Sendable {

    private let optionsMutex: Mutex<Options>
    private let userInfoMutex: Mutex<[CodingUserInfoKey: Sendable]>

    /// The strategy used when encoding dates as part of a dictionary.
    public var dateEncodingStrategy: DateEncodingStrategy {
        get { optionsMutex.withLock { $0.dateEncodingStrategy } }
        set { optionsMutex.withLock { $0.dateEncodingStrategy = newValue } }
    }

    /// The strategy that an encoder uses to encode raw data.
    public var dataEncodingStrategy: DataEncodingStrategy {
        get { optionsMutex.withLock { $0.dataEncodingStrategy } }
        set { optionsMutex.withLock { $0.dataEncodingStrategy = newValue } }
    }

    /// The strategy used by an encoder when it encounters exceptional floating-point values.
    public var nonConformingFloatEncodingStrategy: NonConformingFloatEncodingStrategy {
        get { optionsMutex.withLock { $0.nonConformingFloatEncodingStrategy } }
        set { optionsMutex.withLock { $0.nonConformingFloatEncodingStrategy = newValue } }
    }

    /// The strategy that an encoder uses to encode `nil` values.
    public var nilEncodingStrategy: NilEncodingStrategy {
        get { optionsMutex.withLock { $0.nilEncodingStrategy } }
        set { optionsMutex.withLock { $0.nilEncodingStrategy = newValue } }
    }

    /// A value that determines how to encode a type’s coding keys as dictionary keys.
    public var keyEncodingStrategy: KeyEncodingStrategy {
        get { optionsMutex.withLock { $0.keyEncodingStrategy } }
        set { optionsMutex.withLock { $0.keyEncodingStrategy = newValue } }
    }

    /// A dictionary you use to customize the encoding process by providing contextual information.
    public var userInfo: [CodingUserInfoKey: Sendable] {
        get { userInfoMutex.withLock { $0 } }
        set { userInfoMutex.withLock { $0 = newValue } }
    }

    // MARK: - Initializers

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
    public init(
        dateEncodingStrategy: DateEncodingStrategy = .deferredToDate,
        dataEncodingStrategy: DataEncodingStrategy = .base64,
        nonConformingFloatEncodingStrategy: NonConformingFloatEncodingStrategy = .throw,
        nilEncodingStrategy: NilEncodingStrategy = .useNil,
        keyEncodingStrategy: KeyEncodingStrategy = .useDefaultKeys,
        userInfo: [CodingUserInfoKey: Sendable] = [:]
    ) {
        let options = Options(
            dateEncodingStrategy: dateEncodingStrategy,
            dataEncodingStrategy: dataEncodingStrategy,
            nonConformingFloatEncodingStrategy: nonConformingFloatEncodingStrategy,
            nilEncodingStrategy: nilEncodingStrategy,
            keyEncodingStrategy: keyEncodingStrategy
        )

        self.optionsMutex = Mutex(options)
        self.userInfoMutex = Mutex(userInfo)
    }

    // MARK: - Instance Methods

    /**
     Returns a dictionary representation of the value you supply.
     
     - Parameter value: The value to encode as dictionary.
     - Returns: The encoded dictionary.
     
     If there’s a problem encoding the value you supply, this method throws an error based on the type of problem:
     - The value fails to encode, or contains a nested value that fails to encode—this method throws the corresponding error.
     - The value contains an exceptional floating-point number (such as [infinity](https://developer.apple.com/documentation/swift/floatingpoint/infinity) or [nan](https://developer.apple.com/documentation/swift/floatingpoint/nan)) and you’re using the default ``NonConformingFloatEncodingStrategy/throw`` — this method throws an error.
     */
    public func encode<T: Encodable>(_ value: T) throws -> [String: Sendable] {
        let options = optionsMutex.withLock { $0 }

        let encoder = DictionarySingleValueEncodingContainer(
            options: options,
            userInfo: userInfo,
            codingPath: []
        )

        try value.encode(to: encoder)

        guard let dictionary = encoder.resolveValue() as? [String: Sendable] else {
            let errorContext = EncodingError.Context(
                codingPath: [],
                debugDescription: "Root component cannot be encoded in Dictionary"
            )

            throw EncodingError.invalidValue(value, errorContext)
        }

        return dictionary
    }

    @available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
    public func encode<T: EncodableWithConfiguration>(
        _ value: T,
        configuration: T.EncodingConfiguration
    ) throws -> [String: Sendable] {
        let options = optionsMutex.withLock { $0 }

        let encoder = DictionarySingleValueEncodingContainer(
            options: options,
            userInfo: userInfo,
            codingPath: []
        )

        try value.encode(to: encoder, configuration: configuration)

        guard let dictionary = encoder.resolveValue() as? [String: Sendable] else {
            let errorContext = EncodingError.Context(
                codingPath: [],
                debugDescription: "Root component cannot be encoded in Dictionary"
            )

            throw EncodingError.invalidValue(value, errorContext)
        }

        return dictionary
    }
}
