//
//  AssociatedValue.swift
//
//  From github.com/bradhilton/AssociatedValues
//  Created by Skyvive
//

import Foundation
import ObjectiveC.runtime

fileprivate extension String {
     var address: UnsafeRawPointer {
        return UnsafeRawPointer(bitPattern: abs(hashValue))!
    }
}

public func getAssociatedValue<T>(key: String, object: AnyObject) -> T? {
    return (objc_getAssociatedObject(object, key.address) as? AssociatedValue)?.value as? T
}

public func getAssociatedValue<T>(key: String, object: AnyObject, initialValue: @autoclosure () -> T) -> T {
    return getAssociatedValue(key: key, object: object) ?? setAndReturn(initialValue: initialValue(), key: key, object: object)
}

public func getAssociatedValue<T>(key: String, object: AnyObject, initialValue: () -> T) -> T {
    return getAssociatedValue(key: key, object: object) ?? setAndReturn(initialValue: initialValue(), key: key, object: object)
}

fileprivate func setAndReturn<T>(initialValue: T, key: String, object: AnyObject) -> T {
    set(associatedValue: initialValue, key: key, object: object)
    return initialValue
}

public func set<T>(associatedValue: T?, key: String, object: AnyObject) {
    set(associatedValue: AssociatedValue(associatedValue), key: key, object: object)
}

public func set<T : AnyObject>(weakAssociatedValue: T?, key: String, object: AnyObject) {
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

public class AssociatedObject {
    internal weak var object: AnyObject!
    internal init(_ object: AnyObject) {
        self.object = object
    }
    
    public func get<T>(_ key: String) -> T? {
        guard let object = object else { return nil}
        return getAssociatedValue(key: key, object: object)
    }
    
    public func get<T>(_ key: String, initialValue:  @autoclosure () -> T) -> T {
        return getAssociatedValue(key: key, object: object, initialValue: initialValue)
    }
    
    public func get<T>(_ key: String, initialValue: () -> T) -> T {
        return getAssociatedValue(key: key, object: object, initialValue: initialValue)
    }
        
    public func set<T>(_ value: T, key: String) {
        guard let object = object else { return }
        FZSwiftUtils.set(associatedValue: value, key: key, object: object)
    }
    
    public func set<T: AnyObject>(weak value: T?, key: String) {
        guard let object = object else { return }
        FZSwiftUtils.set(weakAssociatedValue: value, key: key, object: object)
    }
    
    public subscript<T>(key: String, initialValue: T? = nil) -> T?  {
        get {
            if let initialValue = initialValue {
                return get(key, initialValue: initialValue)
            } else {
                return get(key)
            }
        }
        set {  set(newValue, key: key) }
    }
}
