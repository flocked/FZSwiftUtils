//
//  ReferenceConvertible+.swift
//  
//
//  Created by Florian Zand on 14.11.25.
//

import Foundation

extension ReferenceConvertible {
    public typealias ReferenceType = __ObjectiveCBridge<Self>
    public var description: String { "" }
    public var debugDescription: String { description }
    // public var description: String { Mirror(reflecting: self).prettyDescription() }
}

extension ReferenceConvertible where Self: AnyObject {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs === rhs
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
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
        return result != nil
    }

    public static func _unconditionallyBridgeFromObjectiveC(_ source: __ObjectiveCBridge<Self>?) -> Self {
        guard let source = source else { fatalError("Unexpected nil while bridging from ObjectiveC to \(Self.self).") }
        var result: Self?
        _forceBridgeFromObjectiveC(source, result: &result)
        guard let result = result else { fatalError("Failed to bridge \(type(of: source)) to \(Self.self).") }
        return result
    }
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

extension _ObjectiveCBridgeable where Self: RawRepresentable, RawValue: _ObjectiveCBridgeable {
    public typealias _ObjectiveCType = RawValue._ObjectiveCType
    
    public func _bridgeToObjectiveC() -> RawValue._ObjectiveCType {
        rawValue._bridgeToObjectiveC()
    }
    
    public static func _forceBridgeFromObjectiveC(_ source: RawValue._ObjectiveCType, result: inout Self?) {
        var bridged: RawValue?
        RawValue._forceBridgeFromObjectiveC(source, result: &bridged)
        result = Self(rawValue: bridged!)
    }
    
    public static func _conditionallyBridgeFromObjectiveC(_ source: RawValue._ObjectiveCType, result: inout Self?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return result != nil
    }

    public static func _unconditionallyBridgeFromObjectiveC(_ source: RawValue._ObjectiveCType?) -> Self {
        guard let source = source else { fatalError("Unexpected nil while bridging from ObjectiveC to \(Self.self).") }
        var result: Self?
        _forceBridgeFromObjectiveC(source, result: &result)
        guard let result = result else { fatalError("Failed to bridge \(type(of: source)) to \(Self.self).") }
        return result
    }
}


/*
extension _ObjectiveCBridgeable where Self: AnyObject {
    public typealias _ObjectiveCType = Self

    public func _bridgeToObjectiveC() -> Self {
        self
    }

    public static func _forceBridgeFromObjectiveC(_ source: Self, result: inout Self?) {
        result = source
    }

    public static func _conditionallyBridgeFromObjectiveC(_ source: Self, result: inout Self?) -> Bool {
        result = source
        return true
    }

    public static func _unconditionallyBridgeFromObjectiveC(_ source: Self?) -> Self {
        guard let source = source else {
            fatalError("Unexpected nil while bridging from ObjectiveC to \(Self.self).")
        }
        return source
    }
}
*/
