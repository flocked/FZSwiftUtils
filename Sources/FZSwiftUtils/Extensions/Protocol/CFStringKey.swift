//
//  CFStringKey.swift
//
//
//  Created by Florian Zand on 02.11.25.
//

import Foundation

/// A  type that can be represented by a `CFString`
public protocol CFStringKey: RawRepresentable, ReferenceConvertible, ExpressibleByStringLiteral where RawValue == CFString, ReferenceType == NSString {
    init(_ key: CFString)
}

public extension CFStringKey {
    init(rawValue: CFString) {
        self.init(rawValue)
    }
    
    init(stringLiteral value: String) {
        self.init(value as CFString)
    }
    
    func _bridgeToObjectiveC() -> NSString {
        rawValue
    }
    
    static func _forceBridgeFromObjectiveC(_ source: NSString, result: inout Self?) {
        result = Self(source)
    }
    
    static func _conditionallyBridgeFromObjectiveC(_ source: NSString, result: inout Self?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }
    
    static func _unconditionallyBridgeFromObjectiveC(_ source: NSString?) -> Self {
        var result: Self?
        _forceBridgeFromObjectiveC(source!, result: &result)
        return result!
    }
    
    func _bridgeToCF() -> CFString {
        return rawValue
    }
    
    static func _bridgeFromCF(_ source: CFString) -> Self {
        return Self(source)
    }
    
    var description: String {
        "\(self)"
    }
    
    var debugDescription: String {
        "\(self)"
    }
}
