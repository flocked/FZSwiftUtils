//
//  NSKeyedUnarchiver+.swift
//
//
//  Created by Florian Zand on 01.02.24.
//

import Foundation

public extension NSKeyedUnarchiver {
    /// Sets the Boolean value indicating whether the unarchiver requires all unarchived classes to conform to [NSSecureCoding](https://developer.apple.com/documentation/foundation/nssecurecoding).
    @discardableResult
    func requiresSecureCoding(_ requires: Bool) -> Self {
        requiresSecureCoding = requires
        return self
    }
    
    /**
     Decodes and returns the root object.
     
     - Returns: The root object, or `nil` if no root object exists.
     */
    func decodeRootObject() -> Any? {
        decodeObject(forKey: NSKeyedArchiveRootObjectKey)
    }
    
    /**
     Decodes and returns the root object.
     
     - Returns: The root object.
     - Throws: If there isn't a root object of type `Object`.
     */
    func decodeRootObject<Object: NSCoding>() throws -> Object {
        try decodeObject(forKey: NSKeyedArchiveRootObjectKey)
    }
    
    /**
     Decodes and returns an object associated with a given key.
     
     - Parameter key: A key in the archive within the current decoding scope.
     - Returns: The object associated with the key.
     - Throws: If there isn't an object associated with the key of type `Object`.
     */
    func decodeObject<Object: NSCoding>(forKey key: String) throws -> Object {
        guard let object = decodeObject(forKey: key) as? NSCoding else {
            throw Error.missingObject(key: key)
        }
        guard let object = object as? Object else {
            throw Error.typeMismatch(actual: type(of: object), expected: Object.self)

        }
        return object
    }
    
    /**
     Decodes a previously-archived object graph, and returns the root object as the specified type.
     
     - Parameters:
        - data: The object graph previously encoded by NSKeyedArchiver.
        - requiresSecureCoding: A Boolean value indicating whether the unarchived object requires to conform to [NSSecureCoding](https://developer.apple.com/documentation/foundation/nssecurecoding).
     - Returns: The decoded root of the object graph.
     - Throws: If the data isn't an archive, doesn't contain a root object or the decoding failed.
     */
    static func unarchivedObject<Object: NSCoding>(from data: Data, requiresSecureCoding: Bool = false) throws -> Object {
        let value = try unarchivedObject(from: data)
        guard let value = value as? Object else {
            throw Error.typeMismatch(actual: type(of: value as AnyObject), expected: Object.self)
        }
        return value
    }
    
    /**
     Decodes a previously-archived object graph, and returns the root object as the specified type.
     
     - Parameters:
        - data: The object graph previously encoded by NSKeyedArchiver.
        - requiresSecureCoding: A Boolean value indicating whether the unarchived object requires to conform to [NSSecureCoding](https://developer.apple.com/documentation/foundation/nssecurecoding).
     - Returns: The decoded root of the object graph.
     - Throws: If the data isn't an archive, doesn't contain a root object or the decoding failed.
     */
    static func unarchivedObject(from data: Data, requiresSecureCoding: Bool = false) throws -> Any {
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
        unarchiver.requiresSecureCoding = requiresSecureCoding
        guard let value = unarchiver.decodeRootObject() else {
            throw Error.missingRootObject
        }
        return value
    }
}

fileprivate enum Error: LocalizedError {
    case missingRootObject
    case typeMismatch(actual: AnyClass, expected: AnyClass)
    case missingObject(key: String)
    
    var errorDescription: String? {
        switch self {
        case .missingRootObject: return "Missing Root Object"
        case .missingObject: return "Missing Object"
        case .typeMismatch: return "Type Mismatch"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .missingRootObject:
            return "The data does not contain a valid root object."
        case .missingObject(let key):
            return "No object for the key \"\(key)\" found."
        case .typeMismatch(let actual, let expected):
            return "Expected object of type \(expected), but decoded object was of type \(actual)."
        }
    }
}
