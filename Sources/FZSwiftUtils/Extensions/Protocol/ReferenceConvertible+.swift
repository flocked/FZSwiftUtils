//
//  ReferenceConvertible+.swift
//  
//
//  Created by Florian Zand on 14.11.25.
//

import Foundation

extension ReferenceConvertible {
   public typealias ReferenceType = __ObjectiveCBridge<Self>
    public var description: String { Mirror(reflecting: self).prettyDescription() }
    public var debugDescription: String { description }
}

/// Bridges a value to Objective-C.
public class __ObjectiveCBridge<Element>: NSObject, NSCopying {
    let element: Element
    
    init(_ element: Element) {
        self.element = element
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        __ObjectiveCBridge(element)
    }
}

extension _ObjectiveCBridgeable where _ObjectiveCType ==  __ObjectiveCBridge<Self> {
    public func _bridgeToObjectiveC() -> __ObjectiveCBridge<Self> {
        __ObjectiveCBridge<Self>(self)
    }
    
    public static func _forceBridgeFromObjectiveC(_ source: __ObjectiveCBridge<Self>, result: inout Self?) {
        result = source.element
    }
    
    public static func _conditionallyBridgeFromObjectiveC(_ source: __ObjectiveCBridge<Self>, result: inout Self?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }
    
    public static func _unconditionallyBridgeFromObjectiveC(_ source: __ObjectiveCBridge<Self>?) -> Self {
        var result: Self?
        _forceBridgeFromObjectiveC(source!, result: &result)
        return result!
    }
}

extension _ObjectiveCBridgeable {
    public static func _bridgeFromObjectiveC(_ source: _ObjectiveCType?) -> Self? {
        guard let source = source else { return nil }
        var result: Self?
        _forceBridgeFromObjectiveC(source, result: &result)
        return result
    }
}
