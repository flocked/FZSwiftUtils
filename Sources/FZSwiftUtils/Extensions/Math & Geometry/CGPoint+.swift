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
    init(_ x: CGFloat, _ y: CGFloat) {
        self.init(x: x, y: y)
    }
    
    init(_ x: Int, _ y: Int) {
        self.init(x: x, y: y)
    }

    init(_ xY: CGFloat) {
        self.init(x: xY, y: xY)
    }
    
    init(_ xY: Int) {
        self.init(x: xY, y: xY)
    }

    /**
     Returns a new CGPoint by offsetting the current point by the specified offset.

     - Parameter offset: The offset to be applied.
     */
    @_disfavoredOverload
    func offset(by offset: CGPoint) -> CGPoint {
        offsetBy(x: offset.x, y: offset.y)
    }
    
    /**
     Returns a new point by offsetting the current point by the specified value along the x- and y-axes.

     - Parameters:
        - value: The value to be added to the x-coordinate and y-coordinate of the current point.
     */
    @_disfavoredOverload
    func offsetBy(_ amount: CGFloat) -> CGPoint {
        offsetBy(amount, amount)
    }

    /**
     Returns a new point by offsetting the current point along the x-axis by the specified value.

     - Parameter x: The value to be added to the x-coordinate of the current point.
     */
    @_disfavoredOverload
    func offsetBy(x: CGFloat) -> CGPoint {
        offsetBy(x, 0)
    }

    /**
     Returns a new point by offsetting the current point along the y-axis by the specified value.

     - Parameter y: The value to be added to the y-coordinate of the current point.
     */
    @_disfavoredOverload
    func offsetBy(y: CGFloat) -> CGPoint {
        offsetBy(0, y)
    }

    /**
     Returns a new CGPoint by offsetting the current point by the specified values along the x and y axes.

     - Parameters:
        - x: The value to be added to the x-coordinate of the current point.
        - y: The value to be added to the y-coordinate of the current point.

     - Returns: The new CGPoint obtained by offsetting the current point by the specified values.
     */
    @_disfavoredOverload
    func offsetBy(x: CGFloat, y: CGFloat) -> CGPoint {
        CGPoint(x: self.x + x, y: self.y + y)
    }
    
    /**
     Returns a new CGPoint by offsetting the current point by the specified values along the x and y axes.

     - Parameters:
        - x: The value to be added to the x-coordinate of the current point.
        - y: The value to be added to the y-coordinate of the current point.

     - Returns: The new CGPoint obtained by offsetting the current point by the specified values.
     */
    @_disfavoredOverload
    func offsetBy(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        offsetBy(x: x, y: y)
    }
    
    mutating func offset(by offset: CGPoint) {
        self = self.offset(by: offset)
    }
    
    mutating func offsetBy(x: CGFloat) {
        self = self.offsetBy(x: x)
    }
    
    mutating func offsetBy(y: CGFloat) {
        self = self.offsetBy(y: y)
    }
    
    mutating func offsetBy(x: CGFloat, y: CGFloat) {
        self = self.offsetBy(x: x, y: y)
    }
    
    mutating func offsetBy(_ x: CGFloat, _ y: CGFloat) {
        self = self.offsetBy(x: x, y: y)
    }
    
    mutating func offsetBy(_ amount: CGFloat) {
        self = self.offsetBy(amount)
    }

    /**
     Returns the distance between the current point and the specified point.

     - Parameters:
        - point: The target CGPoint.

     - Returns: The distance between the current point and the specified point.
     */
    func distance(to point: CGPoint) -> CGFloat {
        hypot(x - point.x, y - point.y)
    }

    /**
     Returns the scaled integral point of the current point.
     
     The x and y values are scaled based on the current device's screen scale.

     - Returns: The scaled integral CGPoint.
     */
    var scaledIntegral: CGPoint {
        CGPoint(x: x.scaledIntegral, y: y.scaledIntegral)
    }
    
    #if os(macOS)
    /**
     Returns the scaled integral point of the current point for the specified screen.
     
     The x and y values are scaled based on the the screen scale.

     - Parameter screen: The screen for scale.
     */
    func scaledIntegral(for screen: NSScreen) -> CGPoint {
        CGPoint(x: x.scaledIntegral(for: screen), y: y.scaledIntegral(for: screen))
    }
    
    /**
     Returns the scaled integral point of the current point for the specified view.
     
     The x and y values are scaled based on the the view's screen scale.

     - Parameter view: The view for scale.
     */
    func scaledIntegral(for view: NSView) -> Self {
        guard let window = view.window else { return self }
        return scaledIntegral(for: window)
    }
    
    /**
     Returns the scaled integral point of the current point for the specified window.
     
     The x and y values are scaled based on the the window's screen scale.

     - Parameter window: The window for scale.
     */
    func scaledIntegral(for window: NSWindow) -> Self {
        CGPoint(x.scaledIntegral(for: window), y.scaledIntegral(for: window))
    }
    
    /**
     Returns the scaled integral point of the current point for the specified window.

     The x and y values are scaled based on either the key, main or first visible window, or else the main screen and it's backing scale factor.
     
     - Parameter application: The application for the scale factor.
     */
    func scaledIntegral(for application: NSApplication) -> Self {
        CGPoint(x.scaledIntegral(for: application), y.scaledIntegral(for: application))
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

extension CGPoint: Swift.Hashable {
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

    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(lhs.x - rhs.x, lhs.y - rhs.y)
    }

    static func - (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(lhs.x - rhs, lhs.y - rhs)
    }

    static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }

    static func * (l: CGFloat, rhs: CGPoint) -> CGPoint {
        CGPoint(x: l * rhs.x, y: l * rhs.y)
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

    static func += (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs + rhs
    }

    static func += (lhs: inout CGPoint, rhs: CGFloat) {
        lhs = lhs + rhs
    }

    static func -= (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs - rhs
    }

    static func -= (lhs: inout CGPoint, rhs: CGFloat) {
        lhs = lhs - rhs
    }

    static func *= (lhs: inout CGPoint, rhs: CGFloat) {
        lhs = lhs * rhs
    }
    
    static func /= (lhs: inout CGPoint, rhs: CGFloat) {
        lhs = lhs / rhs
    }
}

public extension Collection where Element == CGPoint {
    /// Returns the point with the smallest distance to the specified point.
    func closed(to point: CGPoint) -> CGPoint? {
        compactMap({(point: $0, distance: $0.distance(to: point ))}).sorted(by: \.distance, .smallestFirst).first?.point
    }
}

