//
//  JSONEncoderDecoder+.swift
//
//
//  Created by Florian Zand on 02.06.22.
//

import Foundation

public extension JSONEncoder.DateEncodingStrategy {
    /// The strategy that defers formatting settings to a supplied date format.
    static func formatted(_ format: String) -> Self {
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
        var encoder = self
        encoder.userInfo = userInfo
        return encoder
    }
    
    /// Sets the strategy used when encoding dates as part of a JSON object.
    func dateStrategy(_ strategy: DateEncodingStrategy) -> Self {
        var encoder = self
        encoder.dateEncodingStrategy = strategy
        return encoder
    }
    
    /// Sets the strategy used by an encoder when it encounters exceptional floating-point values.
    func nonConformingFloatStrategy(_ strategy: NonConformingFloatEncodingStrategy) -> Self {
        var encoder = self
        encoder.nonConformingFloatEncodingStrategy = strategy
        return encoder
    }
    
    /// Sets the strategy that an encoder uses to encode raw data.
    func dataStrategy(_ strategy: DataEncodingStrategy) -> Self {
        var encoder = self
        encoder.dataEncodingStrategy = strategy
        return encoder
    }
    
    /// Sets the strategy that determines how to encode a type’s coding keys as JSON keys.
    func keyStrategy(_ strategy: KeyEncodingStrategy) -> Self {
        var encoder = self
        encoder.keyEncodingStrategy = strategy
        return encoder
    }
    
    /// Sets the value that determines the readability, size, and element order of the encoded JSON object.
    func outputFormatting(_ outputFormatting: OutputFormatting) -> Self {
        var encoder = self
        encoder.outputFormatting = outputFormatting
        return encoder
    }
}

public extension JSONDecoder.DateDecodingStrategy {
    //// The strategy that defers formatting settings to a supplied date format.
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
    func assumesTopLevelDictionary(_ assumes: Bool) -> Self {
        var decoder = self
        decoder.assumesTopLevelDictionary = assumes
        return decoder
    }
    
    /// Sets the Boolean value indicating whether decoding supports the JSON5 syntax.
    func allowsJSON5(_ allowsJSON5: Bool) -> Self {
        var decoder = self
        decoder.allowsJSON5 = allowsJSON5
        return decoder
    }
    
    /// Sets the dictionary you use to customize the decoding process by providing contextual information.
    func userInfo(_ userInfo:  [CodingUserInfoKey : any Sendable]) -> Self {
        var decoder = self
        decoder.userInfo = userInfo
        return decoder
    }
    
    /// Sets the strategy used when decoding dates from part of a JSON object.
    func dateStrategy(_ strategy: DateDecodingStrategy) -> Self {
        var decoder = self
        decoder.dateDecodingStrategy = strategy
        return decoder
    }
    
    /// Sets the strategy used by a decoder when it encounters exceptional floating-point values.
    func nonConformingFloatStrategy(_ strategy: NonConformingFloatDecodingStrategy) -> Self {
        var decoder = self
        decoder.nonConformingFloatDecodingStrategy = strategy
        return decoder
    }
    
    /// Sets the strategy that a decoder uses to decode raw data.
    func dataStrategy(_ strategy: DataDecodingStrategy) -> Self {
        var decoder = self
        decoder.dataDecodingStrategy = strategy
        return decoder
    }
    
    /// Sets the strategy that determines how to decode a type’s coding keys from JSON keys.
    func keyStrategy(_ strategy: KeyDecodingStrategy) -> Self {
        var decoder = self
        decoder.keyDecodingStrategy = strategy
        return decoder
    }
}
