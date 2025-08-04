//
//  NSKeyedArchiver+.swift
//
//
//  Created by Florian Zand on 04.08.25.
//

import Foundation

public extension NSKeyedArchiver {
    /**
     Encodes an object graph with the given root object into a data representation, optionally requiring secure coding.
     
     To prevent the possibility of encoding an object that [NSKeyedUnarchiver](https://developer.apple.com/documentation/foundation/nskeyedunarchiver) can’t decode, set `requiresSecureCoding` to `true` whenever possible. This ensures that all encoded objects conform to [NSSecureCoding](https://developer.apple.com/documentation/foundation/nssecurecoding).
          
     - Parameters:
        - object: The root of the object graph to archive.
        - requiresSecureCoding: A Boolean value indicating whether all encoded objects must conform to [NSSecureCoding](https://developer.apple.com/documentation/foundation/nssecurecoding).
        - subclass: The subclass for the data that needs to be a subclass of `object`.
     
     - Note: Enabling secure coding doesn’t change the output format of the archive. This means that you can encode archives with secure coding enabled, and decode them later with secure coding disabled.
     */
    class func archivedData<Object: NSCoding, Subclass: NSCoding>(withRootObject object: Object, requiringSecureCoding: Bool = false, as subclass: Subclass.Type) throws -> Data {
        guard Subclass.self is Object.Type else { throw Error.invalidSubclass(subclass: Subclass.self, superclass: Object.self) }
        NSKeyedArchiver.setClassName(NSStringFromClass(Subclass.self), for: Object.self)
        defer { NSKeyedArchiver.setClassName(nil, for: Object.self) }
        return try NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: requiringSecureCoding)
    }
}

fileprivate enum Error: LocalizedError {
    case invalidSubclass(subclass: AnyClass, superclass: AnyClass)
    
    var errorDescription: String? {
        switch self {
        case .invalidSubclass: return "Invalid Subclass"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .invalidSubclass(let subclass, let superclass): return "Expected \(subclass) to be a subclass of \(superclass), but it isn't."
        }
    }
}
