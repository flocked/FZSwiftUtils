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
     Initializes the type from the file at the specified URL.
     
     - Parameter url: The url of the file.
     - Throws: If the file doesn't exist, can't be accessed or isn't compatible
     */
    init(contentsOf url: URL) throws
    
    /**
     Writes the type to the specified location.
     
     - Parameters:
        - url: The location to write the type.
        - options: Options for writing the type. Default value is `[]`.
     
     - Throws: If the file couldn't be created.
     */
    func write(to url: URL, options: Data.WritingOptions) throws
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
    
    func write(to url: URL, options: Data.WritingOptions = []) throws {
        do {
            let data = try JSONEncoder().encode(self)
            try data.write(to: url)
        } catch {
            throw error
        }
    }
}