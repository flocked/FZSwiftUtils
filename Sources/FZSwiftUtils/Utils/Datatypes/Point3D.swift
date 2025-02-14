//
//  Point3D.swift
//
//
//  Created by Florian Zand on 02.02.25.
//

import Foundation

/// A structure that contains a point in a three-dimensional coordinate system.
public struct Point3D: Hashable, Codable, CustomStringConvertible {
    /// The x-coordinate of the point.
    public var x: CGFloat = 0.0
    
    /// The y-coordinate of the point.
    public var y: CGFloat = 0.0
    
    /// The z-coordinate of the point.
    public var z: CGFloat = 0.0
    
    /// The point with location `(0,0,0)`.
    public static let zero = Point3D()
        
    /**
     Creates a point with the specified coordinates.
     
     - Parameters:
        - x: The x-coordinate of the point.
        - y: The y-coordinate of the point.
        - z: The z-coordinate of the point.
     */
    public init(x: CGFloat = 0.0, y: CGFloat = 0.0, z: CGFloat = 0.0) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    /**
     Creates a point with the specified coordinates.
     
     - Parameters:
        - x: The x-coordinate of the point.
        - y: The y-coordinate of the point.
        - z: The z-coordinate of the point.
     */
    public init(_ x: CGFloat, _ y: CGFloat, _ z: CGFloat) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    /**
     Creates a point with the specified x- and y-coordinate.
     
     - Parameter xy: The x- and y-coordinate of the point.
     */
    public init(_ xy: CGFloat) {
        self.x = xy
        self.y = xy
    }
    
    /**
     Creates a point with the specified x- and y-coordinate.
     
     - Parameters:
        - x: The x-coordinate of the point.
        - y: The y-coordinate of the point.
     */
    public init(_ x: CGFloat, _ y: CGFloat) {
        self.x = x
        self.y = y
    }
    
    /**
     Creates a point with the specified `CGPoint`.
     
     - Parameter point: The `CGPoint` point.
     */
    public init(_ point: CGPoint) {
        self.x = point.x
        self.y = point.y
    }
    
    public var description: String {
        "(\(x), \(y), \(z))"
    }
}

/// The Objective-C class for ``Point3D``.
public class __Point3D: NSObject, NSCopying {
    let point: Point3D
    
    public init(point: Point3D) {
        self.point = point
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        __Point3D(point: point)
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        point == (object as? __Point3D)?.point
    }
}

extension Point3D: ReferenceConvertible {
    /// The Objective-C type for the configuration.
    public typealias ReferenceType = __Point3D
    
    public func _bridgeToObjectiveC() -> __Point3D {
        return __Point3D(point: self)
    }
    
    public static func _forceBridgeFromObjectiveC(_ source: __Point3D, result: inout Point3D?) {
        result = source.point
    }
    
    public static func _conditionallyBridgeFromObjectiveC(_ source: __Point3D, result: inout Point3D?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }
    
    public static func _unconditionallyBridgeFromObjectiveC(_ source: __Point3D?) -> Point3D {
        if let source = source {
            var result: Point3D?
            _forceBridgeFromObjectiveC(source, result: &result)
            return result!
        }
        return Point3D()
    }
    
    public var debugDescription: String {
        description
    }
}
