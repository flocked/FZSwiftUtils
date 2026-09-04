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

/// Returns the associated value for the specified key and object.
public func getAssociatedValue<V>(_ key: String, of object: AnyObject, as type: V.Type = V.self) -> V? {
    (objc_getAssociatedObject(object, key.address) as? AssociatedValue)?.value as? V
}

/// Returns the associated value for the specified key and object, or sets and returns the given initial value if no associated value exists.
public func getAssociatedValue<V>(_ key: String, of object: AnyObject, initial initialValue: @autoclosure () -> V) -> V {
    getAssociatedValue(key, of: object) ?? setAndReturn(initialValue(), for: key, of: object)
}

/// Returns the associated value for the specified key and object, or sets and returns the given initial value if it hasn't previously been initialized.
public func getAssociatedValue<V>(_ key: String, of object: AnyObject, initial initialValue: @autoclosure () -> V?) -> V? {
    setAndReturn(key, of: object, initial: initialValue)
}

/// Returns the weakly associated value for the specified key and object, or sets and returns the given initial value if no associated value exists.
public func getAssociatedValue<V: AnyObject>(_ key: String, of object: AnyObject, weakInitial initialValue: @autoclosure () -> V) -> V? {
    getAssociatedValue(key, of: object) ?? setAndReturn(weak: initialValue(), for: key, of: object)
}

/// Returns the weakly associated value for the specified key and object, or sets and returns the given initial value if it hasn't previously been initialized.
public func getAssociatedValue<V: AnyObject>(_ key: String, of object: AnyObject, weakInitial initialValue: @autoclosure () -> V?) -> V? {
    setAndReturn(key, of: object, weakInitial: initialValue)
}

/// Returns the associated value for the specified key and object, or sets and returns the value produced by the initial value closure if no associated value exists.
public func getAssociatedValue<V>(_ key: String, of object: AnyObject, initial initialValue: () -> V) -> V {
    getAssociatedValue(key, of: object) ?? setAndReturn(initialValue(), for: key, of: object)
}

/// Returns the associated value for the specified key and object, or sets and returns the value produced by the initial value closure if it hasn't previously been initialized.
public func getAssociatedValue<V>(_ key: String, of object: AnyObject, initial initialValue: () -> V?) -> V? {
    setAndReturn(key, of: object, initial: initialValue)
}

/// Returns the weakly associated value for the specified key and object, or sets and returns the value produced by the initial value closure if no associated value exists.
public func getAssociatedValue<V: AnyObject>(_ key: String, of object: AnyObject, weakInitial initialValue: () -> V) -> V? {
    getAssociatedValue(key, of: object) ?? setAndReturn(weak: initialValue(), for: key, of: object)
}

/// Returns the weakly associated value for the specified key and object, or sets and returns the value produced by the initial value closure if it hasn't previously been initialized.
public func getAssociatedValue<V: AnyObject>(_ key: String, of object: AnyObject, weakInitial initialValue: () -> V?) -> V? {
    setAndReturn(key, of: object, weakInitial: initialValue)
}

/// Sets the associated value for the specified key to the given value and returns the previous value.
@discardableResult
public func setAssociatedValue(_ value: Any?, for key: String, of object: AnyObject) -> Any? {
    let oldValue = (objc_getAssociatedObject(object, key.address) as? AssociatedValue)?.value
    objc_setAssociatedObject(object, key.address, value.map({ AssociatedValue($0) }), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return oldValue
}

/// Sets the associated value for the specified key to the given value and returns the previous value.
@discardableResult
@_disfavoredOverload
public func setAssociatedValue<V>(_ value: V?, for key: String, of object: AnyObject) -> V? {
    setAssociatedValue(value, for: key, of: object) as? V
}

/// Sets the associated value for the specified key using a weak reference and returns the previous value.
@discardableResult
public func setAssociatedValue(weak value: AnyObject?, for key: String, of object: AnyObject) -> AnyObject? {
    let oldValue = (objc_getAssociatedObject(object, key.address) as? AssociatedValue)?.value as? AnyObject
    objc_setAssociatedObject(object, key.address, value.map({ AssociatedValue(weak: $0) }), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return oldValue
}

/// Sets the associated value for the specified key using a weak reference and returns the previous value.
@discardableResult
@_disfavoredOverload
public func setAssociatedValue<V: AnyObject>(weak value: V?, for key: String, of object: AnyObject) -> V? {
    setAssociatedValue(weak: value, for: key, of: object) as? V
}

private func setAndReturn<T>(_ value: T, for key: String, of object: AnyObject) -> T {
    setAssociatedValue(value, for: key, of: object)
    return value
}

private func setAndReturn<T: AnyObject>(weak value: T, for key: String, of object: AnyObject) -> T {
    setAssociatedValue(weak: value, for: key, of: object)
    return value
}

private func setAndReturn<V>(_ key: String, of object: AnyObject, initial initialValue: ()->V?) -> V? {
    if let associatedValue = objc_getAssociatedObject(object, key.address) as? AssociatedValue {
        return associatedValue.value as? V
    }
    let value = initialValue()
    objc_setAssociatedObject(object, key.address, AssociatedValue(value), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return value
}

private func setAndReturn<V: AnyObject>(_ key: String, of object: AnyObject, weakInitial initialValue: ()->V?) -> V? {
    if let associatedValue = objc_getAssociatedObject(object, key.address) as? AssociatedValue {
        return associatedValue.value as? V
    }
    let value = initialValue()
    objc_setAssociatedObject(object, key.address, AssociatedValue(weak: value), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return value
}

public extension NSObjectProtocol where Self: NSObject {
    /// Returns the associated value for the specified key.
    func getAssociatedValue<V>(_ key: String, as type: V.Type = V.self) -> V? {
        FZSwiftUtils.getAssociatedValue(key, of: self)
    }
    
    /// Returns the associated value for the specified key, or sets and returns the given initial value if no associated value exists.
    func getAssociatedValue<V>(_ key: String, initial initialValue: @autoclosure () -> V) -> V {
        FZSwiftUtils.getAssociatedValue(key, of: self, initial: initialValue)
    }
    
    /// Returns the associated value for the specified key, or sets and returns the given initial value if it hasn't previously been initialized.
    func getAssociatedValue<V>(_ key: String, initial initialValue: @autoclosure () -> V?) -> V? {
        FZSwiftUtils.getAssociatedValue(key, of: self, initial: initialValue)
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the given initial value if no associated value exists.
    func getAssociatedValue<V: AnyObject>(_ key: String, weakInitial initialValue: @autoclosure () -> V) -> V? {
        FZSwiftUtils.getAssociatedValue(key, of: self, weakInitial: initialValue)
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the given initial value if it hasn't previously been initialized.
    func getAssociatedValue<V: AnyObject>(_ key: String, weakInitial initialValue: @autoclosure () -> V?) -> V? {
        FZSwiftUtils.getAssociatedValue(key, of: self, weakInitial: initialValue)
    }

    /// Returns the associated value for the specified key, or sets and returns the value produced by the initial value closure if no associated value exists.
    func getAssociatedValue<V>(_ key: String, initial initialValue: () -> V) -> V {
        FZSwiftUtils.getAssociatedValue(key, of: self, initial: initialValue)
    }
    
    /// Returns the associated value for the specified key, or sets and returns the value produced by the initial value closure if it hasn't previously been initialized.
    func getAssociatedValue<V>(_ key: String, initial initialValue: () -> V?) -> V? {
        FZSwiftUtils.getAssociatedValue(key, of: self, initial: initialValue)
    }

    /// Returns the weakly associated value for the specified key, or sets and returns the value produced by the initial value closure if no associated value exists.
    func getAssociatedValue<V: AnyObject>(_ key: String, weakInitial initialValue: () -> V) -> V? {
        FZSwiftUtils.getAssociatedValue(key, of: self, weakInitial: initialValue)
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the value produced by the initial value closure if it hasn't previously been initialized.
    func getAssociatedValue<V: AnyObject>(_ key: String, weakInitial initialValue: () -> V?) -> V? {
        FZSwiftUtils.getAssociatedValue(key, of: self, weakInitial: initialValue)
    }
    
    /// Sets the associated value for the specified key to the given value and returns the previous value.
    @discardableResult
    func setAssociatedValue<V>(_ value: V?, for key: String) -> V? {
        FZSwiftUtils.setAssociatedValue(value, for: key, of: self)
    }
    
    /// Sets the associated value for the specified key to the given value and returns the previous value.
    @discardableResult
    func setAssociatedValue(_ value: Any?, for key: String) -> Any? {
        FZSwiftUtils.setAssociatedValue(value, for: key, of: self)
    }
    
    /// Sets the associated value for the specified key using a weak reference and returns the previous value.
    @discardableResult
    func setAssociatedValue(weak value: AnyObject?, for key: String) -> AnyObject? {
        FZSwiftUtils.setAssociatedValue(weak: value, for: key, of: self)
    }
    
    /// Sets the associated value for the specified key using a weak reference and returns the previous value.
    @discardableResult
    func setAssociatedValue<V: AnyObject>(weak value: V?, for key: String) -> V? {
        FZSwiftUtils.setAssociatedValue(weak: value, for: key, of: self)
    }
    
    /// Returns the associated value for the specified key.
    static func getAssociatedValue<V>(_ key: String, as type: V.Type = V.self) -> V? {
        FZSwiftUtils.getAssociatedValue(key, of: self)
    }
    
    /// Returns the associated value for the specified key, or sets and returns the given initial value if no associated value exists.
    static func getAssociatedValue<V>(_ key: String, initial initialValue: @autoclosure () -> V) -> V {
        FZSwiftUtils.getAssociatedValue(key, of: self, initial: initialValue)
    }
    
    /// Returns the associated value for the specified key, or sets and returns the given initial value if it hasn't previously been initialized.
    static func getAssociatedValue<V>(_ key: String, initial initialValue: @autoclosure () -> V?) -> V? {
        FZSwiftUtils.getAssociatedValue(key, of: self, initial: initialValue)
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the given initial value if no associated value exists.
    static func getAssociatedValue<V: AnyObject>(_ key: String, weakInitial initialValue: @autoclosure () -> V) -> V? {
        FZSwiftUtils.getAssociatedValue(key, of: self, weakInitial: initialValue)
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the given initial value if it hasn't previously been initialized.
    static func getAssociatedValue<V: AnyObject>(_ key: String, weakInitial initialValue: @autoclosure () -> V?) -> V? {
        FZSwiftUtils.getAssociatedValue(key, of: self, weakInitial: initialValue)
    }

    /// Returns the associated value for the specified key, or sets and returns the value produced by the initial value closure if no associated value exists.
    static func getAssociatedValue<V>(_ key: String, initial initialValue: () -> V) -> V {
        FZSwiftUtils.getAssociatedValue(key, of: self, initial: initialValue)
    }
    
    /// Returns the associated value for the specified key, or sets and returns the value produced by the initial value closure if it hasn't previously been initialized.
    static func getAssociatedValue<V>(_ key: String, initial initialValue: () -> V?) -> V? {
        FZSwiftUtils.getAssociatedValue(key, of: self, initial: initialValue)
    }

    /// Returns the weakly associated value for the specified key, or sets and returns the value produced by the initial value closure if no associated value exists.
    static func getAssociatedValue<V: AnyObject>(_ key: String, weakInitial initialValue: () -> V) -> V? {
        FZSwiftUtils.getAssociatedValue(key, of: self, weakInitial: initialValue)
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the value produced by the initial value closure if it hasn't previously been initialized.
    static func getAssociatedValue<V: AnyObject>(_ key: String, weakInitial initialValue: () -> V?) -> V? {
        FZSwiftUtils.getAssociatedValue(key, of: self, weakInitial: initialValue)
    }
    
    /// Sets the associated value for the specified key to the given value and returns the previous value.
    @discardableResult
    static func setAssociatedValue<V>(_ value: V?, for key: String) -> V? {
        FZSwiftUtils.setAssociatedValue(value, for: key, of: self)
    }
    
    /// Sets the associated value for the specified key to the given value and returns the previous value.
    @discardableResult
    static func setAssociatedValue(_ value: Any?, for key: String) -> Any? {
        FZSwiftUtils.setAssociatedValue(value, for: key, of: self)
    }
    
    /// Sets the associated value for the specified key using a weak reference and returns the previous value.
    @discardableResult
    static func setAssociatedValue(weak value: AnyObject?, for key: String) -> AnyObject? {
        FZSwiftUtils.setAssociatedValue(weak: value, for: key, of: self)
    }
    
    /// Sets the associated value for the specified key using a weak reference and returns the previous value.
    @discardableResult
    static func setAssociatedValue<V: AnyObject>(weak value: V?, for key: String) -> V? {
        FZSwiftUtils.setAssociatedValue(weak: value, for: key, of: self)
    }
}

public extension NSObjectProtocol where Self: NSObject {
    /// Returns or sets the associated value for the specified key.
    subscript<V>(associated key: String, as type: V.Type = V.self) -> V? {
        get { getAssociatedValue(key) }
        set { setAssociatedValue(newValue, for: key) }
    }
    
    /// Returns the associated value for the specified key, or sets and returns the given initial value if no associated value exists.
    subscript<V>(associated key: String, initial initialValue: @autoclosure () -> V) -> V {
        get { getAssociatedValue(key, initial: initialValue) }
        set { setAssociatedValue(newValue, for: key) }
    }
    
    /// Returns the associated value for the specified key, or sets and returns the given initial value if it hasn't previously been initialized.
    subscript<V>(associated key: String, initial initialValue: @autoclosure () -> V?) -> V? {
        get { getAssociatedValue(key, initial: initialValue) }
        set { setAssociatedValue(newValue, for: key) }
    }
    
    /// Returns the associated value for the specified key, or sets and returns the value produced by the initial value closure if no associated value exists.
    subscript<V>(associated key: String, initial initialValue: () -> V) -> V {
        get { getAssociatedValue(key, initial: initialValue) }
        set { setAssociatedValue(newValue, for: key) }
    }
    
    /// Returns the associated value for the specified key, or sets and returns the value produced by the initial value closure if it hasn't previously been initialized.
    subscript<V>(associated key: String, initial initialValue: () -> V?) -> V? {
        get { getAssociatedValue(key, initial: initialValue) }
        set { setAssociatedValue(newValue, for: key) }
    }
    
    /// Returns or sets the weakly associated value for the specified key.
    subscript<V: AnyObject>(weakAssociated key: String, as type: V.Type = V.self) -> V? {
        get { getAssociatedValue(key) }
        set { setAssociatedValue(weak: newValue, for: key) }
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the given initial value if no associated value exists.
    subscript<V: AnyObject>(weakAssociated key: String, initial initialValue: @autoclosure () -> V) -> V? {
        get { getAssociatedValue(key, weakInitial: initialValue) }
        set { setAssociatedValue(weak: newValue, for: key) }
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the given initial value if it hasn't previously been initialized.
    subscript<V: AnyObject>(weakAssociated key: String, initial initialValue: @autoclosure () -> V?) -> V? {
        get { getAssociatedValue(key, weakInitial: initialValue) }
        set { setAssociatedValue(weak: newValue, for: key) }
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the value produced by the initial value closure if no associated value exists.
    subscript<V: AnyObject>(weakAssociated key: String, initial initialValue: () -> V) -> V? {
        get { getAssociatedValue(key, weakInitial: initialValue) }
        set { setAssociatedValue(weak: newValue, for: key) }
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the value produced by the initial value closure if it hasn't previously been initialized.
    subscript<V: AnyObject>(weakAssociated key: String, initial initialValue: () -> V?) -> V? {
        get { getAssociatedValue(key, weakInitial: initialValue) }
        set { setAssociatedValue(weak: newValue, for: key) }
    }
    
    /// Returns or sets the associated value for the specified key.
    static subscript<V>(associated key: String, as type: V.Type = V.self) -> V? {
        get { getAssociatedValue(key) }
        set { setAssociatedValue(newValue, for: key) }
    }
    
    /// Returns the associated value for the specified key, or sets and returns the given initial value if no associated value exists.
    static subscript<V>(associated key: String, initial initialValue: @autoclosure () -> V) -> V {
        get { getAssociatedValue(key, initial: initialValue) }
        set { setAssociatedValue(newValue, for: key) }
    }
    
    /// Returns the associated value for the specified key, or sets and returns the given initial value if it hasn't previously been initialized.
    static subscript<V>(associated key: String, initial initialValue: @autoclosure () -> V?) -> V? {
        get { getAssociatedValue(key, initial: initialValue) }
        set { setAssociatedValue(newValue, for: key) }
    }
    
    /// Returns the associated value for the specified key, or sets and returns the value produced by the initial value closure if no associated value exists.
    static subscript<V>(associated key: String, initial initialValue: () -> V) -> V {
        get { getAssociatedValue(key, initial: initialValue) }
        set { setAssociatedValue(newValue, for: key) }
    }
    
    /// Returns the associated value for the specified key, or sets and returns the value produced by the initial value closure if it hasn't previously been initialized.
    static subscript<V>(associated key: String, initial initialValue: () -> V?) -> V? {
        get { getAssociatedValue(key, initial: initialValue) }
        set { setAssociatedValue(newValue, for: key) }
    }
    
    /// Returns or sets the weakly associated value for the specified key.
    static subscript<V: AnyObject>(weakAssociated key: String, as type: V.Type = V.self) -> V? {
        get { getAssociatedValue(key) }
        set { setAssociatedValue(weak: newValue, for: key) }
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the given initial value if no associated value exists.
    static subscript<V: AnyObject>(weakAssociated key: String, initial initialValue: @autoclosure () -> V) -> V? {
        get { getAssociatedValue(key, weakInitial: initialValue) }
        set { setAssociatedValue(weak: newValue, for: key) }
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the given initial value if it hasn't previously been initialized.
    static subscript<V: AnyObject>(weakAssociated key: String, initial initialValue: @autoclosure () -> V?) -> V? {
        get { getAssociatedValue(key, weakInitial: initialValue) }
        set { setAssociatedValue(weak: newValue, for: key) }
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the value produced by the initial value closure if no associated value exists.
    static subscript<V: AnyObject>(weakAssociated key: String, initial initialValue: () -> V) -> V? {
        get { getAssociatedValue(key, weakInitial: initialValue) }
        set { setAssociatedValue(weak: newValue, for: key) }
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the value produced by the initial value closure if it hasn't previously been initialized.
    static subscript<V: AnyObject>(weakAssociated key: String, initial initialValue: () -> V?) -> V? {
        get { getAssociatedValue(key, weakInitial: initialValue) }
        set { setAssociatedValue(weak: newValue, for: key) }
    }
}

public extension NSObjectProtocol where Self: NSObject {
    /// Returns the associated value for the specified key.
    func getAssociatedValue<V>(_ keyPath: KeyPath<Self, V?>) -> V? {
        getAssociatedValue(keyPath.stringValue)
    }
    
    /// Returns the associated value for the specified key, or sets and returns the given initial value if no associated value exists.
    func getAssociatedValue<V>(_ keyPath: KeyPath<Self, V>, initial initialValue: @autoclosure () -> V) -> V {
        getAssociatedValue(keyPath.stringValue, initial: initialValue)
    }
    
    /// Returns the associated value for the specified key, or sets and returns the given initial value if it hasn't previously been initialized.
    func getAssociatedValue<V>(_ keyPath: KeyPath<Self, V?>, initial initialValue: @autoclosure () -> V?) -> V? {
        getAssociatedValue(keyPath.stringValue, initial: initialValue)
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the given initial value if no associated value exists.
    func getAssociatedValue<V: AnyObject>(_ keyPath: KeyPath<Self, V?>, weakInitial initialValue: @autoclosure () -> V) -> V? {
        getAssociatedValue(keyPath.stringValue, weakInitial: initialValue)
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the given initial value if it hasn't previously been initialized.
    func getAssociatedValue<V: AnyObject>(_ keyPath: KeyPath<Self, V?>, weakInitial initialValue: @autoclosure () -> V?) -> V? {
        getAssociatedValue(keyPath.stringValue, weakInitial: initialValue)
    }

    /// Returns the associated value for the specified key, or sets and returns the value produced by the initial value closure if no associated value exists.
    func getAssociatedValue<V>(_ keyPath: KeyPath<Self, V>, initial initialValue: () -> V) -> V {
        getAssociatedValue(keyPath.stringValue, initial: initialValue)
    }
    
    /// Returns the associated value for the specified key, or sets and returns the value produced by the initial value closure if it hasn't previously been initialized.
    func getAssociatedValue<V>(_ keyPath: KeyPath<Self, V?>, initial initialValue: () -> V?) -> V? {
        getAssociatedValue(keyPath.stringValue, initial: initialValue)
    }

    /// Returns the weakly associated value for the specified key, or sets and returns the value produced by the initial value closure if no associated value exists.
    func getAssociatedValue<V: AnyObject>(_ keyPath: KeyPath<Self, V?>, weakInitial initialValue: () -> V) -> V? {
        getAssociatedValue(keyPath.stringValue, weakInitial: initialValue)
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the value produced by the initial value closure if it hasn't previously been initialized.
    func getAssociatedValue<V: AnyObject>(_ keyPath: KeyPath<Self, V?>, weakInitial initialValue: () -> V?) -> V? {
        getAssociatedValue(keyPath.stringValue, weakInitial: initialValue)
    }
    
    /// Sets the associated value for the specified key to the given value and returns the previous value.
    @discardableResult
    func setAssociatedValue<V>(_ value: V, for keyPath: KeyPath<Self, V>) -> V? {
        setAssociatedValue(value, for: keyPath.stringValue)
    }
    
    /// Sets the associated value for the specified key using a weak reference and returns the previous value.
    @discardableResult
    func setAssociatedValue<V: AnyObject>(weak value: V?, for keyPath: KeyPath<Self, V?>) -> V? {
        setAssociatedValue(weak: value, for: keyPath.stringValue)
    }
    
    /// Returns the associated value for the specified key.
    static func getAssociatedValue<V>(_ keyPath: KeyPath<Self.Type, V?>) -> V? {
        getAssociatedValue(keyPath.stringValue)
    }
    
    /// Returns the associated value for the specified key, or sets and returns the given initial value if no associated value exists.
    static func getAssociatedValue<V>(_ keyPath: KeyPath<Self.Type, V>, initial initialValue: @autoclosure () -> V) -> V {
        getAssociatedValue(keyPath.stringValue, initial: initialValue)
    }
    
    /// Returns the associated value for the specified key, or sets and returns the given initial value if it hasn't previously been initialized.
    static func getAssociatedValue<V>(_ keyPath: KeyPath<Self.Type, V?>, initial initialValue: @autoclosure () -> V?) -> V? {
        getAssociatedValue(keyPath.stringValue, initial: initialValue)
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the given initial value if no associated value exists.
    static func getAssociatedValue<V: AnyObject>(_ keyPath: KeyPath<Self.Type, V?>, weakInitial initialValue: @autoclosure () -> V) -> V? {
        getAssociatedValue(keyPath.stringValue, weakInitial: initialValue)
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the given initial value if it hasn't previously been initialized.
    static func getAssociatedValue<V: AnyObject>(_ keyPath: KeyPath<Self.Type, V?>, weakInitial initialValue: @autoclosure () -> V?) -> V? {
        getAssociatedValue(keyPath.stringValue, weakInitial: initialValue)
    }

    /// Returns the associated value for the specified key, or sets and returns the value produced by the initial value closure if no associated value exists.
    static func getAssociatedValue<V>(_ keyPath: KeyPath<Self.Type, V>, initial initialValue: () -> V) -> V {
        getAssociatedValue(keyPath.stringValue, initial: initialValue)
    }
    
    /// Returns the associated value for the specified key, or sets and returns the value produced by the initial value closure if it hasn't previously been initialized.
    static func getAssociatedValue<V>(_ keyPath: KeyPath<Self.Type, V?>, initial initialValue: () -> V?) -> V? {
        getAssociatedValue(keyPath.stringValue, initial: initialValue)
    }

    /// Returns the weakly associated value for the specified key, or sets and returns the value produced by the initial value closure if no associated value exists.
    static func getAssociatedValue<V: AnyObject>(_ keyPath: KeyPath<Self.Type, V?>, weakInitial initialValue: () -> V) -> V? {
        getAssociatedValue(keyPath.stringValue, weakInitial: initialValue)
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the value produced by the initial value closure if it hasn't previously been initialized.
    static func getAssociatedValue<V: AnyObject>(_ keyPath: KeyPath<Self.Type, V?>, weakInitial initialValue: () -> V?) -> V? {
        getAssociatedValue(keyPath.stringValue, weakInitial: initialValue)
    }
    
    /// Sets the associated value for the specified key to the given value and returns the previous value.
    @discardableResult
    static func setAssociatedValue<V>(_ value: V, for keyPath: KeyPath<Self.Type, V>) -> V? {
        setAssociatedValue(value, for: keyPath.stringValue)
    }
    
    /// Sets the associated value for the specified key using a weak reference and returns the previous value.
    @discardableResult
    static func setAssociatedValue<V: AnyObject>(weak value: V?, for keyPath: KeyPath<Self.Type, V?>) -> V? {
        setAssociatedValue(weak: value, for: keyPath.stringValue)
    }
}

public extension NSObjectProtocol where Self: NSObject {
    /// Returns or sets the associated value for the specified key.
    subscript<V>(associated keyPath: KeyPath<Self, V?>) -> V? {
        get { getAssociatedValue(keyPath) }
        set { setAssociatedValue(newValue, for: keyPath) }
    }
    
    /// Returns the associated value for the specified key, or sets and returns the given initial value if no associated value exists.
    subscript<V>(associated keyPath: KeyPath<Self, V>, initial initialValue: @autoclosure () -> V) -> V {
        get { getAssociatedValue(keyPath, initial: initialValue) }
        set { setAssociatedValue(newValue, for: keyPath) }
    }
    
    /// Returns the associated value for the specified key, or sets and returns the given initial value if it hasn't previously been initialized.
    subscript<V>(associated keyPath: KeyPath<Self, V?>, initial initialValue: @autoclosure () -> V?) -> V? {
        get { getAssociatedValue(keyPath, initial: initialValue) }
        set { setAssociatedValue(newValue, for: keyPath) }
    }
    
    /// Returns the associated value for the specified key, or sets and returns the value produced by the initial value closure if no associated value exists.
    subscript<V>(associated keyPath: KeyPath<Self, V>, initial initialValue: () -> V) -> V {
        get { getAssociatedValue(keyPath, initial: initialValue) }
        set { setAssociatedValue(newValue, for: keyPath) }
    }
    
    /// Returns the associated value for the specified key, or sets and returns the value produced by the initial value closure if it hasn't previously been initialized.
    subscript<V>(associated keyPath: KeyPath<Self, V?>, initial initialValue: () -> V?) -> V? {
        get { getAssociatedValue(keyPath, initial: initialValue) }
        set { setAssociatedValue(newValue, for: keyPath) }
    }
    
    /// Returns or sets the weakly associated value for the specified key.
    subscript<V: AnyObject>(weakAssociated keyPath: KeyPath<Self, V?>) -> V? {
        get { getAssociatedValue(keyPath) }
        set { setAssociatedValue(weak: newValue, for: keyPath) }
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the given initial value if no associated value exists.
    subscript<V: AnyObject>(weakAssociated keyPath: KeyPath<Self, V?>, initial initialValue: @autoclosure () -> V) -> V? {
        get { getAssociatedValue(keyPath, weakInitial: initialValue) }
        set { setAssociatedValue(weak: newValue, for: keyPath) }
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the given initial value if it hasn't previously been initialized.
    subscript<V: AnyObject>(weakAssociated keyPath: KeyPath<Self, V?>, initial initialValue: @autoclosure () -> V?) -> V? {
        get { getAssociatedValue(keyPath, weakInitial: initialValue) }
        set { setAssociatedValue(weak: newValue, for: keyPath) }
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the value produced by the initial value closure if no associated value exists.
    subscript<V: AnyObject>(weakAssociated keyPath: KeyPath<Self, V?>, initial initialValue: () -> V) -> V? {
        get { getAssociatedValue(keyPath, weakInitial: initialValue) }
        set { setAssociatedValue(weak: newValue, for: keyPath) }
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the value produced by the initial value closure if it hasn't previously been initialized.
    subscript<V: AnyObject>(weakAssociated keyPath: KeyPath<Self, V?>, initial initialValue: () -> V?) -> V? {
        get { getAssociatedValue(keyPath, weakInitial: initialValue) }
        set { setAssociatedValue(weak: newValue, for: keyPath) }
    }
    
    /// Returns or sets the associated value for the specified key.
    static subscript<V>(associated keyPath: KeyPath<Self.Type, V?>) -> V? {
        get { getAssociatedValue(keyPath) }
        set { setAssociatedValue(newValue, for: keyPath) }
    }
    
    /// Returns the associated value for the specified key, or sets and returns the given initial value if no associated value exists.
    static subscript<V>(associated keyPath: KeyPath<Self.Type, V>, initial initialValue: @autoclosure () -> V) -> V {
        get { getAssociatedValue(keyPath, initial: initialValue) }
        set { setAssociatedValue(newValue, for: keyPath) }
    }
    
    /// Returns the associated value for the specified key, or sets and returns the given initial value if it hasn't previously been initialized.
    static subscript<V>(associated keyPath: KeyPath<Self.Type, V?>, initial initialValue: @autoclosure () -> V?) -> V? {
        get { getAssociatedValue(keyPath, initial: initialValue) }
        set { setAssociatedValue(newValue, for: keyPath) }
    }
    
    /// Returns the associated value for the specified key, or sets and returns the value produced by the initial value closure if no associated value exists.
    static subscript<V>(associated keyPath: KeyPath<Self.Type, V>, initial initialValue: () -> V) -> V {
        get { getAssociatedValue(keyPath, initial: initialValue) }
        set { setAssociatedValue(newValue, for: keyPath) }
    }
    
    /// Returns the associated value for the specified key, or sets and returns the value produced by the initial value closure if it hasn't previously been initialized.
    static subscript<V>(associated keyPath: KeyPath<Self.Type, V?>, initial initialValue: () -> V?) -> V? {
        get { getAssociatedValue(keyPath, initial: initialValue) }
        set { setAssociatedValue(newValue, for: keyPath) }
    }
    
    /// Returns or sets the weakly associated value for the specified key.
    static subscript<V: AnyObject>(weakAssociated keyPath: KeyPath<Self.Type, V?>) -> V? {
        get { getAssociatedValue(keyPath) }
        set { setAssociatedValue(weak: newValue, for: keyPath) }
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the given initial value if no associated value exists.
    static subscript<V: AnyObject>(weakAssociated keyPath: KeyPath<Self.Type, V?>, initial initialValue: @autoclosure () -> V) -> V? {
        get { getAssociatedValue(keyPath, weakInitial: initialValue) }
        set { setAssociatedValue(weak: newValue, for: keyPath) }
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the given initial value if it hasn't previously been initialized.
    static subscript<V: AnyObject>(weakAssociated keyPath: KeyPath<Self.Type, V?>, initial initialValue: @autoclosure () -> V?) -> V? {
        get { getAssociatedValue(keyPath, weakInitial: initialValue) }
        set { setAssociatedValue(weak: newValue, for: keyPath) }
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the value produced by the initial value closure if no associated value exists.
    static subscript<V: AnyObject>(weakAssociated keyPath: KeyPath<Self.Type, V?>, initial initialValue: () -> V) -> V? {
        get { getAssociatedValue(keyPath, weakInitial: initialValue) }
        set { setAssociatedValue(weak: newValue, for: keyPath) }
    }
    
    /// Returns the weakly associated value for the specified key, or sets and returns the value produced by the initial value closure if it hasn't previously been initialized.
    static subscript<V: AnyObject>(weakAssociated keyPath: KeyPath<Self.Type, V?>, initial initialValue: () -> V?) -> V? {
        get { getAssociatedValue(keyPath, weakInitial: initialValue) }
        set { setAssociatedValue(weak: newValue, for: keyPath) }
    }
}

fileprivate class AssociatedValue {
    weak var weakValue: AnyObject?
    var strongValue: Any?

    var value: Any? {
        weakValue ?? strongValue
    }

    init(_ value: Any?) {
        strongValue = value
    }

    init(weak: AnyObject?) {
        weakValue = weak
    }
    
    static let none = AssociatedValue(nil)
}

fileprivate var associatedKeys: [AnyHashable: NSObject] = [:]

fileprivate extension Hashable {
    var address: UnsafeRawPointer {
        .unretained(associatedKeys[self, default: NSObject()])
    }
}


