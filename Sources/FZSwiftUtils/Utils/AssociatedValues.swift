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

private extension String {
    var address: UnsafeRawPointer {
        return UnsafeRawPointer(bitPattern: abs(hashValue))!
    }
}

/**
 Returns the associated value for the specified object and key.
 - Parameters key: The key of the associated value.
 - Parameters object: The object of the associated value.
 - Returns: The associated value for the object and key, or nil if the value couldn't be found for the key..
 */
public func getAssociatedValue<T>(key: String, object: AnyObject) -> T? {
    return (objc_getAssociatedObject(object, key.address) as? AssociatedValue)?.value as? T
}

/**
 Returns the associated value for the specified object, key and inital value.
 - Parameters key: The key of the associated value.
 - Parameters object: The object of the associated value.
 - Parameters initialValue: The inital value of the associated value.
 - Returns: The associated value for the object and key.
 */
public func getAssociatedValue<T>(key: String, object: AnyObject, initialValue: @autoclosure () -> T) -> T {
    return getAssociatedValue(key: key, object: object) ?? setAndReturn(initialValue: initialValue(), key: key, object: object)
}

/**
 Returns the associated value for the specified object, key and inital value.
 - Parameters key: The key of the associated value.
 - Parameters object: The object of the associated value.
 - Parameters initialValue: The inital value of the associated value.
 - Returns: The associated value for the object and key.
 */
public func getAssociatedValue<T>(key: String, object: AnyObject, initialValue: () -> T) -> T {
    return getAssociatedValue(key: key, object: object) ?? setAndReturn(initialValue: initialValue(), key: key, object: object)
}

private func setAndReturn<T>(initialValue: T, key: String, object: AnyObject) -> T {
    set(associatedValue: initialValue, key: key, object: object)
    return initialValue
}

/**
 Sets a associated value for the specified object and key.
 - Parameters associatedValue: The value of the associated value.
 - Parameters key: The key of the associated value.
 - Parameters object: The object of the associated value.
 */
public func set<T>(associatedValue: T?, key: String, object: AnyObject) {
    set(associatedValue: AssociatedValue(associatedValue), key: key, object: object)
}

/**
 Sets a weak associated value for the specified object and key.
 - Parameters weakAssociatedValue: The weak value of the associated value.
 - Parameters key: The key of the associated value.
 - Parameters object: The object of the associated value.
 */
public func set<T: AnyObject>(weakAssociatedValue: T?, key: String, object: AnyObject) {
    set(associatedValue: AssociatedValue(weak: weakAssociatedValue), key: key, object: object)
}

private func set(associatedValue: AssociatedValue, key: String, object: AnyObject) {
    objc_setAssociatedObject(object, key.address, associatedValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
}

private class AssociatedValue {
    weak var _weakValue: AnyObject?
    var _value: Any?

    var value: Any? {
        return _weakValue ?? _value
    }

    init(_ value: Any?) {
        _value = value
    }

    init(weak: AnyObject?) {
        _weakValue = weak
    }
}

public extension NSObject {
    var associatedValue: AssociatedObject {
        return AssociatedObject(self)
    }
}

/// An object for getting and setting associated values of a specified object.
public class AssociatedObject {
    internal weak var object: AnyObject!
    internal init(_ object: AnyObject) {
        self.object = object
    }

    /**
     Returns the associated value for the specified key.
     - Parameters key: The key of the associated value.
     - Returns: The associated value for the key.
     */
    public func get<T>(_ key: String) -> T? {
        guard let object = object else { return nil }
        return getAssociatedValue(key: key, object: object)
    }

    /**
     Returns the associated value for the specified key and inital value.
     - Parameters key: The key of the associated value.
     - Parameters initialValue: The inital value of the associated value.
     - Returns: The associated value for the key.
     */
    public func get<T>(_ key: String, initialValue: @autoclosure () -> T) -> T {
        guard let object = object else { return initialValue() }
        return getAssociatedValue(key: key, object: object, initialValue: initialValue)
    }

    /**
     Returns the associated value for the specified key and inital value.
     - Parameters key: The key of the associated value.
     - Parameters initialValue: The inital value of the associated value.
     - Returns: The associated value for the key.
     */
    public func get<T>(_ key: String, initialValue: () -> T) -> T {
        guard let object = object else { return initialValue() }
        return getAssociatedValue(key: key, object: object, initialValue: initialValue)
    }

    /**
     Sets a value for the specified key.
     - Parameters value: The value of the associated value.
     - Parameters key: The key of the associated value.
     */
    public func set<T>(_ value: T, key: String) {
        guard let object = object else { return }
        FZSwiftUtils.set(associatedValue: value, key: key, object: object)
    }

    /**
     Sets a weak value for the specified key.
     - Parameters value: The weak value of the associated value.
     - Parameters key: The key of the associated value.
     */
    public func set<T: AnyObject>(weak value: T?, key: String) {
        guard let object = object else { return }
        FZSwiftUtils.set(weakAssociatedValue: value, key: key, object: object)
    }

    public subscript<T>(key: String, initialValue: T? = nil) -> T? {
        get {
            if let initialValue = initialValue {
                return get(key, initialValue: initialValue)
            } else {
                return get(key)
            }
        }
        set { set(newValue, key: key) }
    }
    
    public subscript<T: AnyObject>(weak key: String, initialValue: T? = nil) -> T? {
        get {
            if let initialValue = initialValue {
                return get(key, initialValue: initialValue)
            } else {
                return get(key)
            }
        }
        set { set(weak: newValue, key: key) }
    }
}
