//
//  CGRect+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import CoreGraphics
import Foundation
#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

public extension CGRect {
    /// Creates a rectangle with  the specified values.
    init(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) {
        self.init(x: x, y: y, width: width, height: height)
    }
    
    /// Creates a rectangle with the specified origin and size.
    init(_ origin: CGPoint, _ size: CGSize) {
        self.init(origin: origin, size: size)
    }
    
    /// Creates a rectangle with the specified origin and a size of `zero`.
    init(_ origin: CGPoint) {
        self.init(origin: origin, size: .zero)
    }
    
    /// Creates a rectangle with the specified size and a origin of `zero`.
    init(_ size: CGSize) {
        self.init(origin: .zero, size: size)
    }
    
    /// Creates a rectangle with the specified origin and a size of `zero`.
    init(origin: CGPoint) {
        self.init(origin)
    }

    /// Creates a rectangle with the specified size and a origin of `zero`.
    init(size: CGSize) {
        self.init(size)
    }

    /// Creates a rectangle with the specified size and a origin of `zero`.
    init(size: CGFloat) {
        self.init(.zero, CGSize(size))
    }
    
    /**
     Creates a rectangle that spans between the specified points.
     
     - Parameters:
        - point1: The first point.
        - point2: The second point.
     */
    init(point1: CGPoint, point2: CGPoint) {
        self.init(x: min(point1.x, point2.x), y: min(point1.y, point2.y), width: abs(point1.x - point2.x), height: abs(point1.y - point2.y))        
    }

    /**
     Returns the scaled integral rectangle based on the current rectangle.
     
     The origin and size values are scaled based on the current device's screen scale.

     - Returns: The scaled integral rectangle.
     */
    var scaledIntegral: CGRect {
        CGRect(origin: origin.scaledIntegral, size: size.scaledIntegral)
    }
    
    #if os(macOS)
    /**
     Returns the scaled integral rectangle based on the current rectangle for the specfied screen.
     
     The origin and size values are scaled based on the screen's backing scale factor.

     - Parameter screen: The screen for scale.
     - Returns: The scaled integral rectangle.
     */
    func scaledIntegral(for screen: NSScreen) -> CGRect {
        CGRect(origin: origin.scaledIntegral(for: screen), size: size.scaledIntegral(for: screen))
    }
    
    /**
     Returns the scaled integral rectangle based on the current rectangle for the specfied view.
     
     The origin and size values are scaled based on the view's window backing scale factor.

     - Parameter view: The view for scale.
     */
    func scaledIntegral(for view: NSView) -> Self {
        guard let window = view.window else { return self }
        return scaledIntegral(for: window)
    }
    
    /**
     Returns the scaled integral rectangle based on the current rectangle for the specfied window.
     
     The origin and size values are scaled based on the window's backing scale factor.

     - Parameter window: The window for scale.
     */
    func scaledIntegral(for window: NSWindow) -> Self {
        CGRect(origin.scaledIntegral(for: window), size.scaledIntegral(for: window))
    }
    
    /**
     Returns the scaled integral rectangle based on the current rectangle for the specfied window.

     The origin and size values are scaled based on either the key, main or first visible window, or else the main screen and it's backing scale factor.
     
     - Parameter application: The application for the scale factor.
     */
    func scaledIntegral(for application: NSApplication) -> Self {
        CGRect(origin.scaledIntegral(for: application), size.scaledIntegral(for: application))
    }
    #endif

    /// The x-coordinate of the origin of the rectangle.
    var x: CGFloat {
        get { origin.x }
        set { origin = origin.xValue(newValue) }
    }

    /// The y-coordinate of the origin of the rectangle.
    var y: CGFloat {
        get { origin.y }
        set { origin = origin.yValue(newValue) }
    }

    /// A size centered that specifies the height and width of the rectangle. Changing this value keeps the rectangle centered.
    var sizeCentered: CGSize {
        get { size }
        set {
            let old = self
            size = newValue
            center = old.center
        }
    }

    /// The left edge of the rectangle.
    var left: CGFloat {
        get { origin.x }
        set { origin.x = newValue }
    }

    /// The right edge of the rectangle.
    var right: CGFloat {
        get { x + width }
        set { x = newValue - width }
    }

    #if canImport(UIKit)
        /// The top edge of the rectangle.
        var top: CGFloat {
            get { y }
            set { y = newValue }
        }

        /// The bottom edge of the rectangle.
        var bottom: CGFloat {
            get { y + height }
            set { y = newValue - height }
        }
    #else
        /// The top edge of the rectangle.
        var top: CGFloat {
            get { y + height }
            set { y = newValue - height }
        }

        /// The bottom edge of the rectangle.
        var bottom: CGFloat {
            get { y }
            set { y = newValue }
        }
    #endif

    /// The top-left point of the rectangle.
    var topLeft: CGPoint {
        get { CGPoint(x: left, y: top) }
        set { left = newValue.x; top = newValue.y }
    }

    /// The top-center point of the rectangle.
    var topCenter: CGPoint {
        get { CGPoint(x: centerX, y: top) }
        set { centerX = newValue.x; top = newValue.y }
    }

    /// The top-right point of the rectangle.
    var topRight: CGPoint {
        get { CGPoint(x: right, y: top) }
        set { right = newValue.x; top = newValue.y }
    }

    /// The center-left point of the rectangle.
    var centerLeft: CGPoint {
        get { CGPoint(x: left, y: centerY) }
        set { left = newValue.x; centerY = newValue.y }
    }

    /// The center point of the rectangle.
    var center: CGPoint {
        get { CGPoint(x: centerX, y: centerY) }
        set { centerX = newValue.x; centerY = newValue.y }
    }

    /// The center-right point of the rectangle.
    var centerRight: CGPoint {
        get { CGPoint(x: right, y: centerY) }
        set { right = newValue.x; centerY = newValue.y }
    }

    /// The bottom-left point of the rectangle.
    var bottomLeft: CGPoint {
        get { CGPoint(x: left, y: bottom) }
        set { left = newValue.x; bottom = newValue.y }
    }

    /// The bottom-center point of the rectangle.
    var bottomCenter: CGPoint {
        get { CGPoint(x: centerX, y: bottom) }
        set { centerX = newValue.x; bottom = newValue.y }
    }

    /// The bottom-right point of the rectangle.
    var bottomRight: CGPoint {
        get { CGPoint(x: right, y: bottom) }
        set { right = newValue.x; bottom = newValue.y }
    }

    /// The horizontal center of the rectangle.
    internal var centerX: CGFloat {
        get { midX }
        set { origin.x = newValue - width * 0.5 }
    }

    /// The vertical center of the rectangle.
    internal var centerY: CGFloat {
        get { midY }
        set { origin.y = newValue - height * 0.5 }
    }
    
    /// Returns the rectangle with the specified x-coordinate value.
    func xValue(_ value: CGFloat) -> CGRect {
        apply(value, to: \.x)
    }
    
    /// Returns the rectangle with the specified y-coordinate value.
    func yValue(_ value: CGFloat) -> CGRect {
        apply(value, to: \.y)
    }
    
    /// Returns the rectangle with the specified width.
    func width(_ value: CGFloat) -> CGRect {
        apply(value, to: \.size.width)
    }
    
    /// Returns the rectangle with the specified height.
    func height(_ value: CGFloat) -> CGRect {
        apply(value, to: \.size.height)
    }
    
    /// Returns the rectangle with the specified left value.
    func left(_ value: CGFloat) -> CGRect {
        apply(value, to: \.left)
    }
    
    /// Returns the rectangle with the right value.
    func right(_ value: CGFloat) -> CGRect {
        apply(value, to: \.right)
    }
    
    /// Returns the rectangle with the specified top value.
    func top(_ value: CGFloat) -> CGRect {
        apply(value, to: \.top)
    }
    
    /// Returns the rectangle with the specified bottom value.
    func bottom(_ value: CGFloat) -> CGRect {
        apply(value, to: \.bottom)
    }
    
    /// Returns the rectangle with the specified top-left point.
    func topLeft(_ value: CGPoint) -> CGRect {
        apply(value, to: \.topLeft)
    }
    
    /// Returns the rectangle with the specified top-center point.
    func topCenter(_ value: CGPoint) -> CGRect {
        apply(value, to: \.topCenter)
    }
    
    /// Returns the rectangle with the specified top-right point.
    func topRight(_ value: CGPoint) -> CGRect {
        apply(value, to: \.topRight)
    }
    
    /// Returns the rectangle with the specified center-left point.
    func centerLeft(_ value: CGPoint) -> CGRect {
        apply(value, to: \.centerLeft)
    }
    
    /// Returns the rectangle with the specified center point
    func center(_ value: CGPoint) -> CGRect {
        apply(value, to: \.center)
    }
    
    /// Returns the rectangle with the specified center-right point.
    func centerRight(_ value: CGPoint) -> CGRect {
        apply(value, to: \.centerRight)
    }
    
    /// Returns the rectangle with the specified bottom-left point.
    func bottomLeft(_ value: CGPoint) -> CGRect {
        apply(value, to: \.bottomLeft)
    }
    
    /// Returns the rectangle with the specified bottom-center point.
    func bottomCenter(_ value: CGPoint) -> CGRect {
        apply(value, to: \.bottomCenter)
    }
    
    /// Returns the rectangle with the specified bottom-right point.
    func bottomRight(_ value: CGPoint) -> CGRect {
        apply(value, to: \.bottomRight)
    }
    
    /// Returns the rectangle with the specified origin.
    func origin(_ origin: CGPoint) -> CGRect {
        apply(origin, to: \.origin)
    }
    
    /// Returns the rectangle with the specified size.
    func size(_ size: CGSize) -> CGRect {
        apply(size, to: \.size)
    }
    
    internal func apply<Value>(_ value: Value, to keyPath: WritableKeyPath<CGRect, Value>) -> Self {
        var rect = self
        rect[keyPath: keyPath] = value
        return rect
    }

    #if os(macOS)
    /**
     Adjusts a rectangle by the given edge insets.
     
     - Parameter insets: The edge insets to be applied to the adjustment.
     - Returns: This inline function increments the origin of rect and decrements the size of rect by applying the appropriate member values of the `NSEdgeInsets` structure.
     */
    func inset(by insets: NSUIEdgeInsets) -> CGRect {
        inset(by: NSDirectionalEdgeInsets(top: insets.top, leading: insets.left, bottom: insets.bottom, trailing: insets.right))
    }
    #endif
    
    /**
     Adjusts a rectangle by the given edge insets.
     
     - Parameter insets: The edge insets to be applied to the adjustment.
     - Returns: This inline function increments the origin of rect and decrements the size of rect by applying the appropriate member values of the `NSDirectionalEdgeInsets` structure.
     */
    func inset(by insets: NSDirectionalEdgeInsets) -> CGRect {
        var result = self
        result.origin.x += insets.leading
        result.origin.y += insets.bottom
        result.size.width -= (insets.leading + insets.trailing)
        result.size.height -= (insets.bottom + insets.top)
        return result
    }
    
    /**
     Returns a rectangle with a width that is smaller or larger than the source rectangle width, with the same center point.
     
     - Parameter dx: The x-coordinate value to use for adjusting the source rectangle. To create an inset rectangle, specify a positive value. To create a larger, encompassing rectangle, specify a negative value.
     */
    func insetBy(dx: CGFloat) -> CGRect {
        insetBy(dx: dx, dy: 0)
    }
    
    /**
     Returns a rectangle with a height that is smaller or larger than the source rectangle height, with the same center point.
     
     - Parameter dy: The y-coordinate value to use for adjusting the source rectangle. To create an inset rectangle, specify a positive value. To create a larger, encompassing rectangle, specify a negative value.
     */
    func insetBy(dy: CGFloat) -> CGRect {
        insetBy(dx: 0, dy: dy)
    }
    
    /**
     Returns a rectangle with an origin that is offset from that of the source rectangle.
     
     - Parameter dx: The offset value for the x-coordinate.
     */
    func offsetBy(dx: CGFloat) -> CGRect {
        offsetBy(dx: dx, dy: 0)
    }
    
    /**
     Returns a rectangle with an origin that is offset from that of the source rectangle.
     
     - Parameter dy: The offset value for the y-coordinate.
     */
    func offsetBy(dy: CGFloat) -> CGRect {
        offsetBy(dx: 0, dy: dy)
    }
    
    /**
     Returns a new rectangle expanded by the specified amount in the given edge directions.

     - Parameters:
        - edges: The edge directions in which to expand the rectangle.
        - amount: The amount by which to expand the rectangle.

     - Returns: A new rectangle expanded by the specified amount in the given edge directions.
     */
    func expand(_ edges: NSUIRectEdge, by amount: CGFloat) -> CGRect {
        expand(edges, to: CGSize(width: edges.contains(any: [.left, .right]) ? width + amount : width, height: edges.contains(any: [.bottom, .top]) ? height + amount : height))
    }
    
    /**
     Returns a new rectangle expanded to the specified size in the given edge directions.

     - Parameters:
        - edges: The edge directions in which to expand the rectangle.
        - amount: The size to which to expand the rectangle.

     - Returns: A new rectangle expanded to the specified size in the given edge directions.
     */
    func expand(_ edges: NSUIRectEdge, to size: CGSize) -> CGRect {
        var frame = self

        let widthDelta = size.width - frame.size.width
        if widthDelta != 0 {
            if edges.contains(.left) && edges.contains(.right) {
                frame.origin.x -= widthDelta / 2
                frame.size.width += widthDelta
            } else if edges.contains(.left) {
                frame.origin.x -= widthDelta
                frame.size.width += widthDelta
            } else if edges.contains(.right) {
                frame.size.width += widthDelta
            }
        }

        let heightDelta = size.height - frame.size.height
        if heightDelta != 0 {
            if edges.contains(.top) && edges.contains(.bottom) {
                #if os(macOS)
                frame.origin.y -= heightDelta / 2
                #else
                frame.origin.y -= heightDelta / 2
                #endif
                frame.size.height += heightDelta
            } else if edges.contains(.top) {
                #if os(macOS)
                frame.size.height += heightDelta
                #else
                frame.origin.y -= heightDelta
                frame.size.height += heightDelta
                #endif
            } else if edges.contains(.bottom) {
                #if os(macOS)
                frame.origin.y -= heightDelta
                frame.size.height += heightDelta
                #else
                frame.size.height += heightDelta
                #endif
            }
        }
        return frame
    }
    
    /**
     Divides the rectangle into rectangles by the specified amount and edge.
     
     - Parameters:
        - count:The amount of rects
        - edge: The side of the rectangle from which to divide the rectangle.
     */
    func divided(by count: Int, from edge: CGRectEdge) -> [CGRect] {
        let value = (edge.isHeight ? height : width) / CGFloat(count)
        return divided(by: value, count: count, from: edge)
    }
    
    /**
     Divides the rectangle into multiple rectangles of the specified size, starting from the given edge.

     This method returns an array of rectangles, each with a `width` or `height` equal to the specified value, depending on the division edge. The final rectangle may be smaller if the remaining space is less than the specified value.

     - Parameters:
        - value: The width or height of each rectangle, based on the division edge.
        - edge: The edge of the rectangle from which the division starts.

     - Returns: An array of rectangles resulting from the division.
     */
    func divided(byValue value: CGFloat, from edge: CGRectEdge) -> [CGRect] {
        guard value > 0.0 else { return [] }
        let total = edge.isHeight ? height : width
        let value = value.clamped(max: total)
        let count = Int(floor(total / value))
        return divided(by: value, count: count, from: edge)
    }
    
    /**
     Divides the rectangle into multiple rectangles based on the specified percentage, starting from the given edge.

     This method returns an array of rectangles, each with a `width` or `height` equal to the specified percentage of the original rectangle's corresponding dimension. The final rectangle may be smaller if the remaining space is less than the specified percentage.

     - Parameters:
        - percentage: The percentage of the rectangle's width or height to use for each division. Values should be between `0` and `1`.
        - edge: The edge of the rectangle from which the division starts.

     - Returns: An array of rectangles resulting from the division.
     */
    func divided(byPercentage percentage: CGFloat, from edge: CGRectEdge) -> [CGRect] {
        guard percentage > 0.0 else { return [] }
        let percentage = percentage.clamped(to: 0...1.0)
        let total = edge.isHeight ? height : width
        let value = total * percentage
        let count = Int(floor(total / value))
        return divided(by: value, count: count, from: edge)
    }
    
    /**
     Creates two rectangles by dividing the original rectangle.
     
     - Parameters:
        - percentage: The percentage of the rectangle's width or height to use for division. The value should be between `0` and `1`.
        - edge: The side of the rectangle from which to measure the atDistance parameter, defining the line along which to divide the rectangle.
     */
    func divided(atPercentage percentage: CGFloat, from edge: CGRectEdge) -> (slice: CGRect, remainder: CGRect) {
        divided(atDistance: edge.isHeight ? height : width * percentage.clamped(to: 0...1.0), from: edge)
    }
    
    internal func divided(by value: CGFloat, count: Int, from edge: CGRectEdge) -> [CGRect] {
        guard count > 0 else { return [] }
        var rect = self
        var rects = (1...count).map({ _ in
            let (slice, remainder) = rect.divided(atDistance: value, from: edge)
            rect = remainder
            return slice
        })
        rects.append(rect)
        return rects
    }

    /**
     Returns a new rectangle scaled by the specified factor, anchored at the specified point.

     - Parameters:
        - factor: The scaling factor to apply to the rectangle.
        - anchor: The anchor point for scaling. The default value is `CGPoint(x: 0.5, y: 0.5)`.

     - Returns: A new rectangle scaled by the specified factor, anchored at the specified point.
     */
    func scaled(byFactor factor: CGFloat, anchor: FractionalPoint = .bottomLeft) -> CGRect {
        let sizeDelta = size.scaled(byFactor: factor)
        return scaled(to: sizeDelta, anchor: anchor)
    }

    /**
     Returns a new rectangle scaled to the specified size, anchored at the specified point.

     - Parameters:
        - size: The target size for scaling the rectangle.
        - anchor: The anchor point for scaling. The default value is `CGPoint(x: 0.5, y: 0.5)`.

     - Returns: A new rectangle scaled to the specified size, anchored at the specified point.
     */
    func scaled(to size: CGSize, anchor: FractionalPoint = .bottomLeft) -> CGRect {
        let sizeDelta = CGSize(width: size.width - width, height: size.height - height)
        return CGRect(origin: CGPoint(x: minX - sizeDelta.width * anchor.x,
                                      y: minY - sizeDelta.height * anchor.y),
                      size: size)
    }

    /**
     Returns a new rectangle scaled to fit the specified size, anchored at the specified point.

     - Parameters:
        - size: The target size for scaling the rectangle to fit.
        - anchor: The anchor point for scaling. The default value is `CGPoint(x: 0.5, y: 0.5)`.

     - Returns: A new rectangle scaled to fit the specified size, anchored at the specified point.
     */
    func scaled(toFit size: CGSize, anchor: FractionalPoint = .bottomLeft) -> CGRect {
        let sizeDelta = self.size.scaled(toFit: size)
        return scaled(to: sizeDelta, anchor: anchor)
    }

    /**
     Returns a new rectangle scaled to fill the specified size, anchored at the specified point.

     - Parameters:
        - size: The target size for scaling the rectangle to fill.
        - anchor: The anchor point for scaling. The default value is `CGPoint(x: 0.5, y: 0.5)`.

     - Returns: A new rectangle scaled to fill the specified size, anchored at the specified point.
     */
    func scaled(toFill size: CGSize, anchor: FractionalPoint = .bottomLeft) -> CGRect {
        let sizeDelta = self.size.scaled(toFill: size)
        return scaled(to: sizeDelta, anchor: anchor)
    }

    /**
     Returns a new rectangle scaled to the specified width, anchored at the specified point.

     - Parameters:
        - width: The target width for scaling the rectangle.
        - anchor: The anchor point for scaling. The default value is `CGPoint(x: 0.5, y: 0.5)`.

     - Returns: A new rectangle scaled to the specified width, anchored at the specified point.
     */
    func scaled(toWidth width: CGFloat, anchor: FractionalPoint = .bottomLeft) -> CGRect {
        let sizeDelta = size.scaled(toWidth: width)
        return scaled(to: sizeDelta, anchor: anchor)
    }

    /**
     Returns a new rectangle scaled to the specified height, anchored at the specified point.

     - Parameters:
        - height: The target height for scaling the rectangle.
        - anchor: The anchor point for scaling. The default value is `CGPoint(x: 0.5, y: 0.5)`.

     - Returns: A new rectangle scaled to the specified height, anchored at the specified point.
     */
    func scaled(toHeight height: CGFloat, anchor: FractionalPoint = .bottomLeft) -> CGRect {
        let sizeDelta = size.scaled(toHeight: height)
        return scaled(to: sizeDelta, anchor: anchor)
    }

    /**
     Returns a new rectangle with rounded coordinates according to the specified rounding rule.

     - Parameters:
        - rule: The rounding rule to apply to the coordinates. The default value is `.toNearestOrAwayFromZero`.

     - Returns: A new rectangle with rounded coordinates according to the specified rounding rule.
     */
    func rounded(_ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> CGRect {
        CGRect(origin.rounded(rule), size.rounded(rule))
    }
    
    /// Clamps the rectangle to the specified minimum size.
    func clamped(minSize: CGSize) -> CGRect {
        CGRect(origin, size.clamped(min: minSize))
    }
    
    /// Clamps the rectangle to the specified maximum size.
    func clamped(maxSize: CGSize) -> CGRect {
        CGRect(origin, size.clamped(max: maxSize))
    }
    
    /**
     Clamps the rectangle to the specified minimum and maximum values.
     
     - Parameters:
        - minWidth: The minimum width needed.
        - minHeight: The minimum height needed.
        - maxWidth: The maximum width allowed.
        - maxHeight: The maximum height allowed.
     */
    func clamped(minWidth: CGFloat? = nil, minHeight: CGFloat? = nil, maxWidth: CGFloat? = nil, maxHeight: CGFloat? = nil) -> CGRect {
        CGRect(origin, size.clamped(minWidth: minWidth, minHeight: minHeight, maxWidth: maxWidth, maxHeight: maxHeight))
    }
    
    /**
     Returns the edge of the rectangle that contains the specified point within a given tolerance.

     This method determines if the provided point lies along any of the rectangle’s edges, considering the specified tolerance as a margin of error. If the point falls within this tolerance range near an edge, the corresponding edge is returned. If the point does not align with any edge within the tolerance, the method returns `nil`.
     
     If the point is within tolerance of multiple edges (e.g., near a corner), the method returns the first matching edge in the following order: `minYEdge`, `maxYEdge`, `minXEdge` and `maxXEdge`.

     - Parameters:
       - point: The point to evaluate.
       - tolerance: The maximum distance from an edge within which the point is considered to be contained by that edge. Must be a non-negative value.

     - Returns: The edge that contains the point within the specified tolerance, or `nil` if the point does not fall within the tolerance of any edge.
     */
    func edge(containing point: CGPoint, tolerance: CGFloat) -> CGRectEdge? {
        guard insetBy(dx: -tolerance, dy: -tolerance).contains(point) else { return nil }
        if point.y >= minY - tolerance && point.y <= minY + tolerance &&
            point.x >= minX - tolerance && point.x <= maxX + tolerance {
            return .minYEdge
        } else if point.y >= maxY - tolerance && point.y <= maxY + tolerance &&
            point.x >= minX - tolerance && point.x <= maxX + tolerance {
            return .maxYEdge
        } else if point.x >= minX - tolerance && point.x <= minX + tolerance &&
            point.y >= minY - tolerance && point.y <= maxY + tolerance {
            return .left
        } else if point.x >= maxX - tolerance && point.x <= maxX + tolerance &&
            point.y >= minY - tolerance && point.y <= maxY + tolerance {
            return .right
        }
        return nil
    }
    
    /**
     Returns the edge or corner of the rectangle that contains the specified point within a given tolerance.

     This method determines if the provided point lies on one of the rectangle's edges or corners, considering the specified tolerance as a margin of error. If the point is within the tolerance range of an edge or corner, the corresponding value is returned. If the point does not align with any edge or corner within the tolerance, the method returns `nil`.

     - Parameters:
       - point: The point to evaluate.
       - tolerance: The maximum distance from an edge or corner within which the point is considered to be contained by that edge or corner. Must be a non-negative value.

     - Returns: The edge or corner that contains the point within the specified tolerance, or `nil` if the point does not fall within the tolerance of any edge or corner.
     */
    func edgeOrCorner(containing point: CGPoint, tolerance: CGFloat) -> RectEdgeCorner? {
        edgeOrCorner(containing: point, tolerance: tolerance, cornerTolerance: tolerance)
    }
    
    /**
     Returns the edge or corner of the rectangle that contains the specified point within a given tolerance.

     This method determines if the provided point lies on one of the rectangle's edges or corners, considering the specified tolerance as a margin of error. If the point is within the tolerance range of an edge or corner, the corresponding value is returned. If the point does not align with any edge or corner within the tolerance, the method returns `nil`.

     - Parameters:
        - point: The point to evaluate.
       - tolerance: The maximum distance from an edge within which the point is considered to be contained by that edge. Must be a non-negative value.
        - cornerTolerance: The maximum distance from a corner within which the point is considered to be contained by that corner. Must be a non-negative value.

     - Returns: The edge or corner that contains the point within the specified tolerance, or `nil` if the point does not fall within the tolerance of any edge or corner.
     */
    func edgeOrCorner(containing point: CGPoint, tolerance: CGFloat, cornerTolerance: CGFloat) -> RectEdgeCorner? {
        if insetBy(dx: -cornerTolerance, dy: -cornerTolerance).contains(point) {
            if point.x >= minX - cornerTolerance && point.x <= minX + cornerTolerance {
                if point.y >= minY - cornerTolerance && point.y <= minY + cornerTolerance {
                    return .minXMinY
                } else if point.y >= maxY - cornerTolerance && point.y <= maxY + cornerTolerance {
                    return .minXMaxY
                }
            }
            if point.x >= maxX - cornerTolerance && point.x <= maxX + cornerTolerance {
                if point.y >= minY - cornerTolerance && point.y <= minY + cornerTolerance {
                    return .maxXMinY
                } else if point.y >= maxY - cornerTolerance && point.y <= maxY + cornerTolerance {
                    return .maxXMaxY
                }
            }
        }
        if insetBy(dx: -tolerance, dy: -tolerance).contains(point) {
            if point.y >= minY - tolerance && point.y <= minY + tolerance {
                return .minY
            } else if point.y >= maxY - tolerance && point.y <= maxY + tolerance {
                return .maxY
            } else if point.x >= minX - tolerance && point.x <= minX + tolerance {
                return .minX
            } else if point.x >= maxX - tolerance && point.x <= maxX + tolerance {
                return .maxX
            }
        }
        return nil
    }
}

public extension CGRect {
    /// The vertical order to split a rectangle.
    enum VerticalSplitOrder: Int  {
        /// Bottom to top.
        case bottomToTop
        /// Top to bottom.
        case topToBottom
        /// Towards the center.
        case towardsCenter
        /// Towards the edges.
        case towardsEdges
        /// Random order.
        case random
    }
    
    /// The horizontal order to split a rectangle.
    enum HorizontalSplitOrder: Int {
        /// Left to right.
        case leftToRight
        /// Right to left.
        case rightToLeft
        /// Towards the center.
        case towardsCenter
        /// Towards the edges.
        case towardsEdges
        /// Random order.
        case random
    }
    /*
    /**
     Splits the rectangle to the specified vertical and horizontal amount of rectangles.
     
     - Parameters:
     - horizontalAmount: The amount of horizontal rectangles.
     - verticalAmount: The amount of vertical rectangles.
     - horizontalOrder: The horizontal order of the rectangles.
     - verticalOrder: The vertical order of the rectangles.
     
     - Returns: An array with the divided rectangles.
     */
    func splitted(horizontalAmount: Int, horizontalOrder: HorizontalSplitOrder = .leftToRight, verticalAmount: Int = 1, verticalOrder: VerticalSplitOrder = .bottomToTop) -> [CGRect] {
        splitted(by: CGSize(size.width / CGFloat(horizontalAmount), size.height / CGFloat(verticalAmount)), horizontalOrder: horizontalOrder, verticalOrder: verticalOrder)
    }
    
    func splitted(verticalAmount: Int, verticalOrder: VerticalSplitOrder = .bottomToTop) -> [CGRect] {
        splitted(horizontalAmount: 1, verticalAmount: verticalAmount, verticalOrder: verticalOrder)
    }
    
    func splitted(_ amount: SplitAmount, horizontalOrder: HorizontalSplitOrder = .leftToRight, verticalOrder: VerticalSplitOrder = .bottomToTop) {
        splitted(.both(5) )
    }
    
    func splitted(_ percentage: SplitPercentage, horizontalOrder: HorizontalSplitOrder = .leftToRight, verticalOrder: VerticalSplitOrder = .bottomToTop) {
        splitted(.both(5) )
    }
    */
    
    struct SplitPercentage: ExpressibleByFloatLiteral {
        /// The percentage of the width of each vertical split.
        public let vertical: CGFloat
        /// The percentage of the height of each horizontal split.
        public let horizontal: CGFloat
        
        /// Splits vertical by the specified percentage of the height.
        public static func vertical(_ percentage: CGFloat) -> Self {
            .init(vertical: percentage, horizontal: 1.0)
        }
        
        /// Splits horizontal by the specified percentage of the width..
        public static func horizontal(_ percentage: CGFloat) -> Self {
            .init(vertical: 1.0, horizontal: percentage)
        }
        
        /// Splits both vertical and horizontal by the specified percentage of the width and height.
        public static func both(_ percentage: CGFloat) -> Self {
            .init(vertical: percentage, horizontal: percentage)
        }
        
        /**
         Splits vertical and horizontal by the specified percentages.
         
         - Parameters:
            - vertical: The vertical split percentage of the height.
            - horizontal: The horizontal split percentage of the width.
         */
        public init(vertical: CGFloat, horizontal: CGFloat) {
            self.vertical = vertical.clamped(to: 0...1.0)
            self.horizontal = horizontal.clamped(to: 0...1.0)
        }
        
        /// Splits both vertical and horizontal by the specified percentage of the width and height.
        public init(floatLiteral value: Double) {
            self.init(vertical: value, horizontal: value)
        }
    }
    
    struct SplitOption: ExpressibleByIntegerLiteral {
        enum Option {
            case size(CGSize)
            case amount(vertical: Int, horizontal: Int)
            case percebtage(vertical: CGFloat, horizontal: CGFloat)
        }
        let option: Option
        
        func splitSize(for rect: CGRect) -> CGSize {
            switch option {
            case .size(let size):
                return size
            case .amount(let vertical, let horizontal):
                return .init(rect.width/CGFloat(horizontal), rect.height/CGFloat(vertical))
            case .percebtage(let vertical, let horizontal):
                return .init(rect.size.width*horizontal.clamped(to: 0...1.0), rect.size.height*vertical.clamped(to: 0...1.0))
            }
        }
        
        init(_ option: Option) {
            self.option = option
        }
        
        public init(integerLiteral value: Int) {
            self.init(.amount(vertical: value, horizontal: value))
        }
        
        public static func vertical(by amount: Int) -> Self {
            .init(.amount(vertical: amount, horizontal: 1))
        }
        
        public static func vertical(relative size: CGFloat) -> Self {
            .init(.percebtage(vertical: size, horizontal: 1.0))
        }
        
        public static func vertical(absolute size: CGFloat) -> Self {
            .init(.size(CGSize(-1, size)))
        }
        
        public static func horizontal(by amount: Int) -> Self {
            .init(.amount(vertical: 1, horizontal: amount))
        }
        
        public static func horizontal(relative size: CGFloat) -> Self {
            .init(.percebtage(vertical: 1.0, horizontal: size))
        }
        
        public static func horizontal(absolute size: CGFloat) -> Self {
            .init(.size(CGSize(size, -1)))
        }
        
        public static func both(by amount: Int) -> Self {
            .init(.amount(vertical: amount, horizontal: amount))
        }
        
        public static func both(relative size: CGFloat) -> Self {
            .init(.percebtage(vertical: size, horizontal: size))
        }
        
        public static func both(absolute size: CGFloat) -> Self {
            .init(.size(CGSize(size, size)))
        }
        
        /*
        public static func amount(vertical: Int, horizontal: Int = 1) -> Self {
            .init(.amount(vertical: vertical, horizontal: horizontal))
        }
        
        public static func amount(horizontal: Int) -> Self {
            .init(.amount(vertical: 1, horizontal: horizontal))
        }
        
        public static func amount(_ amount: Int) -> Self {
            .init(.amount(vertical: amount, horizontal: amount))
        }
        
        public static func percentage(vertical: CGFloat, horizontal: CGFloat = 1.0) -> Self {
            .init(.percebtage(vertical: vertical, horizontal: horizontal))
        }
        
        public static func percentage(horizontal: CGFloat) -> Self {
            .init(.percebtage(vertical: 1.0, horizontal: horizontal))
        }
        
        public static func percentage(_ percentage: CGFloat) -> Self {
            .init(.percebtage(vertical: percentage, horizontal: percentage))
        }
        
        public static func size(vertical: CGFloat) -> Self {
            .init(.size(.init(-1, vertical)))
        }
        
        public static func size(horizontal: CGFloat) -> Self {
            .init(.size(.init(horizontal, -1)))
        }
        
        public static func size(_ size: CGSize) -> Self {
            .init(.size(size))
        }
         */
        
    }
    
    struct SplitAmount: ExpressibleByIntegerLiteral {
        /// The amount of vertical splits.
        public let vertical: Int
        /// The amount of horizontal splits.
        public let horizontal: Int
        
        /// Splits vertical by the specified amount.
        public static func vertical(_ amount: Int) -> Self {
            .init(vertical: amount, horizontal: 1)
        }
        
        /// Splits horizontal by the specified amount.
        public static func horizontal(_ amount: Int) -> Self {
            .init(vertical: 1, horizontal: amount)
        }
        
        /// Splits both vertical and horizontal by the specified amount.
        public static func both(_ amount: Int) -> Self {
            .init(vertical: amount, horizontal: amount)
        }
        
        /// Splits by the specified vertical and horizontal  amount.
        public init(vertical: Int, horizontal: Int) {
            self.vertical = vertical
            self.horizontal = horizontal
        }
        
        /// Splits both vertical and horizontal by the specified amount.
        public init(integerLiteral value: Int) {
            self.init(vertical: value, horizontal: value)
        }
    }
    
    func splitted(_ option: SplitOption, horizontalOrder: HorizontalSplitOrder = .leftToRight, verticalOrder: VerticalSplitOrder = .bottomToTop) -> [CGRect]  {
        splitted(by: option.splitSize(for: self), horizontalOrder: horizontalOrder, verticalOrder: verticalOrder)
    }
    
    /**
     Splits the rectangle into rectangles of the specified size.

     - Parameters:
        - size: The size of an split.
        - horizontalOrder: The horizontal order of the rectangles.
        - verticalOrder: The vertical order of the rectangles.
     
     - Returns: An array with the divided rectangles.
     */
    func splitted(by size: CGSize, horizontalOrder: HorizontalSplitOrder = .leftToRight, verticalOrder: VerticalSplitOrder = .bottomToTop) -> [CGRect] {
        
        var verticalCount = Int(height / size.height)
        var horizontalCount = Int(width / size.width)
                
        let remainingWidth = width - CGFloat(horizontalCount) * size.width
        let remainingHeight = height - CGFloat(verticalCount) * size.height
        if remainingWidth > 0.0 {
            horizontalCount += 1
        }
        if remainingHeight > 0.0 {
            verticalCount += 1
        }
        
        var splits: [CGRect] = []
        var hValues = (0..<horizontalCount).compactMap({CGFloat($0)})
        switch horizontalOrder {
        case .leftToRight: break
        case .rightToLeft:
            hValues = hValues.reversed()
        case .towardsCenter:
            hValues = hValues.reorderedTowardsCenter()
        case .towardsEdges:
            hValues = hValues.reorderedFromCenterOutwards()
        case .random:
            hValues = hValues.shuffled()
        }
        
        var vValues = (0..<verticalCount).compactMap({CGFloat($0)})
        switch verticalOrder {
        case .bottomToTop: break
        case .topToBottom:
            vValues = vValues.reversed()
        case .towardsCenter:
            vValues = vValues.reorderedTowardsCenter()
        case .towardsEdges:
            vValues = vValues.reorderedFromCenterOutwards()
        case .random:
            vValues = vValues.shuffled()
        }
        for vVal in vValues.enumerated() {
            for hVal in hValues.enumerated() {
                var size = size
                if hVal.offset == hValues.count-1, remainingWidth > 0.0 {
                    size.width = remainingWidth
                }
                if vVal.offset == vValues.count-1, remainingHeight > 0.0 {
                    size.height = remainingHeight
                }
                
                splits.append(CGRect(CGPoint(x: hVal.element * size.width, y: vVal.element * size.height), size))
            }
        }
        return splits
    }
    
    /// The distance of the rectangle to the specified point.
    func distance(to point: CGPoint) -> CGFloat {
        if contains(point) {
            return 0.0
        }
        let closestMaxY = CGPoint(x: min(max(point.x, origin.x), maxX), y: origin.y)
        let closestMinY = CGPoint(x: min(max(point.x, origin.x), maxX), y: maxY)
        let closestMinX = CGPoint(x: origin.x, y: min(max(point.y, origin.y), maxY))
        let closestMaxX = CGPoint(x: maxX, y: min(max(point.y, origin.y), maxY))
        return [closestMinX, closestMaxX, closestMinY, closestMaxY].compactMap({ point.distance(to: $0)}).min() ?? .infinity
      }
    
    /// The distance of the rectangle to the specified other rectangle.
    func distance(to rect: CGRect) -> CGFloat {
        intersects(rect) ? 0 : [bottomLeft, bottomCenter, bottomRight, topLeft, topCenter, topRight, centerLeft, centerRight].compactMap({ rect.distance(to: $0) }).min() ?? .infinity
     }
}

extension CGRect: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(size)
        hasher.combine(origin)
    }
}

public extension Collection where Element == CGRect {
    /// The union of all rectangles in the collection.
    func union() -> CGRect {
        return reduce(CGRect.zero) {$0.union($1)}
    }
    
    /// Returns the rectangle in the center.
    var centeredRect: CGRect? {
        sortedByDistance(to: union().center).first
    }
    
    /// Returns the index of the rectangle in the center.
    var indexOfCenteredRect: Index? {
        if let rect = centeredRect {
            return firstIndex(of: rect) ?? nil
        }
        return nil
    }
}

public extension Sequence where Element == CGRect {
    /// Returns the rectangles sorted by distance to the specified point.
    func sortedByDistance(to point: CGPoint, _ order: SequenceSortOrder = .smallestFirst) -> [CGRect] {
        compactMap({(rect: $0, distance: $0.distance(to: point)) }).sorted(by: \.distance, order).compactMap({$0.rect})
    }
    
    /// Returns the rectangles sorted by distance to the specified rectangle.
    func sortedByDistance(to rect: CGRect, _ order: SequenceSortOrder = .smallestFirst) -> [CGRect] {
        compactMap({(rect: $0, distance: $0.distance(to: rect)) }).sorted(by: \.distance, order).compactMap({$0.rect})
    }
    
    /// Returns the closed rectangle in the specified point.
    func closedRect(to point: CGPoint) -> CGRect? {
        sortedByDistance(to: point).first
    }
    
    /// Returns the closed rectangle in the specified other rectangle.
    func closedRect(to rect: CGRect) -> CGRect? {
        sortedByDistance(to: rect).first
    }
}

public extension CGRectEdge {
    /// The left edge of the rectangle.
    static let left: CGRectEdge = .minXEdge
    /// The right edge of the rectangle.
    static let right: CGRectEdge = .maxXEdge
    #if os(macOS)
    /// The bottom edge of the rectangle.
    static let bottom: CGRectEdge = .minYEdge
    /// The top edge of the rectangle.
    static let top: CGRectEdge = .maxYEdge
    #else
    /// The bottom edge of the rectangle.
    static let bottom: CGRectEdge = .maxYEdge
    /// The top edge of the rectangle.
    static let top: CGRectEdge = .minYEdge
    #endif
    
    internal var isHeight: Bool {
        self == .minYEdge || self == .maxYEdge
    }
}

public extension Collection where Element == CGRect {
    /// Aligns the rectangles vertically.
    func alignVertical(alignment: CGRect.HorizontalAlignment = .center) -> [CGRect] {
        if isEmpty || count == 1 { return Array(self) }
        let totalSize = CGSize(map({ $0.width }).max() ?? 0.0, map({ $0.height }).sum())
        var yOffset: CGFloat = 0
        return map({ rect in
            let xOrigin: CGFloat
            switch alignment {
            case .left: xOrigin = 0
            case .center: xOrigin = (totalSize.width - rect.width) / 2
            case .right: xOrigin = totalSize.width-rect.width
            }
            let frame = CGRect(CGPoint(xOrigin, yOffset), rect.size)
            yOffset += rect.height
            return frame
        })
    }
    
    /// Aligns the rectangles horizontally.
    func alignHorizontal(alignment: CGRect.VerticalAlignment = .center) -> [CGRect] {
        if isEmpty || count == 1 { return Array(self) }
        var xOffset: CGFloat = 0
        let totalSize = CGSize(map({ $0.width }).sum(), map({ $0.height }).max() ?? 0.0)
        return map({ rect in
            let yOrigin: CGFloat
            switch alignment {
            case .top: yOrigin = 0
            case .center: yOrigin = (totalSize.height - rect.height) / 2
            case .bottom: yOrigin = totalSize.height-rect.height
            }
            let frame = CGRect(CGPoint(xOffset, yOrigin), rect.size)
            xOffset += rect.width
            return frame
        })
    }
}

extension CGRect {
    /// The vertical alignment of rectangles.
    public enum VerticalAlignment: Int {
        /// bottom.
        case bottom
        /// Center.
        case center
        /// Top.
        case top
    }
    
    /// The horizontal alignment of rectangles.
    public enum HorizontalAlignment: Int {
        /// Left.
        case left
        /// Center.
        case center
        /// Right.
        case right
    }
}
