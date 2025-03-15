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
    /// Decodes and returns a `NSDirectionalEdgeInsets` value that was previously encoded with `encode(_:)`.
    func decodeDirectionalEdgeInsets(forKey key: String) -> NSDirectionalEdgeInsets {
        decodeObject(of: NSValue.self, forKey: key)?.directionalEdgeInsetsValue ?? .init()
    }
    
    /// Decodes and returns a `CGAffineTransform` value that was previously encoded with `encode(_:)`.
    func decodeCGAffineTransform(forKey key: String) -> CGAffineTransform {
        decodeObject(of: NSValue.self, forKey: key)?.cgAffineTransformValue ?? .identity
    }
    
    #if os(macOS) || os(iOS) || os(tvOS)
    /// Decodes and returns a `CATransform3D` value that was previously encoded with `encode(_:)`.
    func decodeCATransform3D(forKey key: String) -> CATransform3D {
        decodeObject(of: NSValue.self, forKey: key)?.caTransform3DValue ?? .init()
    }
    
    /// Decodes and returns a `CMTime` value that was previously encoded with `encode(_:)`.
    func decodeTime(forKey key: String) -> CMTime {
        decodeObject(of: NSValue.self, forKey: key)?.timeValue ?? .zero
    }
    #endif
    
    /// Decodes and returns a `NSRange` value that was previously encoded with `encode(_:)`.
    func decodeRange(forKey key: String) -> NSRange {
        decodeObject(of: NSValue.self, forKey: key)?.rangeValue ?? .notFound
    }
    
    /// Decodes and returns an array of `NSDirectionalEdgeInsets` values that was previously encoded with `encode(_:)`.
    func decodeDirectionalEdgeInsetsArray(forKey key: String) -> [NSDirectionalEdgeInsets] {
        (decodeObject(forKey: key) as? [NSValue])?.map({ $0.directionalEdgeInsetsValue }) ?? []
    }
    
    /// Decodes and returns an array of `NSRange` values that was previously encoded with `encode(_:)`.
    func decodeNSRanges(forKey key: String) -> [NSRange] {
        (decodeObject(forKey: key) as? [NSValue])?.map({ $0.rangeValue }) ?? []
    }
    
    #if os(macOS) || os(iOS) || os(tvOS)
    /// Decodes and returns an array of `CMTime` values that was previously encoded with `encode(_:)`.
    func decodeTimes(forKey key: String) -> [CMTime] {
        (decodeObject(forKey: key) as? [NSValue])?.map({ $0.timeValue }) ?? []
    }
    
    /// Decodes and returns an array of `CATransform3D` values that was previously encoded with `encode(_:)`.
    func decodeCATransform3Ds(forKey key: String) -> [CATransform3D] {
        (decodeObject(forKey: key) as? [NSValue])?.map({ $0.caTransform3DValue }) ?? []
    }
    #endif
    
    /// Decodes and returns an array of `CGAffineTransform` values that was previously encoded with `encode(_:)`.
    func decodeCGAffineTransforms(forKey key: String) -> [CGAffineTransform] {
        (decodeObject(forKey: key) as? [NSValue])?.map({ $0.cgAffineTransformValue }) ?? []
    }
    #if os(macOS)
    /// Decodes and returns a `NSEdgeInsets` value that was previously encoded with `encode(_:)`.
    func decodeEdgeInsets(forKey key: String) -> NSEdgeInsets {
        decodeObject(of: NSValue.self, forKey: key)?.edgeInsetsValue ?? .init()
    }
    
    /// Decodes and returns an array of `NSEdgeInsets` values that was previously encoded with `encode(_:)`.
    func decodeEdgeInsets(forKey key: String) -> [NSEdgeInsets] {
        (decodeObject(forKey: key) as? [NSValue])?.map({ $0.edgeInsetsValue }) ?? []
    }
    
    /// Decodes and returns a range value that was previously encoded with `encode(_:)`.
    func decodeRange<Bound: NSNumberConvertable>(forKey key: String) -> Range<Bound> {
        (decodeObject(forKey: key) as? RangeObjC<Bound>)?.range ?? .init(uncheckedBounds: (.zero, .zero))
    }
    
    /// Decodes and returns a closed range value that was previously encoded with `encode(_:)`.
    func decodeClosedRange<Bound: NSNumberConvertable>(forKey key: String) -> ClosedRange<Bound> {
        (decodeObject(forKey: key) as? RangeObjC<Bound>)?.closedRange ?? .init(uncheckedBounds: (.zero, .zero))
    }
    
    /// Decodes and returns an array of `Range` values that was previously encoded with `encode(_:)`.
    func decodeRanges<Bound: NSNumberConvertable>(forKey key: String) -> [Range<Bound>] {
        (decodeObject(forKey: key) as? [RangeObjC<Bound>])?.compactMap({ $0.range }) ?? []
    }
    
    /// Decodes and returns an array of `ClosedRange` values that was previously encoded with `encode(_:)`.
    func decodeClosedRanges<Bound: NSNumberConvertable>(forKey key: String) -> [ClosedRange<Bound>] {
        (decodeObject(forKey: key) as? [RangeObjC<Bound>])?.compactMap({ $0.closedRange }) ?? []
    }
    
    /// Decodes and returns an array of `CGPoint` values that was previously encoded with `encode(_:)`.
    func decodePoints(forKey key: String) -> [CGPoint] {
        (decodeObject(forKey: key) as? [NSValue])?.map({ $0.pointValue }) ?? []
    }
    
    /// Decodes and returns an array of `CGSize` values that was previously encoded with `encode(_:)`.
    func decodeSizes(forKey key: String) -> [CGSize] {
        (decodeObject(forKey: key) as? [NSValue])?.map({ $0.sizeValue }) ?? []
    }
    
    /// Decodes and returns an array of `CGRect` values that was previously encoded with `encode(_:)`.
    func decodeRects(forKey key: String) -> [CGRect] {
        (decodeObject(forKey: key) as? [NSValue])?.map({ $0.rectValue }) ?? []
    }
    #elseif canImport(UIKit)
    /// Decodes and returns a `UIEdgeInsets` value that was previously encoded with `encode(_:)`.
    func decodeEdgeInsets(forKey key: String) -> UIEdgeInsets {
        (decodeObject(forKey: key) as? NSValue)?.uiEdgeInsetsValue ?? .init()
    }
    
    /// Decodes and returns a `CGVector` value that was previously encoded with `encode(_:)`.
    func decodeCGVector(forKey key: String) -> CGVector {
        decodeObject(of: NSValue.self, forKey: key)?.cgVectorValue ?? .zero
    }
    
    /// Decodes and returns an array of `UIEdgeInsets` values that was previously encoded with `encode(_:)`.
    func decodeEdgeInsetsArray(forKey key: String) -> [UIEdgeInsets] {
        (decodeObject(forKey: key) as? [NSValue])?.map({ $0.uiEdgeInsetsValue }) ?? []
    }
    
    /// Decodes and returns an array of `CGVector` values that was previously encoded with `encode(_:)`.
    func decodeCGVectors(forKey key: String) -> [CGVector] {
        (decodeObject(forKey: key) as? [NSValue])?.map({ $0.cgVectorValue }) ?? []
    }
    
    /// Decodes and returns an array of `CGPoint` values that was previously encoded with `encode(_:)`.
    func decodePoints(forKey key: String) -> [CGPoint] {
        (decodeObject(forKey: key) as? [NSValue])?.map({ $0.cgPointValue }) ?? []
    }
    
    /// Decodes and returns an array of `CGSize` values that was previously encoded with `encode(_:)`.
    func decodeSizes(forKey key: String) -> [CGSize] {
        (decodeObject(forKey: key) as? [NSValue])?.map({ $0.cgSizeValue }) ?? []
    }
    
    /// Decodes and returns an array of `CGRect` values that was previously encoded with `encode(_:)`.
    func decodeRects(forKey key: String) -> [CGRect] {
        (decodeObject(forKey: key) as? [NSValue])?.map({ $0.cgRectValue }) ?? []
    }
    #endif
    
    /// Encodes the specified `NSDirectionalEdgeInsets`.
    func encode(_ directionalEdgeInsets: NSDirectionalEdgeInsets, forKey key: String) {
        encode(NSValue(directionalEdgeInsets: directionalEdgeInsets), forKey: key)
    }
    
    /// Encodes the specified `CGAffineTransform`.
    func encode(_ cgAffineTransform: CGAffineTransform, forKey key: String) {
        encode(NSValue(cgAffineTransform: cgAffineTransform), forKey: key)
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
    #endif
    
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
    
    #if os(macOS) || os(iOS) || os(tvOS)
    /// Encodes the specified array of `CMTime` values.
    func encode(_ times: [CMTime], forKey key: String) {
    encode(times.map { NSValue(time: $0) }, forKey: key)
    }
    
    /// Encodes the specified array of `CATransform3D` values.
    func encode(_ transforms: [CATransform3D], forKey key: String) {
        encode(transforms.map { NSValue(caTransform3D: $0) }, forKey: key)
    }
    #endif
    
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
        encode(ranges.map({RangeObjC($0)}), forKey: key)
    }
    
    /// Encodes the specified array of `ClosedRange` values.
    func encode<Bound: NSNumberConvertable>(_ ranges: [ClosedRange<Bound>], forKey key: String) {
        encode(ranges.map({RangeObjC($0)}), forKey: key)
    }
    
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
    
    private class RangeObjC<Bound: NSNumberConvertable>: NSObject, NSCoding {
        var closedRange: ClosedRange<Bound>?
        var range: Range<Bound>?
        var isClosedRange = false
        
        init(_ closedRange: ClosedRange<Bound>) {
            self.closedRange = closedRange
            isClosedRange = true
        }
        
        init(_ range: Range<Bound>) {
            self.range = range
        }
        
        required init?(coder: NSCoder) {
            isClosedRange = coder.decodeBool(forKey: "isClosedRange")
            if isClosedRange {
                closedRange = .init(uncheckedBounds: ((coder.decodeObject(forKey: "lowerBound") as! NSNumber) as! Bound, (coder.decodeObject(forKey: "upperBound") as! NSNumber) as! Bound))
            } else {
                range = .init(uncheckedBounds: ((coder.decodeObject(forKey: "lowerBound") as! NSNumber) as! Bound, (coder.decodeObject(forKey: "upperBound") as! NSNumber) as! Bound))
            }
        }
        
        func encode(with coder: NSCoder) {
            if let closedRange = closedRange {
                coder.encode((closedRange.lowerBound as! (any _ObjectiveCBridgeable))._bridgeToObjectiveC(), forKey: "lowerBound")
                coder.encode((closedRange.upperBound as! (any _ObjectiveCBridgeable))._bridgeToObjectiveC(), forKey: "upperBound")
            } else if let range = range {
                coder.encode((range.lowerBound as! (any _ObjectiveCBridgeable))._bridgeToObjectiveC(), forKey: "lowerBound")
                coder.encode((range.upperBound as! (any _ObjectiveCBridgeable))._bridgeToObjectiveC(), forKey: "upperBound")
            }
            coder.encode(isClosedRange, forKey: "isClosedRange")
        }
    }
}

/// A number type that can be used converted to and get from `NSNumber`.
public protocol NSNumberConvertable: Comparable { 
    static var zero: Self { get }
}

extension Int: NSNumberConvertable { }
extension Int8: NSNumberConvertable { }
extension Int16: NSNumberConvertable { }
extension Int32: NSNumberConvertable { }
extension Int64: NSNumberConvertable { }
extension UInt: NSNumberConvertable { }
extension UInt8: NSNumberConvertable { }
extension UInt16: NSNumberConvertable { }
extension UInt32: NSNumberConvertable { }
extension UInt64: NSNumberConvertable { }
extension Double: NSNumberConvertable { }
extension Float: NSNumberConvertable { }
extension CGFloat: NSNumberConvertable { }
