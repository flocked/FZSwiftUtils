//
//  NSKeyedUnarchiver+.swift
//
//
//  Created by Florian Zand on 01.02.24.
//

import Foundation

extension NSKeyedUnarchiver {
    /**
     Decodes a previously-archived object.
     
     - Parameter data: Data of an object previously encoded by `NSKeyedArchiver`.
     - Returns: The decoded object.
     - Throws: If the data isn't an archive, doesn't contain the object or the decoding failed.
     */
    public static func unarchive<Object>(_ data: Data) throws -> Object {
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
        unarchiver.requiresSecureCoding = false
        guard let value = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? Object else {
            throw UnarchiverErrors.failedDecoding
        }
        return value
    }
    
    /// Keyed unarchiver errors.
    public enum UnarchiverErrors: Error {
        /// The decoding of the archive failed.
        case failedDecoding
    }
}
