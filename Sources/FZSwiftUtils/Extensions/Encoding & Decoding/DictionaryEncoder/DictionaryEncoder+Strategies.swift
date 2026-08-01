//
//  DictionaryEncoder+Strategies.swift
//
//
//  Created by Florian Zand on 17.05.25.
//

import Foundation

extension DictionaryEncoder {
    /// The strategies for encoding raw data.
    public enum DataEncodingStrategy: Sendable {
        /// The strategy that encodes data using the encoding specified by the data instance itself.
        case deferredToData
        /// The strategy that encodes data using Base 64 encoding.
        case base64
        /// The strategy that encodes data using a user-defined function.
        case custom(@Sendable (_ data: Data, _ encoder: Encoder) throws -> Void)
    }
    
    /// The formatting strategies available for formatting dates when encoding a date as JSON.
    public enum DateEncodingStrategy: Sendable {
        /// The strategy that uses formatting from the `Date` structure.
        case deferredToDate
        /// The strategy that encodes dates in terms of milliseconds since midnight UTC on January 1, 1970.
        case millisecondsSince1970
        /// The strategy that encodes dates in terms of seconds since midnight UTC on January 1, 1970.
        case secondsSince1970
        /// The strategy that formats dates according to the ISO 8601 and RFC 3339 standards.
        case iso8601
        /// The strategy that defers formatting settings to a supplied date formatter.
        case formatted(DateFormatter)
        /// The strategy that formats custom dates by calling a user-defined function.
        case custom(@Sendable (_ date: Date, _ encoder: Encoder) throws -> Void)
    }
    
    /// The strategies for encoding `nil` values.
    public enum NilEncodingStrategy: Sendable {
        /// The strategy that encodes `nil` values as `nil`.
        case useNil
        /// The strategy that encodes `nil` values as `NSNull`.
        case useNSNull
    }
    
    /// The strategies for encoding nonconforming floating-point numbers, also known as IEEE 754 exceptional values.
    public enum NonConformingFloatEncodingStrategy: Sendable {
        /// The strategy that throws an error upon encoding an exceptional floating-point value.
        case `throw`
        /// The strategy that encodes exceptional floating-point values from a specified string representation.
        case convertToString(positiveInfinity: String, negativeInfinity: String, nan: String)
    }
    
    /// The values that determine how to encode a type’s coding keys.
    public enum KeyEncodingStrategy: Sendable {
        /// The key encoding strategy that doesn’t change keys during encoding.
        case useDefaultKeys
        /**
         A key encoding strategy that converts camel-case keys to snake-case keys.
         
         Camel-case and snake-case are two common approaches for combining words when naming parts of an API. The Swift [API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/#general-conventions) recommend using camel-case names. Some `JSON` APIs adopt snake-case; use this strategy when you encounter such an API.
         
         This strategy uses [uppercaseLetters](https://developer.apple.com/documentation/foundation/characterset/uppercaseletters) and [lowercaseLetters](https://developer.apple.com/documentation/foundation/characterset/lowercaseletters) to determine the boundaries between words, and the [system](https://developer.apple.com/documentation/foundation/nslocale/system) locale when converting uppercase letters to lowercase letters.
         
         This strategy follows these steps to convert key names to snake-case:
            1. Split the name into words, preserving leading or trailing underscores.
            2. Insert an underscore between each word.
            3. Convert the resulting string to lowercase.
         
         The following examples show the result of applying this strategy:
         
         ```swift
         "feeFiFoFum" -> "fee_fi_fo_fum"
         "fee_fi_fo_fum" -> "fee_fi_fo_fum"
         "xmlContents" -> "xml_contents"
         ```
         */
        case convertToSnakeCase
        /// The key strategy that formats keys by calling a user-defined function.
        case custom(@Sendable (_ codingPath: [CodingKey]) -> CodingKey)
    }
}

internal extension DictionaryEncoder {
    struct Strategies {
        var date: DateEncodingStrategy
        var data: DataEncodingStrategy
        var nonConformingFloat: NonConformingFloatEncodingStrategy
        var `nil`: NilEncodingStrategy
        var key: KeyEncodingStrategy
    }
}
