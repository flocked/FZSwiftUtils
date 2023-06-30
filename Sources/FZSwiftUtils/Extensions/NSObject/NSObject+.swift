//
//  NSObject+.swift
//
//
//  Created by Florian Zand on 10.10.22.
//

import Foundation

public extension NSKeyedUnarchiver {
    enum Errors: Error {
        /// Unpacking failed.
        case unpackingError
    }
}

public extension NSCoding where Self: NSObject {
    
    /**
     Creates an archived-based copy of the object.
     
     - Throws: An error if the archiving or unarchiving process fails.
     
     - Returns: A copy of the object that is created by archiving and unarchiving the original object.
     */
    func archiveBasedCopy() throws -> Self {
        let archivedData = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
        guard let object = try NSKeyedUnarchiver.unarchivedObject(ofClass: Self.self, from: archivedData) else {
            throw NSKeyedUnarchiver.Errors.unpackingError
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
        self.removeObserver(observer, forKeyPath: keypathString)
    }
    
    /**
     Sets the value safely for the specified key, only if the object contains a property with the given key.
     
     - Parameters:
        - value: The value to set.
        - key: The key of the property to set.
     */
    func setValue(safely value: Any?, forKey key: String) {
        if containsProperty(named: key) {
            setValue(value, forKey: key)
        }
    }

    /**
     Retrieves the value for the specified key, casting it to the specified type, if the object contains a property with the given key.
     
     - Parameters:
        - key: The key of the property to retrieve the value for.
        - type: The type to cast the value to.
     
     - Returns: The value for the specified key, cast to the specified type, or `nil` if the key is not found or the value cannot be cast.
     */
    func value<T>(forKey key: String, type _: T.Type) -> T? {
        if containsProperty(named: key) {
            return value(forKey: key) as? T
        }
        return nil
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
            // Make sure we only check against non-nil returned instance methods.
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
