//
//  Collection+ObjectIdentifier.swift
//
//
//  Created by Florian Zand on 06.11.25.
//

import Foundation

public extension Set where Element == ObjectIdentifier {
    /// Inserts the identifier for the given class in the set if it is not already present.
    mutating func insert(_ cls: AnyClass) { insert(ObjectIdentifier(cls)) }
    
    /// Inserts the identifier for the given object in the set if it is not already present.
    mutating func insert(_ object: AnyObject) { insert(ObjectIdentifier(object)) }
    
    /// Inserts the identifiers for the given classes in the set.
    mutating func insert<S>(_ classes: S) where S: Sequence<AnyClass> {
        insert(classes.map({ ObjectIdentifier($0) }))
    }
    
    /// Inserts the identifiers for the given objects in the set.
    mutating func insert<S>(_ objects: S) where S: Sequence<AnyObject> {
        insert(objects.map({ ObjectIdentifier($0) }))
    }

    /// Removes the identifier for the specified class from the set.
    @discardableResult
    mutating func remove(_ cls: AnyClass) -> ObjectIdentifier? { remove(ObjectIdentifier(cls)) }
    
    /// Removes the identifier for the specified object from the set.
    @discardableResult
    mutating func remove(_ object: AnyObject) -> ObjectIdentifier? { remove(ObjectIdentifier(object)) }
    
    /// Removes the identifiers for the specified classes from the set.
    mutating func remove<S>(_ classes: S) where S: Sequence<AnyClass> {
        remove(classes.map({ ObjectIdentifier($0) }))
    }
    
    /// Removes the identifiers for the specified objects from the set.
    mutating func remove<S>(_ objects: S) where S: Sequence<AnyObject> {
        remove(objects.map({ ObjectIdentifier($0) }))
    }

    /// Returns a Boolean value that indicates whether an identifier for the given class exists in the set.
    func contains(_ key: AnyClass) -> Bool { contains(ObjectIdentifier(key)) }
    
    /// Returns a Boolean value that indicates whether an identifier for the given object exists in the set.
    func contains(_ key: AnyObject) -> Bool { contains(ObjectIdentifier(key)) }
    
    
    subscript(_ key: AnyClass) -> Bool {
        get { contains(key) }
        set {
            if newValue {
                insert(key)
            } else {
                remove(key)
            }
        }
    }
    
    subscript(_ key: AnyObject) -> Bool {
        get { contains(key) }
        set {
            if newValue {
                insert(key)
            } else {
                remove(key)
            }
        }
    }
}

extension Dictionary where Key == ObjectIdentifier {
    public subscript(_ key: AnyClass) -> Value? {
        get { self[ObjectIdentifier(key)] }
        set { self[ObjectIdentifier(key)] = newValue }
    }
    
    public subscript(_ key: AnyClass, default defaultValue: @autoclosure () -> Value) -> Value {
        get { self[ObjectIdentifier(key), default: defaultValue()] }
        set { self[ObjectIdentifier(key)] = newValue }
    }
    
    public subscript(_ key: AnyObject) -> Value? {
        get { self[ObjectIdentifier(key)] }
        set { self[ObjectIdentifier(key)] = newValue }
    }
    
    public subscript(_ key: AnyObject, default defaultValue: @autoclosure () -> Value) -> Value {
        get { self[ObjectIdentifier(key),default: defaultValue()] }
        set { self[ObjectIdentifier(key)] = newValue }
    }
}
