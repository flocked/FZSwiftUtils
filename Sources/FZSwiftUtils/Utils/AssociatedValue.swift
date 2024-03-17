//
//  AssociatedValue.swift
//
//  Parts taken from:
//  github.com/bradhilton/AssociatedValues
//  Created by Skyvive
//  Created by Florian Zand on 23.02.23.
//

import Foundation
import ObjectiveC.runtime

/**
 Returns the associated value for the specified object and key.

 - Parameters:
    - key: The key of the associated value.
    - object: The object of the associated value.
 - Returns: The associated value for the object and key, or `nil` if the value couldn't be found for the key.
 */
public func getAssociatedValue<T>(key: String, object: AnyObject) -> T? {
    (objc_getAssociatedObject(object, key.address) as? _AssociatedValue)?.value as? T
}

/**
 Returns the associated value for the specified object, key and inital value.

 - Parameters:
    - key: The key of the associated value.
    - object: The object of the associated value.
    - initialValue: The inital value of the associated value.
 - Returns: The associated value for the object and key.
 */
public func getAssociatedValue<T>(key: String, object: AnyObject, initialValue: @autoclosure () -> T) -> T {
    getAssociatedValue(key: key, object: object) ?? setAndReturn(initialValue: initialValue(), key: key, object: object)
}

/**
 Returns the associated value for the specified object, key and inital value.

 - Parameters:
    - key: The key of the associated value.
    - object: The object of the associated value.
    - initialValue: The inital value of the associated value.
 - Returns: The associated value for the object and key.
 */
public func getAssociatedValue<T>(key: String, object: AnyObject, initialValue: () -> T) -> T {
    getAssociatedValue(key: key, object: object) ?? setAndReturn(initialValue: initialValue(), key: key, object: object)
}

private func setAndReturn<T>(initialValue: T, key: String, object: AnyObject) -> T {
    set(associatedValue: initialValue, key: key, object: object)
    return initialValue
}

/**
 Sets a associated value for the specified object and key.

 - Parameters:
    - associatedValue: The value of the associated value.
    - key: The key of the associated value.
    - object: The object of the associated value.
 */
public func set<T>(associatedValue: T?, key: String, object: AnyObject) {
    set(associatedValue: _AssociatedValue(associatedValue), key: key, object: object)
}

/**
 Sets a weak associated value for the specified object and key.

 - Parameters:
    - weakAssociatedValue: The weak value of the associated value.
    - key: The key of the associated value.
    - object: The object of the associated value.
 */
public func set<T: AnyObject>(weakAssociatedValue: T?, key: String, object: AnyObject) {
    set(associatedValue: _AssociatedValue(weak: weakAssociatedValue), key: key, object: object)
}

private func set(associatedValue: _AssociatedValue, key: String, object: AnyObject) {
    objc_setAssociatedObject(object, key.address, associatedValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
}

extension NSObjectProtocol where Self: NSObject {
    /**
     Returns the associated value for the specified  key.

     - Parameters:
        - key: The key of the associated value.
     - Returns: The associated value for the key, or `nil` if the value couldn't be found for the key.
     */
    public func getAssociatedValue<T>(_ key: String) -> T? {
        FZSwiftUtils.getAssociatedValue(key: key, object: self)
    }
    
    /**
     Returns the associated value for the specified key and inital value.

     - Parameters:
        - key: The key of the associated value.
        - initialValue: The inital value of the associated value.
     - Returns: The associated value for the object and key.
     */
    public func getAssociatedValue<T>(_ key: String, initialValue: @autoclosure () -> T) -> T {
        FZSwiftUtils.getAssociatedValue(key: key, object: self, initialValue: initialValue)
    }
    
    /**
     Returns the associated value for the specified key and inital value.

     - Parameters:
        - key: The key of the associated value.
        - initialValue: The inital value of the associated value.
     - Returns: The associated value for the key.
     */
    public func getAssociatedValue<T>(_ key: String, initialValue: () -> T) -> T {
        FZSwiftUtils.getAssociatedValue(key: key, object: self, initialValue: initialValue)
    }
    
    /**
     Sets an associated value for the specified key.

     - Parameters:
        - value: The value to set.
        - key: The key of the associated value.
     */
    public func setAssociatedValue<T>(_ value: T?, key: String) {
        FZSwiftUtils.set(associatedValue: value, key: key, object: self)
    }
    
    /**
     Sets a weak associated value for the specified key.

     - Parameters:
        - value: The weak value to set.
        - key: The key of the associated value.
     */
    public func setAssociatedValue<T: AnyObject>(weak value: T?, key: String) {
        FZSwiftUtils.set(weakAssociatedValue: value, key: key, object: self)
    }
    
    /**
     Returns the associated value for the specified  key.

     - Parameters:
        - key: The key of the associated value.
     - Returns: The associated value for the key, or `nil` if the value couldn't be found for the key.
     */
    public static func getAssociatedValue<T>(_ key: String) -> T? {
        FZSwiftUtils.getAssociatedValue(key: key, object: self)
    }
    
    /**
     Returns the associated value for the specified key and inital value.

     - Parameters:
        - key: The key of the associated value.
        - initialValue: The inital value of the associated value.
     - Returns: The associated value for the object and key.
     */
    public static func getAssociatedValue<T>(_ key: String, initialValue: @autoclosure () -> T) -> T {
        FZSwiftUtils.getAssociatedValue(key: key, object: self, initialValue: initialValue)
    }
    
    /**
     Returns the associated value for the specified key and inital value.

     - Parameters:
        - key: The key of the associated value.
        - initialValue: The inital value of the associated value.
     - Returns: The associated value for the key.
     */
    public static func getAssociatedValue<T>(_ key: String, initialValue: () -> T) -> T {
        FZSwiftUtils.getAssociatedValue(key: key, object: self, initialValue: initialValue)
    }
    
    /**
     Sets an associated value for the specified key.

     - Parameters:
        - value: The value to set.
        - key: The key of the associated value.
     */
    public static func setAssociatedValue<T>(_ value: T?, key: String) {
        FZSwiftUtils.set(associatedValue: value, key: key, object: self)
    }
    
    /**
     Sets a weak associated value for the specified key.

     - Parameters:
        - value: The weak value to set.
        - key: The key of the associated value.
     */
    public static func setAssociatedValue<T: AnyObject>(weak value: T?, key: String) {
        FZSwiftUtils.set(weakAssociatedValue: value, key: key, object: self)
    }
}


private class _AssociatedValue {
    weak var _weakValue: AnyObject?
    var _value: Any?

    var value: Any? {
        _weakValue ?? _value
    }

    init(_ value: Any?) {
        _value = value
    }

    init(weak: AnyObject?) {
        _weakValue = weak
    }
}

private extension String {
    var address: UnsafeRawPointer {
        UnsafeRawPointer(bitPattern: abs(hashValue))!
    }
}
