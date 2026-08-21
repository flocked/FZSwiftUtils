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
    init(contentsOf url: URL, decoder: JSONDecoder = .init()) throws {
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
    init(contentsOf path: String, decoder: JSONDecoder = .init()) throws {
        try self.init(contentsOf: .file(path), decoder: decoder)
    }
    
    func write(to url: URL, encoder: JSONEncoder = .init(), options: Data.WritingOptions = []) throws {
        do {
            let data = try encoder.encode(self)
            try data.write(to: url, options: options)
        } catch {
            throw error
        }
    }

    /**
     Writes to the specified location.

     - Parameters:
        - path: The location to write.
        - encoder: The encoder to use for encoding the file contents.
        - options: Options for writing.

     - Throws: If the file couldn't be created.
     */
    func write(to path: String, encoder: JSONEncoder = .init(), options: Data.WritingOptions = []) throws {
        try write(to: .file(path), encoder: encoder, options: options)
    }
}
