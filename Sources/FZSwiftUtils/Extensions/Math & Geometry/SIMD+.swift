//
//  SIMD+.swift
//
//
//  Created by Florian Zand on 01.02.26.
//

import SwiftUI
import simd

public extension SIMD where Scalar: BinaryFloatingPoint {
    /// Wrap the SIMD value as `SIMDAnimatable` to conform to [VectorArithmetic](https://developer.apple.com/documentation/SwiftUI/VectorArithmetic).
    var animatable: SIMDAnimatable<Self> { SIMDAnimatable(self) }
}

/**
 A generic SIMD wrapper that conforms to [VectorArithmetic](https://developer.apple.com/documentation/SwiftUI/VectorArithmetic) so it can be used as [animatabledata](https://developer.apple.com/documentation/swiftui/animatable/animatabledata-6nydg) for SwiftUI [Animatable](https://developer.apple.com/documentation/swiftui/animatable).
 
 Supports any SIMD type (`SIMD2`, `SIMD3`, `SIMD4`, etc.) with `Float` or `Double` scalars.
 */
public struct SIMDAnimatable<V: SIMD>: VectorArithmetic where V.Scalar: BinaryFloatingPoint {
    public var value: V

    public init(_ value: V) { self.value = value }

    public static var zero: Self { Self(V.zero) }

    public static func + (lhs: Self, rhs: Self) -> Self {
        .init(lhs.value + rhs.value)
    }
    
    public static func += (lhs: inout Self, rhs: Self) {
        lhs.value += rhs.value
    }

    public static func - (lhs: Self, rhs: Self) -> Self {
        .init(lhs.value - rhs.value)
    }
    
    public static func -= (lhs: inout Self, rhs: Self) {
        lhs.value -= rhs.value
    }

    public mutating func scale(by rhs: Double) {
        value *= V.Scalar(rhs)
    }

    public var magnitudeSquared: Double {
        (0..<V.scalarCount).reduce(into: 0.0) { result, i in
            result += Double(value[i] * value[i])
        }
    }
}
