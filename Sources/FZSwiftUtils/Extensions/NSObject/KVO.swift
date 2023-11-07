//
//  KVO.swift
//
//
//  Created by Florian Zand on 07.11.23.
//

import Foundation

/// A type that is key-value codable.
protocol KVO: NSObject { }
extension NSObject: KVO { }
extension KVO {
    /// Returns the value for the derived property identified by a given key path.
    public func value<Value>(forKeyPath keyPath: KeyPath<Self, Value>) -> Value? {
        if let value = value(forKeyPath: keyPath.stringValue) {
            return value as? Value
        }
        return nil
    }
    
    /// Returns the value for the derived property identified by a given key path.
    public func value<Value>(forKeyPath keyPath: KeyPath<Self, Value?>) -> Value? {
        if let value = value(forKeyPath: keyPath.stringValue) {
            return value as? Value
        }
        return nil
    }
    
    /// Sets the value for the property identified by a given key path to a given value.
    public func setValue<Value>(_ value: Value, forKeyPath keyPath: KeyPath<Self, Value>){
        self.setValue(value, forKeyPath: keyPath.stringValue)
    }
    
    /// Sets the value for the property identified by a given key path to a given value.
    public  func setValue<Value>(_ value: Value?, forKeyPath keyPath: KeyPath<Self, Value?>){
        self.setValue(value, forKeyPath: keyPath.stringValue)
    }
}
