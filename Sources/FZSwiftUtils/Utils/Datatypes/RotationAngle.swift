//
//  RotationAngle.swift
//
//
//  Created by Florian Zand on 21.03.25.
//

import Foundation

/// A structure representing an angle in degrees and radians.
public struct RotationAngle: Hashable, Equatable, Codable, CustomStringConvertible {
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
    
    /// Returns the given angle unchanged.
    public static prefix func + (angle: RotationAngle) -> RotationAngle {
        angle
    }

    /// Adds two angles and produces their sum.
    public static func + (lhs: RotationAngle, rhs: RotationAngle) -> RotationAngle {
        RotationAngle(radian: lhs.radian + rhs.radian)
    }

    /// Adds two angles and stores the result in the left-hand-side variable.
    public static func += (lhs: inout RotationAngle, rhs: RotationAngle) {
        lhs = lhs + rhs
    }

    /// Returns the additive inverse of the given angle.
    public static prefix func - (angle: RotationAngle) -> RotationAngle {
        RotationAngle(radian: -angle.radian)
    }

    /// Subtracts one angle from another and produces their difference.
    public static func - (lhs: RotationAngle, rhs: RotationAngle) -> RotationAngle {
        RotationAngle(radian: lhs.radian - rhs.radian)
    }

    /// Subtracts the second angle from the first and stores the difference in the left-hand-side variable.
    public static func -= (lhs: inout RotationAngle, rhs: RotationAngle) {
        lhs = lhs - rhs
    }
    
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
    public static func degree(_ degree: Double) -> RotationAngle {
        RotationAngle(degree: degree)
    }
    
    /// Creates an angle from a radian value.
    public static func radian(_ radian: Double) -> RotationAngle {
        RotationAngle(radian: radian)
    }

    /// Returns the inverse cosine of the specified value.
    public static func acos(_ x: Double) -> RotationAngle {
        RotationAngle(radian: Foundation.acos(x))
    }

    /// Returns the inverse hyperbolic cosine of the specified value.
    public static func acosh(_ x: Double) -> RotationAngle {
        RotationAngle(radian: Foundation.acosh(x))
    }

    /// Returns the inverse sine of the specified value.
    public static func asin(_ x: Double) -> RotationAngle {
        RotationAngle(radian: Foundation.asin(x))
    }

    /// Returns the inverse hyperbolic sine of the specified value.
    public static func asinh(_ x: Double) -> RotationAngle {
        RotationAngle(radian: Foundation.asinh(x))
    }

    /// Returns the inverse hyperbolic tangent of the specified value.
    public static func atan(_ x: Double) -> RotationAngle {
        RotationAngle(radian: Foundation.atan(x))
    }

    /// Returns the two-argument arctangent of the specified values.
    public static func atan2(y: Double, x: Double) -> RotationAngle {
        RotationAngle(radian: Foundation.atan2(y, x))
    }

    /// Returns the inverse hyperbolic tangent of the specified value.
    public static func atanh(_ x: Double) -> RotationAngle {
        RotationAngle(radian: Foundation.atanh(x))
    }
    
    /// Returns the specified angle normalized between –180° and 180.0°.
    public var normalized: RotationAngle {
        var normalizedDegrees = degree.truncatingRemainder(dividingBy: 360)
        if normalizedDegrees > 180 {
            normalizedDegrees -= 360
        } else if normalizedDegrees <= -180 {
            normalizedDegrees += 360
        }
        return RotationAngle(degree: normalizedDegrees)
    }

    /// Returns a Boolean value that indicates whether two angles are equal.
    public static func == (lhs: RotationAngle, rhs: RotationAngle) -> Bool {
        lhs.radian == rhs.radian
    }
}
