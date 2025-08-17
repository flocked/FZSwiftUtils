//
//  HashableObject.swift
//
//
//  Created by Florian Zand on 28.06.25.
//

/**
 An object type that conforms to `Hashable`.

 The protocol adds automatic conformance to `Hashable` using the object's identity ([ObjectIdentifier](https://developer.apple.com/documentation/swift/objectidentifier)).
*/
public protocol HashableObject: AnyObject, Hashable { }

extension HashableObject {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
