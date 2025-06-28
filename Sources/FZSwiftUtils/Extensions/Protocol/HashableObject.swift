//
//  HashableObject.swift
//
//
//  Created by Florian Zand on 28.06.25.
//

/// A protocol that provides `Hashable` conformance for class types using object identity (`ObjectIdentifier`).
public protocol HashableObject: AnyObject, Hashable { }

extension HashableObject {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
