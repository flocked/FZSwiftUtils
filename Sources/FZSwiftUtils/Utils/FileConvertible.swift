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

     - Parameter url: The url of the file.
     - Throws: If the file doesn't exist, can't be accessed or isn't compatible.
     */
    init(contentsOf url: URL) throws

    /**
     Initializes from the file at the specified path.

     - Parameter path: The path to the file.
     - Throws: If the file doesn't exist, can't be accessed or isn't compatible.
     */
    init(contentsOf path: String) throws

    /**
     Writes to the specified location.

     - Parameters:
        - url: The location to write.
        - options: Options for writing. Default value is `[]`.

     - Throws: If the file couldn't be created.
     */
    func write(to url: URL, options: Data.WritingOptions) throws

    /**
     Writes to the specified location.

     - Parameters:
        - path: The location to write.
        - options: Options for writing. Default value is `[]`.

     - Throws: If the file couldn't be created.
     */
    func write(to path: String, options: Data.WritingOptions) throws
}

public extension FileConvertible {
    init(contentsOf url: URL) throws {
        do {
            let data = try Data(contentsOf: url)
            self = try JSONDecoder().decode(Self.self, from: data)
        } catch {
            throw error
        }
    }

    init(contentsOf path: String) throws {
        try self.init(contentsOf: URL(fileURLWithPath: path))
    }

    func write(to url: URL, options: Data.WritingOptions = []) throws {
        do {
            let data = try JSONEncoder().encode(self)
            try data.write(to: url, options: options)
        } catch {
            throw error
        }
    }

    func write(to path: String, options: Data.WritingOptions = []) throws {
        try write(to: URL(fileURLWithPath: path), options: options)
    }
}
