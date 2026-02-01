//
//  CFNumber+.swift
//
//
//  Created by Florian Zand on 05.12.25.
//

import Foundation

public extension CFNumber {
    /// Positive infinity value.
    static let infinity = kCFNumberPositiveInfinity!
    /// Negative infinity value.
    static let negativeInfinity = kCFNumberNegativeInfinity!
    /// A quiet NaN (“not a number”).
    static let nan = kCFNumberNaN!
    
    /// The number type.
    @inlinable var type: CFNumberType {
        CFNumberGetType(self)
    }
    
    /// The bytes used by the number to store its value.
    @inlinable var byteSize: Int {
        CFNumberGetByteSize(self) as Int
    }
    
    /// A Boolean value indicating whether the value is is a floating point type.
    @inlinable var isFloatType: Bool {
        CFNumberIsFloatType(self)
    }

    /// Returns the number as the specified numeric value type.
    @inlinable func value<T: CFNumberRepresentable>() -> T {
        T._from(cfNumber: self).result
    }
}

/// A numeric type that can be represented as `CFNumber`.
public protocol CFNumberRepresentable {
    static var cfNumberType: CFNumberType { get }
    static func _from(cfNumber: CFNumber) -> (result: Self, lossless: Bool)
}

extension Int8: CFNumberRepresentable {
    public static let cfNumberType = CFNumberType.sInt8Type
    
    public static func _from(cfNumber: CFNumber) -> (result: Self, lossless: Bool) {
        var result = Self.zero
        let lossless = CFNumberGetValue(cfNumber, Self.cfNumberType, &result)
        return (result, lossless)
    }
}

extension Int16: CFNumberRepresentable {
    public static let cfNumberType = CFNumberType.sInt16Type
    
    public static func _from(cfNumber: CFNumber) -> (result: Self, lossless: Bool) {
        var result = zero
        let lossless = CFNumberGetValue(cfNumber, cfNumberType, &result)
        return (result, lossless)
    }
}

extension Int32: CFNumberRepresentable {
    public static let cfNumberType = CFNumberType.sInt32Type
    
    public static func _from(cfNumber: CFNumber) -> (result: Self, lossless: Bool) {
        var result = zero
        let lossless = CFNumberGetValue(cfNumber, cfNumberType, &result)
        return (result, lossless)
    }
}

extension Int64: CFNumberRepresentable {
    public static let cfNumberType = CFNumberType.sInt64Type
    
    public static func _from(cfNumber: CFNumber) -> (result: Self, lossless: Bool) {
        var result = zero
        let lossless = CFNumberGetValue(cfNumber, cfNumberType, &result)
        return (result, lossless)
    }
}

extension NSInteger: CFNumberRepresentable {
    public static let cfNumberType = CFNumberType.nsIntegerType
    
    public static func _from(cfNumber: CFNumber) -> (result: Self, lossless: Bool) {
        var result = zero
        let lossless = CFNumberGetValue(cfNumber, cfNumberType, &result)
        return (result, lossless)
    }
}

extension Float32: CFNumberRepresentable {
    public static let cfNumberType = CFNumberType.float32Type
    
    public static func _from(cfNumber: CFNumber) -> (result: Self, lossless: Bool) {
        var result = zero
        let lossless = CFNumberGetValue(cfNumber, cfNumberType, &result)
        return (result, lossless)
    }
}

extension Float64: CFNumberRepresentable {
    public static let cfNumberType = CFNumberType.float64Type
    
    public static func _from(cfNumber: CFNumber) -> (result: Self, lossless: Bool) {
        var result = zero
        let lossless = CFNumberGetValue(cfNumber, cfNumberType, &result)
        return (result, lossless)
    }
}

extension CGFloat: CFNumberRepresentable {
    public static let cfNumberType = CFNumberType.cgFloatType
    
    public static func _from(cfNumber: CFNumber) -> (result: Self, lossless: Bool) {
        var result = zero
        let lossless = CFNumberGetValue(cfNumber, cfNumberType, &result)
        return (result, lossless)
    }
}
