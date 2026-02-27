//
//  FileHandle+.swift
//  
//
//  Created by Florian Zand on 17.08.25.
//

import Foundation

extension FileHandle {
    /**
     Reads The string currently available in the file.
     
     - Parameter encoding: The string encoding to use.
     - Returns: The contents, or `nil` the file handle has reached end.
     */
    public func readSome(encoding: String.Encoding = .utf8) throws -> String? {
        guard let data = try readToEnd(), !data.isEmpty else { return nil }
        guard let result = String(data: data, encoding: encoding) else {
            throw Errors.failedToConvertDataToString
        }
        return result
    }

    /**
     Reads the available string synchronously up to the end of file or maximum number of bytes.
          
     - Parameter encoding: The string encoding to use.
     */
    public func read(encoding: String.Encoding = .utf8) throws -> String {
        guard let data = try readToEnd() else {
            throw Errors.noData
        }
        guard let result = String(data: data, encoding: encoding) else {
            throw Errors.failedToConvertDataToString
        }
        return result
    }
    
    /**
     Writes the specified string synchronously to the file handle.
     
     - Parameters:
        - string: The string to write.
        - encoding: The string encoding to use.
    */
    public func write(_ string: String, encoding: String.Encoding = .utf8) throws {
        guard let data = string.data(using: encoding, allowLossyConversion: false) else {
            throw Errors.failedToConvertStringToDara
        }
        try write(contentsOf: data)
    }
    
    fileprivate enum Errors: Error {
        case noData
        case failedToConvertDataToString
        case failedToConvertStringToDara
    }
}

