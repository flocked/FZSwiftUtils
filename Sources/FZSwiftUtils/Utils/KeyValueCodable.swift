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
    
    /// Sets properties of the receiver with values from a given dictionary, using its keys to identify the properties.
    func setValuesForKeys(_ keyedValues: [String : Any])
    
    /// Sets the property of the receiver specified by a given key to a given value.
    func setValue(_ value: Any?, for key: String)
    
    func callSelector(_ selector: Selector, with values: [Any?])
}
