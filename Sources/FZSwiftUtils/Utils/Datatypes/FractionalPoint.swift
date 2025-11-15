//
//  FractionalPoint.swift
//
//
//  Created by Florian Zand on 25.11.24.
//

import Foundation

/// A fractional 2D point.
public struct FractionalPoint: Hashable, Codable, ExpressibleByFloatLiteral, CustomStringConvertible {
    
    /// The x-coordinate of the fractional point.
    public var x: CGFloat = 0.0
    
    /// The y-coordinate of the fractional point.
    public var y: CGFloat = 0.0
    
    /// Converts the point into an absolute point within the specified rectangle.
    public func point(in rect: CGRect) -> CGPoint {
        CGPoint(x: rect.minX + (x * rect.width), y: rect.minY + (y * rect.height))
    }
    
    /**
     Creates a fractional point with the specified x- and y-coordinates.
     
     - Parameters:
        - x: The x-coordinate of the fractional point.
        - y: The y-coordinate of the fractional point.
     */
    public init(x: CGFloat = 0.0, y: CGFloat = 0.0) {
        self.x = x
        self.y = y
    }
    
    /**
     Creates a fractional point with the specified x- and y-coordinates.
     
     - Parameters:
        - x: The x-coordinate of the fractional point.
        - y: The y-coordinate of the fractional point.
     */
    public init(_ x: CGFloat, _ y: CGFloat) {
        self.x = x
        self.y = y
    }
    
    /**
     Creates a fractional point with the specified x- and y-coordinate.
     
     - Parameter xy: The x- and y-coordinate of the fractional point.
     */
    public init(_ xy: CGFloat) {
        self.x = xy
        self.y = xy
    }
    
    /**
     Creates a fractional point with the specified x- and y-coordinate.
     
     - Parameter value: The x- and y-coordinate of the fractional point.
     */
    public init(floatLiteral value: Double) {
        self.x = value
        self.y = value
    }
    
    public var description: String {
        "[x: \(x), y: \(y)]"
    }
    
    /// Left edge center.
    public static let left = FractionalPoint(0.0, 0.5)
    
    /// Center.
    public static let center = FractionalPoint(0.5, 0.5)
    
    /// Right edge center.
    public static let right = FractionalPoint(1.0, 0.5)
    
    #if os(macOS)
    /// Bottom-left corner.
    public static let bottomLeft = FractionalPoint(0.0, 0.0)
    
    /// Bottom edge center.
    public static let bottom = FractionalPoint(0.5, 0.0)
    
    /// Bottom-right corner.
    public static let bottomRight = FractionalPoint(1.0, 0.0)
    
    /// Top-left corner.
    public static let topLeft = FractionalPoint(0.0, 1.0)
    
    /// Top edge center.
    public static let top = FractionalPoint(0.5, 1.0)
    
    /// Top-right corner.
    public static let topRight = FractionalPoint(1.0, 1.0)
    
    /// Bottom-left corner.
    public static let zero = FractionalPoint(0.0, 0.0)
    #else
    /// Bottom-left corner.
    public static let bottomLeft = FractionalPoint(0.0, 1.0)
    
    /// Bottom edge center.
    public static let bottom = FractionalPoint(0.5, 1.0)
    
    /// Bottom-right corner.
    public static let bottomRight = FractionalPoint(1.0, 1.0)
    
    /// Top-left corner.
    public static let topLeft = FractionalPoint(0.0, 0.0)
    
    /// Top edge center.
    public static let top = FractionalPoint(0.5, 0.0)
    
    /// Top-right corner.
    public static let topRight = FractionalPoint(1.0, 0.0)
    
    /// Top-left corner.
    public static let zero = FractionalPoint(0.0, 0.0)
    #endif
    
    var point: CGPoint {
        .init(x, y)
    }
}

extension CGRect {
    /// Converts the specified fractional point into an absolute point within the rectangle.
    public func point(for fractionalPoint: FractionalPoint) -> CGPoint {
        fractionalPoint.point(in: self)
    }
}

/// The Objective-C class for ``FractionalPoint``.
public class __FractionalPoint: NSObject, NSCopying {
    let point: FractionalPoint
    
    public init(point: FractionalPoint) {
        self.point = point
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        __FractionalPoint(point: point)
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        point == (object as? __FractionalPoint)?.point
    }
}

extension FractionalPoint: ReferenceConvertible {
    /// The Objective-C type for the configuration.
    public typealias ReferenceType = NSValue
    
    public func _bridgeToObjectiveC() -> NSValue {
        NSValue(point: point)
    }
    
    public static func _forceBridgeFromObjectiveC(_ source: NSValue, result: inout FractionalPoint?) {
        let source = source.pointValue
        result = FractionalPoint(source.x, source.y)
    }
    
    public static func _conditionallyBridgeFromObjectiveC(_ source: NSValue, result: inout FractionalPoint?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }
    
    public static func _unconditionallyBridgeFromObjectiveC(_ source: NSValue?) -> FractionalPoint {
        if let source = source {
            var result: FractionalPoint?
            _forceBridgeFromObjectiveC(source, result: &result)
            return result!
        }
        return FractionalPoint()
    }
    
    public var debugDescription: String {
        description
    }
}
