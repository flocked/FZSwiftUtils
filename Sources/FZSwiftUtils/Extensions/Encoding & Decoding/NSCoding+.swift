//
//  NSCoding+.swift
//
//
//  Created by Florian Zand on 17.05.25.
//

import Foundation

public extension NSCoding {
    /**
     Archives the object into `Data`.
          
     - Throws: An error if the encoding process fails.
     - Returns: A `Data` representation of the object.
     */
    func archivedData() throws -> Data {
        try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }

    /**
     Creates an archived-based copy of the object.
     
     - Throws: An error if copying fails.
     */
    func archiveBasedCopy() throws -> Self {
        try Self.unarchive(archivedData())
    }
    
    /**
     Creates an archived-based copy of the object as the specified subclass.
     
     - Parameter subclass: The type of the subclass for the copy.
     
     - Throws: An error if copying fails or the specified class isn't a subclass.
     */
    func archiveBasedCopy<Subclass: NSCoding>(as subclass: Subclass.Type) throws -> Subclass {
        NSKeyedArchiver.setClassName(NSStringFromClass(Subclass.self), for: Self.self)
        defer { NSKeyedArchiver.setClassName(nil, for: Self.self) }
        return try Subclass.unarchive(archivedData())
    }
    
    /**
     Decodes a previously-archived object graph, and returns the root object as the type.
     
     - Parameter data: The object graph previously encoded by `NSKeyedArchiver`.
     */
    static func unarchive(_ data: Data) throws -> Self {
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
        unarchiver.requiresSecureCoding = false
        defer { unarchiver.finishDecoding() }
        guard let value = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) else {
            throw NSCodingArchiveError.missingRootObject
        }
        guard let object = value as? Self else {
            throw NSCodingArchiveError.typeMismatch(expected: Self.self, actual: type(of: value))
        }
        return object
    }
}

public extension NSSecureCoding {
    /**
     Archives the object into `Data`.
          
     - Throws: An error if the encoding process fails.
     - Returns: A `Data` representation of the object.
     */
    func archivedData() throws -> Data {
        try archivedData(requiresSecureCoding: Self.supportsSecureCoding)
    }
    
    /**
     Archives the object into `Data`.
     
     - Parameter requiresSecureCoding: A Boolean value indicating whether the unarchived object requires to conform to [NSSecureCoding](https://developer.apple.com/documentation/foundation/nssecurecoding).
     - Throws: An error if the encoding process fails.
     - Returns: A `Data` representation of the object.
     */
    func archivedData(requiresSecureCoding: Bool) throws -> Data {
        try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: requiresSecureCoding)
    }
    
    /**
     Creates an archived-based copy of the object.
     
     - Throws: An error if copying fails.
     */
    func archiveBasedCopy() throws -> Self {
        try Self.unarchive(archivedData())
    }
    
    /**
     Decodes a previously-archived object graph, and returns the root object as the type.
     
     - Parameter data: The object graph previously encoded by `NSKeyedArchiver`.
     */
    static func unarchive(_ data: Data) throws -> Self {
        try NSKeyedUnarchiver.unarchivedObject(ofClass: Self.self, from: data)
    }
    
    /*
    /**
     Decodes a previously-archived object graph, and returns the root object as the type.
     
     - Parameter data: The object graph previously encoded by `NSKeyedArchiver`.
     */
    static func unarchive(_ data: Data) throws -> Self {
        try NSKeyedUnarchiver.unarchivedObject(from: data)
    }
    
    static func unarchive(_ data: Data, requiresSecureCoding: Bool) throws -> Self {
        try NSKeyedUnarchiver.unarchivedObject(ofClass: Self.self, from: data, requiresSecureCoding: requiresSecureCoding)
    }
    */
}

public extension NSCopying where Self: NSObject {
    /// Shallow copy
    func copyAsSelf() -> Self? {
        copy() as? Self
    }
}

fileprivate enum NSCodingArchiveError: LocalizedError {
    case missingRootObject
    case typeMismatch(expected: Any.Type, actual: Any.Type)
    
    public var errorDescription: String? {
        switch self {
        case .missingRootObject:
            return NSLocalizedString(
                "No root object was found in the archive.",
                comment: "NSCoding archive missing root object error"
            )

        case let .typeMismatch(expected, actual):
            return String(
                format: NSLocalizedString(
                    "Expected an object of type %@, but found %@.",
                    comment: "NSCoding archive type mismatch error"
                ),
                String(describing: expected),
                String(describing: actual)
            )
        }
    }

    public var failureReason: String? {
        switch self {
        case .missingRootObject:
            return NSLocalizedString(
                "The archive does not contain a root object.",
                comment: "NSCoding archive missing root object failure reason"
            )

        case .typeMismatch:
            return NSLocalizedString(
                "The archived object's type does not match the requested type.",
                comment: "NSCoding archive type mismatch failure reason"
            )
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .missingRootObject:
            return NSLocalizedString(
                "Verify that the data was created using NSKeyedArchiver and contains a valid root object.",
                comment: "NSCoding archive missing root object recovery suggestion"
            )

        case .typeMismatch:
            return NSLocalizedString(
                "Verify that the requested type matches the type originally archived.",
                comment: "NSCoding archive type mismatch recovery suggestion"
            )
        }
    }
}

extension NSCodingArchiveError: CustomNSError {
    public static let errorDomain = "NSCodingArchiveError"

    public var errorCode: Int {
        switch self {
        case .missingRootObject: return 1
        case .typeMismatch: return 2
        }
    }

    public var errorUserInfo: [String: Any] {
        var userInfo: [String: Any] = [
            NSLocalizedDescriptionKey: errorDescription ?? ""
        ]

        if let failureReason {
            userInfo[NSLocalizedFailureReasonErrorKey] = failureReason
        }

        if let recoverySuggestion {
            userInfo[NSLocalizedRecoverySuggestionErrorKey] = recoverySuggestion
        }

        return userInfo
    }
}
