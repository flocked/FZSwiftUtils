//
//  RotationAngle.swift
//
//
//  Created by Florian Zand on 21.03.25.
//

import Foundation

/// A structure representing an angle in degrees and radians.
public struct RotationAngle: Hashable, Equatable, Codable, CustomStringConvertible, AdditiveArithmetic {
    /// The angle in degrees.
    public var degree: Double {
        didSet { radian = degree * .pi / 180 }
    }
    
    /// The angle in radians.
    public var radian: Double {
        didSet { degree = radian * 180 / .pi }
    }
    
    public var description: String {
        "[degree: \(degree), radian: \(radian)]"
    }
    
    /// Initializes an angle with a value in degrees.
    public init(degree: Double) {
        self.degree = degree
        self.radian = degree * .pi / 180
    }
    
    /// Initializes an angle with a value in radians.
    public init(radian: Double) {
        self.radian = radian
        self.degree = radian * 180 / .pi
    }
    
    /// The angle with the zero value.
    public static let zero = RotationAngle(degree: 0.0)
    
    /// The cosine of the angle.
    public var cos: Double {
        get { Foundation.cos(radian) }
        set { radian = Foundation.acos(newValue) }
    }
    
    /// The hyperbolic cosine of the angle.
    public var cosh: Double {
        get { Foundation.cosh(radian) }
        set { radian = Foundation.acosh(newValue) }
    }
    
    /// The sine of the angle.
    public var sin: Double {
        get { Foundation.sin(radian) }
        set { radian = Foundation.asin(newValue) }
    }
    
    /// Rhe hyperbolic sine of the angle.
    public var sinh: Double {
        get { Foundation.sinh(radian) }
        set { radian = Foundation.asinh(newValue) }
    }
    
    /// Rhe tangent of the angle.
    public var tan: Double {
        get { Foundation.tan(radian) }
        set { radian = Foundation.atan(newValue) }
    }
    
    /// Rhe hyperbolic tangent of the angle.
    public var tanh: Double {
        get { Foundation.tanh(radian) }
        set { radian = Foundation.atanh(newValue) }
    }
    
    /// Creates an angle from a degree value.
    public static func degree(_ degree: Double) -> Self {
        Self(degree: degree)
    }
    
    /// Creates an angle from a radian value.
    public static func radian(_ radian: Double) -> Self {
        Self(radian: radian)
    }

    /// Returns the inverse cosine of the specified value.
    public static func acos(_ x: Double) -> Self {
        Self(radian: Foundation.acos(x))
    }

    /// Returns the inverse hyperbolic cosine of the specified value.
    public static func acosh(_ x: Double) -> Self {
        Self(radian: Foundation.acosh(x))
    }

    /// Returns the inverse sine of the specified value.
    public static func asin(_ x: Double) -> Self {
        Self(radian: Foundation.asin(x))
    }

    /// Returns the inverse hyperbolic sine of the specified value.
    public static func asinh(_ x: Double) -> Self {
        Self(radian: Foundation.asinh(x))
    }

    /// Returns the inverse hyperbolic tangent of the specified value.
    public static func atan(_ x: Double) -> Self {
        Self(radian: Foundation.atan(x))
    }

    /// Returns the two-argument arctangent of the specified values.
    public static func atan2(y: Double, x: Double) -> Self {
        Self(radian: Foundation.atan2(y, x))
    }

    /// Returns the inverse hyperbolic tangent of the specified value.
    public static func atanh(_ x: Double) -> Self {
        Self(radian: Foundation.atanh(x))
    }
    
    /// Returns the specified angle normalized between –180° and 180.0°.
    public var normalized: Self {
        var normalizedDegrees = degree.truncatingRemainder(dividingBy: 360)
        if normalizedDegrees > 180 {
            normalizedDegrees -= 360
        } else if normalizedDegrees <= -180 {
            normalizedDegrees += 360
        }
        return Self(degree: normalizedDegrees)
    }

    /// Returns a Boolean value indicating whether two angles are equal.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.radian == rhs.radian
    }
    
    
    /// Returns the given angle unchanged.
    public static prefix func + (angle: Self) -> Self {
        angle
    }
    
    /// Returns the given angle unchanged.
    public static prefix func - (angle: Self) -> Self {
        .radian(-angle.radian)
    }

    /// Adds two angles and produces their sum.
    public static func + (lhs: Self, rhs: Self) -> Self {
        RotationAngle(radian: lhs.radian + rhs.radian)
    }

    /// Adds two angles and stores the result in the left-hand-side variable.
    public static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }

    /// Subtracts one angle from another and produces their difference.
    public static func - (lhs: Self, rhs: Self) -> Self {
        Self(radian: lhs.radian - rhs.radian)
    }

    /// Subtracts the second angle from the first and stores the difference in the left-hand-side variable.
    public static func -= (lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }

    /// Returns a rotation by adding the specified value to each rotation angle.
    @_disfavoredOverload
    public static func + (lhs: Self, rhs: Int) -> Self {
        .radian(lhs.radian + Double(rhs))
    }

    /// Adds the specified value to each rotation angle.
    @_disfavoredOverload
    public static func += (lhs: inout Self, rhs: Int) {
        lhs = lhs + rhs
    }

    /// Returns a rotation by subtracting the specified value from each rotation angle.
    @_disfavoredOverload
    public static func - (lhs: Self, rhs: Int) -> Self {
        .radian(lhs.radian - Double(rhs))
    }

    /// Subtracts the specified value from each rotation angle.
    @_disfavoredOverload
    public static func -= (lhs: inout Self, rhs: Int) {
        lhs = lhs - rhs
    }

    /// Returns a rotation by adding the specified value to each rotation angle.
    @_disfavoredOverload
    public static func + (lhs: Self, rhs: CGFloat) -> Self {
        .radian(lhs.radian + rhs)
    }

    /// Adds the specified value to each rotation angle.
    @_disfavoredOverload
    public static func += (lhs: inout Self, rhs: CGFloat) {
        lhs = lhs + rhs
    }

    /// Returns a rotation by subtracting the specified value from each rotation angle.
    @_disfavoredOverload
    public static func - (lhs: Self, rhs: CGFloat) -> Self {
        .radian(lhs.radian - rhs)
    }

    /// Subtracts the specified value from each rotation angle.
    @_disfavoredOverload
    public static func -= (lhs: inout Self, rhs: CGFloat) {
        lhs = lhs - rhs
    }
}

/// The Objective-C class for ``RotationAngle``.
public class __RotationAngle: NSObject, NSCopying, NSCoding {
    let angle: RotationAngle

    init(_ angle: RotationAngle) {
        self.angle = angle
    }

    public func encode(with coder: NSCoder) {
        coder.encode(Double(angle.radian), forKey: "angle")
    }

    public required init?(coder: NSCoder) {
        angle = .radian(coder.decode("angle") ?? 0.0)
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        self
    }

    override public func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Self else { return false }
        return self === other || angle == other.angle
    }

    override public var hash: Int {
        Hasher.hash(angle)
    }
}

extension RotationAngle: ReferenceConvertible {
    /// The Objective-C type for the rotation angle.
    public typealias ReferenceType = __RotationAngle

    public func _bridgeToObjectiveC() -> ReferenceType {
        return .init(self)
    }

    public static func _forceBridgeFromObjectiveC(_ source: ReferenceType, result: inout Self?) {
        result = source.angle
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
