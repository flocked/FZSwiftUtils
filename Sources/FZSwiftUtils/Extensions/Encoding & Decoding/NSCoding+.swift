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
        try NSKeyedUnarchiver.unarchivedObject(from: try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false, as: subclass))
    }
    
    /**
     Decodes a previously-archived object graph, and returns the root object as the type.
     
     - Parameter data: The object graph previously encoded by `NSKeyedArchiver`.
     */
    static func unarchive(_ data: Data) throws -> Self {
        try NSKeyedUnarchiver.unarchivedObject(from: data)
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
