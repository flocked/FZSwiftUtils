//
//  JSONEncoderDecoder+.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation

public extension JSONEncoder.DateEncodingStrategy {
    /**
     Creates a date encoding strategy using the specified date format.

     - Parameter format: The format used to encode the dates.
     */
    static func formatted(_ format: String) -> JSONEncoder.DateEncodingStrategy {
        .formatted(DateFormatter(format))
    }
}

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
    convenience init(dateEncodingStrategy: DateEncodingStrategy,
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
}

public extension JSONDecoder.DateDecodingStrategy {
    /**
     Creates a date decoding strategy using the specified date format.

     - Parameter format: The format used to decoding the dates.
     */
    static func formatted(_ format: String) -> JSONDecoder.DateDecodingStrategy {
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
    convenience init(dateDecodingStrategy: DateDecodingStrategy,
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
}
