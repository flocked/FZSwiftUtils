//
//  FileConvertible.swift
//
//
//  Created by Florian Zand on 27.11.23.
//

import Foundation

/// A type that can be read from and written to a file.
public protocol FileConvertible: Codable {
    /**
     Initializes from the file at the specified URL.

     - Parameters:
        - url: The url of the file.
        - decoder: The decoder to use for decoding the file contents.

     - Throws: If the file doesn't exist, can't be accessed or isn't compatible.
     */
    init(contentsOf url: URL, decoder: JSONDecoder) throws

    /**
     Writes to the specified location.

     - Parameters:
        - url: The location to write.
        - encoder: The encoder to use for encoding the file contents.
        - options: Options for writing.

     - Throws: If the file couldn't be created.
     */
    func write(to url: URL, encoder: JSONEncoder, options: Data.WritingOptions) throws
}

public extension FileConvertible {
    init(contentsOf url: URL, decoder: JSONDecoder) throws {
        let data = try Data(contentsOf: url)
        self = try decoder.decode(Self.self, from: data)
    }
    
    /**
     Initializes from the file at the specified URL using custom decoding strategies.

     - Parameters:
        - url: The url of the file.
        - dateDecodingStrategy: The strategy to use for decoding `Date` values.
        - keyDecodingStrategy: The strategy to use for decoding keys.
        - dataDecodingStrategy: The strategy to use for decoding `Data` values.
        - nonConformingFloatDecodingStrategy: The strategy used by a decoder when it encounters exceptional floating-point values.
        - assumesTopLevelDictionary: A Boolean value that indicates whether the decoding assumes the top level of the `JSON` data is a dictionary, even if it doesn’t begin and end with braces.

     - Throws: If the file doesn't exist, can't be accessed or isn't compatible.
     */
    init(contentsOf url: URL, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys, dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .base64, nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy = .throw, assumesTopLevelDictionary: Bool = false) throws {
        try self.init(contentsOf: url, decoder: .init(dateDecodingStrategy: dateDecodingStrategy, keyDecodingStrategy: keyDecodingStrategy, dataDecodingStrategy: dataDecodingStrategy, nonConformingFloatDecodingStrategy: nonConformingFloatDecodingStrategy, assumesTopLevelDictionary: assumesTopLevelDictionary))
    }

    /**
     Initializes from the file at the specified path.

     - Parameters:
        - path: The path to the file.
        - decoder: The decoder to use for decoding the file contents.

     - Throws: If the file doesn't exist, can't be accessed or isn't compatible.
     */
    init(contentsOf path: String, decoder: JSONDecoder) throws {
        try self.init(contentsOf: .file(path), decoder: decoder)
    }
    
    /**
     Initializes from the file at the specified path using custom decoding strategies.

     - Parameters:
        - path: The path to the file.
        - dateDecodingStrategy: The strategy to use for decoding `Date` values.
        - keyDecodingStrategy: The strategy to use for decoding keys.
        - dataDecodingStrategy: The strategy to use for decoding `Data` values.
        - nonConformingFloatDecodingStrategy: The strategy used by a decoder when it encounters exceptional floating-point values.
        - assumesTopLevelDictionary: A Boolean value that indicates whether the decoding assumes the top level of the `JSON` data is a dictionary, even if it doesn’t begin and end with braces.

     - Throws: If the file doesn't exist, can't be accessed or isn't compatible.
     */
    init(contentsOf path: String, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys, dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .base64, nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy = .throw, assumesTopLevelDictionary: Bool = false) throws {
        try self.init(contentsOf: .file(path), dateDecodingStrategy: dateDecodingStrategy, keyDecodingStrategy: keyDecodingStrategy, dataDecodingStrategy: dataDecodingStrategy, nonConformingFloatDecodingStrategy: nonConformingFloatDecodingStrategy, assumesTopLevelDictionary: assumesTopLevelDictionary)
    }
    
    func write(to url: URL, encoder: JSONEncoder, options: Data.WritingOptions = []) throws {
        do {
            let data = try encoder.encode(self)
            try data.write(to: url, options: options)
        } catch {
            throw error
        }
    }

    /**
     Writes to the specified location using custom encoding strategies.

     - Parameters:
        - url: The location to write.
        - dateEncodingStrategy: The strategy to use for encoding `Date` values.
        - keyEncodingStrategy: The strategy to use for encoding keys.
        - dataEncodingStrategy: The strategy to use for encoding `Data` values.
        - nonConformingFloatEncodingStrategy: The strategy used by an encoder when it encounters exceptional floating-point values.
        - outputFormatting: Formatting options for the encoded JSON.
        - options: Options for writing.

     - Throws: If the file couldn't be created.
     */
    func write(to url: URL, dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .deferredToDate, keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys, dataEncodingStrategy: JSONEncoder.DataEncodingStrategy = .base64, nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy = .throw, outputFormatting: JSONEncoder.OutputFormatting = [], options: Data.WritingOptions = []) throws {
        try write(to: url, encoder: .init(dateEncodingStrategy: dateEncodingStrategy, keyEncodingStrategy: keyEncodingStrategy, dataEncodingStrategy: dataEncodingStrategy, nonConformingFloatEncodingStrategy: nonConformingFloatEncodingStrategy, outputFormatting: outputFormatting), options: options)
    }

    /**
     Writes to the specified location.

     - Parameters:
        - path: The location to write.
        - encoder: The encoder to use for encoding the file contents.
        - options: Options for writing.

     - Throws: If the file couldn't be created.
     */
    func write(to path: String, encoder: JSONEncoder, options: Data.WritingOptions = []) throws {
        try write(to: .file(path), encoder: encoder, options: options)
    }
    
    /**
     Writes to the specified location using custom encoding strategies.

     - Parameters:
        - path: The location to write.
        - dateEncodingStrategy: The strategy to use for encoding `Date` values.
        - keyEncodingStrategy: The strategy to use for encoding keys.
        - dataEncodingStrategy: The strategy to use for encoding `Data` values.
        - nonConformingFloatEncodingStrategy: The strategy used by an encoder when it encounters exceptional floating-point values.
        - outputFormatting: Formatting options for the encoded JSON.
        - options: Options for writing.

     - Throws: If the file couldn't be created.
     */
    func write(to path: String, dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .deferredToDate, keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys, dataEncodingStrategy: JSONEncoder.DataEncodingStrategy = .base64, nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy = .throw, outputFormatting: JSONEncoder.OutputFormatting = [], options: Data.WritingOptions = []) throws {
        try write(to: .file(path), encoder: .init(dateEncodingStrategy: dateEncodingStrategy, keyEncodingStrategy: keyEncodingStrategy, dataEncodingStrategy: dataEncodingStrategy, nonConformingFloatEncodingStrategy: nonConformingFloatEncodingStrategy, outputFormatting: outputFormatting), options: options)
    }
}
