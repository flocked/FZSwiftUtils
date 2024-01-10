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

     - Parameter keyPath: The keypath of the property.
     */
    func value<Value>(forKeyPath keyPath: KeyPath<Self, Value>) -> Value? {
        if let value = value(forKeyPath: keyPath.stringValue) {
            return value as? Value
        }
        return nil
    }

    /**
     Returns the value for the derived property identified by a given key path.

     - Parameter keyPath: The keypath of the property.
     */
    func value<Value>(forKeyPath keyPath: KeyPath<Self, Value?>) -> Value? {
        if let value = value(forKeyPath: keyPath.stringValue) {
            return value as? Value
        }
        return nil
    }

    /**
     Sets the value for the property identified by a given key path to a given value.

     - Parameters:
        - value: The value of the property.
        - keyPath: The keypath of the property.
     */
    func setValue<Value>(_ value: Value, forKeyPath keyPath: KeyPath<Self, Value>) {
        setValue(value, forKeyPath: keyPath.stringValue)
    }

    /**
     Sets the value for the property identified by a given key path to a given value.

     - Parameters:
        - value: The value of the property.
        - keyPath: The keypath of the property.
     */
    func setValue<Value>(_ value: Value?, forKeyPath keyPath: KeyPath<Self, Value?>) {
        setValue(value, forKeyPath: keyPath.stringValue)
    }
}
