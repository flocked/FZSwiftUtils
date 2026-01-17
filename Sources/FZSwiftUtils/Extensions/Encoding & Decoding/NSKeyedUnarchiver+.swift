//
//  NSKeyedUnarchiver+.swift
//
//
//  Created by Florian Zand on 01.02.24.
//

import Foundation

public extension NSKeyedUnarchiver {
    /**
     Initializes an archiver to decode data from the specified location.
     
     - Parameters:
        - data: An archive previously encoded by `NSKeyedArchiver`.
        - requiresSecureCoding: A Boolean value indicating whether the unarchived object requires to conform to [NSSecureCoding](https://developer.apple.com/documentation/foundation/nssecurecoding).
     */
    convenience init(forReadingFrom data: Data, requiresSecureCoding: Bool) throws {
        try self.init(forReadingFrom: data)
        self.requiresSecureCoding = requiresSecureCoding
    }
    
    /**
     Decodes and returns the root object.
     
     - Returns: The root object, or `nil` if no root object exists.
     */
    func decodeRootObject() -> Any? {
        decodeObject(forKey: NSKeyedArchiveRootObjectKey)
    }
    
    /**
     Decodes and returns the root object as the specified `NSCoding` type.
     
     - Returns: The root object.
     - Throws: If the data isn't an archive, doesn't contain a root object or the decoding failed.
     */
    func decodeRootObject<Object: NSCoding>(type: Object.Type = Object.self) throws -> Object {
        try decodeObject(forKey: NSKeyedArchiveRootObjectKey)
    }
    
    /**
     Decodes and returns an object associated with a given key.
     
     - Parameter key: A key in the archive within the current decoding scope.
     - Returns: The object associated with the key.
     - Throws: If there isn't an object associated with the key of type `Object`.
     */
    func decodeObject<Object: NSCoding>(forKey key: String) throws -> Object {
        guard let object = decodeObject(forKey: key) else {
            throw DecodingError.valueNotFound(Object.self, .init( "No value found for the key: \(key)."))
        }
        guard let object = object as? Object else {
            throw DecodingError.typeMismatch(type(of: object), .init("Expected object of type \(Object.self), but decoded object was of type \(type(of: object))."))
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
        let rootObject = try unarchivedObject(from: data, requiresSecureCoding: requiresSecureCoding)
        guard let decodedObject = rootObject as? Object else {
            throw DecodingError.typeMismatch(type(of: rootObject), .init("Expected object of type \(Object.self), but decoded object was of type \(type(of: rootObject))."))
        }
        return decodedObject
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
        guard let rootObject = try NSKeyedUnarchiver(forReadingFrom: data, requiresSecureCoding: requiresSecureCoding).decodeRootObject() else {
            throw DecodingError.valueNotFound(Any.self, "The data doesn't contain a root object.")
        }
        return rootObject
    }
}
