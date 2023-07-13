//
//  JSONEncoderDecoder+.swift
//  FZCollection
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation

public extension JSONEncoder.DateEncodingStrategy {
    /**
     Creates a date encoding strategy using the specified date format.
     
     - Parameter format: The string format used to encode the dates.
     - Returns: A `JSONEncoder.DateEncodingStrategy` that formats dates using the specified format.
     */
    static func formatted(_ format: String) -> JSONEncoder.DateEncodingStrategy {
        return .formatted(DateFormatter(format))
    }
}

public extension JSONEncoder {
    /**
     Initializes a JSON encoder with the specified encoding strategies and output formatting options.
     
     - Parameters:
       - dateEncodingStrategy: The strategy to use for encoding dates.
       - outputFormatting: The formatting options to apply to the encoded JSON data. Default is an empty set.
       - keyEncodingStrategy: The strategy to use for encoding keys. Default is `.useDefaultKeys`.
     */
    convenience init(dateEncodingStrategy: DateEncodingStrategy,
                     outputFormatting: OutputFormatting = [],
                     keyEncodingStrategy: KeyEncodingStrategy = .useDefaultKeys)
    {
        self.init()
        self.dateEncodingStrategy = dateEncodingStrategy
        self.outputFormatting = outputFormatting
        self.keyEncodingStrategy = keyEncodingStrategy
    }
}

public extension JSONDecoder.DateDecodingStrategy {
    /**
     Creates a date decoding strategy using the specified date format.
     
     - Parameter format: The string format used to decoding the dates.
     - Returns: A `JSONEncoder.DateDecodingStrategy` that formats dates using the specified format.
     */
    static func formatted(_ format: String) -> JSONDecoder.DateDecodingStrategy {
        return .formatted(DateFormatter(format))
    }
}

public extension JSONDecoder {
    /**
     Initializes a JSON decoder with the specified decoding strategies.
     
     - Parameters:
       - dateDecodingStrategy: The strategy to use for decoding dates.
       - keyDecodingStrategy: The strategy to use for decoding keys. Default is `.useDefaultKeys`.
     */
    convenience init(dateDecodingStrategy: DateDecodingStrategy,
                     keyDecodingStrategy: KeyDecodingStrategy = .useDefaultKeys)
    {
        self.init()
        self.dateDecodingStrategy = dateDecodingStrategy
        self.keyDecodingStrategy = keyDecodingStrategy
    }
}
