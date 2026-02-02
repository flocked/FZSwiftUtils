//
//  SIMD+.swift
//
//
//  Created by Florian Zand on 01.02.26.
//

import simd
import SwiftUI

extension SIMD2: Swift.AdditiveArithmetic where Scalar: BinaryFloatingPoint { }
extension SIMD3: Swift.AdditiveArithmetic where Scalar: BinaryFloatingPoint { }
extension SIMD4: Swift.AdditiveArithmetic where Scalar: BinaryFloatingPoint { }
extension SIMD8: Swift.AdditiveArithmetic where Scalar: BinaryFloatingPoint { }
extension SIMD16: Swift.AdditiveArithmetic where Scalar: BinaryFloatingPoint { }
extension SIMD32: Swift.AdditiveArithmetic where Scalar: BinaryFloatingPoint { }
extension SIMD64: Swift.AdditiveArithmetic where Scalar: BinaryFloatingPoint { }

public extension SIMDStorage {
    /// The scalars of the vector.
    var scalars: [Scalar] {
        get { (0..<scalarCount).map({ self[$0] }) }
    }
    
    /// The valid indices for subscripting the vector.
    public static var indices: Range<Int> { 0..<scalarCount }
    
    /// Accesses the element at the specified index.
    subscript(safe index: Int) -> Scalar? {
        get { index >= 0 && index < scalarCount ? self[index] : nil }
        set {
            guard index >= 0, index < scalarCount, let newValue else { return }
            self[index] = newValue
        }
    }
    
    /// Accesses the elements in the specified range.
    subscript(range: Range<Int>) -> [Scalar] {
        get { range.compactMap({ self[safe: $0] }) }
        set { zip(range, newValue).forEach { self[safe: $0] = $1 } }
    }
    
    /// Accesses the elements in the specified range.
    subscript(range: ClosedRange<Int>) -> [Scalar] {
        get { range.compactMap({ self[safe: $0] }) }
        set { zip(range, newValue).forEach { self[safe: $0] = $1 } }
    }
    
    /// Accesses the elements in the specified range.
    subscript(range: PartialRangeFrom<Int>) -> [Scalar] {
        get { self[range.lowerBound..<scalarCount] }
        set { self[range.lowerBound..<scalarCount] = newValue }
    }
    
    /// Accesses the elements in the specified range.
    subscript(range: PartialRangeUpTo<Int>) -> [Scalar] {
        get { self[0..<range.upperBound] }
        set { self[0..<range.upperBound] = newValue }
    }
    
    /// Accesses the elements in the specified range.
    subscript(range: PartialRangeThrough<Int>) -> [Scalar] {
        get { self[0...range.upperBound] }
        set { self[0...range.upperBound] = newValue }
    }
}

public extension SIMDStorage where Scalar: AdditiveArithmetic {
    /// The scalars of the vector.
    var scalars: [Scalar] {
        get { (0..<scalarCount).map({ self[$0] }) }
        set {
            var newValue = newValue.prefix(scalarCount)
            newValue = newValue + Array(repeating: .zero, count: scalarCount-newValue.count)
            zip(Self.indices, newValue).forEach({ self[$0] = $1 })
        }
    }
}

public extension SIMD where Scalar: AdditiveArithmetic & SIMDScalar {
    /// Creates a vector from the given scalars, truncating to `scalarCount` if too long or padding with `zero` scalars if too short.
    init(padded scalars: [Scalar]) {
        let scalars = scalars.prefix(Self.scalarCount)
        self.init(scalars + Array(repeating: .zero, count: Self.scalarCount-scalars.count))
    }
    
    /// Creates a vector from the given vector.
    init<V: SIMD>(_ vector: V) where V.Scalar == Scalar {
        self.init(padded: vector.scalars)
    }
    
    
    /**
     Converts the vector to a `SIMD2` vector.

     - Parameter first: If `true`, uses the first two scalars; otherwise, the last two.
     - Returns: A `SIMD2` vector.
     */
    func simd2(first: Bool = true) -> SIMD2<Scalar> {
        .init(padded: self[first ? 0..<2 : scalarCount-2..<scalarCount])
    }
    
    /**
     Converts the vector to a `SIMD3` vector.

     - Parameter first: If `true`, uses the first three scalars; otherwise, the last three.
     - Returns: A `SIMD3` vector, padded with `zero` if `scalarCount < 3`.
     */
    func simd3(first: Bool = true) -> SIMD3<Scalar> {
        .init(padded: self[first ? 0..<3 : scalarCount-3..<scalarCount])
    }
    
    /**
     Converts the vector to a `SIMD4` vector.

     - Parameter first: If `true`, uses the first four scalars; otherwise, the last four.
     - Returns: A `SIMD4` vector, padded with `zero` if `scalarCount < 4`.
     */
    func simd4(first: Bool = true) -> SIMD4<Scalar> {
        .init(padded: self[first ? 0..<4 : scalarCount-4..<scalarCount])
    }
    
    /**
     Converts the vector to a `SIMD8` vector.

     - Parameter first: If `true`, uses the first eight scalars; otherwise, the last eight.
     - Returns: A `SIMD8` vector, padded with `zero` if `scalarCount < 8`.
     */
    func simd8(first: Bool = true) -> SIMD8<Scalar> {
        .init(padded: self[first ? 0..<8 : scalarCount-8..<scalarCount])
    }
    
    /**
     Converts the vector to a `SIMD16` vector.

     - Parameter first: If `true`, uses the first sixteen scalars; otherwise, the last sixteen.
     - Returns: A `SIMD16` vector, padded with `zero` if `scalarCount < 16`.
     */
    func simd16(first: Bool = true) -> SIMD16<Scalar> {
        .init(padded: self[first ? 0..<16 : scalarCount-16..<scalarCount])
    }
    
    /**
     Converts the vector to a `SIMD32` vector.

     - Parameter first: If `true`, uses the first thirty-two scalars; otherwise, the last thirty-two.
     - Returns: A `SIMD32` vector, padded with `zero` if `scalarCount < 32`.
     */
    func simd32(first: Bool = true) -> SIMD32<Scalar> {
        .init(padded: self[first ? 0..<32 : scalarCount-32..<scalarCount])
    }
    
    /**
     Converts the vector to a `SIMD64` vector.

     - Parameter first: If `true`, uses the first sixty-four scalars; otherwise, the last sixty-four.
     - Returns: A `SIMD64` vector, padded with `zero` if `scalarCount < 64`.
     */
    func simd64(first: Bool = true) -> SIMD64<Scalar> {
        .init(padded: self[first ? 0..<64 : scalarCount-64..<scalarCount])
    }
}

extension SIMD2 where Scalar == Double {
    /// Returns the sum of the squares of the vector’s elements.
    @inlinable
    public var lengthSquared: Scalar {
        simd_length_squared(self)
    }
    
    /// Returns the Euclidean length of the vector using a precise square root.
    @inlinable
    public var length: Scalar {
        simd_length(self)
    }

    /// Returns an approximate Euclidean length of the vector using a faster, less precise algorithm.
    @inlinable
    public var lengthFast: Scalar {
        simd_fast_length(self)
    }
    
    /// Returns a unit-length vector pointing in the same direction as this vector.
    @inlinable
    public var normalized: Self {
        simd_normalize(self)
    }
    
    /// Returns an approximate unit-length vector pointing in the same direction as this vector using a faster, less precise algorithm.
    @inlinable
    public var normalizedFast: Self {
        simd_fast_normalize(self)
    }
    
    /// Returns the Euclidean distance between this vector and another.
    @inlinable
    public func distance(to other: Self) -> Scalar {
        simd_distance(self, other)
    }
    
    /// Returns an approximate Euclidean distance between this vector and another.
    @inlinable
    public func distanceFast(to other: Self) -> Scalar {
        simd_fast_distance(self, other)
    }
    
    /// Returns the squared Euclidean distance between this vector and another.
    @inlinable
    public func distanceSquared(to other: Self) -> Scalar {
        simd_distance_squared(self, other)
    }
    
    /// Returns the projection of this vector onto another vector.
    @inlinable
    public func project(onto other: Self) -> Self {
        simd_project(self, other)
    }
    
    /// Returns an approximate projection of this vector onto another vector.
    @inlinable
    public func projectFast(onto other: Self) -> Self {
        simd_fast_project(self, other)
    }
    
    /// Returns the dot product of this vector with another.
    @inlinable
    public func dot(with other: Self) -> Scalar {
        simd_dot(self, other)
    }
    
    /// Returns the 1-norm (sum of absolute values) of this vector.
    @inlinable
    public var normOne: Scalar {
        simd_norm_one(self)
    }
    
    /// Returns the infinity norm (maximum absolute value) of this vector.
    @inlinable
    public var normInf: Scalar {
        simd_norm_inf(self)
    }
    
    /// Returns a vector containing the absolute value of each scalar.
    @inlinable
    public var abs: Self {
        simd_abs(self)
    }
    
    /// Returns a vector containing the sign of each scalar (`-1`, `0`, or `1`).
    @inlinable
    public var sign: Self {
        simd_sign(self)
    }
    
    /**
     Returns an approximation of the reciprocal of each scalar.

     This property maps to ``recipFast`` if the compiler setting `-ffast-math` is specified, and to ``recipPrecise`` otherwise.
     */
    @inlinable
    public var recip: Self {
        simd_recip(self)
    }
    
    /**
     Returns a fast approximation of the reciprocal of each scalar.

     If the vector is very close to the limits of representation, the result may overflow or underflow; otherwise it is accurate to at least 22 bits.
     */
    @inlinable
    public var recipFast: Self {
        simd_fast_recip(self)
    }
    
    /**
     Returns a precise approximation of the reciprocal of each scalar.

     If the vector is very close to the limits of representation, the result may overflow or underflow; otherwise it is accurate to a few units in the last place (ULPs).
     */
    @inlinable
    public var recipPrecise: Self {
        simd_precise_recip(self)
    }
    
    /**
     Returns an approximation of the reciprocal square root of each scalar.

     This property maps to ``rsqrtFast`` if the compiler setting `-ffast-math` is specified, and to ``rsqrtPrecise`` otherwise.
     */
    @inlinable
    public var rsqrt: Self {
        simd_rsqrt(self)
    }
    
    /**
     Returns a fast approximation of the reciprocal square root of each scalar.

     It is accurate to at least 22 bits.
     */
    @inlinable
    public var rsqrtFast: Self {
        simd_fast_rsqrt(self)
    }
    
    /**
     Returns a precise approximation of the reciprocal square root of each scalar.

     It is accurate to a few units in the last place.
     */
    @inlinable
    public var rsqrtPrecise: Self {
        simd_precise_rsqrt(self)
    }
    
    /// Returns a vector containing the fractional part of each scalar.
    @inlinable
    public var fract: Self {
        simd_fract(self)
    }
    
    /// Returns the minimum of each scalar and the corresponding scalar in the other vector.
    @inlinable
    public func min(with other: Self) -> Self {
        simd_min(self, other)
    }
    
    /// Returns the maximum of each scalar and the corresponding scalar in the other vector.
    @inlinable
    public func max(with other: Self) -> Self {
        simd_max(self, other)
    }
    
    /// Returns a vector where each scalar is `0` if less than the corresponding scalar in `x`, or `1` otherwise.
    @inlinable
    public func step(at x: Self) -> Self {
        simd_step(self, x)
    }
        
    /// Returns a vector interpolated towards `other` using the per-component factor `amount` in the range 0…1.
    @inlinable
    public func interpolated(towards other: Self, amount: Self) -> Self {
        simd_smoothstep(self, other, amount)
    }

    /// Returns a vector interpolated towards `other` using the uniform factor `amount` in the range 0…1.
    @inlinable
    public func interpolated(towards other: Self, amount: Scalar) -> Self {
        simd_smoothstep(self, other, Self(repeating: amount))
    }

    /// Modifies this vector by interpolating it towards `other` using the per-component factor `amount` in the range 0…1.
    @inlinable
    public mutating func interpolate(towards other: Self, amount: Self) {
        self = simd_smoothstep(self, other, amount)
    }

    /// Modifies this vector by interpolating it towards `other` using the uniform factor `amount` in the range 0…1.
    @inlinable
    public mutating func interpolate(towards other: Self, amount: Scalar) {
        self = simd_smoothstep(self, other, Self(repeating: amount))
    }
}

extension SIMD2 where Scalar == Float {
    /// Returns the sum of the squares of the vector’s elements.
    @inlinable
    public var lengthSquared: Scalar {
        simd_length_squared(self)
    }

    /// Returns the Euclidean length of the vector using a precise square root.
    @inlinable
    public var length: Scalar {
        simd_length(self)
    }

    /// Returns an approximate Euclidean length of the vector using a faster, less precise algorithm.
    @inlinable
    public var lengthFast: Scalar {
        simd_fast_length(self)
    }
    
    /// Returns a unit-length vector pointing in the same direction as this vector.
    @inlinable
    public var normalized: Self {
        simd_normalize(self)
    }
    
    /// Returns an approximate unit-length vector pointing in the same direction as this vector using a faster, less precise algorithm.
    @inlinable
    public var normalizedFast: Self {
        simd_fast_normalize(self)
    }
    
    /// Returns the Euclidean distance between this vector and another.
    @inlinable
    public func distance(to other: Self) -> Scalar {
        simd_distance(self, other)
    }
    
    /// Returns an approximate Euclidean distance between this vector and another.
    @inlinable
    public func distanceFast(to other: Self) -> Scalar {
        simd_fast_distance(self, other)
    }
    
    /// Returns the squared Euclidean distance between this vector and another.
    @inlinable
    public func distanceSquared(to other: Self) -> Scalar {
        simd_distance_squared(self, other)
    }
    
    /// Returns the projection of this vector onto another vector.
    @inlinable
    public func project(onto other: Self) -> Self {
        simd_project(self, other)
    }
    
    /// Returns an approximate projection of this vector onto another vector.
    @inlinable
    public func projectFast(onto other: Self) -> Self {
        simd_fast_project(self, other)
    }
    
    /// Returns the dot product of this vector with another.
    @inlinable
    public func dot(with other: Self) -> Scalar {
        simd_dot(self, other)
    }
    
    /// Returns the 1-norm (sum of absolute values) of this vector.
    @inlinable
    public var normOne: Scalar {
        simd_norm_one(self)
    }
    
    /// Returns the infinity norm (maximum absolute value) of this vector.
    @inlinable
    public var normInf: Scalar {
        simd_norm_inf(self)
    }
    
    /// Returns a vector containing the absolute value of each scalar.
    @inlinable
    public var abs: Self {
        simd_abs(self)
    }
    
    /// Returns a vector containing the sign of each scalar (`-1`, `0`, or `1`).
    @inlinable
    public var sign: Self {
        simd_sign(self)
    }
    
    /**
     Returns an approximation of the reciprocal of each scalar.

     This property maps to ``recipFast`` if the compiler setting `-ffast-math` is specified, and to ``recipPrecise`` otherwise.
     */
    @inlinable
    public var recip: Self {
        simd_recip(self)
    }
    
    /**
     Returns a fast approximation of the reciprocal of each scalar.

     If the vector is very close to the limits of representation, the result may overflow or underflow; otherwise it is accurate to at least 22 bits.
     */
    @inlinable
    public var recipFast: Self {
        simd_fast_recip(self)
    }
    
    /**
     Returns a precise approximation of the reciprocal of each scalar.

     If the vector is very close to the limits of representation, the result may overflow or underflow; otherwise it is accurate to a few units in the last place (ULPs).
     */
    @inlinable
    public var recipPrecise: Self {
        simd_precise_recip(self)
    }
    
    /**
     Returns an approximation of the reciprocal square root of each scalar.

     This property maps to ``rsqrtFast`` if the compiler setting `-ffast-math` is specified, and to ``rsqrtPrecise`` otherwise.
     */
    @inlinable
    public var rsqrt: Self {
        simd_rsqrt(self)
    }
    
    /**
     Returns a fast approximation of the reciprocal square root of each scalar.

     It is accurate to at least 22 bits.
     */
    @inlinable
    public var rsqrtFast: Self {
        simd_fast_rsqrt(self)
    }
    
    /**
     Returns a precise approximation of the reciprocal square root of each scalar.

     It is accurate to a few units in the last place.
     */
    @inlinable
    public var rsqrtPrecise: Self {
        simd_precise_rsqrt(self)
    }
    
    /// Returns a vector containing the fractional part of each scalar.
    @inlinable
    public var fract: Self {
        simd_fract(self)
    }
    
    /// Returns the minimum of each scalar and the corresponding scalar in the other vector.
    @inlinable
    public func min(with other: Self) -> Self {
        simd_min(self, other)
    }
    
    /// Returns the maximum of each scalar and the corresponding scalar in the other vector.
    @inlinable
    public func max(with other: Self) -> Self {
        simd_max(self, other)
    }
    
    /// Returns a vector where each scalar is `0` if less than the corresponding scalar in `x`, or `1` otherwise.
    @inlinable
    public func step(at x: Self) -> Self {
        simd_step(self, x)
    }
        
    /// Returns a vector interpolated towards `other` using the per-component factor `amount` in the range 0…1.
    @inlinable
    public func interpolated(towards other: Self, amount: Self) -> Self {
        simd_smoothstep(self, other, amount)
    }

    /// Returns a vector interpolated towards `other` using the uniform factor `amount` in the range 0…1.
    @inlinable
    public func interpolated(towards other: Self, amount: Scalar) -> Self {
        simd_smoothstep(self, other, Self(repeating: amount))
    }

    /// Modifies this vector by interpolating it towards `other` using the per-component factor `amount` in the range 0…1.
    @inlinable
    public mutating func interpolate(towards other: Self, amount: Self) {
        self = simd_smoothstep(self, other, amount)
    }

    /// Modifies this vector by interpolating it towards `other` using the uniform factor `amount` in the range 0…1.
    @inlinable
    public mutating func interpolate(towards other: Self, amount: Scalar) {
        self = simd_smoothstep(self, other, Self(repeating: amount))
    }
}

extension SIMD3 where Scalar == Double {
    /// Returns the sum of the squares of the vector’s elements.
    @inlinable
    public var lengthSquared: Scalar {
        simd_length_squared(self)
    }

    /// Returns the Euclidean length of the vector using a precise square root.
    @inlinable
    public var length: Scalar {
        simd_length(self)
    }

    /// Returns an approximate Euclidean length of the vector using a faster, less precise algorithm.
    @inlinable
    public var lengthFast: Scalar {
        simd_fast_length(self)
    }
    
    /// Returns a unit-length vector pointing in the same direction as this vector.
    @inlinable
    public var normalized: Self {
        simd_normalize(self)
    }
    
    /// Returns an approximate unit-length vector pointing in the same direction as this vector using a faster, less precise algorithm.
    @inlinable
    public var normalizedFast: Self {
        simd_fast_normalize(self)
    }
    
    /// Returns the Euclidean distance between this vector and another.
    @inlinable
    public func distance(to other: Self) -> Scalar {
        simd_distance(self, other)
    }
    
    /// Returns an approximate Euclidean distance between this vector and another.
    @inlinable
    public func distanceFast(to other: Self) -> Scalar {
        simd_fast_distance(self, other)
    }
    
    /// Returns the squared Euclidean distance between this vector and another.
    @inlinable
    public func distanceSquared(to other: Self) -> Scalar {
        simd_distance_squared(self, other)
    }
    
    /// Returns the projection of this vector onto another vector.
    @inlinable
    public func project(onto other: Self) -> Self {
        simd_project(self, other)
    }
    
    /// Returns an approximate projection of this vector onto another vector.
    @inlinable
    public func projectFast(onto other: Self) -> Self {
        simd_fast_project(self, other)
    }
    
    /// Returns the dot product of this vector with another.
    @inlinable
    public func dot(with other: Self) -> Scalar {
        simd_dot(self, other)
    }
    
    /// Returns the 1-norm (sum of absolute values) of this vector.
    @inlinable
    public var normOne: Scalar {
        simd_norm_one(self)
    }
    
    /// Returns the infinity norm (maximum absolute value) of this vector.
    @inlinable
    public var normInf: Scalar {
        simd_norm_inf(self)
    }
    
    /// Returns a vector containing the absolute value of each scalar.
    @inlinable
    public var abs: Self {
        simd_abs(self)
    }
    
    /// Returns a vector containing the sign of each scalar (`-1`, `0`, or `1`).
    @inlinable
    public var sign: Self {
        simd_sign(self)
    }
    
    /**
     Returns an approximation of the reciprocal of each scalar.

     This property maps to ``recipFast`` if the compiler setting `-ffast-math` is specified, and to ``recipPrecise`` otherwise.
     */
    @inlinable
    public var recip: Self {
        simd_recip(self)
    }
    
    /**
     Returns a fast approximation of the reciprocal of each scalar.

     If the vector is very close to the limits of representation, the result may overflow or underflow; otherwise it is accurate to at least 22 bits.
     */
    @inlinable
    public var recipFast: Self {
        simd_fast_recip(self)
    }
    
    /**
     Returns a precise approximation of the reciprocal of each scalar.

     If the vector is very close to the limits of representation, the result may overflow or underflow; otherwise it is accurate to a few units in the last place (ULPs).
     */
    @inlinable
    public var recipPrecise: Self {
        simd_precise_recip(self)
    }
    
    /**
     Returns an approximation of the reciprocal square root of each scalar.

     This property maps to ``rsqrtFast`` if the compiler setting `-ffast-math` is specified, and to ``rsqrtPrecise`` otherwise.
     */
    @inlinable
    public var rsqrt: Self {
        simd_rsqrt(self)
    }
    
    /**
     Returns a fast approximation of the reciprocal square root of each scalar.

     It is accurate to at least 22 bits.
     */
    @inlinable
    public var rsqrtFast: Self {
        simd_fast_rsqrt(self)
    }
    
    /**
     Returns a precise approximation of the reciprocal square root of each scalar.

     It is accurate to a few units in the last place.
     */
    @inlinable
    public var rsqrtPrecise: Self {
        simd_precise_rsqrt(self)
    }
    
    /// Returns a vector containing the fractional part of each scalar.
    @inlinable
    public var fract: Self {
        simd_fract(self)
    }
    
    /// Returns the minimum of each scalar and the corresponding scalar in the other vector.
    @inlinable
    public func min(with other: Self) -> Self {
        simd_min(self, other)
    }
    
    /// Returns the maximum of each scalar and the corresponding scalar in the other vector.
    @inlinable
    public func max(with other: Self) -> Self {
        simd_max(self, other)
    }
    
    /// Returns a vector where each scalar is `0` if less than the corresponding scalar in `x`, or `1` otherwise.
    @inlinable
    public func step(at x: Self) -> Self {
        simd_step(self, x)
    }
        
    /// Returns a vector interpolated towards `other` using the per-component factor `amount` in the range 0…1.
    @inlinable
    public func interpolated(towards other: Self, amount: Self) -> Self {
        simd_smoothstep(self, other, amount)
    }

    /// Returns a vector interpolated towards `other` using the uniform factor `amount` in the range 0…1.
    @inlinable
    public func interpolated(towards other: Self, amount: Scalar) -> Self {
        simd_smoothstep(self, other, Self(repeating: amount))
    }

    /// Modifies this vector by interpolating it towards `other` using the per-component factor `amount` in the range 0…1.
    @inlinable
    public mutating func interpolate(towards other: Self, amount: Self) {
        self = simd_smoothstep(self, other, amount)
    }

    /// Modifies this vector by interpolating it towards `other` using the uniform factor `amount` in the range 0…1.
    @inlinable
    public mutating func interpolate(towards other: Self, amount: Scalar) {
        self = simd_smoothstep(self, other, Self(repeating: amount))
    }
}

extension SIMD3 where Scalar == Float {
    /// Returns the sum of the squares of the vector’s elements.
    @inlinable
    public var lengthSquared: Scalar {
        simd_length_squared(self)
    }

    /// Returns the Euclidean length of the vector using a precise square root.
    @inlinable
    public var length: Scalar {
        simd_length(self)
    }

    /// Returns an approximate Euclidean length of the vector using a faster, less precise algorithm.
    @inlinable
    public var lengthFast: Scalar {
        simd_fast_length(self)
    }
    
    /// Returns a unit-length vector pointing in the same direction as this vector.
    @inlinable
    public var normalized: Self {
        simd_normalize(self)
    }
    
    /// Returns an approximate unit-length vector pointing in the same direction as this vector using a faster, less precise algorithm.
    @inlinable
    public var normalizedFast: Self {
        simd_fast_normalize(self)
    }
    
    /// Returns the Euclidean distance between this vector and another.
    @inlinable
    public func distance(to other: Self) -> Scalar {
        simd_distance(self, other)
    }
    
    /// Returns an approximate Euclidean distance between this vector and another.
    @inlinable
    public func distanceFast(to other: Self) -> Scalar {
        simd_fast_distance(self, other)
    }
    
    /// Returns the squared Euclidean distance between this vector and another.
    @inlinable
    public func distanceSquared(to other: Self) -> Scalar {
        simd_distance_squared(self, other)
    }
    
    /// Returns the projection of this vector onto another vector.
    @inlinable
    public func project(onto other: Self) -> Self {
        simd_project(self, other)
    }
    
    /// Returns an approximate projection of this vector onto another vector.
    @inlinable
    public func projectFast(onto other: Self) -> Self {
        simd_fast_project(self, other)
    }
    
    /// Returns the dot product of this vector with another.
    @inlinable
    public func dot(with other: Self) -> Scalar {
        simd_dot(self, other)
    }
    
    /// Returns the 1-norm (sum of absolute values) of this vector.
    @inlinable
    public var normOne: Scalar {
        simd_norm_one(self)
    }
    
    /// Returns the infinity norm (maximum absolute value) of this vector.
    @inlinable
    public var normInf: Scalar {
        simd_norm_inf(self)
    }
    
    /// Returns a vector containing the absolute value of each scalar.
    @inlinable
    public var abs: Self {
        simd_abs(self)
    }
    
    /// Returns a vector containing the sign of each scalar (`-1`, `0`, or `1`).
    @inlinable
    public var sign: Self {
        simd_sign(self)
    }
    
    /**
     Returns an approximation of the reciprocal of each scalar.

     This property maps to ``recipFast`` if the compiler setting `-ffast-math` is specified, and to ``recipPrecise`` otherwise.
     */
    @inlinable
    public var recip: Self {
        simd_recip(self)
    }
    
    /**
     Returns a fast approximation of the reciprocal of each scalar.

     If the vector is very close to the limits of representation, the result may overflow or underflow; otherwise it is accurate to at least 22 bits.
     */
    @inlinable
    public var recipFast: Self {
        simd_fast_recip(self)
    }
    
    /**
     Returns a precise approximation of the reciprocal of each scalar.

     If the vector is very close to the limits of representation, the result may overflow or underflow; otherwise it is accurate to a few units in the last place (ULPs).
     */
    @inlinable
    public var recipPrecise: Self {
        simd_precise_recip(self)
    }
    
    /**
     Returns an approximation of the reciprocal square root of each scalar.

     This property maps to ``rsqrtFast`` if the compiler setting `-ffast-math` is specified, and to ``rsqrtPrecise`` otherwise.
     */
    @inlinable
    public var rsqrt: Self {
        simd_rsqrt(self)
    }
    
    /**
     Returns a fast approximation of the reciprocal square root of each scalar.

     It is accurate to at least 22 bits.
     */
    @inlinable
    public var rsqrtFast: Self {
        simd_fast_rsqrt(self)
    }
    
    /**
     Returns a precise approximation of the reciprocal square root of each scalar.

     It is accurate to a few units in the last place.
     */
    @inlinable
    public var rsqrtPrecise: Self {
        simd_precise_rsqrt(self)
    }
    
    /// Returns a vector containing the fractional part of each scalar.
    @inlinable
    public var fract: Self {
        simd_fract(self)
    }
    
    /// Returns the minimum of each scalar and the corresponding scalar in the other vector.
    @inlinable
    public func min(with other: Self) -> Self {
        simd_min(self, other)
    }
    
    /// Returns the maximum of each scalar and the corresponding scalar in the other vector.
    @inlinable
    public func max(with other: Self) -> Self {
        simd_max(self, other)
    }
    
    /// Returns a vector where each scalar is `0` if less than the corresponding scalar in `x`, or `1` otherwise.
    @inlinable
    public func step(at x: Self) -> Self {
        simd_step(self, x)
    }
        
    /// Returns a vector interpolated towards `other` using the per-component factor `amount` in the range 0…1.
    @inlinable
    public func interpolated(towards other: Self, amount: Self) -> Self {
        simd_smoothstep(self, other, amount)
    }

    /// Returns a vector interpolated towards `other` using the uniform factor `amount` in the range 0…1.
    @inlinable
    public func interpolated(towards other: Self, amount: Scalar) -> Self {
        simd_smoothstep(self, other, Self(repeating: amount))
    }

    /// Modifies this vector by interpolating it towards `other` using the per-component factor `amount` in the range 0…1.
    @inlinable
    public mutating func interpolate(towards other: Self, amount: Self) {
        self = simd_smoothstep(self, other, amount)
    }

    /// Modifies this vector by interpolating it towards `other` using the uniform factor `amount` in the range 0…1.
    @inlinable
    public mutating func interpolate(towards other: Self, amount: Scalar) {
        self = simd_smoothstep(self, other, Self(repeating: amount))
    }
}

extension SIMD4 where Scalar == Double {
    /// Returns the sum of the squares of the vector’s elements.
    @inlinable
    public var lengthSquared: Scalar {
        simd_length_squared(self)
    }

    /// Returns the Euclidean length of the vector using a precise square root.
    @inlinable
    public var length: Scalar {
        simd_length(self)
    }

    /// Returns an approximate Euclidean length of the vector using a faster, less precise algorithm.
    @inlinable
    public var lengthFast: Scalar {
        simd_fast_length(self)
    }
    
    /// Returns a unit-length vector pointing in the same direction as this vector.
    @inlinable
    public var normalized: Self {
        simd_normalize(self)
    }
    
    /// Returns an approximate unit-length vector pointing in the same direction as this vector using a faster, less precise algorithm.
    @inlinable
    public var normalizedFast: Self {
        simd_fast_normalize(self)
    }
    
    /// Returns the Euclidean distance between this vector and another.
    @inlinable
    public func distance(to other: Self) -> Scalar {
        simd_distance(self, other)
    }
    
    /// Returns an approximate Euclidean distance between this vector and another.
    @inlinable
    public func distanceFast(to other: Self) -> Scalar {
        simd_fast_distance(self, other)
    }
    
    /// Returns the squared Euclidean distance between this vector and another.
    @inlinable
    public func distanceSquared(to other: Self) -> Scalar {
        simd_distance_squared(self, other)
    }
    
    /// Returns the projection of this vector onto another vector.
    @inlinable
    public func project(onto other: Self) -> Self {
        simd_project(self, other)
    }
    
    /// Returns an approximate projection of this vector onto another vector.
    @inlinable
    public func projectFast(onto other: Self) -> Self {
        simd_fast_project(self, other)
    }
    
    /// Returns the dot product of this vector with another.
    @inlinable
    public func dot(with other: Self) -> Scalar {
        simd_dot(self, other)
    }
    
    /// Returns the 1-norm (sum of absolute values) of this vector.
    @inlinable
    public var normOne: Scalar {
        simd_norm_one(self)
    }
    
    /// Returns the infinity norm (maximum absolute value) of this vector.
    @inlinable
    public var normInf: Scalar {
        simd_norm_inf(self)
    }
    
    /// Returns a vector containing the absolute value of each scalar.
    @inlinable
    public var abs: Self {
        simd_abs(self)
    }
    
    /// Returns a vector containing the sign of each scalar (`-1`, `0`, or `1`).
    @inlinable
    public var sign: Self {
        simd_sign(self)
    }
    
    /**
     Returns an approximation of the reciprocal of each scalar.

     This property maps to ``recipFast`` if the compiler setting `-ffast-math` is specified, and to ``recipPrecise`` otherwise.
     */
    @inlinable
    public var recip: Self {
        simd_recip(self)
    }
    
    /**
     Returns a fast approximation of the reciprocal of each scalar.

     If the vector is very close to the limits of representation, the result may overflow or underflow; otherwise it is accurate to at least 22 bits.
     */
    @inlinable
    public var recipFast: Self {
        simd_fast_recip(self)
    }
    
    /**
     Returns a precise approximation of the reciprocal of each scalar.

     If the vector is very close to the limits of representation, the result may overflow or underflow; otherwise it is accurate to a few units in the last place (ULPs).
     */
    @inlinable
    public var recipPrecise: Self {
        simd_precise_recip(self)
    }
    
    /**
     Returns an approximation of the reciprocal square root of each scalar.

     This property maps to ``rsqrtFast`` if the compiler setting `-ffast-math` is specified, and to ``rsqrtPrecise`` otherwise.
     */
    @inlinable
    public var rsqrt: Self {
        simd_rsqrt(self)
    }
    
    /**
     Returns a fast approximation of the reciprocal square root of each scalar.

     It is accurate to at least 22 bits.
     */
    @inlinable
    public var rsqrtFast: Self {
        simd_fast_rsqrt(self)
    }
    
    /**
     Returns a precise approximation of the reciprocal square root of each scalar.

     It is accurate to a few units in the last place.
     */
    @inlinable
    public var rsqrtPrecise: Self {
        simd_precise_rsqrt(self)
    }
    
    /// Returns a vector containing the fractional part of each scalar.
    @inlinable
    public var fract: Self {
        simd_fract(self)
    }
    
    /// Returns the minimum of each scalar and the corresponding scalar in the other vector.
    @inlinable
    public func min(with other: Self) -> Self {
        simd_min(self, other)
    }
    
    /// Returns the maximum of each scalar and the corresponding scalar in the other vector.
    @inlinable
    public func max(with other: Self) -> Self {
        simd_max(self, other)
    }
    
    /// Returns a vector where each scalar is `0` if less than the corresponding scalar in `x`, or `1` otherwise.
    @inlinable
    public func step(at x: Self) -> Self {
        simd_step(self, x)
    }
        
    /// Returns a vector interpolated towards `other` using the per-component factor `amount` in the range 0…1.
    @inlinable
    public func interpolated(towards other: Self, amount: Self) -> Self {
        simd_smoothstep(self, other, amount)
    }

    /// Returns a vector interpolated towards `other` using the uniform factor `amount` in the range 0…1.
    @inlinable
    public func interpolated(towards other: Self, amount: Scalar) -> Self {
        simd_smoothstep(self, other, Self(repeating: amount))
    }

    /// Modifies this vector by interpolating it towards `other` using the per-component factor `amount` in the range 0…1.
    @inlinable
    public mutating func interpolate(towards other: Self, amount: Self) {
        self = simd_smoothstep(self, other, amount)
    }

    /// Modifies this vector by interpolating it towards `other` using the uniform factor `amount` in the range 0…1.
    @inlinable
    public mutating func interpolate(towards other: Self, amount: Scalar) {
        self = simd_smoothstep(self, other, Self(repeating: amount))
    }
}

extension SIMD4 where Scalar == Float {
    /// Returns the sum of the squares of the vector’s elements.
    @inlinable
    public var lengthSquared: Scalar {
        simd_length_squared(self)
    }

    /// Returns the Euclidean length of the vector using a precise square root.
    @inlinable
    public var length: Scalar {
        simd_length(self)
    }

    /// Returns an approximate Euclidean length of the vector using a faster, less precise algorithm.
    @inlinable
    public var lengthFast: Scalar {
        simd_fast_length(self)
    }
    
    /// Returns a unit-length vector pointing in the same direction as this vector.
    @inlinable
    public var normalized: Self {
        simd_normalize(self)
    }
    
    /// Returns an approximate unit-length vector pointing in the same direction as this vector using a faster, less precise algorithm.
    @inlinable
    public var normalizedFast: Self {
        simd_fast_normalize(self)
    }
    
    /// Returns the Euclidean distance between this vector and another.
    @inlinable
    public func distance(to other: Self) -> Scalar {
        simd_distance(self, other)
    }
    
    /// Returns an approximate Euclidean distance between this vector and another.
    @inlinable
    public func distanceFast(to other: Self) -> Scalar {
        simd_fast_distance(self, other)
    }
    
    /// Returns the squared Euclidean distance between this vector and another.
    @inlinable
    public func distanceSquared(to other: Self) -> Scalar {
        simd_distance_squared(self, other)
    }
    
    /// Returns the projection of this vector onto another vector.
    @inlinable
    public func project(onto other: Self) -> Self {
        simd_project(self, other)
    }
    
    /// Returns an approximate projection of this vector onto another vector.
    @inlinable
    public func projectFast(onto other: Self) -> Self {
        simd_fast_project(self, other)
    }
    
    /// Returns the dot product of this vector with another.
    @inlinable
    public func dot(with other: Self) -> Scalar {
        simd_dot(self, other)
    }
    
    /// Returns the 1-norm (sum of absolute values) of this vector.
    @inlinable
    public var normOne: Scalar {
        simd_norm_one(self)
    }
    
    /// Returns the infinity norm (maximum absolute value) of this vector.
    @inlinable
    public var normInf: Scalar {
        simd_norm_inf(self)
    }
    
    /// Returns a vector containing the absolute value of each scalar.
    @inlinable
    public var abs: Self {
        simd_abs(self)
    }
    
    /// Returns a vector containing the sign of each scalar (`-1`, `0`, or `1`).
    @inlinable
    public var sign: Self {
        simd_sign(self)
    }
    
    /**
     Returns an approximation of the reciprocal of each scalar.

     This property maps to ``recipFast`` if the compiler setting `-ffast-math` is specified, and to ``recipPrecise`` otherwise.
     */
    @inlinable
    public var recip: Self {
        simd_recip(self)
    }
    
    /**
     Returns a fast approximation of the reciprocal of each scalar.

     If the vector is very close to the limits of representation, the result may overflow or underflow; otherwise it is accurate to at least 22 bits.
     */
    @inlinable
    public var recipFast: Self {
        simd_fast_recip(self)
    }
    
    /**
     Returns a precise approximation of the reciprocal of each scalar.

     If the vector is very close to the limits of representation, the result may overflow or underflow; otherwise it is accurate to a few units in the last place (ULPs).
     */
    @inlinable
    public var recipPrecise: Self {
        simd_precise_recip(self)
    }
    
    /**
     Returns an approximation of the reciprocal square root of each scalar.

     This property maps to ``rsqrtFast`` if the compiler setting `-ffast-math` is specified, and to ``rsqrtPrecise`` otherwise.
     */
    @inlinable
    public var rsqrt: Self {
        simd_rsqrt(self)
    }
    
    /**
     Returns a fast approximation of the reciprocal square root of each scalar.

     It is accurate to at least 22 bits.
     */
    @inlinable
    public var rsqrtFast: Self {
        simd_fast_rsqrt(self)
    }
    
    /**
     Returns a precise approximation of the reciprocal square root of each scalar.

     It is accurate to a few units in the last place.
     */
    @inlinable
    public var rsqrtPrecise: Self {
        simd_precise_rsqrt(self)
    }
    
    /// Returns a vector containing the fractional part of each scalar.
    @inlinable
    public var fract: Self {
        simd_fract(self)
    }
    
    /// Returns the minimum of each scalar and the corresponding scalar in the other vector.
    @inlinable
    public func min(with other: Self) -> Self {
        simd_min(self, other)
    }
    
    /// Returns the maximum of each scalar and the corresponding scalar in the other vector.
    @inlinable
    public func max(with other: Self) -> Self {
        simd_max(self, other)
    }
    
    /// Returns a vector where each scalar is `0` if less than the corresponding scalar in `x`, or `1` otherwise.
    @inlinable
    public func step(at x: Self) -> Self {
        simd_step(self, x)
    }
        
    /// Returns a vector interpolated towards `other` using the per-component factor `amount` in the range 0…1.
    @inlinable
    public func interpolated(towards other: Self, amount: Self) -> Self {
        simd_smoothstep(self, other, amount)
    }

    /// Returns a vector interpolated towards `other` using the uniform factor `amount` in the range 0…1.
    @inlinable
    public func interpolated(towards other: Self, amount: Scalar) -> Self {
        simd_smoothstep(self, other, Self(repeating: amount))
    }

    /// Modifies this vector by interpolating it towards `other` using the per-component factor `amount` in the range 0…1.
    @inlinable
    public mutating func interpolate(towards other: Self, amount: Self) {
        self = simd_smoothstep(self, other, amount)
    }

    /// Modifies this vector by interpolating it towards `other` using the uniform factor `amount` in the range 0…1.
    @inlinable
    public mutating func interpolate(towards other: Self, amount: Scalar) {
        self = simd_smoothstep(self, other, Self(repeating: amount))
    }
}

extension SIMD8 where Scalar == Double {
    /// Returns the sum of the squares of the vector’s elements.
    @inlinable
    public var lengthSquared: Scalar {
        simd_length_squared(self)
    }

    /// Returns the Euclidean length of the vector using a precise square root.
    @inlinable
    public var length: Scalar {
        simd_length(self)
    }

    /// Returns an approximate Euclidean length of the vector using a faster, less precise algorithm.
    @inlinable
    public var lengthFast: Scalar {
        simd_fast_length(self)
    }
    
    /// Returns a unit-length vector pointing in the same direction as this vector.
    @inlinable
    public var normalized: Self {
        simd_normalize(self)
    }
    
    /// Returns an approximate unit-length vector pointing in the same direction as this vector using a faster, less precise algorithm.
    @inlinable
    public var normalizedFast: Self {
        simd_fast_normalize(self)
    }
    
    /// Returns the Euclidean distance between this vector and another.
    @inlinable
    public func distance(to other: Self) -> Scalar {
        simd_distance(self, other)
    }
    
    /// Returns an approximate Euclidean distance between this vector and another.
    @inlinable
    public func distanceFast(to other: Self) -> Scalar {
        simd_fast_distance(self, other)
    }
    
    /// Returns the squared Euclidean distance between this vector and another.
    @inlinable
    public func distanceSquared(to other: Self) -> Scalar {
        simd_distance_squared(self, other)
    }
    
    /// Returns the projection of this vector onto another vector.
    @inlinable
    public func project(onto other: Self) -> Self {
        simd_project(self, other)
    }
    
    /// Returns an approximate projection of this vector onto another vector.
    @inlinable
    public func projectFast(onto other: Self) -> Self {
        simd_fast_project(self, other)
    }
    
    /// Returns the dot product of this vector with another.
    @inlinable
    public func dot(with other: Self) -> Scalar {
        simd_dot(self, other)
    }
    
    /// Returns the 1-norm (sum of absolute values) of this vector.
    @inlinable
    public var normOne: Scalar {
        simd_norm_one(self)
    }
    
    /// Returns the infinity norm (maximum absolute value) of this vector.
    @inlinable
    public var normInf: Scalar {
        simd_norm_inf(self)
    }
    
    /// Returns a vector containing the absolute value of each scalar.
    @inlinable
    public var abs: Self {
        simd_abs(self)
    }
    
    /// Returns a vector containing the sign of each scalar (`-1`, `0`, or `1`).
    @inlinable
    public var sign: Self {
        simd_sign(self)
    }
    
    /**
     Returns an approximation of the reciprocal of each scalar.

     This property maps to ``recipFast`` if the compiler setting `-ffast-math` is specified, and to ``recipPrecise`` otherwise.
     */
    @inlinable
    public var recip: Self {
        simd_recip(self)
    }
    
    /**
     Returns a fast approximation of the reciprocal of each scalar.

     If the vector is very close to the limits of representation, the result may overflow or underflow; otherwise it is accurate to at least 22 bits.
     */
    @inlinable
    public var recipFast: Self {
        simd_fast_recip(self)
    }
    
    /**
     Returns a precise approximation of the reciprocal of each scalar.

     If the vector is very close to the limits of representation, the result may overflow or underflow; otherwise it is accurate to a few units in the last place (ULPs).
     */
    @inlinable
    public var recipPrecise: Self {
        simd_precise_recip(self)
    }
    
    /**
     Returns an approximation of the reciprocal square root of each scalar.

     This property maps to ``rsqrtFast`` if the compiler setting `-ffast-math` is specified, and to ``rsqrtPrecise`` otherwise.
     */
    @inlinable
    public var rsqrt: Self {
        simd_rsqrt(self)
    }
    
    /**
     Returns a fast approximation of the reciprocal square root of each scalar.

     It is accurate to at least 22 bits.
     */
    @inlinable
    public var rsqrtFast: Self {
        simd_fast_rsqrt(self)
    }
    
    /**
     Returns a precise approximation of the reciprocal square root of each scalar.

     It is accurate to a few units in the last place.
     */
    @inlinable
    public var rsqrtPrecise: Self {
        simd_precise_rsqrt(self)
    }
    
    /// Returns a vector containing the fractional part of each scalar.
    @inlinable
    public var fract: Self {
        simd_fract(self)
    }
    
    /// Returns the minimum of each scalar and the corresponding scalar in the other vector.
    @inlinable
    public func min(with other: Self) -> Self {
        simd_min(self, other)
    }
    
    /// Returns the maximum of each scalar and the corresponding scalar in the other vector.
    @inlinable
    public func max(with other: Self) -> Self {
        simd_max(self, other)
    }
    
    /// Returns a vector where each scalar is `0` if less than the corresponding scalar in `x`, or `1` otherwise.
    @inlinable
    public func step(at x: Self) -> Self {
        simd_step(self, x)
    }
        
    /// Returns a vector interpolated towards `other` using the per-component factor `amount` in the range 0…1.
    @inlinable
    public func interpolated(towards other: Self, amount: Self) -> Self {
        simd_smoothstep(self, other, amount)
    }

    /// Returns a vector interpolated towards `other` using the uniform factor `amount` in the range 0…1.
    @inlinable
    public func interpolated(towards other: Self, amount: Scalar) -> Self {
        simd_smoothstep(self, other, Self(repeating: amount))
    }

    /// Modifies this vector by interpolating it towards `other` using the per-component factor `amount` in the range 0…1.
    @inlinable
    public mutating func interpolate(towards other: Self, amount: Self) {
        self = simd_smoothstep(self, other, amount)
    }

    /// Modifies this vector by interpolating it towards `other` using the uniform factor `amount` in the range 0…1.
    @inlinable
    public mutating func interpolate(towards other: Self, amount: Scalar) {
        self = simd_smoothstep(self, other, Self(repeating: amount))
    }
}

extension SIMD8 where Scalar == Float {
    /// Returns the sum of the squares of the vector’s elements.
    @inlinable
    public var lengthSquared: Scalar {
        simd_length_squared(self)
    }

    /// Returns the Euclidean length of the vector using a precise square root.
    @inlinable
    public var length: Scalar {
        simd_length(self)
    }

    /// Returns an approximate Euclidean length of the vector using a faster, less precise algorithm.
    @inlinable
    public var lengthFast: Scalar {
        simd_fast_length(self)
    }
    
    /// Returns a unit-length vector pointing in the same direction as this vector.
    @inlinable
    public var normalized: Self {
        simd_normalize(self)
    }
    
    /// Returns an approximate unit-length vector pointing in the same direction as this vector using a faster, less precise algorithm.
    @inlinable
    public var normalizedFast: Self {
        simd_fast_normalize(self)
    }
    
    /// Returns the Euclidean distance between this vector and another.
    @inlinable
    public func distance(to other: Self) -> Scalar {
        simd_distance(self, other)
    }
    
    /// Returns an approximate Euclidean distance between this vector and another.
    @inlinable
    public func distanceFast(to other: Self) -> Scalar {
        simd_fast_distance(self, other)
    }
    
    /// Returns the squared Euclidean distance between this vector and another.
    @inlinable
    public func distanceSquared(to other: Self) -> Scalar {
        simd_distance_squared(self, other)
    }
    
    /// Returns the projection of this vector onto another vector.
    @inlinable
    public func project(onto other: Self) -> Self {
        simd_project(self, other)
    }
    
    /// Returns an approximate projection of this vector onto another vector.
    @inlinable
    public func projectFast(onto other: Self) -> Self {
        simd_fast_project(self, other)
    }
    
    /// Returns the dot product of this vector with another.
    @inlinable
    public func dot(with other: Self) -> Scalar {
        simd_dot(self, other)
    }
    
    /// Returns the 1-norm (sum of absolute values) of this vector.
    @inlinable
    public var normOne: Scalar {
        simd_norm_one(self)
    }
    
    /// Returns the infinity norm (maximum absolute value) of this vector.
    @inlinable
    public var normInf: Scalar {
        simd_norm_inf(self)
    }
    
    /// Returns a vector containing the absolute value of each scalar.
    @inlinable
    public var abs: Self {
        simd_abs(self)
    }
    
    /// Returns a vector containing the sign of each scalar (`-1`, `0`, or `1`).
    @inlinable
    public var sign: Self {
        simd_sign(self)
    }
    
    /**
     Returns an approximation of the reciprocal of each scalar.

     This property maps to ``recipFast`` if the compiler setting `-ffast-math` is specified, and to ``recipPrecise`` otherwise.
     */
    @inlinable
    public var recip: Self {
        simd_recip(self)
    }
    
    /**
     Returns a fast approximation of the reciprocal of each scalar.

     If the vector is very close to the limits of representation, the result may overflow or underflow; otherwise it is accurate to at least 22 bits.
     */
    @inlinable
    public var recipFast: Self {
        simd_fast_recip(self)
    }
    
    /**
     Returns a precise approximation of the reciprocal of each scalar.

     If the vector is very close to the limits of representation, the result may overflow or underflow; otherwise it is accurate to a few units in the last place (ULPs).
     */
    @inlinable
    public var recipPrecise: Self {
        simd_precise_recip(self)
    }
    
    /**
     Returns an approximation of the reciprocal square root of each scalar.

     This property maps to ``rsqrtFast`` if the compiler setting `-ffast-math` is specified, and to ``rsqrtPrecise`` otherwise.
     */
    @inlinable
    public var rsqrt: Self {
        simd_rsqrt(self)
    }
    
    /**
     Returns a fast approximation of the reciprocal square root of each scalar.

     It is accurate to at least 22 bits.
     */
    @inlinable
    public var rsqrtFast: Self {
        simd_fast_rsqrt(self)
    }
    
    /**
     Returns a precise approximation of the reciprocal square root of each scalar.

     It is accurate to a few units in the last place.
     */
    @inlinable
    public var rsqrtPrecise: Self {
        simd_precise_rsqrt(self)
    }
    
    /// Returns a vector containing the fractional part of each scalar.
    @inlinable
    public var fract: Self {
        simd_fract(self)
    }
    
    /// Returns the minimum of each scalar and the corresponding scalar in the other vector.
    @inlinable
    public func min(with other: Self) -> Self {
        simd_min(self, other)
    }
    
    /// Returns the maximum of each scalar and the corresponding scalar in the other vector.
    @inlinable
    public func max(with other: Self) -> Self {
        simd_max(self, other)
    }
    
    /// Returns a vector where each scalar is `0` if less than the corresponding scalar in `x`, or `1` otherwise.
    @inlinable
    public func step(at x: Self) -> Self {
        simd_step(self, x)
    }
        
    /// Returns a vector interpolated towards `other` using the per-component factor `amount` in the range 0…1.
    @inlinable
    public func interpolated(towards other: Self, amount: Self) -> Self {
        simd_smoothstep(self, other, amount)
    }

    /// Returns a vector interpolated towards `other` using the uniform factor `amount` in the range 0…1.
    @inlinable
    public func interpolated(towards other: Self, amount: Scalar) -> Self {
        simd_smoothstep(self, other, Self(repeating: amount))
    }

    /// Modifies this vector by interpolating it towards `other` using the per-component factor `amount` in the range 0…1.
    @inlinable
    public mutating func interpolate(towards other: Self, amount: Self) {
        self = simd_smoothstep(self, other, amount)
    }

    /// Modifies this vector by interpolating it towards `other` using the uniform factor `amount` in the range 0…1.
    @inlinable
    public mutating func interpolate(towards other: Self, amount: Scalar) {
        self = simd_smoothstep(self, other, Self(repeating: amount))
    }
}

extension SIMD16 where Scalar == Double {
    /// Returns the sum of the squares of the vector’s elements.
    @inlinable
    public var lengthSquared: Scalar {
        lowHalf.lengthSquared + highHalf.lengthSquared
    }

    /// Returns the Euclidean length of the vector using a precise square root.
    @inlinable
    public var length: Scalar {
        sqrt(lengthSquared)
    }

    /// Returns an approximate Euclidean length of the vector using a faster, less precise algorithm.
    @inlinable
    public var lengthFast: Scalar {
        let lowHalfLength = lowHalf.lengthFast
        let highHalfLength = highHalf.lengthFast
        return sqrt(lowHalfLength * lowHalfLength + highHalfLength * highHalfLength)
    }
    
    /// Returns a unit-length vector pointing in the same direction as this vector.
    @inlinable
    public var normalized: Self {
        self / length
    }
    
    /// Returns an approximate unit-length vector pointing in the same direction as this vector using a faster, less precise algorithm.
    @inlinable
    public var normalizedFast: Self {
        self / lengthFast
    }
    
    /// Returns the Euclidean distance between this vector and another.
    @inlinable
    public func distance(to other: Self) -> Scalar {
        (self - other).length
    }

    /// Returns an approximate Euclidean distance between this vector and another.
    @inlinable
    public func distanceFast(to other: Self) -> Scalar {
        (self - other).lengthFast
    }

    /// Returns the squared Euclidean distance between this vector and another.
    @inlinable
    public func distanceSquared(to other: Self) -> Scalar {
        let delta = self - other
        return delta.dot(with: delta)
    }

    /// Returns the projection of this vector onto another vector.
    @inlinable
    public func project(onto other: Self) -> Self {
        other * (dot(with: other) / other.dot(with: other))
    }

    /// Returns an approximate projection of this vector onto another vector.
    @inlinable
    public func projectFast(onto other: Self) -> Self {
        let otherLength = other.lengthFast
        return other * (dot(with: other) / (otherLength * otherLength))
    }

    /// Returns the dot product of this vector with another.
    @inlinable
    public func dot(with other: Self) -> Scalar {
        (self * other).sum()
    }

    /// Returns the 1-norm (sum of absolute values) of this vector.
    @inlinable
    public var normOne: Scalar {
        simd_abs(lowHalf).sum() + simd_abs(highHalf).sum()
    }

    /// Returns the infinity norm (maximum absolute value) of this vector.
    @inlinable
    public var normInf: Scalar {
        max(simd_abs(lowHalf).max(), simd_abs(highHalf).max())
    }
    
    /// Returns a vector containing the absolute value of each scalar.
    public var abs: Self {
        .init(lowHalf: lowHalf.abs, highHalf: highHalf.abs)
    }
    
    /// Returns a vector containing the sign of each scalar (`-1`, `0`, or `1`).
    public var sign: Self {
        .init(lowHalf: lowHalf.sign, highHalf: highHalf.sign)
    }
    
    /**
     Returns an approximation of the reciprocal of each scalar.

     This property maps to ``recipFast`` if the compiler setting `-ffast-math` is specified, and to ``recipPrecise`` otherwise.
     */
    public var recip: Self {
        .init(lowHalf: lowHalf.recip, highHalf: highHalf.recip)
    }
    
    /**
     Returns a fast approximation of the reciprocal of each scalar.

     If the vector is very close to the limits of representation, the result may overflow or underflow; otherwise it is accurate to at least 22 bits.
     */
    public var recipFast: Self {
        .init(lowHalf: lowHalf.recipFast, highHalf: highHalf.recipFast)
    }
    
    /**
     Returns a precise approximation of the reciprocal of each scalar.

     If the vector is very close to the limits of representation, the result may overflow or underflow; otherwise it is accurate to a few units in the last place (ULPs).
     */
    public var recipPrecise: Self {
        .init(lowHalf: lowHalf.recipPrecise, highHalf: highHalf.recipPrecise)
    }
    
    /**
     Returns an approximation of the reciprocal square root of each scalar.

     This property maps to ``rsqrtFast`` if the compiler setting `-ffast-math` is specified, and to ``rsqrtPrecise`` otherwise.
     */
    public var rsqrt: Self {
        .init(lowHalf: lowHalf.rsqrt, highHalf: highHalf.rsqrt)
    }
    
    /**
     Returns a fast approximation of the reciprocal square root of each scalar.

     It is accurate to at least 22 bits.
     */
    public var rsqrtFast: Self {
        .init(lowHalf: lowHalf.rsqrtFast, highHalf: highHalf.rsqrtFast)
    }
    
    /**
     Returns a precise approximation of the reciprocal square root of each scalar.

     It is accurate to a few units in the last place.
     */
    public var rsqrtPrecise: Self {
        .init(lowHalf: lowHalf.rsqrtPrecise, highHalf: highHalf.rsqrtPrecise)
    }
    
    /// Returns a vector containing the fractional part of each scalar.
    public var fract: Self {
        .init(lowHalf: lowHalf.fract, highHalf: highHalf.fract)
    }
    
    /// Returns the minimum of each scalar and the corresponding scalar in the other vector.
    public func min(with other: Self) -> Self {
        .init(lowHalf: lowHalf.min(with: other.lowHalf), highHalf: highHalf.min(with: other.highHalf))
    }
    
    /// Returns the maximum of each scalar and the corresponding scalar in the other vector.
    public func max(with other: Self) -> Self {
        .init(lowHalf: lowHalf.max(with: other.lowHalf), highHalf: highHalf.max(with: other.highHalf))
    }
    
    /// Returns a vector where each scalar is `0` if less than the corresponding scalar in `x`, or `1` otherwise.
    public func step(at x: Self) -> Self {
        .init(lowHalf: lowHalf.step(at: x.lowHalf), highHalf: highHalf.step(at: x.highHalf))
    }
    
    /// Returns a vector interpolated towards `other` using the per-component factor `amount` in the range 0…1.
    public func interpolated(towards other: Self, amount: Self) -> Self {
         .init(lowHalf: lowHalf.interpolated(towards: other.lowHalf, amount: amount.lowHalf), highHalf: highHalf.interpolated(towards: other.highHalf, amount: amount.highHalf))
    }

    /// Returns a vector interpolated towards `other` using the uniform factor `amount` in the range 0…1.
    public func interpolated(towards other: Self, amount: Scalar) -> Self {
        .init(lowHalf: lowHalf.interpolated(towards: other.lowHalf, amount: amount), highHalf: highHalf.interpolated(towards: other.highHalf, amount: amount))
    }

    /// Modifies this vector by interpolating it towards `other` using the per-component factor `amount` in the range 0…1.
    public mutating func interpolate(towards other: Self, amount: Self) {
        self = interpolated(towards: other, amount: amount)
    }

    /// Modifies this vector by interpolating it towards `other` using the uniform factor `amount` in the range 0…1.
    public mutating func interpolate(towards other: Self, amount: Scalar) {
        self = interpolated(towards: other, amount: amount)
    }
}

extension SIMD16 where Scalar == Float {
    /// Returns the sum of the squares of the vector’s elements.
    @inlinable
    public var lengthSquared: Scalar {
        simd_length_squared(self)
    }

    /// Returns the Euclidean length of the vector using a precise square root.
    @inlinable
    public var length: Scalar {
        simd_length(self)
    }

    /// Returns an approximate Euclidean length of the vector using a faster, less precise algorithm.
    @inlinable
    public var lengthFast: Scalar {
        simd_fast_length(self)
    }
    
    /// Returns a unit-length vector pointing in the same direction as this vector.
    @inlinable
    public var normalized: Self {
        simd_normalize(self)
    }
    
    /// Returns an approximate unit-length vector pointing in the same direction as this vector using a faster, less precise algorithm.
    @inlinable
    public var normalizedFast: Self {
        simd_fast_normalize(self)
    }
    
    /// Returns the Euclidean distance between this vector and another.
    @inlinable
    public func distance(to other: Self) -> Scalar {
        simd_distance(self, other)
    }
    
    /// Returns an approximate Euclidean distance between this vector and another.
    @inlinable
    public func distanceFast(to other: Self) -> Scalar {
        simd_fast_distance(self, other)
    }
    
    /// Returns the squared Euclidean distance between this vector and another.
    @inlinable
    public func distanceSquared(to other: Self) -> Scalar {
        simd_distance_squared(self, other)
    }
    
    /// Returns the projection of this vector onto another vector.
    @inlinable
    public func project(onto other: Self) -> Self {
        simd_project(self, other)
    }
    
    /// Returns an approximate projection of this vector onto another vector.
    @inlinable
    public func projectFast(onto other: Self) -> Self {
        simd_fast_project(self, other)
    }
    
    /// Returns the dot product of this vector with another.
    @inlinable
    public func dot(with other: Self) -> Scalar {
        simd_dot(self, other)
    }
    
    /// Returns the 1-norm (sum of absolute values) of this vector.
    @inlinable
    public var normOne: Scalar {
        simd_norm_one(self)
    }
    
    /// Returns the infinity norm (maximum absolute value) of this vector.
    @inlinable
    public var normInf: Scalar {
        simd_norm_inf(self)
    }
    
    /// Returns a vector containing the absolute value of each scalar.
    @inlinable
    public var abs: Self {
        simd_abs(self)
    }
    
    /// Returns a vector containing the sign of each scalar (`-1`, `0`, or `1`).
    @inlinable
    public var sign: Self {
        simd_sign(self)
    }
    
    /**
     Returns an approximation of the reciprocal of each scalar.

     This property maps to ``recipFast`` if the compiler setting `-ffast-math` is specified, and to ``recipPrecise`` otherwise.
     */
    @inlinable
    public var recip: Self {
        simd_recip(self)
    }
    
    /**
     Returns a fast approximation of the reciprocal of each scalar.

     If the vector is very close to the limits of representation, the result may overflow or underflow; otherwise it is accurate to at least 22 bits.
     */
    @inlinable
    public var recipFast: Self {
        simd_fast_recip(self)
    }
    
    /**
     Returns a precise approximation of the reciprocal of each scalar.

     If the vector is very close to the limits of representation, the result may overflow or underflow; otherwise it is accurate to a few units in the last place (ULPs).
     */
    @inlinable
    public var recipPrecise: Self {
        simd_precise_recip(self)
    }
    
    /**
     Returns an approximation of the reciprocal square root of each scalar.

     This property maps to ``rsqrtFast`` if the compiler setting `-ffast-math` is specified, and to ``rsqrtPrecise`` otherwise.
     */
    @inlinable
    public var rsqrt: Self {
        simd_rsqrt(self)
    }
    
    /**
     Returns a fast approximation of the reciprocal square root of each scalar.

     It is accurate to at least 22 bits.
     */
    @inlinable
    public var rsqrtFast: Self {
        simd_fast_rsqrt(self)
    }
    
    /**
     Returns a precise approximation of the reciprocal square root of each scalar.

     It is accurate to a few units in the last place.
     */
    @inlinable
    public var rsqrtPrecise: Self {
        simd_precise_rsqrt(self)
    }
    
    /// Returns a vector containing the fractional part of each scalar.
    @inlinable
    public var fract: Self {
        simd_fract(self)
    }
    
    /// Returns the minimum of each scalar and the corresponding scalar in the other vector.
    @inlinable
    public func min(with other: Self) -> Self {
        simd_min(self, other)
    }
    
    /// Returns the maximum of each scalar and the corresponding scalar in the other vector.
    @inlinable
    public func max(with other: Self) -> Self {
        simd_max(self, other)
    }
    
    /// Returns a vector where each scalar is `0` if less than the corresponding scalar in `x`, or `1` otherwise.
    @inlinable
    public func step(at x: Self) -> Self {
        simd_step(self, x)
    }
        
    /// Returns a vector interpolated towards `other` using the per-component factor `amount` in the range 0…1.
    @inlinable
    public func interpolated(towards other: Self, amount: Self) -> Self {
        simd_smoothstep(self, other, amount)
    }

    /// Returns a vector interpolated towards `other` using the uniform factor `amount` in the range 0…1.
    @inlinable
    public func interpolated(towards other: Self, amount: Scalar) -> Self {
        simd_smoothstep(self, other, Self(repeating: amount))
    }

    /// Modifies this vector by interpolating it towards `other` using the per-component factor `amount` in the range 0…1.
    @inlinable
    public mutating func interpolate(towards other: Self, amount: Self) {
        self = simd_smoothstep(self, other, amount)
    }

    /// Modifies this vector by interpolating it towards `other` using the uniform factor `amount` in the range 0…1.
    @inlinable
    public mutating func interpolate(towards other: Self, amount: Scalar) {
        self = simd_smoothstep(self, other, Self(repeating: amount))
    }
}

extension SIMD32 where Scalar == Double {
    /// Returns the sum of the squares of the vector’s elements.
    @inlinable
    public var lengthSquared: Scalar {
        lowHalf.lengthSquared + highHalf.lengthSquared
    }

    /// Returns the Euclidean length of the vector using a precise square root.
    @inlinable
    public var length: Scalar {
        sqrt(lengthSquared)
    }

    /// Returns an approximate Euclidean length of the vector using a faster, less precise algorithm.
    @inlinable
    public var lengthFast: Scalar {
        let lowHalfLength = lowHalf.lengthFast
        let highHalfLength = highHalf.lengthFast
        return sqrt(lowHalfLength * lowHalfLength + highHalfLength * highHalfLength)
    }
    
    /// Returns a unit-length vector pointing in the same direction as this vector.
    @inlinable
    public var normalized: Self {
        self / length
    }
    
    /// Returns an approximate unit-length vector pointing in the same direction as this vector using a faster, less precise algorithm.
    @inlinable
    public var normalizedFast: Self {
        self / lengthFast
    }
    
    /// Returns the Euclidean distance between this vector and another.
    @inlinable
    public func distance(to other: Self) -> Scalar {
        (self - other).length
    }

    /// Returns an approximate Euclidean distance between this vector and another.
    @inlinable
    public func distanceFast(to other: Self) -> Scalar {
        (self - other).lengthFast
    }

    /// Returns the squared Euclidean distance between this vector and another.
    @inlinable
    public func distanceSquared(to other: Self) -> Scalar {
        let delta = self - other
        return delta.dot(with: delta)
    }

    /// Returns the projection of this vector onto another vector.
    @inlinable
    public func project(onto other: Self) -> Self {
        other * (dot(with: other) / other.dot(with: other))
    }

    /// Returns an approximate projection of this vector onto another vector.
    @inlinable
    public func projectFast(onto other: Self) -> Self {
        let otherLength = other.lengthFast
        return other * (dot(with: other) / (otherLength * otherLength))
    }

    /// Returns the dot product of this vector with another.
    @inlinable
    public func dot(with other: Self) -> Scalar {
        (self * other).sum()
    }

    /// Returns the 1-norm (sum of absolute values) of this vector.
    @inlinable
    public var normOne: Scalar {
        lowHalf.abs.sum() + highHalf.abs.sum()
    }

    /// Returns the infinity norm (maximum absolute value) of this vector.
    @inlinable
    public var normInf: Scalar {
        max(lowHalf.abs.max(), highHalf.abs.max())
    }
    
    /// Returns a vector containing the absolute value of each scalar.
    public var abs: Self {
        .init(lowHalf: lowHalf.abs, highHalf: highHalf.abs)
    }
    
    /// Returns a vector containing the sign of each scalar (`-1`, `0`, or `1`).
    public var sign: Self {
        .init(lowHalf: lowHalf.sign, highHalf: highHalf.sign)
    }
    
    /**
     Returns an approximation of the reciprocal of each scalar.

     This property maps to ``recipFast`` if the compiler setting `-ffast-math` is specified, and to ``recipPrecise`` otherwise.
     */
    public var recip: Self {
        .init(lowHalf: lowHalf.recip, highHalf: highHalf.recip)
    }
    
    /**
     Returns a fast approximation of the reciprocal of each scalar.

     If the vector is very close to the limits of representation, the result may overflow or underflow; otherwise it is accurate to at least 22 bits.
     */
    public var recipFast: Self {
        .init(lowHalf: lowHalf.recipFast, highHalf: highHalf.recipFast)
    }
    
    /**
     Returns a precise approximation of the reciprocal of each scalar.

     If the vector is very close to the limits of representation, the result may overflow or underflow; otherwise it is accurate to a few units in the last place (ULPs).
     */
    public var recipPrecise: Self {
        .init(lowHalf: lowHalf.recipPrecise, highHalf: highHalf.recipPrecise)
    }
    
    /**
     Returns an approximation of the reciprocal square root of each scalar.

     This property maps to ``rsqrtFast`` if the compiler setting `-ffast-math` is specified, and to ``rsqrtPrecise`` otherwise.
     */
    public var rsqrt: Self {
        .init(lowHalf: lowHalf.rsqrt, highHalf: highHalf.rsqrt)
    }
    
    /**
     Returns a fast approximation of the reciprocal square root of each scalar.

     It is accurate to at least 22 bits.
     */
    public var rsqrtFast: Self {
        .init(lowHalf: lowHalf.rsqrtFast, highHalf: highHalf.rsqrtFast)
    }
    
    /**
     Returns a precise approximation of the reciprocal square root of each scalar.

     It is accurate to a few units in the last place.
     */
    public var rsqrtPrecise: Self {
        .init(lowHalf: lowHalf.rsqrtPrecise, highHalf: highHalf.rsqrtPrecise)
    }
    
    /// Returns a vector containing the fractional part of each scalar.
    public var fract: Self {
        .init(lowHalf: lowHalf.fract, highHalf: highHalf.fract)
    }
    
    /// Returns the minimum of each scalar and the corresponding scalar in the other vector.
    public func min(with other: Self) -> Self {
        .init(lowHalf: lowHalf.min(with: other.lowHalf), highHalf: highHalf.min(with: other.highHalf))
    }
    
    /// Returns the maximum of each scalar and the corresponding scalar in the other vector.
    public func max(with other: Self) -> Self {
        .init(lowHalf: lowHalf.max(with: other.lowHalf), highHalf: highHalf.max(with: other.highHalf))
    }
    
    /// Returns a vector where each scalar is `0` if less than the corresponding scalar in `x`, or `1` otherwise.
    public func step(at x: Self) -> Self {
        .init(lowHalf: lowHalf.step(at: x.lowHalf), highHalf: highHalf.step(at: x.highHalf))
    }
    
    /// Returns a vector interpolated towards `other` using the per-component factor `amount` in the range 0…1.
    public func interpolated(towards other: Self, amount: Self) -> Self {
         .init(lowHalf: lowHalf.interpolated(towards: other.lowHalf, amount: amount.lowHalf), highHalf: highHalf.interpolated(towards: other.highHalf, amount: amount.highHalf))
    }

    /// Returns a vector interpolated towards `other` using the uniform factor `amount` in the range 0…1.
    public func interpolated(towards other: Self, amount: Scalar) -> Self {
        .init(lowHalf: lowHalf.interpolated(towards: other.lowHalf, amount: amount), highHalf: highHalf.interpolated(towards: other.highHalf, amount: amount))
    }

    /// Modifies this vector by interpolating it towards `other` using the per-component factor `amount` in the range 0…1.
    public mutating func interpolate(towards other: Self, amount: Self) {
        self = interpolated(towards: other, amount: amount)
    }

    /// Modifies this vector by interpolating it towards `other` using the uniform factor `amount` in the range 0…1.
    public mutating func interpolate(towards other: Self, amount: Scalar) {
        self = interpolated(towards: other, amount: amount)
    }
}

extension SIMD32 where Scalar == Float {
    /// Returns the sum of the squares of the vector’s elements.
    @inlinable
    public var lengthSquared: Scalar {
        lowHalf.lengthSquared + highHalf.lengthSquared
    }

    /// Returns the Euclidean length of the vector using a precise square root.
    @inlinable
    public var length: Scalar {
        sqrt(lengthSquared)
    }

    /// Returns an approximate Euclidean length of the vector using a faster, less precise algorithm.
    @inlinable
    public var lengthFast: Scalar {
        let lowHalfLength = lowHalf.lengthFast
        let highHalfLength = highHalf.lengthFast
        return sqrt(lowHalfLength * lowHalfLength + highHalfLength * highHalfLength)
    }
    
    /// Returns a unit-length vector pointing in the same direction as this vector.
    @inlinable
    public var normalized: Self {
        self / length
    }
    
    /// Returns an approximate unit-length vector pointing in the same direction as this vector using a faster, less precise algorithm.
    @inlinable
    public var normalizedFast: Self {
        self / lengthFast
    }
    
    /// Returns the Euclidean distance between this vector and another.
    @inlinable
    public func distance(to other: Self) -> Scalar {
        (self - other).length
    }

    /// Returns an approximate Euclidean distance between this vector and another.
    @inlinable
    public func distanceFast(to other: Self) -> Scalar {
        (self - other).lengthFast
    }

    /// Returns the squared Euclidean distance between this vector and another.
    @inlinable
    public func distanceSquared(to other: Self) -> Scalar {
        let delta = self - other
        return delta.dot(with: delta)
    }

    /// Returns the projection of this vector onto another vector.
    @inlinable
    public func project(onto other: Self) -> Self {
        other * (dot(with: other) / other.dot(with: other))
    }

    /// Returns an approximate projection of this vector onto another vector.
    @inlinable
    public func projectFast(onto other: Self) -> Self {
        let otherLength = other.lengthFast
        return other * (dot(with: other) / (otherLength * otherLength))
    }

    /// Returns the dot product of this vector with another.
    @inlinable
    public func dot(with other: Self) -> Scalar {
        (self * other).sum()
    }

    /// Returns the 1-norm (sum of absolute values) of this vector.
    @inlinable
    public var normOne: Scalar {
        lowHalf.abs.sum() + highHalf.abs.sum()
    }

    /// Returns the infinity norm (maximum absolute value) of this vector.
    @inlinable
    public var normInf: Scalar {
        max(lowHalf.abs.max(), highHalf.abs.max())
    }
    
    /// Returns a vector containing the absolute value of each scalar.
    public var abs: Self {
        .init(lowHalf: lowHalf.abs, highHalf: highHalf.abs)
    }
    
    /// Returns a vector containing the sign of each scalar (`-1`, `0`, or `1`).
    public var sign: Self {
        .init(lowHalf: lowHalf.sign, highHalf: highHalf.sign)
    }
    
    /**
     Returns an approximation of the reciprocal of each scalar.

     This property maps to ``recipFast`` if the compiler setting `-ffast-math` is specified, and to ``recipPrecise`` otherwise.
     */
    public var recip: Self {
        .init(lowHalf: lowHalf.recip, highHalf: highHalf.recip)
    }
    
    /**
     Returns a fast approximation of the reciprocal of each scalar.

     If the vector is very close to the limits of representation, the result may overflow or underflow; otherwise it is accurate to at least 22 bits.
     */
    public var recipFast: Self {
        .init(lowHalf: lowHalf.recipFast, highHalf: highHalf.recipFast)
    }
    
    /**
     Returns a precise approximation of the reciprocal of each scalar.

     If the vector is very close to the limits of representation, the result may overflow or underflow; otherwise it is accurate to a few units in the last place (ULPs).
     */
    public var recipPrecise: Self {
        .init(lowHalf: lowHalf.recipPrecise, highHalf: highHalf.recipPrecise)
    }
    
    /**
     Returns an approximation of the reciprocal square root of each scalar.

     This property maps to ``rsqrtFast`` if the compiler setting `-ffast-math` is specified, and to ``rsqrtPrecise`` otherwise.
     */
    public var rsqrt: Self {
        .init(lowHalf: lowHalf.rsqrt, highHalf: highHalf.rsqrt)
    }
    
    /**
     Returns a fast approximation of the reciprocal square root of each scalar.

     It is accurate to at least 22 bits.
     */
    public var rsqrtFast: Self {
        .init(lowHalf: lowHalf.rsqrtFast, highHalf: highHalf.rsqrtFast)
    }
    
    /**
     Returns a precise approximation of the reciprocal square root of each scalar.

     It is accurate to a few units in the last place.
     */
    public var rsqrtPrecise: Self {
        .init(lowHalf: lowHalf.rsqrtPrecise, highHalf: highHalf.rsqrtPrecise)
    }
    
    /// Returns a vector containing the fractional part of each scalar.
    public var fract: Self {
        .init(lowHalf: lowHalf.fract, highHalf: highHalf.fract)
    }
    
    /// Returns the minimum of each scalar and the corresponding scalar in the other vector.
    public func min(with other: Self) -> Self {
        .init(lowHalf: lowHalf.min(with: other.lowHalf), highHalf: highHalf.min(with: other.highHalf))
    }
    
    /// Returns the maximum of each scalar and the corresponding scalar in the other vector.
    public func max(with other: Self) -> Self {
        .init(lowHalf: lowHalf.max(with: other.lowHalf), highHalf: highHalf.max(with: other.highHalf))
    }
    
    /// Returns a vector where each scalar is `0` if less than the corresponding scalar in `x`, or `1` otherwise.
    public func step(at x: Self) -> Self {
        .init(lowHalf: lowHalf.step(at: x.lowHalf), highHalf: highHalf.step(at: x.highHalf))
    }
    
    /// Returns a vector interpolated towards `other` using the per-component factor `amount` in the range 0…1.
    public func interpolated(towards other: Self, amount: Self) -> Self {
         .init(lowHalf: lowHalf.interpolated(towards: other.lowHalf, amount: amount.lowHalf), highHalf: highHalf.interpolated(towards: other.highHalf, amount: amount.highHalf))
    }

    /// Returns a vector interpolated towards `other` using the uniform factor `amount` in the range 0…1.
    public func interpolated(towards other: Self, amount: Scalar) -> Self {
        .init(lowHalf: lowHalf.interpolated(towards: other.lowHalf, amount: amount), highHalf: highHalf.interpolated(towards: other.highHalf, amount: amount))
    }

    /// Modifies this vector by interpolating it towards `other` using the per-component factor `amount` in the range 0…1.
    public mutating func interpolate(towards other: Self, amount: Self) {
        self = interpolated(towards: other, amount: amount)
    }

    /// Modifies this vector by interpolating it towards `other` using the uniform factor `amount` in the range 0…1.
    public mutating func interpolate(towards other: Self, amount: Scalar) {
        self = interpolated(towards: other, amount: amount)
    }
}

extension SIMD64 where Scalar == Double {
    /// Returns the sum of the squares of the vector’s elements.
    @inlinable
    public var lengthSquared: Scalar {
        lowHalf.lengthSquared + highHalf.lengthSquared
    }

    /// Returns the Euclidean length of the vector using a precise square root.
    @inlinable
    public var length: Scalar {
        sqrt(lengthSquared)
    }

    /// Returns an approximate Euclidean length of the vector using a faster, less precise algorithm.
    @inlinable
    public var lengthFast: Scalar {
        let lowHalfLength = lowHalf.lengthFast
        let highHalfLength = highHalf.lengthFast
        return sqrt(lowHalfLength * lowHalfLength + highHalfLength * highHalfLength)
    }
    
    /// Returns a unit-length vector pointing in the same direction as this vector.
    @inlinable
    public var normalized: Self {
        self / length
    }
    
    /// Returns an approximate unit-length vector pointing in the same direction as this vector using a faster, less precise algorithm.
    @inlinable
    public var normalizedFast: Self {
        self / lengthFast
    }
    
    /// Returns the Euclidean distance between this vector and another.
    @inlinable
    public func distance(to other: Self) -> Scalar {
        (self - other).length
    }

    /// Returns an approximate Euclidean distance between this vector and another.
    @inlinable
    public func distanceFast(to other: Self) -> Scalar {
        (self - other).lengthFast
    }

    /// Returns the squared Euclidean distance between this vector and another.
    @inlinable
    public func distanceSquared(to other: Self) -> Scalar {
        let delta = self - other
        return delta.dot(with: delta)
    }

    /// Returns the projection of this vector onto another vector.
    @inlinable
    public func project(onto other: Self) -> Self {
        other * (dot(with: other) / other.dot(with: other))
    }

    /// Returns an approximate projection of this vector onto another vector.
    @inlinable
    public func projectFast(onto other: Self) -> Self {
        let otherLength = other.lengthFast
        return other * (dot(with: other) / (otherLength * otherLength))
    }

    /// Returns the dot product of this vector with another.
    @inlinable
    public func dot(with other: Self) -> Scalar {
        (self * other).sum()
    }

    /// Returns the 1-norm (sum of absolute values) of this vector.
    @inlinable
    public var normOne: Scalar {
        lowHalf.abs.sum() + highHalf.abs.sum()
    }

    /// Returns the infinity norm (maximum absolute value) of this vector.
    @inlinable
    public var normInf: Scalar {
        max(lowHalf.abs.max(), highHalf.abs.max())
    }
    
    /// Returns a vector containing the absolute value of each scalar.
    public var abs: Self {
        .init(lowHalf: lowHalf.abs, highHalf: highHalf.abs)
    }
    
    /// Returns a vector containing the sign of each scalar (`-1`, `0`, or `1`).
    public var sign: Self {
        .init(lowHalf: lowHalf.sign, highHalf: highHalf.sign)
    }
    
    /**
     Returns an approximation of the reciprocal of each scalar.

     This property maps to ``recipFast`` if the compiler setting `-ffast-math` is specified, and to ``recipPrecise`` otherwise.
     */
    public var recip: Self {
        .init(lowHalf: lowHalf.recip, highHalf: highHalf.recip)
    }
    
    /**
     Returns a fast approximation of the reciprocal of each scalar.

     If the vector is very close to the limits of representation, the result may overflow or underflow; otherwise it is accurate to at least 22 bits.
     */
    public var recipFast: Self {
        .init(lowHalf: lowHalf.recipFast, highHalf: highHalf.recipFast)
    }
    
    /**
     Returns a precise approximation of the reciprocal of each scalar.

     If the vector is very close to the limits of representation, the result may overflow or underflow; otherwise it is accurate to a few units in the last place (ULPs).
     */
    public var recipPrecise: Self {
        .init(lowHalf: lowHalf.recipPrecise, highHalf: highHalf.recipPrecise)
    }
    
    /**
     Returns an approximation of the reciprocal square root of each scalar.

     This property maps to ``rsqrtFast`` if the compiler setting `-ffast-math` is specified, and to ``rsqrtPrecise`` otherwise.
     */
    public var rsqrt: Self {
        .init(lowHalf: lowHalf.rsqrt, highHalf: highHalf.rsqrt)
    }
    
    /**
     Returns a fast approximation of the reciprocal square root of each scalar.

     It is accurate to at least 22 bits.
     */
    public var rsqrtFast: Self {
        .init(lowHalf: lowHalf.rsqrtFast, highHalf: highHalf.rsqrtFast)
    }
    
    /**
     Returns a precise approximation of the reciprocal square root of each scalar.

     It is accurate to a few units in the last place.
     */
    public var rsqrtPrecise: Self {
        .init(lowHalf: lowHalf.rsqrtPrecise, highHalf: highHalf.rsqrtPrecise)
    }
    
    /// Returns a vector containing the fractional part of each scalar.
    public var fract: Self {
        .init(lowHalf: lowHalf.fract, highHalf: highHalf.fract)
    }
    
    /// Returns the minimum of each scalar and the corresponding scalar in the other vector.
    public func min(with other: Self) -> Self {
        .init(lowHalf: lowHalf.min(with: other.lowHalf), highHalf: highHalf.min(with: other.highHalf))
    }
    
    /// Returns the maximum of each scalar and the corresponding scalar in the other vector.
    public func max(with other: Self) -> Self {
        .init(lowHalf: lowHalf.max(with: other.lowHalf), highHalf: highHalf.max(with: other.highHalf))
    }
    
    /// Returns a vector where each scalar is `0` if less than the corresponding scalar in `x`, or `1` otherwise.
    public func step(at x: Self) -> Self {
        .init(lowHalf: lowHalf.step(at: x.lowHalf), highHalf: highHalf.step(at: x.highHalf))
    }
    
    /// Returns a vector interpolated towards `other` using the per-component factor `amount` in the range 0…1.
    public func interpolated(towards other: Self, amount: Self) -> Self {
         .init(lowHalf: lowHalf.interpolated(towards: other.lowHalf, amount: amount.lowHalf), highHalf: highHalf.interpolated(towards: other.highHalf, amount: amount.highHalf))
    }

    /// Returns a vector interpolated towards `other` using the uniform factor `amount` in the range 0…1.
    public func interpolated(towards other: Self, amount: Scalar) -> Self {
        .init(lowHalf: lowHalf.interpolated(towards: other.lowHalf, amount: amount), highHalf: highHalf.interpolated(towards: other.highHalf, amount: amount))
    }

    /// Modifies this vector by interpolating it towards `other` using the per-component factor `amount` in the range 0…1.
    public mutating func interpolate(towards other: Self, amount: Self) {
        self = interpolated(towards: other, amount: amount)
    }

    /// Modifies this vector by interpolating it towards `other` using the uniform factor `amount` in the range 0…1.
    public mutating func interpolate(towards other: Self, amount: Scalar) {
        self = interpolated(towards: other, amount: amount)
    }
}

extension SIMD64 where Scalar == Float {
    /// Returns the sum of the squares of the vector’s elements.
    @inlinable
    public var lengthSquared: Scalar {
        lowHalf.lengthSquared + highHalf.lengthSquared
    }

    /// Returns the Euclidean length of the vector using a precise square root.
    @inlinable
    public var length: Scalar {
        sqrt(lengthSquared)
    }

    /// Returns an approximate Euclidean length of the vector using a faster, less precise algorithm.
    @inlinable
    public var lengthFast: Scalar {
        let lowHalfLength = lowHalf.lengthFast
        let highHalfLength = highHalf.lengthFast
        return sqrt(lowHalfLength * lowHalfLength + highHalfLength * highHalfLength)
    }
    
    /// Returns a unit-length vector pointing in the same direction as this vector.
    @inlinable
    public var normalized: Self {
        self / length
    }
    
    /// Returns an approximate unit-length vector pointing in the same direction as this vector using a faster, less precise algorithm.
    @inlinable
    public var normalizedFast: Self {
        self / lengthFast
    }
    
    /// Returns the Euclidean distance between this vector and another.
    @inlinable
    public func distance(to other: Self) -> Scalar {
        (self - other).length
    }

    /// Returns an approximate Euclidean distance between this vector and another.
    @inlinable
    public func distanceFast(to other: Self) -> Scalar {
        (self - other).lengthFast
    }

    /// Returns the squared Euclidean distance between this vector and another.
    @inlinable
    public func distanceSquared(to other: Self) -> Scalar {
        let delta = self - other
        return delta.dot(with: delta)
    }

    /// Returns the projection of this vector onto another vector.
    @inlinable
    public func project(onto other: Self) -> Self {
        other * (dot(with: other) / other.dot(with: other))
    }

    /// Returns an approximate projection of this vector onto another vector.
    @inlinable
    public func projectFast(onto other: Self) -> Self {
        let otherLength = other.lengthFast
        return other * (dot(with: other) / (otherLength * otherLength))
    }

    /// Returns the dot product of this vector with another.
    @inlinable
    public func dot(with other: Self) -> Scalar {
        (self * other).sum()
    }

    /// Returns the 1-norm (sum of absolute values) of this vector.
    @inlinable
    public var normOne: Scalar {
        lowHalf.abs.sum() + highHalf.abs.sum()
    }

    /// Returns the infinity norm (maximum absolute value) of this vector.
    @inlinable
    public var normInf: Scalar {
        max(lowHalf.abs.max(), highHalf.abs.max())
    }
}

extension SIMD2 where Scalar == Double {
    /**
     Tests whether this point lies inside, on, or outside the circumcircle defined by three points.

     - Parameters:
       - a: The first point defining the circumcircle.
       - b: The second point defining the circumcircle.
       - c: The third point defining the circumcircle.
     - Returns: A positive value if this point is inside the circumcircle, zero if on it, and negative if outside; the sign flips if the triangle (a, b, c) is negatively oriented.
     */
    @inlinable
    public func inCircumcircle(_ a: Self, _ b: Self, _ c: Self) -> Scalar {
        simd_incircle(self, a, b, c)
    }
    
    /**
     Returns the orientation of two 2D vectors.
     
     - Parameters:
        - x: The first vector.
        - y: The second vector.
     - Returns: A positive value, if `(x, y)` are positively oriented, `zero` if they are colinear, and a negative value if they are negatively oriented.
            
        In 2D, "positively oriented" means the sequence `(0, x, y)` proceeds counter-clockwise when viewed along the positive z-axis, or equivalently, the cross product of `x` and `y` extended to 3D has a positive z-component.
     */
    @inlinable
    public static func orientiation(of x: Self, _ y: Self) -> Scalar {
        simd_orient(x, y)
    }
    
    /**
     Returns the orientation of a triangle defined by the specified points.
          
     - Parameters:
        - a: The first point of the triangle.
        - b: The second point of the triangle.
        - c: The third point of the triangle.
     - Returns: A positive value if the triangle is positively oriented, `zero` if it is degenerate (three points in a line), and a negative value if it is negatively oriented.
            
        "Positively oriented" means `(a, b, c)` proceeds counter-clockwise along the positive z-axis, or equivalently, the cross product of `a-c` and `b-c` extended to 3D has a positive z-component.
     */
    @inlinable
    public static func orientiation(of a: Self, _ b: Self, _ c: Self) -> Scalar {
        simd_orient(a, b, c)
    }
}

extension SIMD2 where Scalar == Float {
    /**
     Tests whether this point lies inside, on, or outside the circumcircle defined by three points.

     - Parameters:
       - a: The first point defining the circumcircle.
       - b: The second point defining the circumcircle.
       - c: The third point defining the circumcircle.
     - Returns: A positive value if this point is inside the circumcircle, zero if on it, and negative if outside; the sign flips if the triangle (a, b, c) is negatively oriented.
     */
    @inlinable
    public func inCircumcircle(_ a: Self, _ b: Self, _ c: Self) -> Scalar {
        simd_incircle(self, a, b, c)
    }
    
    /**
     Returns the orientation of two 2D vectors.
     
     - Parameters:
        - x: The first vector.
        - y: The second vector.
     - Returns: A positive value, if `(x, y)` are positively oriented, `zero` if they are colinear, and a negative value if they are negatively oriented.
            
        In 2D, "positively oriented" means the sequence `(0, x, y)` proceeds counter-clockwise when viewed along the positive z-axis, or equivalently, the cross product of `x` and `y` extended to 3D has a positive z-component.
     */
    @inlinable
    public static func orientiation(of x: Self, _ y: Self) -> Scalar {
        simd_orient(x, y)
    }
    
    /**
     Returns the orientation of a triangle defined by the specified points.
          
     - Parameters:
        - a: The first point of the triangle.
        - b: The second point of the triangle.
        - c: The third point of the triangle.
     - Returns: A positive value if the triangle is positively oriented, `zero` if it is degenerate (three points in a line), and a negative value if it is negatively oriented.
            
        "Positively oriented" means `(a, b, c)` proceeds counter-clockwise along the positive z-axis, or equivalently, the cross product of `a-c` and `b-c` extended to 3D has a positive z-component.
     */
    @inlinable
    public static func orientiation(of a: Self, _ b: Self, _ c: Self) -> Scalar {
        simd_orient(a, b, c)
    }
}

extension SIMD3 where Scalar == Double {
    /**
     Tests whether this point lies inside, on, or outside the circumsphere defined by four points.

     - Parameters:
       - a: The first point defining the circumsphere.
       - b: The second point defining the circumsphere.
       - c: The third point defining the circumsphere.
       - d: The fourth point defining the circumsphere.
     - Returns: A positive value if this point is inside the circumsphere, zero if on it, and negative if outside; the sign flips if the points are negatively oriented.
     */
    @inlinable
    public func inCircumsphere(_ a: Self, _ b: Self, _ c: Self, _ d: Self) -> Scalar {
       simd_insphere(self, a, b, c, d)
    }
    
    /**
     Returns the orientation of three 3D vectors.

     - Parameters:
        - x: The first vector.
        - y: The second vector.
        - z: The third vector.
     - Returns: A positive value if `(x, y, z)` are positively oriented, zero if they are collinear, and a negative value if they are negatively oriented.
            
        "Positively oriented" in 3D means vectors `x`, `y`, and `z` follow the right-hand rule, or equivalently, the dot product of `z` with the cross product of `x` and `y` is positive.
     */
    @inlinable
    public static func orientiation(of x: Self, _ y: Self, _ z: Self) -> Scalar {
        simd_orient(x, y, z)
    }
    
    /**
     Returns the orientation of a tetrahedron defined by the specified four points.

     - Parameters:
        - a: The first point of the tetrahedron.
        - b: The second point of the tetrahedron.
        - c: The third point of the tetrahedron.
        - d: The fourth point of the tetrahedron.
     - Returns: A positive value if the tetrahedron is positively oriented, `zero` if it is degenerate (four points in a plane), and a negative value if it is negatively oriented.
     
        "Positively oriented" means vectors `(a-d, b-d, c-d)` follow the right-hand rule, or equivalently, the dot product of `c-d` with the cross product of `a-d` and `b-d` is positive.
     */
    @inlinable
    public static func orientiation(of a: Self, _ b: Self, _ c: Self, _ d: Self) -> Scalar {
        simd_orient(a, b, c, d)
    }
}

extension SIMD3 where Scalar == Float {
    /**
     Tests whether this point lies inside, on, or outside the circumsphere defined by four points.

     - Parameters:
       - a: The first point defining the circumsphere.
       - b: The second point defining the circumsphere.
       - c: The third point defining the circumsphere.
       - d: The fourth point defining the circumsphere.
     - Returns: A positive value if this point is inside the circumsphere, zero if on it, and negative if outside; the sign flips if the points are negatively oriented.
     */
    @inlinable
    public func inCircumsphere(_ a: Self, _ b: Self, _ c: Self, _ d: Self) -> Scalar {
       simd_insphere(self, a, b, c, d)
    }
    
    /**
     Returns the orientation of three 3D vectors.

     - Parameters:
        - x: The first vector.
        - y: The second vector.
        - z: The third vector.
     - Returns: A positive value if `(x, y, z)` are positively oriented, zero if they are collinear, and a negative value if they are negatively oriented.
            
        "Positively oriented" in 3D means vectors `x`, `y`, and `z` follow the right-hand rule, or equivalently, the dot product of `z` with the cross product of `x` and `y` is positive.
     */
    @inlinable
    public static func orientiation(of x: Self, _ y: Self, _ z: Self) -> Scalar {
        simd_orient(x, y, z)
    }
    
    /**
     Returns the orientation of a tetrahedron defined by the specified four points.

     - Parameters:
        - a: The first point of the tetrahedron.
        - b: The second point of the tetrahedron.
        - c: The third point of the tetrahedron.
        - d: The fourth point of the tetrahedron.
     - Returns: A positive value if the tetrahedron is positively oriented, `zero` if it is degenerate (four points in a plane), and a negative value if it is negatively oriented.
     
        "Positively oriented" means vectors `(a-d, b-d, c-d)` follow the right-hand rule, or equivalently, the dot product of `c-d` with the cross product of `a-d` and `b-d` is positive.
     */
    @inlinable
    public static func orientiation(of a: Self, _ b: Self, _ c: Self, _ d: Self) -> Scalar {
        simd_orient(a, b, c, d)
    }
}

// MARK: - VectorArithmetic

extension SIMD2: SwiftUI.VectorArithmetic where Scalar == Double {
    @inlinable
    public mutating func scale(by rhs: Double) {
        self *= rhs
    }
    
    @inlinable
    public var magnitudeSquared: Double {
        simd_length_squared(self)
    }
}

extension SIMD3: SwiftUI.VectorArithmetic where Scalar == Double {
    @inlinable
    public mutating func scale(by rhs: Double) {
        self *= rhs
    }
    
    @inlinable
    public var magnitudeSquared: Double {
        simd_length_squared(self)
    }
}

extension SIMD4: SwiftUI.VectorArithmetic where Scalar == Double {
    @inlinable
    public mutating func scale(by rhs: Double) {
        self *= rhs
    }
    
    @inlinable
    public var magnitudeSquared: Double {
        simd_length_squared(self)
    }
}

extension SIMD8: SwiftUI.VectorArithmetic where Scalar == Double {
    @inlinable
    public mutating func scale(by rhs: Double) {
        self *= rhs
    }
    
    @inlinable
    public var magnitudeSquared: Double {
        simd_length_squared(self)
    }
}

extension SIMD16: SwiftUI.VectorArithmetic where Scalar == Double {
    @inlinable
    public mutating func scale(by rhs: Double) {
        self *= rhs
    }
    
    @inlinable
    public var magnitudeSquared: Double {
        lowHalf.magnitudeSquared + highHalf.magnitudeSquared
    }
}

extension SIMD32: SwiftUI.VectorArithmetic where Scalar == Double {
    @inlinable
    public mutating func scale(by rhs: Double) {
        self *= rhs
    }
    
    @inlinable
    public var magnitudeSquared: Double {
        lowHalf.magnitudeSquared + highHalf.magnitudeSquared
    }
}

extension SIMD64: SwiftUI.VectorArithmetic where Scalar == Double {
    @inlinable
    public mutating func scale(by rhs: Double) {
        self *= rhs
    }
    
    @inlinable
    public var magnitudeSquared: Double {
        lowHalf.magnitudeSquared + highHalf.magnitudeSquared
    }
}

/*
extension SIMD8 where Scalar: AdditiveArithmetic {
    /// Creates a new vector from the given elements.
    init(_ v0: Scalar, _ v1: Scalar) {
        self.init(v0, v1, .zero, .zero, .zero, .zero, .zero, .zero)
    }
    
    /// Creates a new vector from the given elements.
    init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar) {
        self.init(v0, v1, v2, .zero, .zero, .zero, .zero, .zero)
    }
    
    /// Creates a new vector from the given elements.
    init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar) {
        self.init(v0, v1, v2, v3, .zero, .zero, .zero, .zero)
    }
    
    /// Creates a new vector from the given elements.
    init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar, _ v4: Scalar) {
        self.init(v0, v1, v2, v3, v4, .zero, .zero, .zero)
    }
    
    /// Creates a new vector from the given elements.
    init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar, _ v4: Scalar, _ v5: Scalar) {
        self.init(v0, v1, v2, v3, v4, v5, .zero, .zero)
    }
    
    /// Creates a new vector from the given elements.
    init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar, _ v4: Scalar, _ v5: Scalar, _ v6: Scalar) {
        self.init(v0, v1, v2, v3, v4, v5, v6, .zero)
    }
}

extension SIMD16 where Scalar: AdditiveArithmetic {
    /// Creates a new vector from the given elements.
    init(_ v0: Scalar, _ v1: Scalar) {
        self.init(v0, v1, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero)
    }
    
    /// Creates a new vector from the given elements.
    init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar) {
        self.init(v0, v1, v2, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero)
    }
    
    /// Creates a new vector from the given elements.
    init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar) {
        self.init(v0, v1, v2, v3, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero)
    }
    
    /// Creates a new vector from the given elements.
    init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar, _ v4: Scalar) {
        self.init(v0, v1, v2, v3, v4, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero)
    }
    
    /// Creates a new vector from the given elements.
    init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar, _ v4: Scalar, _ v5: Scalar) {
        self.init(v0, v1, v2, v3, v4, v5, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero)
    }
    
    /// Creates a new vector from the given elements.
    init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar, _ v4: Scalar, _ v5: Scalar, _ v6: Scalar) {
        self.init(v0, v1, v2, v3, v4, v5, v6, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero)
    }
    
    /// Creates a new vector from the given elements.
    init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar, _ v4: Scalar, _ v5: Scalar, _ v6: Scalar, _ v7: Scalar) {
        self.init(v0, v1, v2, v3, v4, v5, v6, v7, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero)
    }
    
    /// Creates a new vector from the given elements.
    init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar, _ v4: Scalar, _ v5: Scalar, _ v6: Scalar, _ v7: Scalar, _ v8: Scalar) {
        self.init(v0, v1, v2, v3, v4, v5, v6, v7, v8, .zero, .zero, .zero, .zero, .zero, .zero, .zero)
    }
    
    /// Creates a new vector from the given elements.
    init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar, _ v4: Scalar, _ v5: Scalar, _ v6: Scalar, _ v7: Scalar, _ v8: Scalar, _ v9: Scalar) {
        self.init(v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, .zero, .zero, .zero, .zero, .zero, .zero)
    }
    
    /// Creates a new vector from the given elements.
    init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar, _ v4: Scalar, _ v5: Scalar, _ v6: Scalar, _ v7: Scalar, _ v8: Scalar, _ v9: Scalar, _ v10: Scalar) {
        self.init(v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, .zero, .zero, .zero, .zero, .zero)
    }
    
    /// Creates a new vector from the given elements.
    init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar, _ v4: Scalar, _ v5: Scalar, _ v6: Scalar, _ v7: Scalar, _ v8: Scalar, _ v9: Scalar, _ v10: Scalar, _ v11: Scalar) {
        self.init(v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, .zero, .zero, .zero, .zero)
    }
    
    /// Creates a new vector from the given elements.
    init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar, _ v4: Scalar, _ v5: Scalar, _ v6: Scalar, _ v7: Scalar, _ v8: Scalar, _ v9: Scalar, _ v10: Scalar, _ v11: Scalar, _ v12: Scalar) {
        self.init(v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, .zero, .zero, .zero)
    }
    
    /// Creates a new vector from the given elements.
    init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar, _ v4: Scalar, _ v5: Scalar, _ v6: Scalar, _ v7: Scalar, _ v8: Scalar, _ v9: Scalar, _ v10: Scalar, _ v11: Scalar, _ v12: Scalar, _ v13: Scalar) {
        self.init(v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, .zero, .zero)
    }
    
    /// Creates a new vector from the given elements.
    init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar, _ v4: Scalar, _ v5: Scalar, _ v6: Scalar, _ v7: Scalar, _ v8: Scalar, _ v9: Scalar, _ v10: Scalar, _ v11: Scalar, _ v12: Scalar, _ v13: Scalar, _ v14: Scalar) {
        self.init(v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, .zero)
    }
}
*/
