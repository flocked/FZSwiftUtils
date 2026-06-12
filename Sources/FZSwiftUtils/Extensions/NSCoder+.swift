//
//  NSCoder+.swift
//
//
//  Created by Florian Zand on 28.02.25.
//

import Foundation
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import CoreMedia

public extension NSCoder {
    /// Encodes the specified values conforming to `RawRepresentable` for the given key.
    func encode<V: RawRepresentable>(_ value: V, forKey key: String) where V.RawValue: NSObject & NSCoding {
        encode(value.rawValue, forKey: key)
    }
    
    /// Encodes the specified values conforming to `RawRepresentable` for the given key.
    func encode<V: RawRepresentable>(_ values: [V], forKey key: String) where V.RawValue: NSObject & NSCoding {
        encode(values.map(\.rawValue) as NSArray, forKey: key)
    }
    
    /// Encodes the specified values conforming to `RawRepresentable` for the given key.
    func encode<Key: RawRepresentable & Hashable, Value>(_ value: [Key: Value], forKey key: String) where Key.RawValue: NSObject & NSCoding {
        encode(value.mapKeys { $0.rawValue }, forKey: key)
    }
    
    /// Encodes the specified value conforming to `RawRepresentable` for the given key.
    func encode<V: RawRepresentable>(_ value: V, forKey key: String) where V.RawValue: _ObjectiveCBridgeable, V.RawValue._ObjectiveCType: NSObject & NSCoding {
        encode(value.rawValue._bridgeToObjectiveC(), forKey: key)
    }
    
    /// Encodes the specified values conforming to `RawRepresentable` for the given key.
    func encode<V: RawRepresentable>(_ values: [V], forKey key: String) where V.RawValue: _ObjectiveCBridgeable, V.RawValue._ObjectiveCType: NSObject & NSCoding {
        encode(values.map(\.rawValue) as NSArray, forKey: key)
    }
    
    /// Encodes the specified values conforming to `RawRepresentable` for the given key.
    func encode<Key: RawRepresentable & Hashable, Value>(_ value: [Key: Value], forKey key: String) where Key.RawValue: _ObjectiveCBridgeable, Key.RawValue._ObjectiveCType: NSObject & NSCoding {
        encode(value.mapKeys { $0.rawValue._bridgeToObjectiveC() }, forKey: key)
    }
    
    /// Encodes the specified values conforming to `RawRepresentable` for the given key.
    func encode<Key, Value: RawRepresentable>(_ value: [Key: Value], forKey key: String) where Value.RawValue: NSObject & NSCoding {
        encode(value.mapValues { $0.rawValue }, forKey: key)
    }
    
    /// Encodes the specified values conforming to `RawRepresentable` for the given key.
    func encode<Key, Value: RawRepresentable>(_ value: [Key: Value], forKey key: String) where Value.RawValue: _ObjectiveCBridgeable, Value.RawValue._ObjectiveCType: NSObject & NSCoding {
        encode(value.mapValues { $0.rawValue._bridgeToObjectiveC() }, forKey: key)
    }
}

public extension NSCoder {
    /// Encodes a raw-representable value.
    func encode<V: RawRepresentable>(_ value: V) where V.RawValue: NSObject & NSCoding {
        encode(value.rawValue)
    }
    
    /// Encodes an array of raw-representable values.
    func encode<V: RawRepresentable>(_ values: [V]) where V.RawValue: NSObject & NSCoding {
        encode(values.map(\.rawValue) as NSArray)
    }
    
    /// Encodes a dictionary with raw-representable keys.
    func encode<Key: RawRepresentable & Hashable, Value>(_ value: [Key: Value]) where Key.RawValue: NSObject & NSCoding {
        encode(value.mapKeys { $0.rawValue })
    }
    
    /// Encodes a bridged raw-representable value.
    func encode<V: RawRepresentable>(_ value: V) where V.RawValue: _ObjectiveCBridgeable, V.RawValue._ObjectiveCType: NSObject & NSCoding {
        encode(value.rawValue._bridgeToObjectiveC())
    }
    
    /// Encodes an array of bridged raw-representable values.
    func encode<V: RawRepresentable>(_ values: [V]) where V.RawValue: _ObjectiveCBridgeable, V.RawValue._ObjectiveCType: NSObject & NSCoding {
        encode(values.map(\.rawValue) as NSArray)
    }
    
    /// Encodes a dictionary with bridged raw-representable keys.
    func encode<Key: RawRepresentable & Hashable, Value>(_ value: [Key: Value]) where Key.RawValue: _ObjectiveCBridgeable, Key.RawValue._ObjectiveCType: NSObject & NSCoding {
        encode(value.mapKeys { $0.rawValue._bridgeToObjectiveC() })
    }
    
    /// Encodes a dictionary with raw-representable values.
    func encode<Key, Value: RawRepresentable>(_ value: [Key: Value]) where Value.RawValue: NSObject & NSCoding {
        encode(value.mapValues { $0.rawValue })
    }
    
    /// Encodes a dictionary with bridged raw-representable values.
    func encode<Key, Value: RawRepresentable>(_ value: [Key: Value]) where Value.RawValue: _ObjectiveCBridgeable, Value.RawValue._ObjectiveCType: NSObject & NSCoding {
        encode(value.mapValues { $0.rawValue._bridgeToObjectiveC() })
    }
}

public extension NSCoder {
    /// Decodes an optional object value for the specified key.
    func decode<V>(_ key: String, as type: V.Type = V.self) -> V? {
        decodeObject(forKey: key) as? V
    }
    
    /// Decodes an optional integer value for the specified key.
    func decode(_ key: String) -> Int? {
        containsValue(forKey: key) ? decodeInteger(forKey: key) : nil
    }
    
    /// Decodes an optional 32-bit integer value for the specified key.
    func decode(_ key: String) -> Int32? {
        containsValue(forKey: key) ? decodeInt32(forKey: key) : nil
    }
    
    /// Decodes an optional 64-bit integer value for the specified key.
    func decode(_ key: String) -> Int64? {
        containsValue(forKey: key) ? decodeInt64(forKey: key) : nil
    }
    
    /// Decodes an optional double value for the specified key.
    func decode(_ key: String) -> Double? {
        containsValue(forKey: key) ? decodeDouble(forKey: key) : nil
    }
    
    /// Decodes an optional float value for the specified key.
    func decode(_ key: String) -> Float? {
        containsValue(forKey: key) ? decodeFloat(forKey: key) : nil
    }
    
    /// Decodes an optional Boolean value for the specified key.
    func decode(_ key: String) -> Bool? {
        containsValue(forKey: key) ? decodeBool(forKey: key) : nil
    }
    
    /// Decodes an optional point value for the specified key.
    func decode(_ key: String) -> CGPoint? {
        decode(key, as: CGPoint.self)
    }
    
    /// Decodes an optional size value for the specified key.
    func decode(_ key: String) -> CGSize? {
        decode(key, as: CGSize.self)
    }
    
    /// Decodes an optional rectangle value for the specified key.
    func decode(_ key: String) -> CGRect? {
        decode(key, as: CGRect.self)
    }
    
    #if os(macOS)
    /// Decodes optional edge insets for the specified key.
    func decode(_ key: String) -> NSEdgeInsets? {
        decode(key, as: NSEdgeInsets.self)
    }
    #else
    /// Decodes optional edge insets for the specified key.
    func decode(_ key: String) -> UIEdgeInsets? {
        decode(key, as: UIEdgeInsets.self)
    }
    
    /// Decodes an optional offset value for the specified key.
    func decode(_ key: String) -> UIOffset? {
        decode(key, as: UIOffset.self)
    }
    #endif
    
    /// Decodes an optional vector value for the specified key.
    func decode(_ key: String) -> CGVector? {
        decode(key, as: CGVector.self)
    }
    
    /// Decodes an optional raw-representable value for the specified key.
    func decode<V: RawRepresentable>(_ key: String, as type: V.Type = V.self) -> V? where V.RawValue: NSObject & NSCoding {
        guard let rawValue = decodeObject(of: V.RawValue.self, forKey: key) else { return nil }
        return .init(rawValue: rawValue)
    }
    
    /// Decodes an optional array of raw-representable values for the specified key.
    func decode<V: RawRepresentable>(_ key: String, as type: V.Type = V.self) -> [V]? where V.RawValue: NSObject & NSCoding {
        guard let values = decodeObject(of: NSArray.self, forKey: key) as? [V.RawValue] else { return nil }
        return values.compactMap { .init(rawValue: $0) }
    }
    
    /// Decodes an optional dictionary with raw-representable keys for the specified key.
    func decode<Key: RawRepresentable, Value>(_ key: String, as type: [Key: Value].Type = [Key: Value].self) -> [Key: Value]? where Key.RawValue: NSObject & NSCoding {
        guard let values = decodeObject(of: NSDictionary.self, forKey: key) as? [Key.RawValue: Value] else { return nil }
        return values.compactMapKeys { .init(rawValue: $0) }
    }
    
    /// Decodes an optional dictionary with raw-representable values for the specified key.
    func decode<Key, Value: RawRepresentable>(_ key: String, as type: [Key: Value].Type = [Key: Value].self) -> [Key: Value]? where Value.RawValue: NSObject & NSCoding {
        guard let values = decodeObject(of: NSDictionary.self, forKey: key) as? [Key: Value.RawValue] else { return nil }
        return values.compactMapValues { .init(rawValue: $0) }
    }
    
    /// Decodes an optional bridged raw-representable value for the specified key.
    func decode<V: RawRepresentable>(_ key: String, as type: V.Type = V.self) -> V? where V.RawValue: _ObjectiveCBridgeable, V.RawValue._ObjectiveCType: NSObject & NSCoding {
        guard let value = decodeObject(of: V.RawValue._ObjectiveCType.self, forKey: key) else { return nil }
        return .bridge(from: value)
    }
    
    /// Decodes an optional dictionary with bridged raw-representable keys for the specified key.
    func decode<Key: RawRepresentable, Value>(_ key: String, as type: [Key: Value].Type = [Key: Value].self) -> [Key: Value]? where Key.RawValue: _ObjectiveCBridgeable, Key.RawValue._ObjectiveCType: NSObject & NSCoding {
        guard let values = decodeObject(of: NSDictionary.self, forKey: key) as? [Key.RawValue._ObjectiveCType: Value] else { return nil }
        return values.compactMapKeys { .bridge(from: $0) }
    }
    
    /// Decodes an optional dictionary with bridged raw-representable values for the specified key.
    func decode<Key, Value: RawRepresentable>(_ key: String, as type: [Key: Value].Type = [Key: Value].self) -> [Key: Value]? where Value.RawValue: _ObjectiveCBridgeable, Value.RawValue._ObjectiveCType: NSObject & NSCoding {
        guard let values = decodeObject(of: NSDictionary.self, forKey: key) as? [Key: Value.RawValue._ObjectiveCType] else { return nil }
        return values.compactMapValues { .bridge(from: $0) }
    }
}

public extension NSCoder {
    /// Decodes an optional object value.
    func decode<V>(as type: V.Type = V.self) -> V? {
        decodeObject() as? V
    }
    
    /// Decodes an optional raw-representable value.
    func decode<V: RawRepresentable>(as type: V.Type = V.self) -> V? where V.RawValue: NSObject & NSCoding {
        guard let rawValue = decodeObject() as? V.RawValue else { return nil }
        return .init(rawValue: rawValue)
    }
    
    /// Decodes an optional array of raw-representable values.
    func decode<V: RawRepresentable>(as type: V.Type = V.self) -> [V]? where V.RawValue: NSObject & NSCoding {
        guard let values = decodeObject() as? [V.RawValue] else { return nil }
        return values.compactMap { .init(rawValue: $0) }
    }
    
    /// Decodes an optional dictionary with raw-representable keys.
    func decode<Key: RawRepresentable, Value>(as type: [Key: Value].Type = [Key: Value].self) -> [Key: Value]? where Key.RawValue: NSObject & NSCoding {
        guard let values = decodeObject() as? [Key.RawValue: Value] else { return nil }
        return values.compactMapKeys { .init(rawValue: $0) }
    }
    
    /// Decodes an optional dictionary with raw-representable values.
    func decode<Key, Value: RawRepresentable>(as type: [Key: Value].Type = [Key: Value].self) -> [Key: Value]? where Value.RawValue: NSObject & NSCoding {
        guard let values = decodeObject() as? [Key: Value.RawValue] else { return nil }
        return values.compactMapValues { .init(rawValue: $0) }
    }
    
    /// Decodes an optional bridged raw-representable value.
    func decode<V: RawRepresentable>(as type: V.Type = V.self) -> V? where V.RawValue: _ObjectiveCBridgeable, V.RawValue._ObjectiveCType: NSObject & NSCoding {
        guard let value = decodeObject() as? V.RawValue._ObjectiveCType else { return nil }
        return .bridge(from: value)
    }
    
    /// Decodes an optional dictionary with bridged raw-representable keys.
    func decode<Key: RawRepresentable, Value>(as type: [Key: Value].Type = [Key: Value].self) -> [Key: Value]? where Key.RawValue: _ObjectiveCBridgeable, Key.RawValue._ObjectiveCType: NSObject & NSCoding {
        guard let values = decodeObject() as? [Key.RawValue._ObjectiveCType: Value] else { return nil }
        return values.compactMapKeys { .bridge(from: $0) }
    }
    
    /// Decodes an optional dictionary with bridged raw-representable values.
    func decode<Key, Value: RawRepresentable>(as type: [Key: Value].Type = [Key: Value].self) -> [Key: Value]? where Value.RawValue: _ObjectiveCBridgeable, Value.RawValue._ObjectiveCType: NSObject & NSCoding {
        guard let values = decodeObject() as? [Key: Value.RawValue._ObjectiveCType] else { return nil }
        return values.compactMapValues { .bridge(from: $0) }
    }
}

public extension NSCoder {
    /// Decodes and returns a `NSRange` value that was previously encoded with `encode(_:)`.
    func decodeRange(forKey key: String) -> NSRange {
        decode(key) ?? .notFound
    }
    
    #if os(macOS) || os(iOS) || os(tvOS)
    /// Decodes and returns a `CATransform3D` value that was previously encoded with `encode(_:)`.
    func decodeCATransform3D(forKey key: String) -> CATransform3D {
        decode(key) ?? .init()
    }
    #endif

    #if os(macOS)
    /// Decodes and returns a `NSDirectionalEdgeInsets` value that was previously encoded with `encode(_:)`.
    func decodeDirectionalEdgeInsets(forKey key: String) -> NSDirectionalEdgeInsets {
        decode(key) ?? .zero
    }
    
    /// Decodes and returns a `CGAffineTransform` value that was previously encoded with `encode(_:)`.
    func decodeCGAffineTransform(forKey key: String) -> CGAffineTransform {
        decode(key) ?? .identity
    }
    
    /// Decodes and returns a `NSEdgeInsets` value that was previously encoded with `encode(_:)`.
    func decodeEdgeInsets(forKey key: String) -> NSEdgeInsets {
        decode(key) ?? .init()
    }
    
    /// Decodes and returns a `CMTime` value that was previously encoded with `encode(_:)`.
    func decodeTime(forKey key: String) -> CMTime {
        decode(key) ?? .zero
    }
    #endif
}
