//
//  Rotation.swift
//
//
//  Created by Florian Zand on 14.02.25.
//

import Foundation

/// Rotation in a three-dimensional space.
public struct Rotation: Hashable, Codable, Sendable, CustomStringConvertible {
    /// The rotation angles around the x-, y-, and z-axes.
    public struct Angles: Hashable, Codable, Sendable, CustomStringConvertible, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
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

        /// Returns the specified rotation angles unchanged.
        public static prefix func + (angles: Self) -> Self {
            angles
        }

        /// Returns rotation angles with each rotation angle negated.
        public static prefix func - (angles: Self) -> Self {
            .init(x: -angles.x, y: -angles.y, z: -angles.z)
        }

        /// Returns rotation angles by adding the corresponding rotation angles.
        public static func + (lhs: Self, rhs: Self) -> Self {
            .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
        }

        /// Adds the corresponding rotation angles.
        public static func += (lhs: inout Self, rhs: Self) {
            lhs = lhs + rhs
        }

        /// Returns rotation angles by subtracting the corresponding rotation angles.
        public static func - (lhs: Self, rhs: Self) -> Self {
            lhs + -rhs
        }

        /// Subtracts the corresponding rotation angles.
        public static func -= (lhs: inout Self, rhs: Self) {
            lhs = lhs - rhs
        }

        /// Returns rotation angles by adding the specified value to each rotation angle.
        @_disfavoredOverload
        public static func + (lhs: Self, rhs: CGFloat) -> Self {
            .init(x: lhs.x + rhs, y: lhs.y + rhs, z: lhs.z + rhs)
        }

        /// Adds the specified value to each rotation angle.
        @_disfavoredOverload
        public static func += (lhs: inout Self, rhs: CGFloat) {
            lhs = lhs + rhs
        }

        /// Returns rotation angles by subtracting the specified value from each rotation angle.
        @_disfavoredOverload
        public static func - (lhs: Self, rhs: CGFloat) -> Self {
            .init(x: lhs.x - rhs, y: lhs.y - rhs, z: lhs.z - rhs)
        }

        /// Subtracts the specified value from each rotation angle.
        @_disfavoredOverload
        public static func -= (lhs: inout Self, rhs: CGFloat) {
            lhs = lhs - rhs
        }

        /// Returns rotation angles by adding the specified value to each rotation angle.
        @_disfavoredOverload
        public static func + (lhs: Self, rhs: Int) -> Self {
            .init(x: lhs.x + CGFloat(rhs), y: lhs.y + CGFloat(rhs), z: lhs.z + CGFloat(rhs))
        }

        /// Adds the specified value to each rotation angle.
        @_disfavoredOverload
        public static func += (lhs: inout Self, rhs: Int) {
            lhs = lhs + rhs
        }

        /// Returns rotation angles by subtracting the specified value from each rotation angle.
        @_disfavoredOverload
        public static func - (lhs: Self, rhs: Int) -> Self {
            .init(x: lhs.x - CGFloat(rhs), y: lhs.y - CGFloat(rhs), z: lhs.z - CGFloat(rhs))
        }

        /// Subtracts the specified value from each rotation angle.
        @_disfavoredOverload
        public static func -= (lhs: inout Self, rhs: Int) {
            lhs = lhs - rhs
        }

        /// Returns rotation angles by adding the point's coordinates to the x- and y-axis rotation angles.
        @_disfavoredOverload
        public static func + (lhs: Self, rhs: CGPoint) -> Self {
            .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z)
        }

        /// Adds the point's coordinates to the x- and y-axis rotation angles.
        @_disfavoredOverload
        public static func += (lhs: inout Self, rhs: CGPoint) {
            lhs = lhs + rhs
        }

        /// Returns rotation angles by subtracting the point's coordinates from the x- and y-axis rotation angles.
        @_disfavoredOverload
        public static func - (lhs: Self, rhs: CGPoint) -> Self {
            .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z)
        }

        /// Subtracts the point's coordinates from the x- and y-axis rotation angles.
        @_disfavoredOverload
        public static func -= (lhs: inout Self, rhs: CGPoint) {
            lhs = lhs - rhs
        }
    }

    /// The rotation angles, expressed in radians.
    public var radians: Angles = .init()

    /// The rotation angles, expressed in degrees.
    public var degrees: Angles {
        get { .init(x: radians.x.radiansToDegrees, y: radians.y.radiansToDegrees, z: radians.z.radiansToDegrees) }
        set { radians = .init(x: newValue.x.degreesToRadians, y: newValue.y.degreesToRadians, z: newValue.z.degreesToRadians) }
    }

    /// Normalizes the rotation.
    public mutating func normalize() {
        self = normalized
    }

    /// Returns a rotation with each rotation angle normalized.
    public var normalized: Self {
        .init(radians: .init(x: radians.x.positiveRemainder(dividingBy: 2 * .pi),
                             y: radians.y.positiveRemainder(dividingBy: 2 * .pi),
                             z: radians.z.positiveRemainder(dividingBy: 2 * .pi)))
    }

    public var description: String {
        "(radians: \(radians), degrees: \(degrees))"
    }

    /**
     Creates a rotation using angles expressed in radians.

     - Parameter radians: The rotation angles in radians.
     */
    public init(radians: Angles) {
        self.radians = radians
    }

    /**
     Creates a rotation using angles expressed in degrees.

     - Parameter degrees: The rotation angles in degrees.
     */
    public init(degrees: Angles) {
        self.degrees = degrees
    }

    /**
     Creates a rotation using angles expressed in radians.

     - Parameters:
       - x: The angle of rotation around the x-axis.
       - y: The angle of rotation around the y-axis.
       - z: The angle of rotation around the z-axis.
     */
    public static func radians(x: CGFloat = 0.0, y: CGFloat = 0.0, z: CGFloat = 0.0) -> Self {
        .init(radians: .init(x: x, y: y, z: z))
    }

    /**
     Creates a rotation using angles expressed in radians.

     - Parameters:
       - x: The angle of rotation around the x-axis.
       - y: The angle of rotation around the y-axis.
       - z: The angle of rotation around the z-axis.
     */
    public static func radians(_ x: CGFloat, _ y: CGFloat, _ z: CGFloat) -> Self {
        .init(radians: .init(x: x, y: y, z: z))
    }

    /**
     Creates a rotation using angles expressed in radians.

     - Parameter angle: The x- and y-axis rotation angles.
     */
    public static func radians(_ angle: CGPoint) -> Self {
        .init(radians: .init(angle))
    }

    /**
     Creates a rotation using angles expressed in degrees.

     - Parameters:
       - x: The angle of rotation around the x-axis.
       - y: The angle of rotation around the y-axis.
       - z: The angle of rotation around the z-axis.
     */
    public static func degrees(x: CGFloat = 0.0, y: CGFloat = 0.0, z: CGFloat = 0.0) -> Self {
        .init(degrees: .init(x: x, y: y, z: z))
    }

    /**
     Creates a rotation using angles expressed in degrees.

     - Parameters:
       - x: The angle of rotation around the x-axis.
       - y: The angle of rotation around the y-axis.
       - z: The angle of rotation around the z-axis.
     */
    public static func degrees(_ x: CGFloat, _ y: CGFloat, _ z: CGFloat) -> Self {
        .init(degrees: .init(x: x, y: y, z: z))
    }

    /**
     Creates a rotation using angles expressed in degrees.

     - Parameter angle: The x- and y-axis rotation angles.
     */
    public static func degrees(_ angle: CGPoint) -> Self {
        .init(degrees: .init(angle))
    }

    /// A rotation with zero rotation around all axes.
    public static let zero = Self(radians: .zero)

    /// Returns the specified rotation unchanged.
    public static prefix func + (rotation: Self) -> Self {
        rotation
    }

    /// Returns a rotation with each rotation angle negated.
    public static prefix func - (rotation: Self) -> Self {
        .init(radians: -rotation.radians)
    }

    /// Returns a rotation by adding the corresponding rotation angles.
    public static func + (lhs: Self, rhs: Self) -> Self {
        .init(radians: lhs.radians + rhs.radians)
    }

    /// Adds the corresponding rotation angles.
    public static func += (lhs: inout Self, rhs: Self) {
        lhs.radians += rhs.radians
    }

    /// Returns a rotation by subtracting the corresponding rotation angles.
    public static func - (lhs: Self, rhs: Self) -> Self {
        .init(radians: lhs.radians - rhs.radians)
    }

    /// Subtracts the corresponding rotation angles.
    public static func -= (lhs: inout Self, rhs: Self) {
        lhs.radians -= rhs.radians
    }

    /// Returns a rotation by adding the specified value to each rotation angle.
    @_disfavoredOverload
    public static func + (lhs: Self, rhs: Int) -> Self {
        .init(radians: lhs.radians + rhs)
    }

    /// Adds the specified value to each rotation angle.
    @_disfavoredOverload
    public static func += (lhs: inout Self, rhs: Int) {
        lhs.radians += rhs
    }

    /// Returns a rotation by subtracting the specified value from each rotation angle.
    @_disfavoredOverload
    public static func - (lhs: Self, rhs: Int) -> Self {
        .init(radians: lhs.radians - rhs)
    }

    /// Subtracts the specified value from each rotation angle.
    @_disfavoredOverload
    public static func -= (lhs: inout Self, rhs: Int) {
        lhs.radians -= rhs
    }

    /// Returns a rotation by adding the specified value to each rotation angle.
    @_disfavoredOverload
    public static func + (lhs: Self, rhs: CGFloat) -> Self {
        .init(radians: lhs.radians + rhs)
    }

    /// Adds the specified value to each rotation angle.
    @_disfavoredOverload
    public static func += (lhs: inout Self, rhs: CGFloat) {
        lhs.radians += rhs
    }

    /// Returns a rotation by subtracting the specified value from each rotation angle.
    @_disfavoredOverload
    public static func - (lhs: Self, rhs: CGFloat) -> Self {
        .init(radians: lhs.radians - rhs)
    }

    /// Subtracts the specified value from each rotation angle.
    @_disfavoredOverload
    public static func -= (lhs: inout Self, rhs: CGFloat) {
        lhs.radians -= rhs
    }

    /// Returns a rotation by adding the point's coordinates to the x- and y-axis rotation angles.
    @_disfavoredOverload
    public static func + (lhs: Self, rhs: CGPoint) -> Self {
        .init(radians: lhs.radians + rhs)
    }

    /// Adds the point's coordinates to the x- and y-axis rotation angles.
    @_disfavoredOverload
    public static func += (lhs: inout Self, rhs: CGPoint) {
        lhs.radians += rhs
    }

    /// Returns a rotation by subtracting the point's coordinates from the x- and y-axis rotation angles.
    @_disfavoredOverload
    public static func - (lhs: Self, rhs: CGPoint) -> Self {
        .init(radians: lhs.radians - rhs)
    }

    /// Subtracts the point's coordinates from the x- and y-axis rotation angles.
    @_disfavoredOverload
    public static func -= (lhs: inout Self, rhs: CGPoint) {
        lhs.radians -= rhs
    }
}

/// The Objective-C class for ``Rotation``.
public class __Rotation: NSObject, NSCopying, NSCoding {
    let rotation: Rotation

    init(_ rotation: Rotation) {
        self.rotation = rotation
    }

    public func encode(with coder: NSCoder) {
        coder.encode(Double(rotation.radians.x), forKey: "x")
        coder.encode(Double(rotation.radians.y), forKey: "y")
        coder.encode(Double(rotation.radians.z), forKey: "z")
    }

    public required init?(coder: NSCoder) {
        rotation = .init(radians: .init(coder.decodeDouble(forKey: "x"),coder.decodeDouble(forKey: "y"), coder.decodeDouble(forKey: "z")))
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

extension Rotation: ReferenceConvertible {
    /// The Objective-C type for the rotation.
    public typealias ReferenceType = __Rotation

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

/*
 public var fractional: FractionalPoint {
     get { .init(x/90.0, y/90.0) }
     set {
         // newValue.x.interpolated(from: -90...90, to: -90...90)
         x = newValue.x.interpolated(from: 0...1, to: -90...90)
         y = newValue.y.interpolated(from: 0...1, to: -90...90)
     }
 }
 */
