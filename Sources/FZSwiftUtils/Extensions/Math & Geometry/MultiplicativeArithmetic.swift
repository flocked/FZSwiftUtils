//
//  MultiplicativeArithmetic.swift
//
//
//  Created by Florian Zand on 17.11.23.
//

import Foundation

/// A type with values that support multiplication and division.
public protocol MultiplicativeArithmetic: AdditiveArithmetic {
    /// Divides two values and produces their division.
    static func / (lhs: Self, rhs: Self) -> Self
    /// Divides two values and stores the result in the left-hand-side variable.
    static func /= (lhs: inout Self, rhs: Self)
    /// Multiplies two values and produces their multiplication.
    static func * (lhs: Self, rhs: Self) -> Self
    /// Multiplies two values and stores the result in the left-hand-side variable.
    static func *= (lhs: inout Self, rhs: Self)
}

extension Double: MultiplicativeArithmetic {}
extension Float: MultiplicativeArithmetic {}
extension CGFloat: MultiplicativeArithmetic {}
extension Int: MultiplicativeArithmetic {}
extension Int8: MultiplicativeArithmetic {}
extension Int16: MultiplicativeArithmetic {}
extension Int32: MultiplicativeArithmetic {}
extension Int64: MultiplicativeArithmetic {}
extension UInt: MultiplicativeArithmetic {}
extension UInt8: MultiplicativeArithmetic {}
extension UInt16: MultiplicativeArithmetic {}
extension UInt32: MultiplicativeArithmetic {}
extension UInt64: MultiplicativeArithmetic {}
#if arch(arm64)
@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
extension Float16: MultiplicativeArithmetic {}
#endif
