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
    func decodeRootObject<DecodedObjectType: NSCoding>(as objectType: DecodedObjectType.Type = DecodedObjectType.self) throws -> DecodedObjectType {
        try decodeObject(forKey: NSKeyedArchiveRootObjectKey)
    }
    
    /**
     Decodes and returns an object associated with a given key.
     
     - Parameter key: A key in the archive within the current decoding scope.
     - Returns: The object associated with the key.
     - Throws: If there isn't an object associated with the key of type `Object`.
     */
    func decodeObject<DecodedObjectType: NSCoding>(forKey key: String, as objectType: DecodedObjectType.Type = DecodedObjectType.self) throws -> DecodedObjectType {
        guard let object = decodeObject(forKey: key) else {
            throw key ==  NSKeyedArchiveRootObjectKey ? NSCodingArchiveError.missingRootObject : NSCodingArchiveError.missingObject(key: key)
        }
        guard let object = object as? DecodedObjectType else {
            throw NSCodingArchiveError.typeMismatch(expected: DecodedObjectType.self, actual: type(of: object))
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
    static func unarchive<DecodedObjectType: NSCoding>(_ data: Data, as objectType: DecodedObjectType.Type = DecodedObjectType.self, requiresSecureCoding: Bool = false) throws -> DecodedObjectType {
        try unarchiveObject(data, requiresSecureCoding: requiresSecureCoding)
    }
    
    static func unarchive<DecodedObjectType: NSObject & NSSecureCoding>(_ data: Data, as objectType: DecodedObjectType.Type = DecodedObjectType.self) throws -> DecodedObjectType {
        guard let object = try NSKeyedUnarchiver.unarchivedObject(ofClass: objectType, from: data) else {
            throw NSCodingArchiveError.missingRootObject
        }
        return object
    }
    
    internal static func unarchiveObject<DecodedObjectType: NSCoding>(_ data: Data, as objectType: DecodedObjectType.Type = DecodedObjectType.self, requiresSecureCoding: Bool = false, replacingClassName className: String? = nil) throws -> DecodedObjectType {
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
        unarchiver.requiresSecureCoding = requiresSecureCoding
        defer { unarchiver.finishDecoding() }
        if let className = className {
            unarchiver.setClass(objectType, forClassName: className)
        }
        return try unarchiver.decodeRootObject()
    }
}

enum NSCodingArchiveError: LocalizedError, CustomNSError {
    case missingRootObject
    case missingObject(key: String)
    case typeMismatch(expected: Any.Type, actual: Any.Type)
    
    var errorDescription: String? {
        switch self {
        case .missingRootObject:
            "No root object was found in the archive."
        case let .typeMismatch(expected, actual):
            "Expected an object of type \(expected), but found \(actual)."
            case let .missingObject(key):
            "No object found for key: \(key)"
        }
    }

    var failureReason: String? {
        switch self {
        case .missingRootObject:
            "The archive does not contain a root object."
        case .typeMismatch:
            "The archived object's type does not match the requested type."
        case .missingObject:
            "The archive does not contain a object for the specified key."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .missingRootObject:
            "Verify that the data was created using NSKeyedArchiver and contains a valid root object."
        case .typeMismatch:
            "Verify that the requested type matches the type originally archived."
        case .missingObject:
            "Verify that the data was created using NSKeyedArchiver and contains a valid object for the specified key."
        }
    }
    
    static let errorDomain = "NSCodingArchiveError"

    var errorCode: Int {
        switch self {
        case .missingRootObject: 1
        case .typeMismatch: 2
        case .missingObject: 3
        }
    }

    var errorUserInfo: [String: Any] {
        [NSLocalizedDescriptionKey: errorDescription ?? "",
        NSLocalizedFailureReasonErrorKey: failureReason,
        NSLocalizedRecoverySuggestionErrorKey: recoverySuggestion,
        ].nonNil
    }
}
