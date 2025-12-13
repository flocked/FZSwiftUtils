//
//  ReferenceConvertible+.swift
//  
//
//  Created by Florian Zand on 14.11.25.
//

import Foundation

extension ReferenceConvertible where ReferenceType == __ObjectiveCBox<Self> {
    public var debugDescription: String { description }
}

extension _ObjectiveCBridgeable where _ObjectiveCType ==  __ObjectiveCBox<Self> {
    public func _bridgeToObjectiveC() -> __ObjectiveCBox<Self> {
        __ObjectiveCBox(self)
    }

    public static func _forceBridgeFromObjectiveC(_ source: __ObjectiveCBox<Self>, result: inout Self?) {
        result = source.value
    }

    public static func _conditionallyBridgeFromObjectiveC(_ source: __ObjectiveCBox<Self>, result: inout Self?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return result != nil
    }

    public static func _unconditionallyBridgeFromObjectiveC(_ source: __ObjectiveCBox<Self>?) -> Self {
        guard let source = source else { fatalError("Unexpected nil while bridging from ObjectiveC to \(Self.self).") }
        var result: Self?
        _forceBridgeFromObjectiveC(source, result: &result)
        guard let result = result else { fatalError("Failed to bridge \(type(of: source)) to \(Self.self).") }
        return result
    }
}

public class __ObjectiveCBox<Element>: NSObject, NSCopying {
    let value: Element

    init(_ value: Element) {
        self.value = value
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        __ObjectiveCBox(value)
    }
}

/*
 /// A type that can be bridged to Objetive-C.
 public protocol ObjectiveCBridgeable: ReferenceConvertible { }

 extension ObjectiveCBridgeable {
     public typealias ReferenceType = __ObjectiveCBox<Self>
 }

 */

/*
extension _ObjectiveCBridgeable {
    public static func _conditionallyBridgeFromObjectiveC(source: _ObjectiveCType, result: inout Self?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return result != nil
    }
    
    public static func _unconditionallyBridgeFromObjectiveC(source: _ObjectiveCType?)-> Self {
        guard let source = source else { fatalError("Unexpected nil while bridging from ObjectiveC to \(Self.self).") }
        var result : Self?
        _forceBridgeFromObjectiveC(source, result: &result)
        guard let result = result else { fatalError("Failed to bridge \(type(of: source)) to \(Self.self).") }
        return result
    }
}
 */
