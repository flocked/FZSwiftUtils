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
        try NSKeyedUnarchiver.unarchivedObject(from: try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false))
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
        guard let object = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Self else { throw CocoaError(.coderReadCorrupt) }
        return object
      // try NSKeyedUnarchiver.unarchivedObject(from: data)
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
    
    /*
    /**
     Decodes a previously-archived object graph, and returns the root object as the type.
     
     - Parameter data: The object graph previously encoded by `NSKeyedArchiver`.
     */
    static func unarchive(_ data: Data) throws -> Self {
       try unarchive(data, requiresSecureCoding: supportsSecureCoding)
    }
    
    /**
     Decodes a previously-archived object graph, and returns the root object as the type.
     
     - Parameters:
        - data: The object graph previously encoded by `NSKeyedArchiver`.
        - requiresSecureCoding: A Boolean value indicating whether the unarchived object requires to conform to [NSSecureCoding](https://developer.apple.com/documentation/foundation/nssecurecoding).
     */
    static func unarchive(_ data: Data, requiresSecureCoding: Bool) throws -> Self {
       try NSKeyedUnarchiver.unarchivedObject(from: data, requiresSecureCoding: requiresSecureCoding)
    }
     */
}

public extension NSCoding where Self: NSObject {
    /// Returns a new instance that’s a copy of the receiver.
    func copyAsSelf() -> Self? {
        copy() as? Self
    }
}
