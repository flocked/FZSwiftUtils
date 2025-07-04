//
//  NSObject+Copy.swift
//
//
//  Created by Florian Zand on 17.05.25.
//

import Foundation

public extension NSCoding {
    /**
     Archives the object into `Data`.
     
     If the object conforms to `NSSecureCoding`, set `requiringSecureCoding` to `true` for added security.
     
     - Parameter requiringSecureCoding: A Boolean value indicating whether secure coding is required.
     - Throws: An error if the encoding process fails.
     - Returns: A `Data` representation of the object.
     */
    func archivedData(requiringSecureCoding: Bool = false) throws -> Data {
        try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: requiringSecureCoding)
    }
}

public extension NSCoding where Self: NSObject {
    /**
     Creates an archived-based copy of the object.
     
     - Throws: An error if copying fails.
     */
    func archiveBasedCopy() throws -> Self {
        let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
        unarchiver.requiresSecureCoding = false
        guard let copy = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) else {
            throw CodingErrors.unarchivingFailed
        }
        guard let copy = copy as? Self else {
            throw CodingErrors.typeMismatch(actual: type(of: copy as AnyObject), expected: Self.self)
        }
        return copy
    }
    
    /**
     Creates an archived-based copy of the object as the specified subclass.
     
     - Parameter subclass: The type of the subclass for the copy.
     
     - Throws: An error if copying fails or the specified class isn't a subclass.
     */
    func archiveBasedCopy<Subclass: NSObject & NSCoding>(as subclass: Subclass.Type) throws -> Subclass {
        guard Subclass.self is Self.Type else {
            throw CodingErrors.invalidSubclass(subclass: Subclass.self, superclass: Self.self)
        }
        let subclassName = NSStringFromClass(Subclass.self)
        NSKeyedArchiver.setClassName(subclassName, for: Self.self)
        let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
        NSKeyedArchiver.setClassName(nil, for: Self.self)
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
        unarchiver.requiresSecureCoding = false
        unarchiver.setClass(Subclass.self, forClassName: subclassName)
        guard let copy = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) else {
            throw CodingErrors.unarchivingFailed
        }
        guard let copy = copy as? Subclass else {
            throw CodingErrors.typeMismatch(actual: type(of: copy as AnyObject), expected: Subclass.self)
        }
        return copy
    }
    
    /// Returns a new instance that’s a copy of the receiver.
    func copyAsSelf() -> Self? {
        copy() as? Self
    }
}

fileprivate enum CodingErrors: LocalizedError {
    case typeMismatch(actual: AnyClass, expected: AnyClass)
    case unarchivingFailed
    case invalidSubclass(subclass: AnyClass, superclass: AnyClass)
    
    var errorDescription: String? {
        switch self {
        case .typeMismatch: return "Type Mismatch"
        case .unarchivingFailed: return "Unarchiving Failed"
        case .invalidSubclass: return "Invalid Subclass"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .typeMismatch(let actual, let expected):
            return "Expected object of type \(expected), but decoded object was of type \(actual)."
        case .unarchivingFailed:
            return "The archived data couldn't be unarchived. It may be corrupted or missing required objects."
        case .invalidSubclass(let subclass, let superclass):
            return "Expected \(subclass) to be a subclass of \(superclass), but it isn't."
        }
    }
}
