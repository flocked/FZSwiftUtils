//
//  NSObject+KeyPath.swift
//
//
//  Created by Florian Zand on 07.11.23.
//

import Foundation

public extension NSObjectProtocol where Self: NSObject {
    /**
     Returns the value for the derived property identified by a given key path.

     - Parameter keyPath: The key path of the property.
     */
    func value<Value>(forKeyPath keyPath: KeyPath<Self, Value>) -> Value? {
        value(forKeyPath: keyPath.stringValue)
    }

    /**
     Sets the value for the property identified by a given key path to the specified value.

     - Parameters:
        - value: The new value for the property.
        - keyPath: The key path of the property.
     - Returns: The object.
     */
    @discardableResult
    func setValue<Value>(_ value: Value, forKeyPath keyPath: WritableKeyPath<Self, Value>) -> Self {
        setValue(safely: value, forKeyPath: keyPath.stringValue)
        return self
    }
    
    /// Sets the value of the specific key path and returns the object.
    @discardableResult
    func setValue<Value>(_ keyPath: ReferenceWritableKeyPath<Self, Value>, to value: Value) -> Self {
        self[keyPath: keyPath] = value
        return self
    }
}
