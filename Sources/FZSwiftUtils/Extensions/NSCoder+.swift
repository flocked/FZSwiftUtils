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
        encode(value.mapKeys({$0.rawValue}), forKey: key)
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
        encode(value.mapKeys({$0.rawValue._bridgeToObjectiveC()}), forKey: key)
    }
    
    /// Encodes the specified values conforming to `RawRepresentable` for the given key.
    func encode<Key, Value: RawRepresentable>(_ value: [Key: Value], forKey key: String) where Value.RawValue: NSObject & NSCoding {
        encode(value.mapValues({$0.rawValue}), forKey: key)
    }
    
    /// Encodes the specified values conforming to `RawRepresentable` for the given key.
    func encode<Key, Value: RawRepresentable>(_ value: [Key: Value], forKey key: String) where Value.RawValue: _ObjectiveCBridgeable, Value.RawValue._ObjectiveCType: NSObject & NSCoding {
        encode(value.mapValues({$0.rawValue._bridgeToObjectiveC()}), forKey: key)
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
        encode(value.mapKeys({ $0.rawValue }))
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
        encode(value.mapKeys({ $0.rawValue._bridgeToObjectiveC() }))
    }
    
    /// Encodes a dictionary with raw-representable values.
    func encode<Key, Value: RawRepresentable>(_ value: [Key: Value]) where Value.RawValue: NSObject & NSCoding {
        encode(value.mapValues({ $0.rawValue }))
    }
    
    /// Encodes a dictionary with bridged raw-representable values.
    func encode<Key, Value: RawRepresentable>(_ value: [Key: Value]) where Value.RawValue: _ObjectiveCBridgeable, Value.RawValue._ObjectiveCType: NSObject & NSCoding {
        encode(value.mapValues({ $0.rawValue._bridgeToObjectiveC() }))
    }
}

public extension NSCoder {
    /// Decodes a required object value for the specified key.
    func decode<V>(_ key: String, as type: V.Type = V.self) -> V {
        decodeIfPresent(key)!
    }
    
    /// Decodes an optional object value for the specified key.
    func decodeIfPresent<V>(_ key: String, as type: V.Type = V.self) -> V? {
        decodeObject(forKey: key) as? V
    }
    
    /// Decodes a required integer value for the specified key.
    func decode(_ key: String) -> Int {
        decodeIfPresent(key)!
    }
    
    /// Decodes an optional integer value for the specified key.
    func decodeIfPresent(_ key: String) -> Int? {
        containsValue(forKey: key) ? decodeInteger(forKey: key) : nil
    }
    
    /// Decodes a required 32-bit integer value for the specified key.
    func decode(_ key: String) -> Int32 {
        decodeIfPresent(key)!
    }
    
    /// Decodes an optional 32-bit integer value for the specified key.
    func decodeIfPresent(_ key: String) -> Int32? {
        containsValue(forKey: key) ? decodeInt32(forKey: key) : nil
    }
    
    /// Decodes a required 64-bit integer value for the specified key.
    func decode(_ key: String) -> Int64 {
        decodeIfPresent(key)!
    }
    
    /// Decodes an optional 64-bit integer value for the specified key.
    func decodeIfPresent(_ key: String) -> Int64? {
        containsValue(forKey: key) ? decodeInt64(forKey: key) : nil
    }
    
    /// Decodes a required double value for the specified key.
    func decode(_ key: String) -> Double {
        decodeIfPresent(key)!
    }
    
    /// Decodes an optional double value for the specified key.
    func decodeIfPresent(_ key: String) -> Double? {
        containsValue(forKey: key) ? decodeDouble(forKey: key) : nil
    }
    
    /// Decodes a required float value for the specified key.
    func decode(_ key: String) -> Float {
        decodeIfPresent(key)!
    }
    
    /// Decodes an optional float value for the specified key.
    func decodeIfPresent(_ key: String) -> Float? {
        containsValue(forKey: key) ? decodeFloat(forKey: key) : nil
    }
    
    /// Decodes a required Boolean value for the specified key.
    func decode(_ key: String) -> Bool {
        decodeIfPresent(key)!
    }
    
    /// Decodes an optional Boolean value for the specified key.
    func decodeIfPresent(_ key: String) -> Bool? {
        containsValue(forKey: key) ? decodeBool(forKey: key) : nil
    }
    
    /// Decodes a required point value for the specified key.
    func decode(_ key: String) -> CGPoint {
        decodeIfPresent(key)!
    }
    
    #if os(macOS)
    /// Decodes an optional point value for the specified key.
    func decodeIfPresent(_ key: String) -> CGPoint? {
        containsValue(forKey: key) ? decodePoint(forKey: key) : nil
    }
    #else
    /// Decodes an optional point value for the specified key.
    func decodeIfPresent(_ key: String) -> CGPoint? {
        containsValue(forKey: key) ? decodeCGPoint(forKey: key) : nil
    }
    #endif
    
    /// Decodes a required size value for the specified key.
    func decode(_ key: String) -> CGSize {
        decodeIfPresent(key)!
    }
    
    #if os(macOS)
    /// Decodes an optional size value for the specified key.
    func decodeIfPresent(_ key: String) -> CGSize? {
        containsValue(forKey: key) ? decodeSize(forKey: key) : nil
    }
    #else
    /// Decodes an optional size value for the specified key.
    func decodeIfPresent(_ key: String) -> CGSize? {
        containsValue(forKey: key) ? decodeCGSize(forKey: key) : nil
    }
    #endif
    
    /// Decodes a required rectangle value for the specified key.
    func decode(_ key: String) -> CGRect {
        decodeIfPresent(key)!
    }
    
    #if os(macOS)
    /// Decodes an optional rectangle value for the specified key.
    func decodeIfPresent(_ key: String) -> CGRect? {
        containsValue(forKey: key) ? decodeRect(forKey: key) : nil
    }
    #else
    /// Decodes an optional rectangle value for the specified key.
    func decodeIfPresent(_ key: String) -> CGRect? {
        containsValue(forKey: key) ? decodeCGRect(forKey: key) : nil
    }
    #endif
    
    #if os(macOS)
    /// Decodes required edge insets for the specified key.
    func decode(_ key: String) -> NSEdgeInsets {
        decodeIfPresent(key)!
    }
    
    /// Decodes optional edge insets for the specified key.
    func decodeIfPresent(_ key: String) -> NSEdgeInsets? {
        decodeIfPresent(key, as: NSEdgeInsets.self)
    }
    #else
    /// Decodes required edge insets for the specified key.
    func decode(_ key: String) -> UIEdgeInsets {
        decodeIfPresent(key)!
    }
    
    /// Decodes optional edge insets for the specified key.
    func decodeIfPresent(_ key: String) -> UIEdgeInsets? {
        decodeIfPresent(key, as: UIEdgeInsets.self)
    }
    
    /// Decodes required edge insets for the specified key.
    func decode(_ key: String) -> UIOffset {
        decodeIfPresent(key)!
    }
    
    /// Decodes optional edge insets for the specified key.
    func decodeIfPresent(_ key: String) -> UIOffset? {
        decodeIfPresent(key, as: UIOffset.self)
    }
    #endif
    
    /// Decodes a required vector value for the specified key.
    func decode(_ key: String) -> CGVector {
        decodeIfPresent(key)!
    }
    
    /// Decodes an optional vector value for the specified key.
    func decodeIfPresent(_ key: String) -> CGVector? {
        decodeIfPresent(key, as: CGVector.self)
    }
    
    /// Decodes a required raw-representable value for the specified key.
    func decode<V: RawRepresentable>(_ key: String, as type: V.Type = V.self) -> V where V.RawValue: NSObject & NSCoding {
        decodeIfPresent(key)!
    }
    
    /// Decodes an optional raw-representable value for the specified key.
    func decodeIfPresent<V: RawRepresentable>(_ key: String, as type: V.Type = V.self) -> V? where V.RawValue: NSObject & NSCoding {
        guard let rawValue = decodeObject(of: V.RawValue.self, forKey: key) else { return nil }
        return .init(rawValue: rawValue)
    }
    
    /// Decodes a required array of raw-representable values for the specified key.
    func decode<V: RawRepresentable>(_ key: String, as type: V.Type = V.self) -> [V] where V.RawValue: NSObject & NSCoding {
        decodeIfPresent(key)!
    }
    
    /// Decodes an optional array of raw-representable values for the specified key.
    func decodeIfPresent<V: RawRepresentable>(_ key: String, as type: V.Type = V.self) -> [V]? where V.RawValue: NSObject & NSCoding {
        guard let values = decodeObject(of: NSArray.self, forKey: key) as? [V.RawValue] else { return nil }
        return values.compactMap({.init(rawValue: $0)})
    }
    
    /// Decodes a required dictionary with raw-representable keys for the specified key.
    func decode<Key: RawRepresentable, Value>(_ key: String, as type: [Key: Value].Type = [Key: Value].self) -> [Key: Value] where Key.RawValue: NSObject & NSCoding {
        decodeIfPresent(key)!
    }
    
    /// Decodes an optional dictionary with raw-representable keys for the specified key.
    func decodeIfPresent<Key: RawRepresentable, Value>(_ key: String, as type: [Key: Value].Type = [Key: Value].self) -> [Key: Value]? where Key.RawValue: NSObject & NSCoding {
        guard let values = decodeObject(of: NSDictionary.self, forKey: key) as? [Key.RawValue: Value] else { return nil }
        return values.compactMapKeys({ .init(rawValue: $0) })
    }
    
    /// Decodes a required dictionary with raw-representable values for the specified key.
    func decode<Key, Value: RawRepresentable>(_ key: String, as type: [Key: Value].Type = [Key: Value].self) -> [Key: Value] where Value.RawValue: NSObject & NSCoding {
        decodeIfPresent(key)!
    }
    
    /// Decodes an optional dictionary with raw-representable values for the specified key.
    func decodeIfPresent<Key, Value: RawRepresentable>(_ key: String, as type: [Key: Value].Type = [Key: Value].self) -> [Key: Value]? where Value.RawValue: NSObject & NSCoding {
        guard let values = decodeObject(of: NSDictionary.self, forKey: key) as? [Key: Value.RawValue] else { return nil }
        return values.compactMapValues({ .init(rawValue: $0) })
    }
    
    /// Decodes a required bridged raw-representable value for the specified key.
    func decode<V: RawRepresentable>(_ key: String, as type: V.Type = V.self) -> V where V.RawValue: _ObjectiveCBridgeable, V.RawValue._ObjectiveCType: NSObject & NSCoding {
        decodeIfPresent(key)!
    }
    
    /// Decodes an optional bridged raw-representable value for the specified key.
    func decodeIfPresent<V: RawRepresentable>(_ key: String, as type: V.Type = V.self) -> V? where V.RawValue: _ObjectiveCBridgeable, V.RawValue._ObjectiveCType: NSObject & NSCoding {
        guard let value = decodeObject(of: V.RawValue._ObjectiveCType.self, forKey: key) else { return nil }
        var rawValue: V.RawValue?
        V.RawValue._forceBridgeFromObjectiveC(value, result: &rawValue)
        guard let rawValue = rawValue else { return nil }
        return .init(rawValue: rawValue)
    }
    
    /// Decodes a required dictionary with bridged raw-representable keys for the specified key.
    func decode<Key: RawRepresentable, Value>(_ key: String, as type: [Key: Value].Type = [Key: Value].self) -> [Key: Value] where Key.RawValue: _ObjectiveCBridgeable, Key.RawValue._ObjectiveCType: NSObject & NSCoding {
        decodeIfPresent(key)!
    }
    
    /// Decodes an optional dictionary with bridged raw-representable keys for the specified key.
    func decodeIfPresent<Key: RawRepresentable, Value>(_ key: String, as type: [Key: Value].Type = [Key: Value].self) -> [Key: Value]? where Key.RawValue: _ObjectiveCBridgeable, Key.RawValue._ObjectiveCType: NSObject & NSCoding {
        guard let values = decodeObject(of: NSDictionary.self, forKey: key) as? [Key.RawValue._ObjectiveCType: Value] else { return nil }
        return values.compactMapKeys({ value in
            var rawValue: Key.RawValue?
            Key.RawValue._forceBridgeFromObjectiveC(value, result: &rawValue)
            guard let rawValue = rawValue else { return nil }
            return .init(rawValue: rawValue)
        })
    }
    
    /// Decodes a required dictionary with bridged raw-representable values for the specified key.
    func decode<Key, Value: RawRepresentable>(_ key: String, as type: [Key: Value].Type = [Key: Value].self) -> [Key: Value] where Value.RawValue: _ObjectiveCBridgeable, Value.RawValue._ObjectiveCType: NSObject & NSCoding {
        decodeIfPresent(key)!
    }
    
    /// Decodes an optional dictionary with bridged raw-representable values for the specified key.
    func decodeIfPresent<Key, Value: RawRepresentable>(_ key: String, as type: [Key: Value].Type = [Key: Value].self) -> [Key: Value]? where Value.RawValue: _ObjectiveCBridgeable, Value.RawValue._ObjectiveCType: NSObject & NSCoding {
        guard let values = decodeObject(of: NSDictionary.self, forKey: key) as? [Key: Value.RawValue._ObjectiveCType] else { return nil }
        return values.compactMapValues({ value in
            var rawValue: Value.RawValue?
            Value.RawValue._forceBridgeFromObjectiveC(value, result: &rawValue)
            guard let rawValue = rawValue else { return nil }
            return .init(rawValue: rawValue)
        })
    }
}

public extension NSCoder {
    /// Decodes a required object value.
    func decode<V>(as type: V.Type = V.self) -> V {
        decodeIfPresent()!
    }
    
    /// Decodes an optional object value.
    func decodeIfPresent<V>(as type: V.Type = V.self) -> V? {
        decodeObject() as? V
    }
    
    /// Decodes a required raw-representable value.
    func decode<V: RawRepresentable>(as type: V.Type = V.self) -> V where V.RawValue: NSObject & NSCoding {
        decodeIfPresent()!
    }
    
    /// Decodes an optional raw-representable value.
    func decodeIfPresent<V: RawRepresentable>(as type: V.Type = V.self) -> V? where V.RawValue: NSObject & NSCoding {
        guard let rawValue = decodeObject() as? V.RawValue else { return nil }
        return .init(rawValue: rawValue)
    }
    
    /// Decodes a required array of raw-representable values.
    func decode<V: RawRepresentable>(as type: V.Type = V.self) -> [V] where V.RawValue: NSObject & NSCoding {
        decodeIfPresent()!
    }
    
    /// Decodes an optional array of raw-representable values.
    func decodeIfPresent<V: RawRepresentable>(as type: V.Type = V.self) -> [V]? where V.RawValue: NSObject & NSCoding {
        guard let values = decodeObject() as? [V.RawValue] else { return nil }
        return values.compactMap({ .init(rawValue: $0) })
    }
    
    /// Decodes a required dictionary with raw-representable keys.
    func decode<Key: RawRepresentable, Value>(as type: [Key: Value].Type = [Key: Value].self) -> [Key: Value] where Key.RawValue: NSObject & NSCoding {
        decodeIfPresent()!
    }
    
    /// Decodes an optional dictionary with raw-representable keys.
    func decodeIfPresent<Key: RawRepresentable, Value>(as type: [Key: Value].Type = [Key: Value].self) -> [Key: Value]? where Key.RawValue: NSObject & NSCoding {
        guard let values = decodeObject() as? [Key.RawValue: Value] else { return nil }
        return values.compactMapKeys({ .init(rawValue: $0) })
    }
    
    /// Decodes a required dictionary with raw-representable values.
    func decode<Key, Value: RawRepresentable>(as type: [Key: Value].Type = [Key: Value].self) -> [Key: Value] where Value.RawValue: NSObject & NSCoding {
        decodeIfPresent()!
    }
    
    /// Decodes an optional dictionary with raw-representable values.
    func decodeIfPresent<Key, Value: RawRepresentable>(as type: [Key: Value].Type = [Key: Value].self) -> [Key: Value]? where Value.RawValue: NSObject & NSCoding {
        guard let values = decodeObject() as? [Key: Value.RawValue] else { return nil }
        return values.compactMapValues({ .init(rawValue: $0) })
    }
    
    /// Decodes a required bridged raw-representable value.
    func decode<V: RawRepresentable>(as type: V.Type = V.self) -> V where V.RawValue: _ObjectiveCBridgeable, V.RawValue._ObjectiveCType: NSObject & NSCoding {
        decodeIfPresent()!
    }
    
    /// Decodes an optional bridged raw-representable value.
    func decodeIfPresent<V: RawRepresentable>(as type: V.Type = V.self) -> V? where V.RawValue: _ObjectiveCBridgeable, V.RawValue._ObjectiveCType: NSObject & NSCoding {
        guard let value = decodeObject() as? V.RawValue._ObjectiveCType else { return nil }
        var rawValue: V.RawValue?
        V.RawValue._forceBridgeFromObjectiveC(value, result: &rawValue)
        guard let rawValue = rawValue else { return nil }
        return .init(rawValue: rawValue)
    }
    
    /// Decodes a required dictionary with bridged raw-representable keys.
    func decode<Key: RawRepresentable, Value>(as type: [Key: Value].Type = [Key: Value].self) -> [Key: Value] where Key.RawValue: _ObjectiveCBridgeable, Key.RawValue._ObjectiveCType: NSObject & NSCoding {
        decodeIfPresent()!
    }
    
    /// Decodes an optional dictionary with bridged raw-representable keys.
    func decodeIfPresent<Key: RawRepresentable, Value>(as type: [Key: Value].Type = [Key: Value].self) -> [Key: Value]? where Key.RawValue: _ObjectiveCBridgeable, Key.RawValue._ObjectiveCType: NSObject & NSCoding {
        guard let values = decodeObject() as? [Key.RawValue._ObjectiveCType: Value] else { return nil }
        return values.compactMapKeys({ value in
            var rawValue: Key.RawValue?
            Key.RawValue._forceBridgeFromObjectiveC(value, result: &rawValue)
            guard let rawValue = rawValue else { return nil }
            return .init(rawValue: rawValue)
        })
    }
    
    /// Decodes a required dictionary with bridged raw-representable values.
    func decode<Key, Value: RawRepresentable>(as type: [Key: Value].Type = [Key: Value].self) -> [Key: Value] where Value.RawValue: _ObjectiveCBridgeable, Value.RawValue._ObjectiveCType: NSObject & NSCoding {
        decodeIfPresent()!
    }
    
    /// Decodes an optional dictionary with bridged raw-representable values.
    func decodeIfPresent<Key, Value: RawRepresentable>(as type: [Key: Value].Type = [Key: Value].self) -> [Key: Value]? where Value.RawValue: _ObjectiveCBridgeable, Value.RawValue._ObjectiveCType: NSObject & NSCoding {
        guard let values = decodeObject() as? [Key: Value.RawValue._ObjectiveCType] else { return nil }
        return values.compactMapValues({ value in
            var rawValue: Value.RawValue?
            Value.RawValue._forceBridgeFromObjectiveC(value, result: &rawValue)
            guard let rawValue = rawValue else { return nil }
            return .init(rawValue: rawValue)
        })
    }
}

public extension NSCoder {
    /// Decodes and returns a `NSDirectionalEdgeInsets` value that was previously encoded with `encode(_:)`.
    func decodeDirectionalEdgeInsets(forKey key: String) -> NSDirectionalEdgeInsets {
        decodeIfPresent(key) ?? .zero
    }
    
    /// Decodes and returns an array of `NSDirectionalEdgeInsets` values that was previously encoded with `encode(_:)`.
    func decodeDirectionalEdgeInsetsArray(forKey key: String) -> [NSDirectionalEdgeInsets] {
        decodeIfPresent(key) ?? []
    }
    
    /// Decodes and returns a `CGAffineTransform` value that was previously encoded with `encode(_:)`.
    func decodeCGAffineTransform(forKey key: String) -> CGAffineTransform {
        decodeIfPresent(key) ?? .identity
    }
    
    /// Decodes and returns an array of `CGAffineTransform` values that was previously encoded with `encode(_:)`.
    func decodeCGAffineTransforms(forKey key: String) -> [CGAffineTransform] {
        decodeIfPresent(key) ?? []
    }
    
    /// Decodes and returns a `NSRange` value that was previously encoded with `encode(_:)`.
    func decodeRange(forKey key: String) -> NSRange {
        decodeIfPresent(key) ?? .notFound
    }
    
    /// Decodes and returns an array of `NSRange` values that was previously encoded with `encode(_:)`.
    func decodeNSRanges(forKey key: String) -> [NSRange] {
        decodeIfPresent(key) ?? []
    }
    
    #if os(macOS) || os(iOS) || os(tvOS)
    /// Decodes and returns a `CATransform3D` value that was previously encoded with `encode(_:)`.
    func decodeCATransform3D(forKey key: String) -> CATransform3D {
        decodeIfPresent(key) ?? .init()
    }
    
    /// Decodes and returns an array of `CATransform3D` values that was previously encoded with `encode(_:)`.
    func decodeCATransform3Ds(forKey key: String) -> [CATransform3D] {
        decodeIfPresent(key) ?? []
    }
    
    /// Decodes and returns a `CMTime` value that was previously encoded with `encode(_:)`.
    func decodeTime(forKey key: String) -> CMTime {
        decodeIfPresent(key) ?? .zero
    }
    
    /// Decodes and returns an array of `CMTime` values that was previously encoded with `encode(_:)`.
    func decodeTimes(forKey key: String) -> [CMTime] {
        decodeIfPresent(key) ?? []
    }
    #endif

    #if os(macOS)
    /// Decodes and returns a `NSEdgeInsets` value that was previously encoded with `encode(_:)`.
    func decodeEdgeInsets(forKey key: String) -> NSEdgeInsets {
        decodeIfPresent(key) ?? .init()
    }
    
    /// Decodes and returns an array of `NSEdgeInsets` values that was previously encoded with `encode(_:)`.
    func decodeEdgeInsetsArray(forKey key: String) -> [NSEdgeInsets] {
        decodeIfPresent(key) ?? []
    }
    
    /// Decodes and returns an array of `CGPoint` values that was previously encoded with `encode(_:)`.
    func decodePoints(forKey key: String) -> [CGPoint] {
        decodeIfPresent(key) ?? []
    }
    
    /// Decodes and returns an array of `CGSize` values that was previously encoded with `encode(_:)`.
    func decodeSizes(forKey key: String) -> [CGSize] {
        decodeIfPresent(key) ?? []
    }
    
    /// Decodes and returns an array of `CGRect` values that was previously encoded with `encode(_:)`.
    func decodeRects(forKey key: String) -> [CGRect] {
        decodeIfPresent(key) ?? []
    }

    #elseif canImport(UIKit)
    /// Decodes and returns a `UIEdgeInsets` value that was previously encoded with `encode(_:)`.
    func decodeEdgeInsets(forKey key: String) -> UIEdgeInsets {
        decodeIfPresent(key) ?? .init()
    }
    
    /// Decodes and returns an array of `UIEdgeInsets` values that was previously encoded with `encode(_:)`.
    func decodeEdgeInsetsArray(forKey key: String) -> [UIEdgeInsets] {
        decodeIfPresent(key) ?? []
    }
    
    /// Decodes and returns a `CGVector` value that was previously encoded with `encode(_:)`.
    func decodeCGVector(forKey key: String) -> CGVector {
        decodeIfPresent(key) ?? .zero
    }
    
    /// Decodes and returns an array of `CGVector` values that was previously encoded with `encode(_:)`.
    func decodeCGVectors(forKey key: String) -> [CGVector] {
        decodeIfPresent(key) ?? []
    }
    
    /// Decodes and returns an array of `CGPoint` values that was previously encoded with `encode(_:)`.
    func decodePoints(forKey key: String) -> [CGPoint] {
        decodeIfPresent(key) ?? []
    }
    
    /// Decodes and returns an array of `CGSize` values that was previously encoded with `encode(_:)`.
    func decodeSizes(forKey key: String) -> [CGSize] {
        decodeIfPresent(key) ?? []
    }
    
    /// Decodes and returns an array of `CGRect` values that was previously encoded with `encode(_:)`.
    func decodeRects(forKey key: String) -> [CGRect] {
        decodeIfPresent(key) ?? []
    }
    #endif
}
