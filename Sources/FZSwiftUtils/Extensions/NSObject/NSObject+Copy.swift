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
            throw NSCodingError.decodingFailed
        }
        guard let copy = copy as? Self else {
            throw NSCodingError.castingFailed(type(of: copy as AnyObject), Self.self)
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
            throw NSCodingError.notASubclass(Subclass.self, Self.self)
        }
        let subclassName = NSStringFromClass(Subclass.self)
        NSKeyedArchiver.setClassName(subclassName, for: Self.self)
        let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
        NSKeyedArchiver.setClassName(nil, for: Self.self)
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
        unarchiver.requiresSecureCoding = false
        unarchiver.setClass(Subclass.self, forClassName: subclassName)
        guard let copy = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) else {
            throw NSCodingError.decodingFailed
        }
        guard let copy = copy as? Subclass else {
            throw NSCodingError.castingFailed(type(of: copy as AnyObject), Subclass.self)
        }
        return copy
    }
    
    /// Returns a new instance that’s a copy of the receiver.
    func copyAsSelf() -> Self? {
        copy() as? Self
    }
}

/// `NSCoding` errors.
enum NSCodingError: LocalizedError {
    /// Casting the object failed.
    case castingFailed(_ fromClass: AnyClass, _ toClass: AnyClass)
    /// Decoding the object failed.
    case decodingFailed
    /// Class isn't a subclass.
    case notASubclass(_ subclass: AnyClass, _ class: AnyClass)
    
    var errorDescription: String? {
        switch self {
        case .decodingFailed:
            return "Couldn't decode the object."
        case .castingFailed(let class1, let class2):
            return "Couldn't cast the object from \(class1) to \(class2)"
        case .notASubclass(let class1, let class2):
            return "\(class1) isn't a subclass of \(class2)"
        }
    }
}
