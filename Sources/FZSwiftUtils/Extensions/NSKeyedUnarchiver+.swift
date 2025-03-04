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
    public static func unarchive<Object: NSObject>(_ data: Data, requiresSecureCoding: Bool = false) throws -> Object where Object: NSCoding {
        let value = try unarchive(data)
        guard let value = value as? Object else {
            throw UnarchiverErrors.wrongMapping(original: type(of: value), new: Object.self)
        }
        return value
    }
    
    /**
     Decodes a previously-archived object.
     
     - Parameter data: Data of an object previously encoded by `NSKeyedArchiver`.
     - Returns: The decoded object.
     - Throws: If the data isn't an archive, doesn't contain the object or the decoding failed.
     */
    public static func unarchive(_ data: Data, requiresSecureCoding: Bool = false) throws -> AnyObject {
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
        unarchiver.requiresSecureCoding = requiresSecureCoding
        guard let value = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? AnyObject else {
            throw UnarchiverErrors.failedDecoding
        }
        return value
    }
    
    /// Keyed unarchiver errors.
    enum UnarchiverErrors: Error, LocalizedError {
        /// The decoding of the archive failed.
        case failedDecoding
        
        case wrongMapping(original: AnyClass, new: AnyClass)
        
        var errorDescription: String? {
            switch self {
            case .failedDecoding: return "The root object couldn't be decoded."
            case .wrongMapping(let original, let new): return "The object of type \(original) couldn't be cast to \(new)."
            }
        }
    }
}
