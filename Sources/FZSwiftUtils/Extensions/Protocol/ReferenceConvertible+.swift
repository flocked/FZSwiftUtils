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
    
    public static func _bridge(from object: _ObjectiveCType) -> Self? {
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
    public static func _bridge(from object: RawValue._ObjectiveCType) -> Self? {
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
