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
    func archiveBasedCopy<Subclass: NSCoding>(as subclass: Subclass.Type = Subclass.self) throws -> Subclass {
        try NSKeyedUnarchiver.unarchiveObject(archivedData(), as: subclass, replacingClassName: NSStringFromClass(type(of: self)))
    }
    
    /**
     Decodes a previously-archived object graph, and returns the root object as the type.
     
     - Parameter data: The object graph previously encoded by `NSKeyedArchiver`.
     */
    static func unarchive(_ data: Data) throws -> Self {
        try NSKeyedUnarchiver.unarchive(data, as: Self.self)
    }
}

public extension NSSecureCoding {
    /**
     Archives the object into `Data`.
     
     - Parameter requiresSecureCoding: A Boolean value indicating whether the unarchived object requires to conform to [NSSecureCoding](https://developer.apple.com/documentation/foundation/nssecurecoding).
     - Throws: An error if the encoding process fails.
     - Returns: A `Data` representation of the object.
     */
    func archivedData(requiresSecureCoding: Bool = Self.supportsSecureCoding) throws -> Data {
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
     Creates an archived-based copy of the object as the specified subclass.
     
     - Parameter subclass: The type of the subclass for the copy.
     
     - Throws: An error if copying fails or the specified class isn't a subclass.
     */
    func archiveBasedCopy<Subclass: NSCoding>(as subclass: Subclass.Type = Subclass.self) throws -> Subclass {
        try NSKeyedUnarchiver.unarchiveObject(archivedData(requiresSecureCoding: false), as: subclass, replacingClassName: NSStringFromClass(type(of: self)))
    }
    
    /**
     Decodes a previously-archived object graph, and returns the root object as the type.
     
     - Parameter data: The object graph previously encoded by `NSKeyedArchiver`.
     */
    static func unarchive(_ data: Data) throws -> Self {
        try NSKeyedUnarchiver.unarchive(data, as: Self.self, requiresSecureCoding: Self.supportsSecureCoding)
    }
    
    static func unarchive(_ data: Data) throws -> Self where Self: NSObject {
        try NSKeyedUnarchiver.unarchive(data, as: Self.self)
    }
}

public extension NSCopying where Self: NSObject {
    /// Shallow copy
    func copyAsSelf() -> Self? {
        copy() as? Self
    }
}
