//
//  CGPoint+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import CoreGraphics
import Foundation
#if os(macOS)
    import AppKit
#endif

public extension CGPoint {
    /// Creates a point with the specified x and y value.
    init(_ x: CGFloat, _ y: CGFloat) {
        self.init(x: x, y: y)
    }

    /// Creates a point with the specified x and y value.
    init(_ xY: CGFloat) {
        self.init(x: xY, y: xY)
    }

    /**
     Returns a new CGPoint by offsetting the current point by the specified offset.

     - Parameters:
        - offset: The offset to be applied.
     */
    func offset(by offset: CGPoint) -> CGPoint {
        CGPoint(x: x + offset.x, y: y + offset.y)
    }

    /**
     Returns a new point by offsetting the current point by the specified value along the x- and y-axes.

     - Parameters:
        - value: The value to be added to the x-coordinate and y-coordinate of the current point.
     */
    func offset(by value: CGFloat) -> CGPoint {
        CGPoint(x: x + value, y: y + value)
    }

    /**
     Returns a new point by offsetting the current point along the x-axis by the specified value.

     - Parameter x: The value to be added to the x-coordinate of the current point.
     */
    func offset(x: CGFloat) -> CGPoint {
        CGPoint(x: self.x + x, y: y)
    }

    /**
     Returns a new point by offsetting the current point along the y-axis by the specified value.

     - Parameter y: The value to be added to the y-coordinate of the current point.
     */
    func offset(y: CGFloat) -> CGPoint {
        CGPoint(x: x, y: self.y + y)
    }

    /**
     Returns a new CGPoint by offsetting the current point by the specified values along the x and y axes.

     - Parameters:
        - x: The value to be added to the x-coordinate of the current point.
        - y: The value to be added to the y-coordinate of the current point.

     - Returns: The new CGPoint obtained by offsetting the current point by the specified values.
     */
    func offset(x: CGFloat = 0, y: CGFloat) -> CGPoint {
        CGPoint(x: self.x + x, y: self.y + y)
    }

    /**
     Returns the distance between the current point and the specified point.

     - Parameters:
        - point: The target CGPoint.

     - Returns: The distance between the current point and the specified point.
     */
    func distance(to point: CGPoint) -> CGFloat {
        let xdst = x - point.x
        let ydst = y - point.y
        return sqrt((xdst * xdst) + (ydst * ydst))
    }

    /**
     Returns the scaled integral point of the current CGPoint.
     
     The x and y values are scaled based on the current device's screen scale.

     - Returns: The scaled integral CGPoint.
     */
    var scaledIntegralhs: CGPoint {
        CGPoint(x: x.scaledIntegral, y: y.scaledIntegral)
    }
    
    #if os(macOS)
    /**
     Returns the scaled integral point of the current CGPoint for the specified screen.
     
     The x and y values are scaled based on the the screen scale.

     - Parameter screen: The screen for scale.
     - Returns: The scaled integral CGPoint.
     */
    func scaledIntegral(for screen: NSScreen) -> CGPoint {
        CGPoint(x: x.scaledIntegral(for: screen), y: y.scaledIntegral(for: screen))
    }
    #endif

    /**
     Returns a new CGPoint with rounded x and y values using the specified rounding rule.

     - Parameters:
        - rule: The rounding rule to be applied. The default value is `.toNearestOrAwayFromZero`.

     - Returns: The new CGPoint with rounded x and y values.
     */
    func rounded(_ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> CGPoint {
        CGPoint(x: x.rounded(rule), y: y.rounded(rule))
    }

    /// The point as `CGSize`, using the x-coordinate as width and y-coordinate as height.
    var size: CGSize {
        CGSize(x, y)
    }
    
    /// Returns the point with the specified x-coordinate value.
    func xValue(_ value: CGFloat) -> CGPoint {
        CGPoint(value, y)
    }
    
    /// Returns the point with the specified y-coordinate value.
    func yValue(_ value: CGFloat) -> CGPoint {
        CGPoint(x, value)
    }
}

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

public extension CGPoint {
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(lhs.x + rhs.x, lhs.y + rhs.y)
    }

    static func + (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(lhs.x + rhs, lhs.y + rhs)
    }

    static func + (lhs: CGPoint, rhs: Double) -> CGPoint {
        CGPoint(lhs.x + rhs, lhs.y + rhs)
    }

    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(lhs.x - rhs.x, lhs.y - rhs.y)
    }

    static func - (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(lhs.x - rhs, lhs.y - rhs)
    }

    static func - (lhs: CGPoint, rhs: Double) -> CGPoint {
        CGPoint(lhs.x - rhs, lhs.y - rhs)
    }

    static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }

    static func * (l: CGFloat, rhs: CGPoint) -> CGPoint {
        CGPoint(x: l * rhs.x, y: l * rhs.y)
    }

    static func * (lhs: CGPoint, rhs: Double) -> CGPoint {
        CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }

    static func * (lhs: Double, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs * rhs.x, y: lhs * rhs.y)
    }

    static func * (lhs: CGPoint, rhs: CGPoint) -> CGFloat {
        lhs.x * rhs.x + lhs.y * rhs.y
    }

    static func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }

    static func / (lhs: CGPoint, rhs: Double) -> CGPoint {
        CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }

    static func += (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs + rhs
    }

    static func += (lhs: inout CGPoint, rhs: Double) {
        lhs = lhs + rhs
    }

    static func += (lhs: inout CGPoint, rhs: CGFloat) {
        lhs = lhs + rhs
    }

    static func -= (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs - rhs
    }

    static func -= (lhs: inout CGPoint, rhs: Double) {
        lhs = lhs - rhs
    }

    static func -= (lhs: inout CGPoint, rhs: CGFloat) {
        lhs = lhs - rhs
    }

    static func *= (lhs: inout CGPoint, rhs: CGFloat) {
        lhs = lhs * rhs
    }

    static func *= (lhs: inout CGPoint, rhs: Double) {
        lhs = lhs * rhs
    }
    
    static func /= (lhs: inout CGPoint, rhs: CGFloat) {
        lhs = lhs / rhs
    }

    static func /= (lhs: inout CGPoint, rhs: Double) {
        lhs = lhs / rhs
    }
}

public extension Collection where Element == CGPoint {
    /// Returns the point with the smallest distance to the specified point.
    func closed(to point: CGPoint) -> CGPoint? {
        compactMap({(point: $0, distance: $0.distance(to: point ))}).sorted(by: \.distance, .smallestFirst).first?.point
    }
}
