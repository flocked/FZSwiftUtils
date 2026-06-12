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
    /// Encodes an object and associates it with the string key.
    func encode<T: _ObjectiveCBridgeable>(_ value: T, forKey key: String) where T._ObjectiveCType: NSObject, T._ObjectiveCType: NSCoding {
        encode(T._bridgeToObjectiveC(value), forKey: key)
    }
    
    func encode<T: _ObjectiveCBridgeable>(_ values: [T], forKey key: String) where T._ObjectiveCType: NSObject, T._ObjectiveCType: NSCoding {
        encode(values.map { T._bridgeToObjectiveC($0) }, forKey: key)
    }
    
    /**
     Decode an object as an expected type, failing if the archived type doesn’t match.
     
     If the coder responds `true` to `requiresSecureCoding`, then the coder calls `failWithError(_:)` in either of the following cases:
     - The class indicated by `DecodedObjectType` doesn’t implement `NSSecureCoding`.
     - The unarchived class doesn’t match `DecodedObjectType`, nor do any of its superclasses.
     
     If the coder doesn’t require secure coding, it ignores the cls parameter and does not check the decoded object.
     
     - Parameter key: The key indicating the member to decode.
     
     - Returns: The decoded object, or `nil` if decoding fails.
     */
    func decode<DecodedObjectType: NSObject & NSCoding>(forKey key: String) -> DecodedObjectType? {
        decodeObject(of: DecodedObjectType.self, forKey: key)
    }
    
    /**
     Decode an object as an expected type, failing if the archived type doesn’t match.
     
     If the coder responds `true` to `requiresSecureCoding`, then the coder calls `failWithError(_:)` in either of the following cases:
     - The class indicated by `DecodedObjectType` doesn’t implement `NSSecureCoding`.
     - The unarchived class doesn’t match `DecodedObjectType`, nor do any of its superclasses.
     
     If the coder doesn’t require secure coding, it ignores the cls parameter and does not check the decoded object.
     
     - Parameter key: The key indicating the member to decode.
     
     - Returns: The decoded object, or `nil` if decoding fails.
     */
    func decode<DecodedObjectType: _ObjectiveCBridgeable>(forKey key: String) -> DecodedObjectType? where DecodedObjectType._ObjectiveCType: NSObject, DecodedObjectType._ObjectiveCType: NSCoding {
        guard let obj: DecodedObjectType._ObjectiveCType = decode(forKey: key) else { return nil }
        var result: DecodedObjectType?
        DecodedObjectType._forceBridgeFromObjectiveC(obj, result: &result)
        return result
    }
    
    /**
     Decode an object as an expected type, failing if the archived type doesn’t match.
     
     If the coder responds `true` to `requiresSecureCoding`, then the coder calls `failWithError(_:)` in either of the following cases:
     - The class indicated by `cls` doesn’t implement `NSSecureCoding`.
     - The unarchived class doesn’t match `cls`, nor do any of its superclasses.
     
     If the coder doesn’t require secure coding, it ignores the cls parameter and does not check the decoded object.
     
     - Parameters:
        - cls: The expected class of the object being decoded.
        - key: The key indicating the member to decode.
     
     - Returns: The decoded object, or `nil` if decoding fails.
     */
    func decodeObject<DecodedObjectType: _ObjectiveCBridgeable>(of cls: DecodedObjectType.Type, forKey key: String) -> DecodedObjectType? where DecodedObjectType._ObjectiveCType: NSObject, DecodedObjectType._ObjectiveCType: NSCoding {
        decode(forKey: key)
    }
    
    /// Decodes and returns a `NSDirectionalEdgeInsets` value that was previously encoded with `encode(_:)`.
    func decodeDirectionalEdgeInsets(forKey key: String) -> NSDirectionalEdgeInsets {
        decodeObject(of: NSValue.self, forKey: key)?.directionalEdgeInsetsValue ?? .init()
    }
    
    /// Decodes and returns an array of `NSDirectionalEdgeInsets` values that was previously encoded with `encode(_:)`.
    func decodeDirectionalEdgeInsetsArray(forKey key: String) -> [NSDirectionalEdgeInsets] {
        (decodeObject(forKey: key) as? [NSValue])?.map { $0.directionalEdgeInsetsValue } ?? []
    }
    
    /// Decodes and returns a `CGAffineTransform` value that was previously encoded with `encode(_:)`.
    func decodeCGAffineTransform(forKey key: String) -> CGAffineTransform {
        decodeObject(of: NSValue.self, forKey: key)?.cgAffineTransformValue ?? .identity
    }
    
    /// Decodes and returns an array of `CGAffineTransform` values that was previously encoded with `encode(_:)`.
    func decodeCGAffineTransforms(forKey key: String) -> [CGAffineTransform] {
        (decodeObject(forKey: key) as? [NSValue])?.map { $0.cgAffineTransformValue } ?? []
    }
    
    /// Decodes and returns a `NSRange` value that was previously encoded with `encode(_:)`.
    func decodeRange(forKey key: String) -> NSRange {
        decodeObject(of: NSValue.self, forKey: key)?.rangeValue ?? .notFound
    }
    
    /// Decodes and returns an array of `NSRange` values that was previously encoded with `encode(_:)`.
    func decodeNSRanges(forKey key: String) -> [NSRange] {
        (decodeObject(forKey: key) as? [NSValue])?.map { $0.rangeValue } ?? []
    }
    
    #if os(macOS) || os(iOS) || os(tvOS)
    /// Decodes and returns a `CATransform3D` value that was previously encoded with `encode(_:)`.
    func decodeCATransform3D(forKey key: String) -> CATransform3D {
        decodeObject(of: NSValue.self, forKey: key)?.caTransform3DValue ?? .init()
    }
    
    /// Decodes and returns an array of `CATransform3D` values that was previously encoded with `encode(_:)`.
    func decodeCATransform3Ds(forKey key: String) -> [CATransform3D] {
        (decodeObject(forKey: key) as? [NSValue])?.map { $0.caTransform3DValue } ?? []
    }
    
    /// Decodes and returns a `CMTime` value that was previously encoded with `encode(_:)`.
    func decodeTime(forKey key: String) -> CMTime {
        decodeObject(of: NSValue.self, forKey: key)?.timeValue ?? .zero
    }
    
    /// Decodes and returns an array of `CMTime` values that was previously encoded with `encode(_:)`.
    func decodeTimes(forKey key: String) -> [CMTime] {
        (decodeObject(forKey: key) as? [NSValue])?.map { $0.timeValue } ?? []
    }
    #endif

    #if os(macOS)
    /// Decodes and returns a `NSEdgeInsets` value that was previously encoded with `encode(_:)`.
    func decodeEdgeInsets(forKey key: String) -> NSEdgeInsets {
        decodeObject(of: NSValue.self, forKey: key)?.edgeInsetsValue ?? .init()
    }
    
    /// Decodes and returns an array of `NSEdgeInsets` values that was previously encoded with `encode(_:)`.
    func decodeEdgeInsets(forKey key: String) -> [NSEdgeInsets] {
        (decodeObject(forKey: key) as? [NSValue])?.map { $0.edgeInsetsValue } ?? []
    }
    
    /// Decodes and returns a range value that was previously encoded with `encode(_:)`.
    func decodeRange<Bound: NSNumberConvertable>(forKey key: String) -> Range<Bound> {
        (decodeObject(forKey: key) as? RangeObjC<Bound>)?.range ?? .init(uncheckedBounds: (.zero, .zero))
    }
    
    /// Decodes and returns an array of `Range` values that was previously encoded with `encode(_:)`.
    func decodeRanges<Bound: NSNumberConvertable>(forKey key: String) -> [Range<Bound>] {
        (decodeObject(forKey: key) as? [RangeObjC<Bound>])?.compactMap { $0.range } ?? []
    }
    
    /// Decodes and returns a closed range value that was previously encoded with `encode(_:)`.
    func decodeClosedRange<Bound: NSNumberConvertable>(forKey key: String) -> ClosedRange<Bound> {
        (decodeObject(forKey: key) as? RangeObjC<Bound>)?.closedRange ?? .init(uncheckedBounds: (.zero, .zero))
    }
    
    /// Decodes and returns an array of `ClosedRange` values that was previously encoded with `encode(_:)`.
    func decodeClosedRanges<Bound: NSNumberConvertable>(forKey key: String) -> [ClosedRange<Bound>] {
        (decodeObject(forKey: key) as? [RangeObjC<Bound>])?.compactMap { $0.closedRange } ?? []
    }
    
    /// Decodes and returns an array of `CGPoint` values that was previously encoded with `encode(_:)`.
    func decodePoints(forKey key: String) -> [CGPoint] {
        (decodeObject(forKey: key) as? [NSValue])?.map { $0.pointValue } ?? []
    }
    
    /// Decodes and returns an array of `CGSize` values that was previously encoded with `encode(_:)`.
    func decodeSizes(forKey key: String) -> [CGSize] {
        (decodeObject(forKey: key) as? [NSValue])?.map { $0.sizeValue } ?? []
    }
    
    /// Decodes and returns an array of `CGRect` values that was previously encoded with `encode(_:)`.
    func decodeRects(forKey key: String) -> [CGRect] {
        (decodeObject(forKey: key) as? [NSValue])?.map { $0.rectValue } ?? []
    }

    #elseif canImport(UIKit)
    /// Decodes and returns a `UIEdgeInsets` value that was previously encoded with `encode(_:)`.
    func decodeEdgeInsets(forKey key: String) -> UIEdgeInsets {
        (decodeObject(forKey: key) as? NSValue)?.uiEdgeInsetsValue ?? .init()
    }
    
    /// Decodes and returns an array of `UIEdgeInsets` values that was previously encoded with `encode(_:)`.
    func decodeEdgeInsetsArray(forKey key: String) -> [UIEdgeInsets] {
        (decodeObject(forKey: key) as? [NSValue])?.map { $0.uiEdgeInsetsValue } ?? []
    }
    
    /// Decodes and returns a `CGVector` value that was previously encoded with `encode(_:)`.
    func decodeCGVector(forKey key: String) -> CGVector {
        decodeObject(of: NSValue.self, forKey: key)?.cgVectorValue ?? .zero
    }
    
    /// Decodes and returns an array of `CGVector` values that was previously encoded with `encode(_:)`.
    func decodeCGVectors(forKey key: String) -> [CGVector] {
        (decodeObject(forKey: key) as? [NSValue])?.map { $0.cgVectorValue } ?? []
    }
    
    /// Decodes and returns an array of `CGPoint` values that was previously encoded with `encode(_:)`.
    func decodePoints(forKey key: String) -> [CGPoint] {
        (decodeObject(forKey: key) as? [NSValue])?.map { $0.cgPointValue } ?? []
    }
    
    /// Decodes and returns an array of `CGSize` values that was previously encoded with `encode(_:)`.
    func decodeSizes(forKey key: String) -> [CGSize] {
        (decodeObject(forKey: key) as? [NSValue])?.map { $0.cgSizeValue } ?? []
    }
    
    /// Decodes and returns an array of `CGRect` values that was previously encoded with `encode(_:)`.
    func decodeRects(forKey key: String) -> [CGRect] {
        (decodeObject(forKey: key) as? [NSValue])?.map { $0.cgRectValue } ?? []
    }
    #endif
}

public extension NSCoder {
    /// Encodes the specified `NSDirectionalEdgeInsets`.
    func encode(_ directionalEdgeInsets: NSDirectionalEdgeInsets, forKey key: String) {
        encode(NSValue(directionalEdgeInsets: directionalEdgeInsets), forKey: key)
    }
    
    /// Encodes the specified `CGAffineTransform`.
    func encode(_ cgAffineTransform: CGAffineTransform, forKey key: String) {
        encode(NSValue(cgAffineTransform: cgAffineTransform), forKey: key)
    }
    
    /// Encodes the specified `NSRange`.
    func encode(_ range: NSRange, forKey key: String) {
        encode(NSValue(range: range), forKey: key)
    }
    
    /// Encodes the specified array of `NSDirectionalEdgeInsets` values.
    func encode(_ directionalEdgeInsets: [NSDirectionalEdgeInsets], forKey key: String) {
        encode(directionalEdgeInsets.map { NSValue(directionalEdgeInsets: $0) }, forKey: key)
    }
    
    /// Encodes the specified array of `NSRange` values.
    func encode(_ ranges: [NSRange], forKey key: String) {
        encode(ranges.map { NSValue(range: $0) }, forKey: key)
    }
    
    /// Encodes the specified array of `CGAffineTransform` values.
    func encode(_ transforms: [CGAffineTransform], forKey key: String) {
        encode(transforms.map { NSValue(cgAffineTransform: $0) }, forKey: key)
    }
    
    /// Encodes the specified range.
    func encode<Bound: NSNumberConvertable>(_ range: Range<Bound>, forKey key: String) {
        encode(RangeObjC(range), forKey: key)
    }
    
    /// Encodes the specified closed range.
    func encode<Bound: NSNumberConvertable>(_ range: ClosedRange<Bound>, forKey key: String) {
        encode(RangeObjC(range), forKey: key)
    }
    
    /// Encodes the specified array of `Range` values.
    func encode<Bound: NSNumberConvertable>(_ ranges: [Range<Bound>], forKey key: String) {
        encode(ranges.map { RangeObjC($0) }, forKey: key)
    }
    
    /// Encodes the specified array of `ClosedRange` values.
    func encode<Bound: NSNumberConvertable>(_ ranges: [ClosedRange<Bound>], forKey key: String) {
        encode(ranges.map { RangeObjC($0) }, forKey: key)
    }
    
    #if os(macOS) || os(iOS) || os(tvOS)
    /// Encodes the specified `CATransform3D`.
    func encode(_ caTransform3D: CATransform3D, forKey key: String) {
        encode(NSValue(caTransform3D: caTransform3D), forKey: key)
    }

    /// Encodes the specified `CMTime`.
    func encode(_ time: CMTime, forKey key: String) {
        encode(NSValue(time: time), forKey: key)
    }
    
    /// Encodes the specified array of `CMTime` values.
    func encode(_ times: [CMTime], forKey key: String) {
        encode(times.map { NSValue(time: $0) }, forKey: key)
    }

    /// Encodes the specified array of `CATransform3D` values.
    func encode(_ transforms: [CATransform3D], forKey key: String) {
        encode(transforms.map { NSValue(caTransform3D: $0) }, forKey: key)
    }
    #endif
    
    #if os(macOS)
    /// Encodes the specified `NSEdgeInsets`.
    func encode(_ edgeInsets: NSEdgeInsets, forKey key: String) {
        encode(NSValue(edgeInsets: edgeInsets), forKey: key)
    }
    
    /// Encodes the specified array of `NSEdgeInsets` values.
    func encode(_ edgeInsets: [NSEdgeInsets], forKey key: String) {
        encode(edgeInsets.map { NSValue(edgeInsets: $0) }, forKey: key)
    }
    
    /// Encodes the specified array of `CGPoint` values.
    func encode(_ points: [CGPoint], forKey key: String) {
        encode(points.map { NSValue(point: $0) }, forKey: key)
    }
    
    /// Encodes the specified array of `CGSize` values.
    func encode(_ sizes: [CGSize], forKey key: String) {
        encode(sizes.map { NSValue(size: $0) }, forKey: key)
    }
    
    /// Encodes the specified array of `CGRect` values.
    func encode(_ rects: [CGRect], forKey key: String) {
        encode(rects.map { NSValue(rect: $0) }, forKey: key)
    }
    #elseif canImport(UIKit)
    /// Encodes the specified `NSEdgeInsets`.
    func encode(_ edgeInsets: UIEdgeInsets, forKey key: String) {
        encode(NSValue(uiEdgeInsets: edgeInsets), forKey: key)
    }
    
    /// Encodes the specified `CATransform3D`.
    func encode(_ cgVector: CGVector, forKey key: String) {
        encode(NSValue(cgVector: cgVector), forKey: key)
    }
    
    /// Encodes the specified array of `UIEdgeInsets` values.
    func encode(_ edgeInsets: [UIEdgeInsets], forKey key: String) {
        encode(edgeInsets.map { NSValue(uiEdgeInsets: $0) }, forKey: key)
    }
    
    /// Encodes the specified array of `CGVector` values.
    func encode(_ cgVectors: [CGVector], forKey key: String) {
        encode(cgVectors.map { NSValue(cgVector: $0) }, forKey: key)
    }
    
    /// Encodes the specified array of `CGPoint` values.
    func encode(_ points: [CGPoint], forKey key: String) {
        encode(points.map { NSValue(cgPoint: $0) }, forKey: key)
    }
    
    /// Encodes the specified array of `CGSize` values.
    func encode(_ sizes: [CGSize], forKey key: String) {
        encode(sizes.map { NSValue(cgSize: $0) }, forKey: key)
    }
    
    /// Encodes the specified array of `CGRect` values.
    func encode(_ rects: [CGRect], forKey key: String) {
        encode(rects.map { NSValue(cgRect: $0) }, forKey: key)
    }
    #endif
}

public extension NSCoder {
    /// Decodes and returns a `NSObject` conforming to `NSCoding` for the specified key, if present.
    @_disfavoredOverload
    func decode<DecodedObjectType: NSObject & NSCoding>(_ key: String) -> DecodedObjectType? {
        _decode(key)
    }
    
    fileprivate func _decode<DecodedObjectType: NSObject & NSCoding>(_ key: String) -> DecodedObjectType? {
        decodeObject(of: DecodedObjectType.self, forKey: key)
    }
    
    /// Decodes and returns an object of type `DecodedObjectType` for the specified key.
    @_disfavoredOverload
    func decode<DecodedObjectType: _ObjectiveCBridgeable>(_ key: String) -> DecodedObjectType? where DecodedObjectType._ObjectiveCType: NSObject & NSCoding {
        _decode(key)
    }
    
    fileprivate func _decode<DecodedObjectType: _ObjectiveCBridgeable>(_ key: String) -> DecodedObjectType? where DecodedObjectType._ObjectiveCType: NSObject & NSCoding {
        guard let object: DecodedObjectType._ObjectiveCType = decode(key) else { return nil }
        var result: DecodedObjectType?
        DecodedObjectType._forceBridgeFromObjectiveC(object, result: &result)
        return result
    }
    
    /// Decodes and returns an `Int` for the specified key.
    func decode(_ key: String) -> Int {
        decodeInteger(forKey: key)
    }
    
    /// Decodes and returns an `Int` for the specified key, if present.
    func decodeIfPresent(_ key: String) -> Int? {
        containsValue(forKey: key) ? decode(key) : nil
    }
    
    /// Decodes and returns an array of `Int` values for the specified key.
    func decode(_ key: String) -> [Int] {
        decode(key)!
    }
    
    /// Decodes and returns an array of `Int` values for the specified key, if present.
    func decodeIfPresent(_ key: String) -> [Int]? {
        containsValue(forKey: key) ? _decode(key) : nil
    }
    
    /// Decodes and returns an `Int32` for the specified key.
    func decode(_ key: String) -> Int32 {
        decodeInt32(forKey: key)
    }
    
    /// Decodes and returns an `Int32` for the specified key, if present.
    func decodeIfPresent(_ key: String) -> Int32? {
        containsValue(forKey: key) ? decode(key) : nil
    }
    
    /// Decodes and returns an array of `Int32` values for the specified key.
    func decode(_ key: String) -> [Int32] {
        decode(key)!
    }
    
    /// Decodes and returns an array of `Int32` values for the specified key, if present.
    func decodeIfPresent(_ key: String) -> [Int32]? {
        containsValue(forKey: key) ? _decode(key) : nil
    }
    
    /// Decodes and returns an `Int64` for the specified key.
    func decode(_ key: String) -> Int64 {
        decodeInt64(forKey: key)
    }
    
    /// Decodes and returns an `Int64` for the specified key, if present.
    func decodeIfPresent(_ key: String) -> Int64? {
        containsValue(forKey: key) ? decode(key) : nil
    }
    
    /// Decodes and returns an array of `Int64` values for the specified key.
    func decode(_ key: String) -> [Int64] {
        decode(key)!
    }
    
    /// Decodes and returns an array of `Int64` values for the specified key, if present.
    func decodeIfPresent(_ key: String) -> [Int64]? {
        containsValue(forKey: key) ? _decode(key) : nil
    }
    
    /// Decodes and returns a `Double` for the specified key.
    func decode(_ key: String) -> Double {
        decodeDouble(forKey: key)
    }
    
    /// Decodes and returns a `Double` for the specified key, if present.
    func decodeIfPresent(_ key: String) -> Double? {
        containsValue(forKey: key) ? decode(key) : nil
    }
    
    /// Decodes and returns an array of `Double` values for the specified key.
    func decode(_ key: String) -> [Double] {
        decode(key)!
    }
    
    /// Decodes and returns an array of `Double` values for the specified key, if present.
    func decodeIfPresent(_ key: String) -> [Double]? {
        containsValue(forKey: key) ? _decode(key) : nil
    }
    
    /// Decodes and returns a `Float` for the specified key.
    func decode(_ key: String) -> Float {
        decodeFloat(forKey: key)
    }
    
    /// Decodes and returns a `Float` for the specified key, if present.
    func decodeIfPresent(_ key: String) -> Float? {
        containsValue(forKey: key) ? decode(key) : nil
    }
    
    /// Decodes and returns an array of `Float` values for the specified key.
    func decode(_ key: String) -> [Float] {
        decode(key)!
    }
    
    /// Decodes and returns an array of `Float` values for the specified key, if present.
    func decodeIfPresent(_ key: String) -> [Float]? {
        containsValue(forKey: key) ? _decode(key) : nil
    }
    
    /// Decodes and returns a `Bool` for the specified key.
    func decode(_ key: String) -> Bool {
        decodeBool(forKey: key)
    }
    
    /// Decodes and returns a `Bool` for the specified key, if present.
    func decodeIfPresent(_ key: String) -> Bool? {
        containsValue(forKey: key) ? decode(key) : nil
    }
    
    /// Decodes and returns an array of `Bool` values for the specified key.
    func decode(_ key: String) -> [Bool] {
        decode(key)!
    }
    
    /// Decodes and returns an array of `Bool` values for the specified key, if present.
    func decodeIfPresent(_ key: String) -> [Bool]? {
        containsValue(forKey: key) ? _decode(key) : nil
    }
    
    /// Decodes and returns a `CGRect` for the specified key.
    func decode(_ key: String) -> CGRect {
        decodeRect(forKey: key)
    }
    
    /// Decodes and returns a `CGRect` for the specified key, if present.
    func decodeIfPresent(_ key: String) -> CGRect? {
        containsValue(forKey: key) ? decode(key) : nil
    }
    
    /// Decodes and returns an array of `CGRect` values for the specified key.
    func decode(_ key: String) -> [CGRect] {
        decodeRects(forKey: key)
    }
    
    /// Decodes and returns an array of `CGRect` values for the specified key, if present.
    func decodeIfPresent(_ key: String) -> [CGRect]? {
        containsValue(forKey: key) ? decode(key) : nil
    }
    
    /// Decodes and returns a `CGPoint` for the specified key.
    func decode(_ key: String) -> CGPoint {
        decodePoint(forKey: key)
    }
    
    /// Decodes and returns a `CGPoint` for the specified key, if present.
    func decodeIfPresent(_ key: String) -> CGPoint? {
        containsValue(forKey: key) ? decode(key) : nil
    }
    
    /// Decodes and returns an array of `CGPoint` values for the specified key.
    func decode(_ key: String) -> [CGPoint] {
        decodePoints(forKey: key)
    }
    
    /// Decodes and returns an array of `CGPoint` values for the specified key, if present.
    func decodeIfPresent(_ key: String) -> [CGPoint]? {
        containsValue(forKey: key) ? decode(key) : nil
    }
    
    /// Decodes and returns a `CGSize` for the specified key.
    func decode(_ key: String) -> CGSize {
        decodeSize(forKey: key)
    }
    
    /// Decodes and returns a `CGSize` for the specified key, if present.
    func decodeIfPresent(_ key: String) -> CGSize? {
        containsValue(forKey: key) ? decode(key) : nil
    }
    
    /// Decodes and returns an array of `CGSize` values for the specified key.
    func decode(_ key: String) -> [CGSize] {
        decodeSizes(forKey: key)
    }
    
    /// Decodes and returns an array of `CGSize` values for the specified key, if present.
    func decodeIfPresent(_ key: String) -> [CGSize]? {
        containsValue(forKey: key) ? decode(key) : nil
    }
    
    /// Decodes and returns an `NSRange` for the specified key.
    func decode(_ key: String) -> NSRange {
        decodeRange(forKey: key)
    }
    
    /// Decodes and returns an `NSRange` for the specified key, if present.
    func decodeIfPresent(_ key: String) -> NSRange? {
        containsValue(forKey: key) ? decode(key) : nil
    }
    
    /// Decodes and returns an array of `NSRange` values for the specified key.
    func decode(_ key: String) -> [NSRange] {
        decodeNSRanges(forKey: key)
    }
    
    /// Decodes and returns an array of `NSRange` values for the specified key, if present.
    func decodeIfPresent(_ key: String) -> [NSRange]? {
        containsValue(forKey: key) ? decode(key) : nil
    }
    
    /// Decodes and returns a `CGAffineTransform` for the specified key.
    func decode(_ key: String) -> CGAffineTransform {
        decodeCGAffineTransform(forKey: key)
    }
    
    /// Decodes and returns a `CGAffineTransform` for the specified key, if present.
    func decodeIfPresent(_ key: String) -> CGAffineTransform? {
        containsValue(forKey: key) ? decode(key) : nil
    }
    
    /// Decodes and returns an array of `CGAffineTransform` values for the specified key.
    func decode(_ key: String) -> [CGAffineTransform] {
        decodeCGAffineTransforms(forKey: key)
    }
    
    /// Decodes and returns an array of `CGAffineTransform` values for the specified key, if present.
    func decodeIfPresent(_ key: String) -> [CGAffineTransform]? {
        containsValue(forKey: key) ? decode(key) : nil
    }
    
    /// Decodes and returns an `NSDirectionalEdgeInsets` for the specified key.
    func decode(_ key: String) -> NSDirectionalEdgeInsets {
        decodeDirectionalEdgeInsets(forKey: key)
    }
    
    /// Decodes and returns an `NSDirectionalEdgeInsets` for the specified key, if present.
    func decodeIfPresent(_ key: String) -> NSDirectionalEdgeInsets? {
        containsValue(forKey: key) ? decode(key) : nil
    }
    
    /// Decodes and returns an array of `NSDirectionalEdgeInsets` values for the specified key.
    func decode(_ key: String) -> [NSDirectionalEdgeInsets] {
        decodeDirectionalEdgeInsetsArray(forKey: key)
    }
    
    /// Decodes and returns an array of `NSDirectionalEdgeInsets` values for the specified key, if present.
    func decodeIfPresent(_ key: String) -> [NSDirectionalEdgeInsets]? {
        containsValue(forKey: key) ? decode(key) : nil
    }
    
    #if os(macOS)
    /// Decodes and returns an `NSEdgeInsets` for the specified key.
    func decode(_ key: String) -> NSEdgeInsets {
        decodeEdgeInsets(forKey: key)
    }
    
    /// Decodes and returns an `NSEdgeInsets` for the specified key, if present.
    func decodeIfPresent(_ key: String) -> NSEdgeInsets? {
        containsValue(forKey: key) ? decode(key) : nil
    }
    
    /// Decodes and returns an array of `NSEdgeInsets` values for the specified key.
    func decode(_ key: String) -> [NSEdgeInsets] {
        decodeEdgeInsets(forKey: key)
    }
    
    /// Decodes and returns an array of `NSEdgeInsets` values for the specified key, if present.
    func decodeIfPresent(_ key: String) -> [NSEdgeInsets]? {
        containsValue(forKey: key) ? decode(key) : nil
    }
    
    /// Decodes and returns a `Range<Bound>` for the specified key.
    func decode<Bound: NSNumberConvertable>(_ key: String) -> Range<Bound> {
        decodeRange(forKey: key)
    }
    
    /// Decodes and returns a `Range<Bound>` for the specified key, if present.
    func decodeIfPresent<Bound: NSNumberConvertable>(_ key: String) -> Range<Bound>? {
        containsValue(forKey: key) ? decode(key) : nil
    }
    
    /// Decodes and returns an array of `Range<Bound>` values for the specified key.
    func decode<Bound: NSNumberConvertable>(_ key: String) -> [Range<Bound>] {
        decodeRanges(forKey: key)
    }
    
    /// Decodes and returns an array of `Range<Bound>` values for the specified key, if present.
    func decodeIfPresent<Bound: NSNumberConvertable>(_ key: String) -> [Range<Bound>]? {
        containsValue(forKey: key) ? decode(key) : nil
    }
    
    /// Decodes and returns a `ClosedRange<Bound>` for the specified key.
    func decode<Bound: NSNumberConvertable>(_ key: String) -> ClosedRange<Bound> {
        decodeClosedRange(forKey: key)
    }
    
    /// Decodes and returns a `ClosedRange<Bound>` for the specified key, if present.
    func decodeIfPresent<Bound: NSNumberConvertable>(_ key: String) -> ClosedRange<Bound>? {
        containsValue(forKey: key) ? decode(key) : nil
    }
    
    /// Decodes and returns an array of `ClosedRange<Bound>` values for the specified key.
    func decode<Bound: NSNumberConvertable>(_ key: String) -> [ClosedRange<Bound>] {
        decodeClosedRanges(forKey: key)
    }
    
    /// Decodes and returns an array of `ClosedRange<Bound>` values for the specified key, if present.
    func decodeIfPresent<Bound: NSNumberConvertable>(_ key: String) -> [ClosedRange<Bound>]? {
        containsValue(forKey: key) ? decode(key) : nil
    }

    #elseif canImport(UIKit)
    /// Decodes and returns a `UIEdgeInsets` for the specified key.
    func decode(_ key: String) -> UIEdgeInsets {
        decodeEdgeInsets(forKey: key)
    }
    
    /// Decodes and returns a `UIEdgeInsets` for the specified key, if present.
    func decodeIfPresent(_ key: String) -> UIEdgeInsets? {
        containsValue(forKey: key) ? decode(key) : nil
    }
    
    /// Decodes and returns an array of `UIEdgeInsets` values for the specified key.
    func decode(_ key: String) -> [UIEdgeInsets] {
        decodeEdgeInsets(forKey: key)
    }
    
    /// Decodes and returns an array of `UIEdgeInsets` values for the specified key, if present.
    func decodeIfPresent(_ key: String) -> [UIEdgeInsets]? {
        containsValue(forKey: key) ? decode(key) : nil
    }
    
    /// Decodes and returns a `CGVector` for the specified key.
    func decode(_ key: String) -> CGVector {
        decodeCGVector(forKey: key)
    }
    
    /// Decodes and returns a `CGVector` for the specified key, if present.
    func decodeIfPresent(_ key: String) -> CGVector? {
        containsValue(forKey: key) ? decode(key) : nil
    }
    
    /// Decodes and returns an array of `CGVector` values for the specified key.
    func decode(_ key: String) -> [CGVector] {
        decodeCGVectors(forKey: key)
    }
    
    /// Decodes and returns an array of `CGVector` values for the specified key, if present.
    func decodeIfPresent(_ key: String) -> [CGVector]? {
        containsValue(forKey: key) ? decode(key) : nil
    }
    #endif
    
    #if os(macOS) || os(iOS) || os(tvOS)
    /// Decodes and returns a `CATransform3D` for the specified key.
    func decode(_ key: String) -> CATransform3D {
        decodeCATransform3D(forKey: key)
    }
    
    /// Decodes and returns a `CATransform3D` for the specified key, if present.
    func decodeIfPresent(_ key: String) -> CATransform3D? {
        containsValue(forKey: key) ? decode(key) : nil
    }
    
    /// Decodes and returns an array of `CATransform3D` values for the specified key.
    func decode(_ key: String) -> [CATransform3D] {
        decodeCATransform3Ds(forKey: key)
    }
    
    /// Decodes and returns an array of `CATransform3D` values for the specified key, if present.
    func decodeIfPresent(_ key: String) -> [CATransform3D]? {
        containsValue(forKey: key) ? decode(key) : nil
    }
    
    /// Decodes and returns a `CMTime` for the specified key.
    func decode(_ key: String) -> CMTime {
        decodeTime(forKey: key)
    }
    
    /// Decodes and returns a `CMTime` for the specified key, if present.
    func decodeIfPresent(_ key: String) -> CMTime? {
        containsValue(forKey: key) ? decode(key) : nil
    }
    
    /// Decodes and returns an array of `CMTime` values for the specified key.
    func decode(_ key: String) -> [CMTime] {
        decodeTimes(forKey: key)
    }
    
    /// Decodes and returns an array of `CMTime` values for the specified key, if present.
    func decodeIfPresent(_ key: String) -> [CMTime]? {
        containsValue(forKey: key) ? decode(key) : nil
    }
    #endif
}

private class RangeObjC<Bound: NSNumberConvertable>: NSObject, NSCoding {
    let lowerBound: Bound
    let upperBound: Bound
    let isClosed: Bool
    
    init(_ range: Range<Bound>) {
        self.lowerBound = range.lowerBound
        self.upperBound = range.upperBound
        self.isClosed = false
    }
    
    init(_ range: ClosedRange<Bound>) {
        self.lowerBound = range.lowerBound
        self.upperBound = range.upperBound
        self.isClosed = true
    }
    
    var closedRange: ClosedRange<Bound>? {
        isClosed ? .init(uncheckedBounds: (lowerBound, upperBound)) : nil
    }
    
    var range: Range<Bound>? {
        !isClosed ? .init(uncheckedBounds: (lowerBound, upperBound)) : nil
    }
    
    required init?(coder: NSCoder) {
        lowerBound = (coder.decodeObject(forKey: "lowerBound") as! NSNumber) as! Bound
        upperBound = (coder.decodeObject(forKey: "upperBound") as! NSNumber) as! Bound
        isClosed = coder.decodeBool(forKey: "isClosed")
    }
    
    func encode(with coder: NSCoder) {
        coder.encode((lowerBound as! (any _ObjectiveCBridgeable))._bridgeToObjectiveC(), forKey: "lowerBound")
        coder.encode((upperBound as! (any _ObjectiveCBridgeable))._bridgeToObjectiveC(), forKey: "upperBound")
        coder.encode(isClosed, forKey: "isClosed")
    }
}
