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
public func getAssociatedValue<T>(_ key: String, object: AnyObject) -> T? {
    (objc_getAssociatedObject(object, key.address) as? AssociatedValue)?.value as? T
}

/**
 Returns the associated value for the specified object, key and inital value.

 - Parameters:
    - key: The key of the associated value.
    - object: The object of the associated value.
    - initialValue: The inital value of the associated value.
 - Returns: The associated value for the object and key.
 */
public func getAssociatedValue<T>(_ key: String, object: AnyObject, initialValue: @autoclosure () -> T) -> T {
    getAssociatedValue(key, object: object) ?? setAndReturn(initialValue: initialValue(), key: key, object: object)
}

/**
 Returns the associated value for the specified object, key and inital value.

 - Parameters:
    - key: The key of the associated value.
    - object: The object of the associated value.
    - initialValue: The inital value of the associated value.
 - Returns: The associated value for the object and key.
 */
public func getAssociatedValue<T: AnyObject>(_ key: String, object: AnyObject, weakInitialValue initialValue: @autoclosure () -> T) -> T {
    getAssociatedValue(key, object: object) ?? setAndReturn(weakInitialValue: initialValue(), key: key, object: object)
}

/**
 Returns the associated value for the specified object, key and inital value.

 - Parameters:
    - key: The key of the associated value.
    - object: The object of the associated value.
    - initialValue: The inital value of the associated value.
 - Returns: The associated value for the object and key.
 */
public func getAssociatedValue<T>(_ key: String, object: AnyObject, initialValue: () -> T) -> T {
    getAssociatedValue(key, object: object) ?? setAndReturn(initialValue: initialValue(), key: key, object: object)
}

/**
 Returns the associated value for the specified object, key and inital value.

 - Parameters:
    - key: The key of the associated value.
    - object: The object of the associated value.
    - initialValue: The inital value of the associated value.
 - Returns: The associated value for the object and key.
 */
public func getAssociatedValue<T: AnyObject>(_ key: String, object: AnyObject, weakInitialValue initialValue: () -> T) -> T {
    getAssociatedValue(key, object: object) ?? setAndReturn(weakInitialValue: initialValue(), key: key, object: object)
}

/**
 Sets a associated value for the specified object and key.

 - Parameters:
    - associatedValue: The value of the associated value.
    - key: The key of the associated value.
    - object: The object of the associated value.
 */
public func setAssociatedValue<T>(_ value: T?, key: String, object: AnyObject) {
    setAssociatedValue(AssociatedValue(value), key: key, object: object)
}

/**
 Sets a weak associated value for the specified object and key.

 - Parameters:
    - weakAssociatedValue: The weak value of the associated value.
    - key: The key of the associated value.
    - object: The object of the associated value.
 */
public func setAssociatedValue<T: AnyObject>(weak value: T?, key: String, object: AnyObject) {
    setAssociatedValue(AssociatedValue(weak: value), key: key, object: object)
}

private func setAssociatedValue(_ value: AssociatedValue, key: String, object: AnyObject) {
    objc_setAssociatedObject(object, key.address, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
}

private func setAndReturn<T>(initialValue: T, key: String, object: AnyObject) -> T {
    setAssociatedValue( initialValue, key: key, object: object)
    return initialValue
}

private func setAndReturn<T: AnyObject>(weakInitialValue: T, key: String, object: AnyObject) -> T {
    setAssociatedValue(weak: weakInitialValue, key: key, object: object)
    return weakInitialValue
}

extension NSObjectProtocol where Self: NSObject {
    /**
     Returns the associated value for the specified key.

     - Parameter key: The key of the associated value.
     - Returns: The associated value for the key, or `nil` if the value couldn't be found for the key.
     */
    public func getAssociatedValue<T>(_ key: String) -> T? {
        FZSwiftUtils.getAssociatedValue(key, object: self)
    }
    
    /**
     Returns the associated value for the specified key and inital value.

     - Parameters:
        - key: The key of the associated value.
        - initialValue: The inital value of the associated value.
     - Returns: The associated value for the object and key.
     */
    public func getAssociatedValue<T>(_ key: String, initialValue: @autoclosure () -> T) -> T {
        FZSwiftUtils.getAssociatedValue(key, object: self, initialValue: initialValue)
    }
    
    /**
     Returns the associated value for the specified key and inital value.

     - Parameters:
        - key: The key of the associated value.
        - initialValue: The inital value of the associated value.
     - Returns: The associated value for the object and key.
     */
    public func getAssociatedValue<T: AnyObject>(_ key: String, weakInitialValue initialValue: @autoclosure () -> T) -> T {
        FZSwiftUtils.getAssociatedValue(key, object: self, weakInitialValue: initialValue)
    }

    /**
     Returns the associated value for the specified key and inital value.

     - Parameters:
        - key: The key of the associated value.
        - initialValue: The inital value of the associated value.
     - Returns: The associated value for the key.
     */
    public func getAssociatedValue<T>(_ key: String, initialValue: () -> T) -> T {
        FZSwiftUtils.getAssociatedValue(key, object: self, initialValue: initialValue)
    }

    /**
     Returns the associated value for the specified key and inital value.

     - Parameters:
        - key: The key of the associated value.
        - initialValue: The inital value of the associated value.
     - Returns: The associated value for the key.
     */
    public func getAssociatedValue<T: AnyObject>(_ key: String, weakInitialValue initialValue: () -> T) -> T {
        FZSwiftUtils.getAssociatedValue(key, object: self, weakInitialValue: initialValue)
    }
    
    /**
     Sets an associated value for the specified key.

     - Parameters:
        - value: The value to set.
        - key: The key of the associated value.
     */
    public func setAssociatedValue<T>(_ value: T?, key: String) {
        FZSwiftUtils.setAssociatedValue(value, key: key, object: self)
    }
    
    /**
     Sets a weak associated value for the specified key.

     - Parameters:
        - value: The weak value to set.
        - key: The key of the associated value.
     */
    public func setAssociatedValue<T: AnyObject>(weak value: T?, key: String) {
        FZSwiftUtils.setAssociatedValue(weak: value, key: key, object: self)
    }
    
    /**
     Returns the associated value for the specified  key.

     - Parameter key: The key of the associated value.
     - Returns: The associated value for the key, or `nil` if the value couldn't be found for the key.
     */
    public static func getAssociatedValue<T>(_ key: String) -> T? {
        FZSwiftUtils.getAssociatedValue(key, object: self)
    }
    
    /**
     Returns the associated value for the specified key and inital value.

     - Parameters:
        - key: The key of the associated value.
        - initialValue: The inital value of the associated value.
     - Returns: The associated value for the object and key.
     */
    public static func getAssociatedValue<T>(_ key: String, initialValue: @autoclosure () -> T) -> T {
        FZSwiftUtils.getAssociatedValue(key, object: self, initialValue: initialValue)
    }
    
    /**
     Returns the associated value for the specified key and inital value.

     - Parameters:
        - key: The key of the associated value.
        - initialValue: The inital value of the associated value.
     - Returns: The associated value for the object and key.
     */
    public static func getAssociatedValue<T: AnyObject>(_ key: String, weakInitialValue initialValue: @autoclosure () -> T) -> T {
        FZSwiftUtils.getAssociatedValue(key, object: self, weakInitialValue: initialValue)
    }
    
    /**
     Returns the associated value for the specified key and inital value.
     
     If the associated value for the key is `nil`, the associated value is set to the initial value and the value is returned.

     - Parameters:
        - key: The key of the associated value.
        - initialValue: The inital value of the associated value.
     - Returns: The associated value for the key.
     */
    public static func getAssociatedValue<T>(_ key: String, initialValue: () -> T) -> T {
        FZSwiftUtils.getAssociatedValue(key, object: self, initialValue: initialValue)
    }
    
    /**
     Returns the associated value for the specified key and inital value.
     
     If the associated value for the key is `nil`, the associated value is set to the initial value and the value is returned.

     - Parameters:
        - key: The key of the associated value.
        - initialValue: The inital value of the associated value.
     - Returns: The associated value for the key.
     */
    public static func getAssociatedValue<T: AnyObject>(_ key: String, weakInitialValue initialValue: () -> T) -> T {
        FZSwiftUtils.getAssociatedValue(key, object: self, weakInitialValue: initialValue)
    }
    
    /**
     Sets an associated value for the specified key.

     - Parameters:
        - value: The value to set.
        - key: The key of the associated value.
     */
    public static func setAssociatedValue<T>(_ value: T?, key: String) {
        FZSwiftUtils.setAssociatedValue(value, key: key, object: self)
    }
    
    /**
     Sets a weak associated value for the specified key.

     - Parameters:
        - value: The weak value to set.
        - key: The key of the associated value.
     */
    public static func setAssociatedValue<T: AnyObject>(weak value: T?, key: String) {
        FZSwiftUtils.setAssociatedValue(weak: value, key: key, object: self)
    }
}

extension NSObjectProtocol where Self: NSObject {
    /**
     Returns the associated value for the specified key.
     
     - Parameter key: The key of the associated value.
     - Returns: The associated value for the key, or `nil` if the value couldn't be found for the key.
     */
    public func getAssociatedValue<T>(_ key: KeyPath<Self, T>) -> T? {
        FZSwiftUtils.getAssociatedValue(key.stringValue, object: self)
    }
    
    /**
     Returns the associated value for the specified key and inital value.
     
     - Parameters:
        - key: The key of the associated value.
        - initialValue: The inital value of the associated value.
     - Returns: The associated value for the object and key.
     */
    public func getAssociatedValue<T>(_ key: KeyPath<Self, T>, initialValue: @autoclosure () -> T) -> T {
        FZSwiftUtils.getAssociatedValue(key.stringValue, object: self, initialValue: initialValue)
    }
    
    /**
     Returns the associated value for the specified key and inital value.
     
     - Parameters:
        - key: The key of the associated value.
        - initialValue: The inital value of the associated value.
     - Returns: The associated value for the object and key.
     */
    public func getAssociatedValue<T: AnyObject>(_ key: KeyPath<Self, T>, weakInitialValue initialValue: @autoclosure () -> T) -> T {
        FZSwiftUtils.getAssociatedValue(key.stringValue, object: self, weakInitialValue: initialValue)
    }
    
    /**
     Returns the associated value for the specified key and inital value.
     
     - Parameters:
        - key: The key of the associated value.
        - initialValue: The inital value of the associated value.
     - Returns: The associated value for the key.
     */
    public func getAssociatedValue<T>(_ key: KeyPath<Self, T>, initialValue: () -> T) -> T {
        FZSwiftUtils.getAssociatedValue(key.stringValue, object: self, initialValue: initialValue)
    }
    
    /**
     Returns the associated value for the specified key and inital value.
     
     - Parameters:
        - key: The key of the associated value.
        - initialValue: The inital value of the associated value.
     - Returns: The associated value for the key.
     */
    public func getAssociatedValue<T: AnyObject>(_ key: KeyPath<Self, T>, weakInitialValue initialValue: () -> T) -> T {
        FZSwiftUtils.getAssociatedValue(key.stringValue, object: self, weakInitialValue: initialValue)
    }
    
    /**
     Sets an associated value for the specified key.
     
     - Parameters:
        - value: The value to set.
        - key: The key of the associated value.
     */
    public func setAssociatedValue<T>(_ value: T?, key: KeyPath<Self, T>) {
        FZSwiftUtils.setAssociatedValue(value, key: key.stringValue, object: self)
    }
    
    /**
     Sets a weak associated value for the specified key.
     
     - Parameters:
        - value: The weak value to set.
        - key: The key of the associated value.
     */
    public func setAssociatedValue<T: AnyObject>(weak value: T?, key: KeyPath<Self, T>) {
        FZSwiftUtils.setAssociatedValue(weak: value, key: key.stringValue, object: self)
    }
    
    /**
     Returns the associated value for the specified  key.
     
     - Parameter key: The key of the associated value.
     - Returns: The associated value for the key, or `nil` if the value couldn't be found for the key.
     */
    public static func getAssociatedValue<T>(_ key: KeyPath<Self, T>) -> T? {
        FZSwiftUtils.getAssociatedValue(key.stringValue, object: self)
    }
    
    /**
     Returns the associated value for the specified key and inital value.
     
     - Parameters:
        - key: The key of the associated value.
        - initialValue: The inital value of the associated value.
     - Returns: The associated value for the object and key.
     */
    public static func getAssociatedValue<T>(_ key: KeyPath<Self, T>, initialValue: @autoclosure () -> T) -> T {
        FZSwiftUtils.getAssociatedValue(key.stringValue, object: self, initialValue: initialValue)
    }
    
    /**
     Returns the associated value for the specified key and inital value.
     
     - Parameters:
        - key: The key of the associated value.
        - initialValue: The inital value of the associated value.
     - Returns: The associated value for the object and key.
     */
    public static func getAssociatedValue<T: AnyObject>(_ key: KeyPath<Self, T>, weakInitialValue initialValue: @autoclosure () -> T) -> T {
        FZSwiftUtils.getAssociatedValue(key.stringValue, object: self, weakInitialValue: initialValue)
    }
    
    /**
     Returns the associated value for the specified key and inital value.
     
     If the associated value for the key is `nil`, the associated value is set to the initial value and the value is returned.
     
     - Parameters:
        - key: The key of the associated value.
        - initialValue: The inital value of the associated value.
     - Returns: The associated value for the key.
     */
    public static func getAssociatedValue<T>(_ key: KeyPath<Self, T>, initialValue: () -> T) -> T {
        FZSwiftUtils.getAssociatedValue(key.stringValue, object: self, initialValue: initialValue)
    }
    
    /**
     Returns the associated value for the specified key and inital value.
     
     If the associated value for the key is `nil`, the associated value is set to the initial value and the value is returned.
     
     - Parameters:
        - key: The key of the associated value.
        - initialValue: The inital value of the associated value.
     - Returns: The associated value for the key.
     */
    public static func getAssociatedValue<T: AnyObject>(_ key: KeyPath<Self, T>, weakInitialValue initialValue: () -> T) -> T {
        FZSwiftUtils.getAssociatedValue(key.stringValue, object: self, weakInitialValue: initialValue)
    }
    
    /**
     Sets an associated value for the specified key.
     
     - Parameters:
        - value: The value to set.
        - key: The key of the associated value.
     */
    public static func setAssociatedValue<T>(_ value: T?, key: KeyPath<Self, T>) {
        FZSwiftUtils.setAssociatedValue(value, key: key.stringValue, object: self)
    }
    
    /**
     Sets a weak associated value for the specified key.
     
     - Parameters:
        - value: The weak value to set.
        - key: The key of the associated value.
     */
    public static func setAssociatedValue<T: AnyObject>(weak value: T?, key: KeyPath<Self, T>) {
        FZSwiftUtils.setAssociatedValue(weak: value, key: key.stringValue, object: self)
    }
}

extension NSObjectProtocol where Self: NSObject {
    /// Returns the associated value for the specified key.
    public subscript<T>(associatedValue key: String) -> T? {
        get { getAssociatedValue(key) }
        set { setAssociatedValue(newValue, key: key) }
    }
    
    /// Returns the associated value for the specified key and sets the initial value.
    public subscript<T>(associatedValue key: String, initial initial: @autoclosure () -> T) -> T {
        get { getAssociatedValue(key, initialValue: initial) }
        set { setAssociatedValue(newValue, key: key) }
    }
    
    /// Returns the associated value for the specified key and sets the initial value.
    public subscript<T>(associatedValue key: String, initial initial: () -> T) -> T {
        get { getAssociatedValue(key, initialValue: initial) }
        set { setAssociatedValue(newValue, key: key) }
    }
    
    /// Returns the associated value for the specified key.
    public subscript<T: AnyObject>(weakAssociatedValue key: String) -> T? {
        get { getAssociatedValue(key) }
        set { setAssociatedValue(weak: newValue, key: key) }
    }
    
    /// Returns the associated value for the specified key and sets the initial value.
    public subscript<T: AnyObject>(weakAssociatedValue key: String, initial: @autoclosure () -> T) -> T {
        get { getAssociatedValue(key, initialValue: initial) }
        set { setAssociatedValue(weak: newValue, key: key) }
    }
    
    /// Returns the associated value for the specified key and sets the initial value.
    public subscript<T: AnyObject>(weakAssociatedValue key: String, initial: () -> T) -> T {
        get { getAssociatedValue(key, initialValue: initial) }
        set { setAssociatedValue(weak: newValue, key: key) }
    }
    
    /// Returns the associated value for the specified key.
    public static subscript<T>(associatedValue key: String) -> T? {
        get { getAssociatedValue(key) }
        set { setAssociatedValue(newValue, key: key) }
    }
    
    /// Returns the associated value for the specified key and sets the initial value.
    public static subscript<T>(associatedValue key: String, initial initial: @autoclosure () -> T) -> T {
        get { getAssociatedValue(key, initialValue: initial) }
        set { setAssociatedValue(newValue, key: key) }
    }
    
    /// Returns the associated value for the specified key and sets the initial value.
    public static subscript<T>(associatedValue key: String, initial initial: () -> T) -> T {
        get { getAssociatedValue(key, initialValue: initial) }
        set { setAssociatedValue(newValue, key: key) }
    }
    
    /// Returns the associated value for the specified key and sets the initial value.
    public static subscript<T: AnyObject>(weakAssociatedValue key: String, initial: @autoclosure () -> T) -> T {
        get { getAssociatedValue(key, weakInitialValue: initial) }
        set { setAssociatedValue(newValue, key: key) }
    }
    
    /// Returns the associated value for the specified key and sets the initial value.
    public static subscript<T: AnyObject>(weakAssociatedValue key: String, initial: () -> T) -> T {
        get { getAssociatedValue(key, weakInitialValue: initial) }
        set { setAssociatedValue(newValue, key: key) }
    }
}

extension NSObjectProtocol where Self: NSObject {
    /// Returns the associated value for the specified key.
    public subscript<T>(associatedValue keyPath: KeyPath<Self, T>) -> T? {
        get { getAssociatedValue(keyPath.stringValue) }
        set { setAssociatedValue(newValue, key: keyPath.stringValue) }
    }
    
    /// Returns the associated value for the specified key and sets the initial value.
    public subscript<T>(associatedValue keyPath: KeyPath<Self, T>, initial initial: @autoclosure () -> T) -> T {
        get { getAssociatedValue(keyPath.stringValue, initialValue: initial) }
        set { setAssociatedValue(newValue, key: keyPath.stringValue) }
    }
    
    /// Returns the associated value for the specified key and sets the initial value.
    public subscript<T>(associatedValue keyPath: KeyPath<Self, T>, initial initial: () -> T) -> T {
        get { getAssociatedValue(keyPath.stringValue, initialValue: initial) }
        set { setAssociatedValue(newValue, key: keyPath.stringValue) }
    }
    
    /// Returns the associated value for the specified key.
    public subscript<T: AnyObject>(weakAssociatedValue keyPath: KeyPath<Self, T>) -> T? {
        get { getAssociatedValue(keyPath.stringValue) }
        set { setAssociatedValue(weak: newValue, key: keyPath.stringValue) }
    }
    
    /// Returns the associated value for the specified key and sets the initial value.
    public subscript<T: AnyObject>(weakAssociatedValue keyPath: KeyPath<Self, T>, initial initial: @autoclosure () -> T) -> T {
        get { getAssociatedValue(keyPath.stringValue, weakInitialValue: initial) }
        set { setAssociatedValue(weak: newValue, key: keyPath.stringValue) }
    }
    
    /// Returns the associated value for the specified key and sets the initial value.
    public subscript<T: AnyObject>(weakAssociatedValue keyPath: KeyPath<Self, T>, initial initial: () -> T) -> T {
        get { getAssociatedValue(keyPath.stringValue, weakInitialValue: initial) }
        set { setAssociatedValue(weak: newValue, key: keyPath.stringValue) }
    }
    
    /// Returns the associated value for the specified key.
    public static subscript<T>(associatedValue keyPath: KeyPath<Self, T>) -> T? {
        get { getAssociatedValue(keyPath.stringValue) }
        set { setAssociatedValue(newValue, key: keyPath.stringValue) }
    }
    
    /// Returns the associated value for the specified key and sets the initial value.
    public static subscript<T>(associatedValue keyPath:  KeyPath<Self, T>, initial initial: @autoclosure () -> T) -> T {
        get { getAssociatedValue(keyPath.stringValue, initialValue: initial) }
        set { setAssociatedValue(newValue, key: keyPath.stringValue) }
    }
    
    /// Returns the associated value for the specified key and sets the initial value.
    public static subscript<T>(associatedValue keyPath:  KeyPath<Self, T>, initial initial: () -> T) -> T {
        get { getAssociatedValue(keyPath.stringValue, initialValue: initial) }
        set { setAssociatedValue(newValue, key: keyPath.stringValue) }
    }
    
    /// Returns the associated value for the specified key.
    public static subscript<T: AnyObject>(weakAssociatedValue keyPath: KeyPath<Self, T>) -> T? {
        get { getAssociatedValue(keyPath.stringValue) }
        set { setAssociatedValue(weak: newValue, key: keyPath.stringValue) }
    }
    
    /// Returns the associated value for the specified key and sets the initial value.
    public static subscript<T: AnyObject>(weakAssociatedValue keyPath: KeyPath<Self, T>, initial initial: @autoclosure () -> T) -> T {
        get { getAssociatedValue(keyPath.stringValue, weakInitialValue: initial) }
        set { setAssociatedValue(weak: newValue, key: keyPath.stringValue) }
    }
    
    /// Returns the associated value for the specified key and sets the initial value.
    public static subscript<T: AnyObject>(weakAssociatedValue keyPath: KeyPath<Self, T>, initial initial: () -> T) -> T {
        get { getAssociatedValue(keyPath.stringValue, weakInitialValue: initial) }
        set { setAssociatedValue(weak: newValue, key: keyPath.stringValue) }
    }
}

fileprivate class AssociatedValue {
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
