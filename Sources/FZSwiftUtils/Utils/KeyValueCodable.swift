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
    
    /// Calls the selector with the name and values.
    func call(_ name: String, values: [Any?])
    
}

public extension KeyValueCodable {
    func value(for key: String) -> Any? {
        return nil
    }
    
    func setValue(_ value: Any?, for key: String) {
        
    }
    
    func call(_ name: String, values: [Any]) {
    }
}
