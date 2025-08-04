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
     
     If the object conforms to `NSSecureCoding`, set `requiringSecureCoding` to `true` for added security.
     
     - Parameter requiringSecureCoding: A Boolean value indicating whether secure coding is required.
     - Throws: An error if the encoding process fails.
     - Returns: A `Data` representation of the object.
     */
    func archivedData(requiringSecureCoding: Bool = false) throws -> Data {
        try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: requiringSecureCoding)
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
}

public extension NSCoding where Self: NSObject {
    /// Returns a new instance that’s a copy of the receiver.
    func copyAsSelf() -> Self? {
        copy() as? Self
    }
}
