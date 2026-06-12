//
//  ReferenceConvertible+.swift
//  
//
//  Created by Florian Zand on 14.11.25.
//

import Foundation

extension _ObjectiveCBridgeable {
    /// The bridged Objective-C type.
    public static var _ObjectiveCClass: AnyClass {
        _ObjectiveCType.self
    }
    
    public static func bridge(from object: _ObjectiveCType) -> Self? {
        var value: Self?
        Self._forceBridgeFromObjectiveC(object, result: &value)
        guard let value = value else { return nil }
        return value
    }
    
    /*
     public init?(_ object: _ObjectiveCType) {
         var value: Self?
         Self._forceBridgeFromObjectiveC(object, result: &value)
         guard let value = value else { return nil }
         self = value
     }
     */
}

extension RawRepresentable where RawValue: _ObjectiveCBridgeable {
    public static func bridge(from object: RawValue._ObjectiveCType) -> Self? {
        var rawValue: RawValue?
        RawValue._forceBridgeFromObjectiveC(object, result: &rawValue)
        guard let rawValue = rawValue else { return nil }
        return Self(rawValue: rawValue)
    }
    
    /*
     public init?(_ object: RawValue._ObjectiveCType) {
         var rawValue: RawValue?
         RawValue._forceBridgeFromObjectiveC(object, result: &rawValue)
         guard let rawValue = rawValue, let value = Self(rawValue: rawValue) else { return nil }
         self = value
     }
     */
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
