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
            throw Errors.typeMismatch(actual: type(of: value), expected: Object.self)
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
            throw Errors.missingRootObject
        }
        return value
    }
    
    enum Errors: LocalizedError {
        case missingRootObject
        case typeMismatch(actual: AnyClass, expected: AnyClass)
        
        var errorDescription: String? {
            switch self {
            case .missingRootObject:
                return "Missing Root Object"
            case .typeMismatch:
                return "Type Mismatch"
            }
        }
        
        var failureReason: String? {
            switch self {
            case .missingRootObject:
                return "The data does not contain a valid root object under the expected archive key."
            case .typeMismatch(let actual, let expected):
                return "Expected object of type \(expected), but decoded object was of type \(actual)."
            }
        }
    }
}
