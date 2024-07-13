//
//  NSObject+.swift
//
//
//  Created by Florian Zand on 10.10.22.
//

import Foundation

/// `NSCoding` errors.
public enum NSCodingError: Error {
    /// Unpacking failed.
    case unpacking
    /// Casting failed.
    case castingFailed
}

extension NSObjectProtocol where Self: NSObject {
    /**
     Sets the value of the property at the specified key path.
     
     - Parameters:
        - value: The value of the property.
        - keyPath: The key path to the property.
     - Returns: The object.
     */
    @discardableResult
    public func setValue<Value>(_ value: Value, for keyPath: ReferenceWritableKeyPath<Self, Value>) -> Self {
        apply {
            $0[keyPath: keyPath] = value
        }
    }
    
    func apply(_ modifier: @escaping (Self) -> Void) -> Self {
        modifier(self)
        return self
    }
}

public extension NSCoding where Self: NSObject {
    
    /**
     Creates an archived-based copy of the object.

     - Throws: An error if copying fails.
     */
    func archiveBasedCopy() throws -> Self {
        let data: Data
        let unarchiver: NSKeyedUnarchiver
        if #available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *) {
            data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
            unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
        } else {
            data = NSKeyedArchiver.archivedData(withRootObject: self)
            unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        }
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
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        encode(with: archiver)
        archiver.finishEncoding()
        let unarchiver = NSKeyedUnarchiver(forReadingWith: data as Data)
        guard let object = Subclass(coder: unarchiver) else {
            throw NSCodingError.castingFailed
        }
        return object
    }
}

public extension NSObject {
    /**
     Removes an observer for the specified key path.

     - Parameters:
        - observer: The observer to remove.
        - keypath: The key path to stop observing.
     */
    func removeObserver<Value>(_ observer: NSObject, for keypath: KeyPath<NSObject, Value>) {
        guard let keypathString = keypath._kvcKeyPathString else { return }
        removeObserver(observer, forKeyPath: keypathString)
    }
    
    /**
     Returns the value for the property identified by a given key.

     - Parameter key: The key of the property.
     - Returns: The value for the property identified by key, or `nil` if the key doesn't exist.
     */
    func value(forKeySafely key: String) -> Any? {
        guard Self.canGetValue(key) else { return nil }
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
        guard Self.canGetValue(key) else { return }
        setValue(value, forKey: key)
    }

    /**
     Checks if the object overrides the specified selector.

     - Parameters:
        - selector: The selector to check for override.

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
