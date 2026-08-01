//
//  DictionaryDecoder+Strategies.swift
//
//
//  Created by Florian Zand on 17.05.25.
//

import Foundation

public extension DictionaryDecoder {
    /// The strategies for decoding raw data.
    enum DataDecodingStrategy: Sendable {
        /// The strategy that encodes data using the encoding specified by the data instance itself.
        case deferredToData
        /// The strategy that decodes data using Base 64 decoding.
        case base64
        /// The strategy that decodes data using a user-defined function.
        case custom(@Sendable (_ decoder: Decoder) throws -> Data)
    }
    
    /// The strategies available for formatting dates when decoding them from Dictionary.
    enum DateDecodingStrategy: Sendable {
        /// The strategy that uses formatting from the Date structure.
        case deferredToDate
        /// The strategy that decodes dates in terms of seconds since midnight UTC on January 1st, 1970.
        case secondsSince1970
        /// The strategy that decodes dates in terms of milliseconds since midnight UTC on January 1st, 1970.
        case millisecondsSince1970
        /// The strategy that formats dates according to the ISO 8601 standard.
        case iso8601
        /// The strategy that defers formatting settings to a supplied date formatter.
        case formatted(DateFormatter)
        /// The strategy that formats custom dates by calling a user-defined function.
        case custom(@Sendable (_ decoder: Decoder) throws -> Date)
        /// The strategy that defers formatting settings to a supplied date format.
        public static func formatted(_ format: String) -> Self {
            formatted(DateFormatter(format))
        }
    }
    
    /// The strategies for encoding nonconforming floating-point numbers, also known as IEEE 754 exceptional values.
    enum NonConformingFloatDecodingStrategy: Sendable {
        /// The strategy that throws an error upon decoding an exceptional floating-point value.
        case `throw`
        /// The strategy that decodes exceptional floating-point values from a specified string representation.
        case convertFromString(positiveInfinity: String, negativeInfinity: String, nan: String)
    }
    
    /// The values that determine how to decode a type’s coding keys from Dictionary keys.
    enum KeyDecodingStrategy: Sendable {
        /// A key decoding strategy that doesn’t change key names during decoding.
        case useDefaultKeys
        /**
          A key decoding strategy that converts snake-case keys to camel-case keys.
         
          Snake-case and camel-case are two common approaches for combining words when naming parts of an API. The Swift [API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/#general-conventions) recommend using camel-case names. Some `JSON` APIs adopt snake-case; use this strategy when you encounter such an API.
         
          This strategy uses [uppercaseLetters](https://developer.apple.com/documentation/foundation/characterset/uppercaseletters) and [lowercaseLetters](https://developer.apple.com/documentation/foundation/characterset/lowercaseletters) to determine the boundaries between words, and the [system](https://developer.apple.com/documentation/foundation/nslocale/system) locale when converting uppercase letters to lowercase letters.
         
          This strategy follows these steps to convert key names to camel-case:
            1. Capitalize each word that follows an underscore.
            2. Remove all underscores that aren’t at the very start or end of the string.
            3. Combine the words into a single string.
         
          The following examples show the result of applying this strategy:
          ```swift
          "fee_fi_fo_fum" -> "feeFiFoFum"
          "feeFiFoFum" -> "feeFiFoFum"
          "base_uri" -> "baseUri"
          ```
          */
        case convertFromSnakeCase
        /// A key decoding strategy defined by the closure you supply.
        case custom(@Sendable (_ codingPath: [CodingKey]) -> CodingKey)
    }
}

extension DictionaryDecoder {
    struct Strategies {
        var date: DateDecodingStrategy
        var data: DataDecodingStrategy
        var nonConformingFloat: NonConformingFloatDecodingStrategy
        var key: KeyDecodingStrategy
    }
}
