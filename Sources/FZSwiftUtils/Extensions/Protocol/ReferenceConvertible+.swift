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

extension _ObjectiveCBridgeable where Self: RawRepresentable, RawValue: BinaryInteger {
    public typealias _ObjectiveCType = NSNumber
    
    public func _bridgeToObjectiveC() -> NSNumber {
        NSNumber(rawValue)
    }

    public static func _forceBridgeFromObjectiveC(_ source: NSNumber, result: inout Self?) {
        result = .init(rawValue: source.binaryInteger())
    }

    public static func _conditionallyBridgeFromObjectiveC(_ source: NSNumber, result: inout Self?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return result != nil
    }

    public static func _unconditionallyBridgeFromObjectiveC(_ source: NSNumber?) -> Self {
        guard let source = source else { fatalError("Unexpected nil while bridging from ObjectiveC to \(Self.self).") }
        var result: Self?
        _forceBridgeFromObjectiveC(source, result: &result)
        guard let result = result else { fatalError("Failed to bridge \(type(of: source)) to \(Self.self).") }
        return result
    }
}

extension _ObjectiveCBridgeable where Self: RawRepresentable, RawValue: BinaryFloatingPoint {
    public typealias _ObjectiveCType = NSNumber

    
    public func _bridgeToObjectiveC() -> NSNumber {
        NSNumber(rawValue)
    }

    public static func _forceBridgeFromObjectiveC(_ source: NSNumber, result: inout Self?) {
        result = .init(rawValue: source.binaryFloatingPoint())
    }

    public static func _conditionallyBridgeFromObjectiveC(_ source: NSNumber, result: inout Self?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return result != nil
    }

    public static func _unconditionallyBridgeFromObjectiveC(_ source: NSNumber?) -> Self {
        guard let source = source else { fatalError("Unexpected nil while bridging from ObjectiveC to \(Self.self).") }
        var result: Self?
        _forceBridgeFromObjectiveC(source, result: &result)
        guard let result = result else { fatalError("Failed to bridge \(type(of: source)) to \(Self.self).") }
        return result
    }
}

extension _ObjectiveCBridgeable where Self: RawRepresentable, RawValue == String {
    public typealias _ObjectiveCType = NSString
    
    public func _bridgeToObjectiveC() -> NSString {
        rawValue as NSString
    }

    public static func _forceBridgeFromObjectiveC(_ source: NSString, result: inout Self?) {
        result = .init(rawValue: source as String)
    }

    public static func _conditionallyBridgeFromObjectiveC(_ source: NSString, result: inout Self?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return result != nil
    }

    public static func _unconditionallyBridgeFromObjectiveC(_ source: NSString?) -> Self {
        guard let source = source else { fatalError("Unexpected nil while bridging from ObjectiveC to \(Self.self).") }
        var result: Self?
        _forceBridgeFromObjectiveC(source, result: &result)
        guard let result = result else { fatalError("Failed to bridge \(type(of: source)) to \(Self.self).") }
        return result
    }
}

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

fileprivate extension NSNumber {
    func binaryInteger<Value: BinaryInteger>() -> Value {
        // If the target integer type is signed, use int64Value.
        if Value.isSigned {
            return Value(self.int64Value)
        } else {
            return Value(self.uint64Value)
        }
    }

    func binaryFloatingPoint<Value: BinaryFloatingPoint>() -> Value {
        // doubleValue is the most precise bridge NSNumber exposes.
        return Value(self.doubleValue)
    }
}
