//
//  Interpolatable.swift
//
//
//  Created by Florian Zand on 13.12.25.
//

import QuartzCore
import simd
import Accelerate

/// A type that can be linearly interpolated.
public protocol Interpolatable {
    /// The fraction type that is used to linearly interpolate.
    associatedtype FractionType: FloatingPoint

    /**
     Returns the current value linearly interpolated to the specified other value based on the given fraction.

     - Parameters:
        - other: The end value to interpolate to.
        - fraction: The fraction to interpolate between the two values (ibetween `0.0` and `1.0`).
     - Returns: The interpolated value.
     */
    func interpolated(to other: Self, fraction: FractionType) -> Self
    
    /**
     Interpolates the current value linearly to the specified other value based on the given fraction.

     - Parameters:
        - other: The end value to interpolate to.
        - fraction: The fraction to interpolate between the two values (ibetween `0.0` and `1.0`).
     */
    mutating func interpolate(to: Self, fraction: FractionType)
}

extension Interpolatable {
    public mutating func interpolate(to value: Self, fraction: FractionType) {
        self = interpolated(to: value, fraction: fraction)
    }
}

extension Double: Interpolatable {
    public func interpolated(to value: Double, fraction: Double) -> Double {
        self + ((value - self) * fraction)
    }
}

extension Float: Interpolatable {
    public func interpolated(to value: Float, fraction: Float) -> Float {
        self + ((value - self) * fraction)
    }
}

extension CGFloat: Interpolatable {
    public func interpolated(to value: CGFloat, fraction: CGFloat) -> CGFloat {
        self + ((value - self) * fraction)
    }
}

extension Array: Interpolatable where Element: Interpolatable {
    public func interpolated(to value: Array<Element>, fraction: Element.FractionType) -> Array<Element> {
        if self is [Double] {
            if count == value.count, count != 0 {
                return unsafeBitCast(vDSP.linearInterpolate(toDouble(self), toDouble(value), using: unsafeBitCast(fraction)))
            }
            let count = Swift.min(count, value.count)
            guard count > 0 else { return [] }
            return unsafeBitCast(vDSP.linearInterpolate(toDouble(Self(self[0..<count])), toDouble(Self(value[0..<count])), using: unsafeBitCast(fraction)))
        } else if self is [Float] {
            if count == value.count, count != 0 {
                return unsafeBitCast(vDSP.linearInterpolate(toFloat(Self(self[0..<count])), toFloat(Self(value[0..<count])), using: unsafeBitCast(fraction)))
            }
            let count = Swift.min(count, value.count)
            guard count > 0 else { return [] }
            return unsafeBitCast(vDSP.linearInterpolate(unsafeBitCast(self[0..<count], to: [Float].self), unsafeBitCast(value[0..<count], to: [Float].self), using: unsafeBitCast(fraction)))
        }
        return zip(self, value).map { from, to in
             from.interpolated(to: to, fraction: fraction)
        }
    }
    
    fileprivate func toDouble(_ value: Self) -> [Double] {
        unsafeBitCast(value)
    }
    
    fileprivate func toFloat(_ value: Self) -> [Float] {
        unsafeBitCast(value)
    }
}

extension SIMD2: Interpolatable where Scalar: FloatingPoint & SIMDScalar {
    public func interpolated(to: Self, fraction: Self.Scalar) -> Self {
        self + ((to - self) * Self(repeating: fraction))
    }
}

extension SIMD3: Interpolatable where Scalar: FloatingPoint & SIMDScalar {
    public func interpolated(to: Self, fraction: Self.Scalar) -> Self {
        self + ((to - self) * Self(repeating: fraction))
    }
}

extension SIMD4: Interpolatable where Scalar: FloatingPoint & SIMDScalar {
    public func interpolated(to: Self, fraction: Self.Scalar) -> Self {
        self + ((to - self) * Self(repeating: fraction))
    }
}

extension SIMD8: Interpolatable where Scalar: FloatingPoint & SIMDScalar {
    public func interpolated(to: Self, fraction: Self.Scalar) -> Self {
        self + ((to - self) * Self(repeating: fraction))
    }
}

extension SIMD16: Interpolatable where Scalar: FloatingPoint & SIMDScalar {
    public func interpolated(to: Self, fraction: Self.Scalar) -> Self {
        self + ((to - self) * Self(repeating: fraction))
    }
}

extension SIMD32: Interpolatable where Scalar: FloatingPoint & SIMDScalar {
    public func interpolated(to: Self, fraction: Self.Scalar) -> Self {
        self + ((to - self) * Self(repeating: fraction))
    }
}

extension SIMD64: Interpolatable where Scalar: FloatingPoint & SIMDScalar {
    public func interpolated(to: Self, fraction: Self.Scalar) -> Self {
        self + ((to - self) * Self(repeating: fraction))
    }
}

extension simd_quatf: Interpolatable {
    public func interpolated(to: Self, fraction: Float) -> simd_quatf {
        return simd_slerp(self, to, fraction)
    }
}

extension simd_quatd: Interpolatable {
    public func interpolated(to: Self, fraction: Double) -> Self {
        simd_slerp(self, to, fraction)
    }
}

extension simd_quath: Interpolatable {
    public func interpolated(to: Self, fraction: Float16) -> simd_quath {
        return simd_slerp(self, to, fraction)
    }
}
