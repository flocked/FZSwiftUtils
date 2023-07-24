//
//  File.swift
//  
//
//  Created by Florian Zand on 24.07.23.
//

import Foundation

public protocol KeyValueCodable {
    /// Returns the value for the property identified by a given key.
    func value(for key: String) -> Any?
        
    /// Sets the property of the receiver specified by a given key to a given value.
    func setValue(_ value: Any?, for key: String)
    
    /// Calls the selector with the specified name and values and returns its result.
    @discardableResult
    func call(_ name: String, values: [Any?]) -> Any?
    
}

public extension KeyValueCodable {
    func value(for key: String) -> Any? {
        return nil
    }
    
    func value<V>(for key: String) -> V? {
        return self.value(for: key) as? V
    }
    
    func setValue(_ value: Any?, for key: String) {
        
    }
    
    @discardableResult
    func call(_ name: String, values: [Any?]) -> Any? {
        return nil
    }
    
    func call<V>(_ name: String, values: [Any?]) -> V? {
        return self.call(name, values: values) as? V
    }
}
