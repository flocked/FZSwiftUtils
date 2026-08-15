//
//  ReferenceConvertible+.swift
//
//
//  Created by Florian Zand on 14.11.25.
//

import Foundation

public extension _ObjectiveCBridgeable {
    static func _bridge(from object: _ObjectiveCType) -> Self? {
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

public extension RawRepresentable where RawValue: _ObjectiveCBridgeable {
    static func _bridge(from object: RawValue._ObjectiveCType) -> Self? {
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

/// A type that can be bridged to an Objective-C type.
public protocol ObjCBridgeable: ReferenceConvertible where ReferenceType == __ReferenceValue<Self> {}

/// An Objective-C type that wraps a Swift value.
public class __ReferenceValue<Value: Hashable>: NSObject, NSCopying {
    let value: Value

    init(_ value: Value) {
        self.value = value
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        self
    }

    override public func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Self else { return false }
        return self === other || value == other.value
    }

    override public var hash: Int {
        value.hashValue
    }
}

public extension ObjCBridgeable {
    func _bridgeToObjectiveC() -> ReferenceType {
        ReferenceType(self)
    }

    static func _forceBridgeFromObjectiveC(_ source: ReferenceType, result: inout Self?) {
        result = source.value
    }

    static func _conditionallyBridgeFromObjectiveC(_ source: ReferenceType, result: inout Self?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }

    static func _unconditionallyBridgeFromObjectiveC(_ source: ReferenceType?) -> Self {
        guard let source else {
            fatalError("Unable to bridge \(ReferenceType.self) to \(Self.self)")
        }
        return source.value
    }

    var debugDescription: String {
        description
    }
}
