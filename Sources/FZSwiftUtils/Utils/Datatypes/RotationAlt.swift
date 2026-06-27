//
//  RotationAlt.swift
//  FZSwiftUtils
//
//  Created by Florian Zand on 27.06.26.
//

import Foundation
import simd

/**
 Represents a three-dimensional rotation.

 `Rotation` stores the represented orientation as a quaternion and exposes
 Euler-angle and axis-angle views as conveniences.
 */
public struct RotationAlt: Hashable, Codable, Sendable, CustomStringConvertible, ApproximateEquatable, Interpolatable {

    /// The quaternion representing the rotation.
    public var quaternion: simd_quatd

    /**
     The Euler-angle representation expressed in radians.

     Setting this property updates ``quaternion`` using ``anglesOrder``.
     */
    public var radians: Angles {
        get { quaternion.eulerAngles(order: anglesOrder) }
        set { quaternion = simd_quatd(eulerAngles: newValue, order: anglesOrder) }
    }

    /**
     The Euler-angle representation expressed in degrees.

     Setting this property updates ``quaternion`` using ``anglesOrder``.
     */
    public var degrees: Angles {
        get { radians.degrees }
        set { radians = newValue.radians }
    }
    
    /**
     The Euler-angle order used by ``radians`` and ``degrees``.

     Changing this value does not modify the represented rotation. It only changes how the quaternion is converted to and from Euler angles.
     
     The default value is ``AnglesOrder/xyz``.
     */
    public var anglesOrder: AnglesOrder = .xyz
    
    /// The order used when converting between Euler angles and the quaternion.
    public enum AnglesOrder: Hashable, Codable, CustomStringConvertible, Sendable {
        /// xyz
        case xyz
        /// zyx
        case zyx
        
        public var description: String {
            self == .xyz ? "xyz" : "zyx"
        }
    }

    /**
     The axis of rotation.

     Together with ``angle``, this forms the axis-angle representation.
     */
    public var axis: Axis {
        get {
            let axis = quaternion.axis
            return .init(x: CGFloat(axis.x), y: CGFloat(axis.y), z: CGFloat(axis.z))
        }
        set {
            quaternion = simd_quatd(angle: quaternion.angle, axis: simd.normalize(newValue.simdValue))
        }
    }

    /// The angle of the rotation.
    public var angle: Angle {
        get { .radians(CGFloat(quaternion.angle)) }
        set { quaternion = simd_quatd(angle: Double(newValue.radians), axis: quaternion.axis) }
    }

    /// A rotation whose quaternion is normalized.
    public var normalized: Self {
        var normalized = Self(quaternion: quaternion.normalized)
        normalized.anglesOrder = anglesOrder
        return normalized
    }

    /// Normalizes the quaternion.
    public mutating func normalize() {
        quaternion = quaternion.normalized
    }
    
    /// The inverse rotation.
    public var inverted: Self {
        var inverted = Self(quaternion: quaternion.inverse)
        inverted.anglesOrder = anglesOrder
        return inverted
    }

    // Inverts the rotation.
    public mutating func invert() {
        self = inverted
    }
    
    public func isApproximatelyEqual(to other: Self, epsilon: CGFloat = sqrt(.ulpOfOne)) -> Bool {
        let lhs = quaternion.normalized
        let rhs = other.quaternion.normalized
        let dot = abs(lhs.real * rhs.real + lhs.imag.x * rhs.imag.x + lhs.imag.y * rhs.imag.y + lhs.imag.z * rhs.imag.z)
        return 1.0 - dot <= Double(epsilon)
    }
    
    /**
     Returns the spherical linear interpolation between the rotation and another rotation.

     - Parameters:
       - other: The destination rotation.
       - fraction: The interpolation parameter, where `0` returns this rotation and `1` returns `other`.
     - Returns: The interpolated rotation.
     */
    public func interpolated(to other: Self, fraction: CGFloat) -> Self {
        var rotation = Self(quaternion: simd_slerp(quaternion, other.quaternion, Double(fraction)))
        rotation.anglesOrder = anglesOrder
        return rotation
    }
    
    public var description: String {
        let angles = degrees
        return "Rotation(x: \(angles.x)°, y: \(angles.y)°, z: \(angles.z)°, order: .\(anglesOrder))"
    }
    
    /// Creates the identity rotation.
    public init() {
        quaternion = simd_quatd(ix: 0, iy: 0, iz: 0, r: 1)
    }

    /**
     Creates a rotation axis from the specified quaternion.

     - Parameter quaternion: The quaternion representing the rotation.
     */
    public init(quaternion: simd_quatd) {
        self.quaternion = quaternion.normalized
    }

    /**
     Creates a rotation with the specified angles expressed in radians.

     - Parameters:
        - x: The angle of rotation around the x-axis.
        - y: The angle of rotation around the y-axis.
        - z: The angle of rotation around the z-axis.
        - order: The angle order.
     */
    public init(radians: Angles, order: AnglesOrder = .xyz) {
        quaternion = simd_quatd(eulerAngles: radians, order: order)
        anglesOrder = order
    }

    /**
     Creates a rotation with the specified angles expressed in degrees.

     - Parameters:
        - x: The angle of rotation around the x-axis.
        - y: The angle of rotation around the y-axis.
        - z: The angle of rotation around the z-axis.
        - order: The angle order.
     */
    public init(degrees: Angles, order: AnglesOrder = .xyz) {
        self.init(radians: degrees.radians, order: order)
    }
    
    /// The identity rotation.
    public static let identity = Self()

    /// Alias for `identity`.
    public static let zero = identity
    
    /**
     Creates a rotation with the specified angles expressed in degrees.

     - Parameters:
        - x: The angle of rotation around the x-axis.
        - y: The angle of rotation around the y-axis.
        - z: The angle of rotation around the z-axis.
        - order: The angle order.
     */
    public static func degrees(x: CGFloat = 0.0, y: CGFloat = 0.0, z: CGFloat = 0.0, order: AnglesOrder = .xyz) -> Self {
        .init(degrees: .init(x, y, z), order: order)
    }
    
    /**
     Creates a rotation with the specified angles expressed in radians.

     - Parameters:
        - x: The angle of rotation around the x-axis.
        - y: The angle of rotation around the y-axis.
        - z: The angle of rotation around the z-axis.
        - order: The angle order.
     */
    public static func radians(x: CGFloat = 0.0, y: CGFloat = 0.0, z: CGFloat = 0.0, order: AnglesOrder = .xyz) -> Self {
        .init(radians: .init(x, y, z), order: order)
    }

    /**
     Creates a rotation with the specified rotation axis and angle, expressed in degrees.

     - Parameters:
       - axis: The rotation axis.
       - angle: The rotation angle.
     */
    public static func axis(_ axis: Axis, angle: Angle) -> Self {
        .init(axis: axis, angle: angle)
    }

    /**
     Creates a rotation with the specified rotation axis and angle, expressed in radians.

     - Parameters:
       - axis: The rotation axis.
       - angle: The rotation angle.
     */
    public init(axis: Axis, angle: Angle) {
        quaternion = simd_quatd(angle: Double(angle.radians), axis: simd.normalize(axis.simdValue))
    }
    
    private enum CodingKeys: String, CodingKey {
        case anglesOrder
        case quaternionIx
        case quaternionIy
        case quaternionIz
        case quaternionR
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        anglesOrder = try container.decode(AnglesOrder.self, forKey: .anglesOrder)
        quaternion = simd_quatd(
            ix: try container.decode(Double.self, forKey: .quaternionIx),
            iy: try container.decode(Double.self, forKey: .quaternionIy),
            iz: try container.decode(Double.self, forKey: .quaternionIz),
            r: try container.decode(Double.self, forKey: .quaternionR)
        ).normalized
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(anglesOrder, forKey: .anglesOrder)
        try container.encode(quaternion.imag.x, forKey: .quaternionIx)
        try container.encode(quaternion.imag.y, forKey: .quaternionIy)
        try container.encode(quaternion.imag.z, forKey: .quaternionIz)
        try container.encode(quaternion.real, forKey: .quaternionR)
    }
    
    /// Returns the rotation unchanged.
    public static prefix func + (rotation: Self) -> Self {
        rotation
    }

    /// Returns the inverse rotation.
    public static prefix func - (rotation: Self) -> Self {
        rotation.inverted
    }

    /// Returns the rotation by applying the right-hand rotation after the left-hand rotation.
    public static func * (lhs: Self, rhs: Self) -> Self {
        var rotation = Self(quaternion: lhs.quaternion * rhs.quaternion)
        rotation.anglesOrder = lhs.anglesOrder
        return rotation
    }

    /// Applies the right-hand rotation after the left-hand rotation.
    public static func *= (lhs: inout Self, rhs: Self) {
        lhs = lhs * rhs
    }
    
    /// Returns the spherical linear interpolation between the identity rotation and the rotation.
    public static func * <T: BinaryFloatingPoint>(lhs: Self, rhs: T) -> Self {
        Self.identity.interpolated(to: lhs, fraction: CGFloat(rhs))
    }

    /// Returns the spherical linear interpolation between the identity rotation and the rotation.
    public static func * <T: BinaryInteger>(lhs: Self, rhs: T) -> Self {
        lhs * Double(rhs)
    }
    
    /// Returns the spherical linear interpolation between the identity rotation and the rotation.
    public static func * <T: BinaryFloatingPoint>(lhs: T, rhs: Self) -> Self {
        rhs * lhs
    }

    /// Returns the spherical linear interpolation between the identity rotation and the rotation.
    public static func * <T: BinaryInteger>(lhs: T, rhs: Self) -> Self {
        rhs * lhs
    }
}

extension RotationAlt {
    /// Three Euler angle components.
    public struct Angles: Hashable, Codable, Sendable, CustomStringConvertible, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral, AdditiveArithmetic {
        /// The rotation angle around the x-axis.
        public var x: CGFloat = 0.0
        /// The rotation angle around the y-axis.
        public var y: CGFloat = 0.0
        /// The rotation angle around the z-axis.
        public var z: CGFloat = 0.0
        
        public var description: String {
            "(x: \(x), y: \(y), z: \(z))"
        }

        /// Rotation angles with zero values for all axes.
        public static let zero = Self()

        /**
         Creates rotation angles around the x-, y-, and z-axes.

         - Parameters:
           - x: The angle of rotation around the x-axis.
           - y: The angle of rotation around the y-axis.
           - z: The angle of rotation around the z-axis.
         */
        public init(x: CGFloat = 0.0, y: CGFloat = 0.0, z: CGFloat = 0.0) {
            self.x = x
            self.y = y
            self.z = z
        }

        /**
         Creates rotation angles around the x-, y-, and z-axes.

         - Parameters:
           - x: The angle of rotation around the x-axis.
           - y: The angle of rotation around the y-axis.
           - z: The angle of rotation around the z-axis.
         */
        public init(_ x: CGFloat, _ y: CGFloat, _ z: CGFloat) {
            self.x = x
            self.y = y
            self.z = z
        }

        /**
         Creates rotation angles from a point.

         - Parameter angle: The x- and y-axis rotation angles.
         */
        public init(_ angle: CGPoint) {
            self.x = angle.x
            self.y = angle.y
        }

        /// Creates rotation angles with the z-axis rotation angle set to the specified integer value.
        public init(integerLiteral value: Int) {
            z = CGFloat(value)
        }

        /// Creates rotation angles with the z-axis rotation angle set to the specified floating-point value.
        public init(floatLiteral value: Double) {
            z = value
        }

        /// Returns rotation angles unchanged.
        public static prefix func + (angles: Self) -> Self {
            angles
        }

        /// Returns rotation angles with each component negated.
        public static prefix func - (angles: Self) -> Self {
            .init(x: -angles.x, y: -angles.y, z: -angles.z)
        }

        /// Returns rotation angles by adding the corresponding components.
        public static func + (lhs: Self, rhs: Self) -> Self {
            .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
        }

        /// Adds the corresponding components.
        public static func += (lhs: inout Self, rhs: Self) {
            lhs = lhs + rhs
        }

        /// Returns rotation angles by subtracting the corresponding components.
        public static func - (lhs: Self, rhs: Self) -> Self {
            .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
        }

        /// Subtracts the corresponding components.
        public static func -= (lhs: inout Self, rhs: Self) {
            lhs = lhs - rhs
        }

        /// Returns rotation angles by adding the specified value to each component.
        @_disfavoredOverload
        public static func + <T: BinaryInteger>(lhs: Self, rhs: T) -> Self {
            let value = CGFloat(rhs)
            return .init(x: lhs.x + value, y: lhs.y + value, z: lhs.z + value)
        }

        /// Returns rotation angles by adding the specified value to each component.
        @_disfavoredOverload
        public static func + <T: BinaryFloatingPoint>(lhs: Self, rhs: T) -> Self {
            let value = CGFloat(rhs)
            return .init(x: lhs.x + value, y: lhs.y + value, z: lhs.z + value)
        }

        /// Returns rotation angles by adding the specified value to each component.
        @_disfavoredOverload
        public static func + <T: BinaryInteger>(lhs: T, rhs: Self) -> Self {
            rhs + lhs
        }

        /// Returns rotation angles by adding the specified value to each component.
        @_disfavoredOverload
        public static func + <T: BinaryFloatingPoint>(lhs: T, rhs: Self) -> Self {
            rhs + lhs
        }

        /// Adds the specified value to each component.
        @_disfavoredOverload
        public static func += <T: BinaryInteger>(lhs: inout Self, rhs: T) {
            lhs = lhs + rhs
        }

        /// Adds the specified value to each component.
        @_disfavoredOverload
        public static func += <T: BinaryFloatingPoint>(lhs: inout Self, rhs: T) {
            lhs = lhs + rhs
        }

        /// Returns rotation angles by subtracting the specified value from each component.
        @_disfavoredOverload
        public static func - <T: BinaryInteger>(lhs: Self, rhs: T) -> Self {
            let value = CGFloat(rhs)
            return .init(x: lhs.x - value, y: lhs.y - value, z: lhs.z - value)
        }

        /// Returns rotation angles by subtracting the specified value from each component.
        @_disfavoredOverload
        public static func - <T: BinaryFloatingPoint>(lhs: Self, rhs: T) -> Self {
            let value = CGFloat(rhs)
            return .init(x: lhs.x - value, y: lhs.y - value, z: lhs.z - value)
        }

        /// Returns rotation angles by subtracting each component from the specified value.
        @_disfavoredOverload
        public static func - <T: BinaryInteger>(lhs: T, rhs: Self) -> Self {
            let value = CGFloat(lhs)
            return .init(x: value - rhs.x, y: value - rhs.y, z: value - rhs.z)
        }

        /// Returns rotation angles by subtracting each component from the specified value.
        @_disfavoredOverload
        public static func - <T: BinaryFloatingPoint>(lhs: T, rhs: Self) -> Self {
            let value = CGFloat(lhs)
            return .init(x: value - rhs.x, y: value - rhs.y, z: value - rhs.z)
        }

        /// Subtracts the specified value from each component.
        @_disfavoredOverload
        public static func -= <T: BinaryInteger>(lhs: inout Self, rhs: T) {
            lhs = lhs - rhs
        }

        /// Subtracts the specified value from each component.
        @_disfavoredOverload
        public static func -= <T: BinaryFloatingPoint>(lhs: inout Self, rhs: T) {
            lhs = lhs - rhs
        }

        /// Returns rotation angles by multiplying each component by the specified value.
        @_disfavoredOverload
        public static func * <T: BinaryInteger>(lhs: Self, rhs: T) -> Self {
            let value = CGFloat(rhs)
            return .init(x: lhs.x * value, y: lhs.y * value, z: lhs.z * value)
        }

        /// Returns rotation angles by multiplying each component by the specified value.
        @_disfavoredOverload
        public static func * <T: BinaryFloatingPoint>(lhs: Self, rhs: T) -> Self {
            let value = CGFloat(rhs)
            return .init(x: lhs.x * value, y: lhs.y * value, z: lhs.z * value)
        }

        /// Returns rotation angles by multiplying each component by the specified value.
        @_disfavoredOverload
        public static func * <T: BinaryInteger>(lhs: T, rhs: Self) -> Self {
            rhs * lhs
        }

        /// Returns rotation angles by multiplying each component by the specified value.
        @_disfavoredOverload
        public static func * <T: BinaryFloatingPoint>(lhs: T, rhs: Self) -> Self {
            rhs * lhs
        }

        /// Multiplies each component by the specified value.
        @_disfavoredOverload
        public static func *= <T: BinaryInteger>(lhs: inout Self, rhs: T) {
            lhs = lhs * rhs
        }

        /// Multiplies each component by the specified value.
        @_disfavoredOverload
        public static func *= <T: BinaryFloatingPoint>(lhs: inout Self, rhs: T) {
            lhs = lhs * rhs
        }

        /// Returns rotation angles by dividing each component by the specified value.
        @_disfavoredOverload
        public static func / <T: BinaryInteger>(lhs: Self, rhs: T) -> Self {
            let value = CGFloat(rhs)
            return .init(x: lhs.x / value, y: lhs.y / value, z: lhs.z / value)
        }

        /// Returns rotation angles by dividing each component by the specified value.
        @_disfavoredOverload
        public static func / <T: BinaryFloatingPoint>(lhs: Self, rhs: T) -> Self {
            let value = CGFloat(rhs)
            return .init(x: lhs.x / value, y: lhs.y / value, z: lhs.z / value)
        }

        /// Divides each component by the specified value.
        @_disfavoredOverload
        public static func /= <T: BinaryInteger>(lhs: inout Self, rhs: T) {
            lhs = lhs / rhs
        }

        /// Divides each component by the specified value.
        @_disfavoredOverload
        public static func /= <T: BinaryFloatingPoint>(lhs: inout Self, rhs: T) {
            lhs = lhs / rhs
        }
        
        /// The angles converted from radians to degrees.
        var degrees: Self {
            .init(x: x.radiansToDegrees, y: y.radiansToDegrees, z: z.radiansToDegrees)
        }

        /// The angles converted from degrees to radians.
        var radians: Self {
            .init(x: x.degreesToRadians, y: y.degreesToRadians, z: z.degreesToRadians)
        }
    }
}

extension RotationAlt {
    /// A three-dimensional rotation axis.
    public struct Axis: Hashable, Codable, Sendable, CustomStringConvertible, AdditiveArithmetic {
        /// The x-component of the axis.
        public var x: CGFloat
        /// The y-component of the axis.
        public var y: CGFloat
        /// The z-component of the axis.
        public var z: CGFloat

        /// The x-axis.
        public static let x = Self(x: 1, y: 0, z: 0)
        /// The y-axis.
        public static let y = Self(x: 0, y: 1, z: 0)
        /// The z-axis.
        public static let z = Self(x: 0, y: 0, z: 1)
        /// Rotation axis with all components equal to zero.
        public static let zero = Self()

        /**
         Creates an axis with the specified components.

         - Parameters:
           - x: The x-component of the axis.
           - y: The y-component of the axis.
           - z: The z-component of the axis.
         */
        public init(x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) {
            self.x = x
            self.y = y
            self.z = z
        }
        
        public var description: String {
            "(x: \(x), y: \(y), z: \(z))"
        }

        var simdValue: SIMD3<Double> {
            .init(Double(x), Double(y), Double(z))
        }
        
        /// Returns the axis unchanged.
        public static prefix func + (axis: Self) -> Self {
            axis
        }

        /// Returns an axis with each component negated.
        public static prefix func - (axis: Self) -> Self {
            .init(x: -axis.x, y: -axis.y, z: -axis.z)
        }

        /// Returns an axis by adding the corresponding components.
        public static func + (lhs: Self, rhs: Self) -> Self {
            .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
        }

        /// Adds the corresponding components.
        public static func += (lhs: inout Self, rhs: Self) {
            lhs = lhs + rhs
        }

        /// Returns an axis by subtracting the corresponding components.
        public static func - (lhs: Self, rhs: Self) -> Self {
            lhs + -rhs
        }

        /// Subtracts the corresponding components.
        public static func -= (lhs: inout Self, rhs: Self) {
            lhs = lhs - rhs
        }
        
        /// Returns an axis by multiplying each component by the specified scalar.
        public static func * <T: BinaryFloatingPoint>(lhs: Self, rhs: T) -> Self {
            let value = CGFloat(rhs)
            return .init(x: lhs.x * value, y: lhs.y * value, z: lhs.z * value)
        }

        /// Returns an axis by multiplying each component by the specified scalar.
        public static func * <T: BinaryFloatingPoint>(lhs: T, rhs: Self) -> Self {
            rhs * lhs
        }

        /// Multiplies each component by the specified scalar.
        public static func *= <T: BinaryFloatingPoint>(lhs: inout Self, rhs: T) {
            lhs = lhs * rhs
        }

        /// Returns an axis by dividing each component by the specified scalar.
        public static func / <T: BinaryFloatingPoint>(lhs: Self, rhs: T) -> Self {
            let value = CGFloat(rhs)
            return .init(x: lhs.x / value, y: lhs.y / value, z: lhs.z / value)
        }

        /// Divides each component by the specified scalar.
        public static func /= <T: BinaryFloatingPoint>(lhs: inout Self, rhs: T) {
            lhs = lhs / rhs
        }
        
        /// Returns an axis by multiplying each component by the specified scalar.
        public static func * <T: BinaryInteger>(lhs: Self, rhs: T) -> Self {
            let value = CGFloat(rhs)
            return .init(x: lhs.x * value, y: lhs.y * value, z: lhs.z * value)
        }

        /// Returns an axis by multiplying each component by the specified scalar.
        public static func * <T: BinaryInteger>(lhs: T, rhs: Self) -> Self {
            rhs * lhs
        }

        /// Multiplies each component by the specified scalar.
        public static func *= <T: BinaryInteger>(lhs: inout Self, rhs: T) {
            lhs = lhs * rhs
        }

        /// Returns an axis by dividing each component by the specified scalar.
        public static func / <T: BinaryInteger>(lhs: Self, rhs: T) -> Self {
            let value = CGFloat(rhs)
            return .init(x: lhs.x / value, y: lhs.y / value, z: lhs.z / value)
        }

        /// Divides each component by the specified scalar.
        public static func /= <T: BinaryInteger>(lhs: inout Self, rhs: T) {
            lhs = lhs / rhs
        }
    }
}

extension RotationAlt {
    /// A geometric angle.
    public struct Angle: Hashable, Codable, AdditiveArithmetic, CustomStringConvertible {
        /// The angle in radians.
        public var radians: CGFloat
        
        /// The angle in degrees.
        public var degrees: CGFloat {
            get { radians.radiansToDegrees }
            set { radians = newValue.degreesToRadians }
        }
        
        /// Creates an angle with the specified double-precision radians.
        public init(radians: CGFloat) {
            self.radians = radians
        }
        
        /// Creates an angle with the specified double-precision degrees.
        public init(degrees: CGFloat) {
            self.radians = degrees.degreesToRadians
        }
        
        /// Creates an angle.
        public init() {
            self.radians = 0.0
        }
        
        /// Returns the specified angle normalized between –180° and 180°.
        public var normalized: Self {
            .degrees((degrees + 180).modulo(360) - 180)
        }
        
        /// Normalizes the angle.
        public mutating func normalize() {
            self = normalized
        }
        
        public var description: String {
            "(radians: \(radians), degrees: \(degrees))"
        }
        
        /// The angle with the zero value.
        public static let zero = Self()
        
        /// Returns a new angle structure with the specified double-precision radians.
        public static func radians(_ radians: CGFloat) -> Self {
            .init(radians: radians)
        }
        
        /// Returns a new angle structure with the specified double-precision degrees.
        public static func degrees(_ degrees: CGFloat) -> Self {
            .init(degrees: degrees)
        }
        
        /**
         Returns the inverse cosine of the specified value.

         - Parameter value: The value whose inverse cosine is to be returned.
         - Returns: The inverse cosine of `value`.
         */
        static func acos(_ value: Double) -> Self {
            .radians(CGFloat(Darwin.acos(value)))
        }

        /**
         Returns the inverse hyperbolic cosine of the specified value.

         - Parameter value: The value whose inverse hyperbolic cosine is to be returned.
         - Returns: The inverse hyperbolic cosine of `value`.
         */
        static func acosh(_ value: Double) -> Self {
            .radians(CGFloat(Darwin.acosh(value)))
        }

        /**
         Returns the inverse sine of the specified value.

         - Parameter value: The value whose inverse sine is to be returned.
         - Returns: The inverse sine of `value`.
         */
        static func asin(_ value: Double) -> Self {
            .radians(CGFloat(Darwin.asin(value)))
        }

        /**
         Returns the inverse hyperbolic sine of the specified value.

         - Parameter value: The value whose inverse hyperbolic sine is to be returned.
         - Returns: The inverse hyperbolic sine of `value`.
         */
        static func asinh(_ value: Double) -> Self {
            .radians(CGFloat(Darwin.asinh(value)))
        }

        /**
         Returns the inverse tangent of the specified value.

         - Parameter value: The value whose inverse tangent is to be returned.
         - Returns: The inverse tangent of `value`.
         */
        static func atan(_ value: Double) -> Self {
            .radians(CGFloat(Darwin.atan(value)))
        }

        /**
         Returns the two-argument arctangent of the specified values.

         - Parameters:
           - y: The y-coordinate.
           - x: The x-coordinate.
         - Returns: The two-argument arctangent of `y` and `x`.
         */
        static func atan2(y: Double, x: Double) -> Self {
            .radians(CGFloat(Darwin.atan2(y, x)))
        }

        /**
         Returns the inverse hyperbolic tangent of the specified value.

         - Parameter value: The value whose inverse hyperbolic tangent is to be returned.
         - Returns: The inverse hyperbolic tangent of `value`.
         */
        static func atanh(_ value: Double) -> Self {
            .radians(CGFloat(Darwin.atanh(value)))
        }
        
        /// Returns the given angle unchanged.
        public static prefix func + (angle: Self) -> Self {
            angle
        }

        /// Returns the inverse rotation.
        public static prefix func - (angle: Self) -> Self {
            .radians(-angle.radians)
        }
        
        /// Adds two angles and produces their sum.
        public static func + (lhs: Self, rhs: Self) -> Self {
            .radians(lhs.radians + rhs.radians)
        }
        
        /// Adds two angles and stores the result in the left-hand-side variable.
        public static func += (lhs: inout Self, rhs: Self) {
            lhs = lhs + rhs
        }
        
        /// Returns the additive inverse of the given angle.
        public static func - (lhs: Self, rhs: Self) -> Self {
            .radians(lhs.radians - rhs.radians)
        }
        
        /// Subtracts one angle from another and produces their difference.
        public static func -= (lhs: inout Self, rhs: Self) {
            lhs = lhs - rhs
        }
    }
}

private extension simd_quatd {

    /**
     Creates a quaternion from Euler angles.

     - Important: The exact multiplication order must match the convention used
       by `eulerAngles(order:)`.
     */
    init(eulerAngles angles: RotationAlt.Angles, order: RotationAlt.AnglesOrder) {
        let qx = simd_quatd(angle: Double(angles.x), axis: SIMD3<Double>(1, 0, 0))
        let qy = simd_quatd(angle: Double(angles.y), axis: SIMD3<Double>(0, 1, 0))
        let qz = simd_quatd(angle: Double(angles.z), axis: SIMD3<Double>(0, 0, 1))

        switch order {
        case .xyz:
            self = qz * qy * qx
        case .zyx:
            self = qx * qy * qz
        }
    }

    /**
     Returns Euler angles for the quaternion.

     - Important: These formulas must be verified against the multiplication
       convention used by `init(eulerAngles:order:)`.
     */
    func eulerAngles(order: RotationAlt.AnglesOrder) -> RotationAlt.Angles {
        let q = normalized
        let x = q.imag.x
        let y = q.imag.y
        let z = q.imag.z
        let w = q.real

        switch order {
        case .xyz:
            return .init(
                x: CGFloat(atan2(2 * (w * x + y * z), 1 - 2 * (x * x + y * y))),
                y: CGFloat(asin((2 * (w * y - z * x)).clamped(to: -1...1))),
                z: CGFloat(atan2(2 * (w * z + x * y), 1 - 2 * (y * y + z * z)))
            )

        case .zyx:
            return .init(
                x: CGFloat(atan2(2 * (w * x + y * z), 1 - 2 * (x * x + y * y))),
                y: CGFloat(asin((2 * (w * y - z * x)).clamped(to: -1...1))),
                z: CGFloat(atan2(2 * (w * z + x * y), 1 - 2 * (y * y + z * z)))
            )
        }
    }
}

/// The Objective-C class for ``RotationAlt``.
public class __RotationAlt: NSObject, NSCopying, NSCoding {
    let rotation: RotationAlt

    init(_ rotation: RotationAlt) {
        self.rotation = rotation
    }

    public func encode(with coder: NSCoder) {
        let vector = rotation.quaternion.vector
        coder.encode(Double(vector.x), forKey: "x")
        coder.encode(Double(vector.y), forKey: "y")
        coder.encode(Double(vector.z), forKey: "z")
        coder.encode(Double(vector.w), forKey: "w")
    }

    public required init?(coder: NSCoder) {
        rotation = .init(quaternion: .init(vector: .init(coder.decode("x") ?? 0.0, coder.decode("y") ?? 0.0, coder.decode("z") ?? 0.0, coder.decode("w") ?? 0.0)))
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        self
    }

    override public func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Self else { return false }
        return self === other || rotation == other.rotation
    }

    override public var hash: Int {
        Hasher.hash(rotation)
    }
}

extension RotationAlt: ReferenceConvertible {
    /// The Objective-C type for the rotation.
    public typealias ReferenceType = __RotationAlt

    public func _bridgeToObjectiveC() -> ReferenceType {
        return .init(self)
    }

    public static func _forceBridgeFromObjectiveC(_ source: ReferenceType, result: inout Self?) {
        result = source.rotation
    }

    public static func _conditionallyBridgeFromObjectiveC(_ source: ReferenceType, result: inout Self?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }

    public static func _unconditionallyBridgeFromObjectiveC(_ source: ReferenceType?) -> Self {
        if let source = source {
            var result: Self?
            _forceBridgeFromObjectiveC(source, result: &result)
            return result!
        }
        return .zero
    }

    public var debugDescription: String {
        description
    }
}

fileprivate extension FloatingPoint {
    func modulo(_ divisor: Self) -> Self {
        guard divisor != 0 else { return 0 }

        let remainder = truncatingRemainder(dividingBy: divisor)
        if remainder == 0 {
            return 0
        }
        if (remainder < 0) != (divisor < 0) {
            return remainder + divisor
        }
        return remainder
    }
}
