//
//  PropertyListConvertible.swift
//
//
//  Created by Florian Zand on 18.06.26.
//

import Foundation

/// A type that can be read from and written to a file.
public protocol PropertyListConvertible: Codable {
    /**
     Initializes from the file at the specified URL.

     - Parameters:
        - url: The url of the file.
        - decoder: The decoder to use for decoding the file contents.

     - Throws: If the file doesn't exist, can't be accessed or isn't compatible.
     */
    init(contentsOf url: URL, decoder: PropertyListDecoder) throws

    /**
     Writes to the specified location.

     - Parameters:
        - url: The location to write.
        - encoder: The encoder to use for encoding the file contents.
        - options: Options for writing.

     - Throws: If the file couldn't be created.
     */
    func write(to url: URL, encoder: PropertyListEncoder, options: Data.WritingOptions) throws
}

public extension PropertyListConvertible {
    init(contentsOf url: URL, decoder: PropertyListDecoder = PropertyListDecoder()) throws {
        let data = try Data(contentsOf: url)
        self = try decoder.decode(Self.self, from: data)
    }

    /**
     Initializes from the file at the specified path.

     - Parameters:
        - path: The path to the file.
        - decoder: The decoder to use for decoding the file contents.

     - Throws: If the file doesn't exist, can't be accessed or isn't compatible.
     */
    init(contentsOf path: String, decoder: PropertyListDecoder = PropertyListDecoder()) throws {
        try self.init(contentsOf: .file(path), decoder: decoder)
    }
    
    func write(to url: URL, encoder: PropertyListEncoder, options: Data.WritingOptions = []) throws {
        let data = try encoder.encode(self)
        try data.write(to: url, options: options)
    }

    /**
     Writes to the specified location.

     - Parameters:
        - path: The location to write.
        - encoder: The encoder to use for encoding the file contents.
        - options: Options for writing.

     - Throws: If the file couldn't be created.
     */
    func write(to path: String, encoder: PropertyListEncoder, options: Data.WritingOptions = []) throws {
        try write(to: .file(path), encoder: encoder, options: options)
    }
    
    /**
     Writes to the specified location.

     - Parameters:
        - url: The location to write.
        - format: The property list format of the file.
        - options: Options for writing.

     - Throws: If the file couldn't be created.
     */
    func write(to url: URL, format: PropertyListDecoder.PropertyListFormat = .xml, options: Data.WritingOptions = []) throws {
        try write(to: url, encoder: .init(format: format), options: options)
    }
    
    /**
     Writes to the specified location.

     - Parameters:
        - path: The location to write.
        - format: The property list format of the file.
        - options: Options for writing.

     - Throws: If the file couldn't be created.
     */
    func write(to path: String, format: PropertyListDecoder.PropertyListFormat = .xml, options: Data.WritingOptions = []) throws {
        try write(to: path, encoder: .init(format: format), options: options)
    }
}
