//
//  NSObject+.swift
//
//
//  Created by Florian Zand on 10.10.22.
//

import Foundation

extension NSObject {
    /// The identifier of the object.
    public var objectIdentifier: ObjectIdentifier {
        ObjectIdentifier(self)
    }
}

extension NSObjectProtocol where Self: NSObject {
    /// The type of the object.
    public var classType: Self.Type {
        return type(of: self)
    }
}

/// `NSCoding` errors.
public enum NSCodingError: Error {
    /// Unpacking failed.
    case unpacking
    /// Casting failed.
    case castingFailed
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
        guard let copy = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? Self else {
            throw NSCodingError.unpacking
        }
        return copy
    }
    
    /**
     Creates an archived-based copy of the object as the specified subclass.
     
     - Parameter subclass: The type of the subclass for the copy.

     - Throws: An error if copying fails or the specified class isn't a subclass.
     */
    func archiveBasedCopy<Subclass: NSObject & NSCoding>(as subclass: Subclass.Type) throws -> Subclass {
        let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
        unarchiver.requiresSecureCoding = false
        guard let object = Subclass(coder: unarchiver) else {
            throw NSCodingError.castingFailed
        }
        return object
    }
}

public extension NSObjectProtocol where Self: NSObject {
    /**
     Registers an observer object to receive KVO notifications for the key path relative to the object receiving this message.

     - Parameters:
        - observer: The object to register for KVO notifications. The observer must implement the key-value observing method `observeValue(forKeyPath:of:change:context:)`.
        - keypath: The key path to stop observing.
        - options: The observation options.
        - context: Arbitrary data that is passed to observer in `observeValue(forKeyPath:of:change:context:)`.
     */
    func addObserver<Value>(_ observer: NSObject, for keypath: KeyPath<Self, Value>,
                            options: NSKeyValueObservingOptions = [],
                            context: UnsafeMutableRawPointer? = nil) {
        guard let keypathString = keypath._kvcKeyPathString else { return }
        addObserver(observer, forKeyPath: keypathString, options: options, context: context)
    }
    
    /**
     Stops the observer object from receiving change notifications for the property specified by the key path.

     - Parameters:
        - observer: The observer to remove.
        - keypath: The key path to stop observing.
        - context: Arbitrary data that more specifically identifies the observer to be removed.
     */
    func removeObserver<Value>(_ observer: NSObject, for keypath: KeyPath<Self, Value>, context: UnsafeMutableRawPointer? = nil) {
        guard let keypathString = keypath._kvcKeyPathString else { return }
        removeObserver(observer, forKeyPath: keypathString, context: context)
    }
}

public extension NSObject {
    /**
     Returns the value for the property identified by a given key.

     - Parameter key: The key of the property.
     - Returns: The value for the property identified by key, or `nil` if the key doesn't exist.
     */
    func value(forKeySafely key: String) -> Any? {
        guard Self.containsProperty(key) else { return nil }
        return value(forKey: key)
    }
    
    /**
     Returns the value for the property identified by a given key.

     - Parameter key: The key of the property.
     - Returns: The value for the property identified by key, or `nil` if the key doesn't exist.
     */
    func value<Value>(forKey key: String) -> Value? {
        value(forKeySafely: key) as? Value
    }
    
    /**
     Sets the value safely for the specified key, only if the object contains a property with the given key.

     - Parameters:
        - value: The value to set.
        - key: The key of the property to set.
     */
    func setValue(safely value: Any?, forKey key: String) {
        guard Self.containsProperty(key) else { return }
        setValue(value, forKey: key)
    }

    /**
     Checks if the object overrides the specified selector.

     - Parameter selector: The selector to check for override.

     - Returns: `true` if the object overrides the selector, `false` otherwise.
     */
    func overrides(_ selector: Selector) -> Bool {
        var currentClass: AnyClass = type(of: self)
        let method: Method? = class_getInstanceMethod(currentClass, selector)

        while let superClass: AnyClass = class_getSuperclass(currentClass) {
            // Make sure we only check against non-`nil` returned instance methods.
            if class_getInstanceMethod(superClass, selector).map({ $0 != method }) ?? false {
                return true
            }
            currentClass = superClass
        }
        return false
    }

    /**
     Checks if the object is a subclass of the specified class.

     - Parameters:
        - class_: The class to check against.

     - Returns: `true` if the object is a subclass of the specified class, `false` otherwise.
     */
    func isSubclass(of class_: AnyClass) -> Bool {
        var currentClass: AnyClass = type(of: self)
        while let superClass: AnyClass = class_getSuperclass(currentClass) {
            if superClass == class_ {
                return true
            }
            currentClass = superClass
        }
        return false
    }
}
