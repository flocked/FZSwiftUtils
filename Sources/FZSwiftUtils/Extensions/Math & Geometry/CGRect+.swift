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
    /// Creates a rectangle with the specified values.
    init(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) {
        self.init(x: x, y: y, width: width, height: height)
    }
    
    /// Creates a rectangle with the specified origin and size.
    init(_ origin: CGPoint, _ size: CGSize) {
        self.init(origin: origin, size: size)
    }

    /// Creates a rectangle with the specified size.
    init(size: CGSize) {
        self.init(x: 0, y: 0, width: size.width, height: size.height)
    }

    /// Creates a rectangle with the specified size.
    init(size: CGFloat) {
        self.init(x: 0, y: 0, width: size, height: size)
    }

    /**
     Initializes a rectangle with the specified point and size.

     - Parameters:
        - point: The center point of the rectangle.
        - size: The size of the rectangle.
        - integralized: A Boolean value indicating whether the resulting rectangle should have integral values.

     - Returns: A new rectangle initialized with the specified parameters.
     */
    init(aroundPoint point: CGPoint, size: CGSize, integralized: Bool = false) {
        let unintegralizedRect = CGRect(x: point.x - size.width / 2.0, y: point.y - size.height / 2.0, width: size.width, height: size.height)
        let result = integralized ? unintegralizedRect.scaledIntegral : unintegralizedRect
        self.init(x: result.origin.x, y: result.origin.y, width: result.size.width, height: result.size.height)
    }

    /**
     Returns the scaled integral rectangle based on the current rectangle.
     
     The origin and size values are scaled based on the current device's screen scale.

     - Returns: The scaled integral rectangle.
     */
    var scaledIntegral: CGRect {
        CGRect(
            x: origin.x.scaledIntegral,
            y: origin.y.scaledIntegral,
            width: size.width.scaledIntegral,
            height: size.height.scaledIntegral
        )
    }
    
    #if os(macOS)
    /**
     Returns the scaled integral rectangle based on the current rectangle for the specfied screen.
     
     The origin and size values are scaled based on the screen scale.

     - Parameter screen: The screen for scale.
     - Returns: The scaled integral rectangle.
     */
    func scaledIntegral(for screen: NSScreen) -> CGRect {
        CGRect(
            x: origin.x.scaledIntegral(for: screen),
            y: origin.y.scaledIntegral(for: screen),
            width: size.width.scaledIntegral(for: screen),
            height: size.height.scaledIntegral(for: screen)
        )
    }
    #endif

    /// The x-coordinate of the origin of the rectangle.
    var x: CGFloat {
        get { origin.x }
        set {
            var origin = origin
            origin.x = newValue
            self.origin = origin
        }
    }

    /// The y-coordinate of the origin of the rectangle.
    var y: CGFloat {
        get { origin.y }
        set {
            var origin = origin
            origin.y = newValue
            self.origin = origin
        }
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
    
    internal func apply<Value>(_ value: Value, to keyPath: WritableKeyPath<CGRect, Value>) -> Self {
        var rect = self
        rect[keyPath: keyPath] = value
        return rect
    }

    /// Returns a rectangle that is smaller or larger than the source rectangle, with the same center point.
    func inset(by edgeInsets: NSUIEdgeInsets) -> CGRect {
        inset(by: NSDirectionalEdgeInsets(top: edgeInsets.top, leading: edgeInsets.left, bottom: edgeInsets.bottom, trailing: edgeInsets.right))
    }
    
    /// Returns a rectangle that is smaller or larger than the source rectangle, with the same center point.
    func inset(by edgeInsets: NSDirectionalEdgeInsets) -> CGRect {
        var result = self
        result.origin.x += edgeInsets.leading
        result.origin.y += edgeInsets.bottom
        result.size.width -= (edgeInsets.leading + edgeInsets.trailing)
        result.size.height -= (edgeInsets.bottom + edgeInsets.top)
        return result
    }
    
    /**
     Returns a rectangle with a width that is smaller or larger than the source rectangle width, with the same center point.
     
     - Parameter dx: The x-coordinate value to use for adjusting the source rectangle. To create an inset rectangle, specify a positive value. To create a larger, encompassing rectangle, specify a negative value.
     - Returns: A rectangle. The origin value is offset in the x-axis by the distance specified by the `dx` parameter, and its width adjusted by `(2*dx)`, relative to the source rectangle. If `dx` is a positive value, then the rectangle’s width is decreased. If `dx` is a negative value, the rectangle’s width is increased.
     */
    func insetBy(dx: CGFloat) -> CGRect {
        insetBy(dx: dx, dy: 0)
    }
    
    /**
     Returns a rectangle with a height that is smaller or larger than the source rectangle height, with the same center point.
     
     - Parameter dy: The y-coordinate value to use for adjusting the source rectangle. To create an inset rectangle, specify a positive value. To create a larger, encompassing rectangle, specify a negative value.
     - Returns: A rectangle. The origin value is offset in the y-axis by the distance specified by the `dy` parameter, and its height adjusted by `(2*dy)`, relative to the source rectangle. If `dy` is a positive value, then the rectangle’s height is decreased. If `dy` is a negative value, the rectangle’s height is increased.
     */
    func insetBy(dy: CGFloat) -> CGRect {
        insetBy(dx: 0, dy: dy)
    }
    
    /**
     Returns a new rectangle expanded by the specified amount in the given edge directions.

     - Parameters:
        - edges: The edge directions in which to expand the rectangle.
        - amount: The amount by which to expand the rectangle.

     - Returns: A new rectangle expanded by the specified amount in the given edge directions.
     */
    func expand(_ edges: NSUIRectEdge, by amount: CGFloat) -> CGRect {
        var frame = self
        if edges.contains([.left, .right]) {
            frame = CGRect(x: minX - (amount / 2.0), y: minY, width: width + amount, height: height)
        } else if edges.contains(.left) {
            frame = CGRect(x: minX - amount, y: minY, width: width + amount, height: height)
        } else if edges.contains(.right) {
            frame = CGRect(x: minX, y: minY, width: width + amount, height: height)
        }
        
        if edges.contains(.height) {
            return CGRect(x: frame.minX, y: frame.minY - (amount / 2.0), width: frame.width, height: frame.height + amount)
        } else if edges.contains(.bottom) {
            #if os(macOS)
            return CGRect(x: frame.minX, y: frame.minY - amount, width: frame.width, height: frame.height + amount)
            #else
            return CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height + amount)
            #endif
        } else if edges.contains(.top) {
            #if os(macOS)
            return CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height + amount)
            #else
            return CGRect(x: frame.minX, y: frame.minY - amount, width: frame.width, height: frame.height + amount)
            #endif
        }
        return frame
    }
    
    /**
     Returns a new rectangle scaled by the specified factor.

     - Parameters:
        - factor: The scaling factor to apply to the rectangle.
        - centered: A Boolean value indicating whether the scaling should be centered around the CGRect's center point. The default value is `true`.

     - Returns: A new rectangle scaled by the specified factor.
     */
    func scaled(byFactor factor: CGFloat, centered: Bool = true) -> CGRect {
        var rect = self
        rect.size = rect.size.scaled(byFactor: factor)
        if centered {
            rect.center = center
        }
        return rect
    }

    /**
     Returns a new rectangle scaled by the specified factor, anchored at the specified point.

     - Parameters:
        - factor: The scaling factor to apply to the rectangle.
        - anchor: The anchor point for scaling. The default value is `CGPoint(x: 0.5, y: 0.5)`.

     - Returns: A new rectangle scaled by the specified factor, anchored at the specified point.
     */
    func scaled(byFactor factor: CGFloat, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
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
    func scaled(to size: CGSize, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
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
    func scaled(toFit size: CGSize, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
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
    func scaled(toFill size: CGSize, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
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
    func scaled(toWidth width: CGFloat, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
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
    func scaled(toHeight height: CGFloat, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
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
        CGRect(x: x.rounded(rule), y: y.rounded(rule), width: width.rounded(rule), height: height.rounded(rule))
    }
    
    /// Clamps the rectangle to the specified minimum size.
    func clamped(minSize: CGSize) -> CGRect {
        CGRect(origin, size.clamped(minSize: minSize))
    }
    
    /// Clamps the rectangle to the specified maximum size.
    func clamped(maxSize: CGSize) -> CGRect {
        CGRect(origin, size.clamped(maxSize: maxSize))
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
    func centeredRect() -> CGRect? {
        return centeredRect(in: union().center)
    }
    
    /// Returns the rectangle in the center of the specified point.
    func centeredRect(in point: CGPoint) -> CGRect? {
        guard !isEmpty else { return nil }
        return compactMap({(rect: $0, distance: $0.center.distance(to: point)) }).sorted(by: \.distance, .smallestFirst).first?.rect
    }
    
    /// Returns the rectangle in the center of the specified rect.
    func centeredRect(in rect: CGRect) -> CGRect? {
        return centeredRect(in: rect.center)
    }
    
    /// Returns the index of the rectangle in the center.
    func indexOfCenteredRect() -> Index? {
        if let rect = centeredRect() {
            return firstIndex(of: rect) ?? nil
        }
        return nil
    }
    
    /// Returns the index of the rectangle in the center of the specified point.
    func indexOfCenteredRect(in point: CGPoint) -> Index? {
        if let rect = centeredRect(in: point) {
            return firstIndex(of: rect) ?? nil
        }
        return nil
    }
    
    /// Returns the  index of rectangle in the center of the specified rect.
    func indexOfCenteredRect(in rect: CGRect) -> Index? {
        if let rect = centeredRect(in: rect) {
            return firstIndex(of: rect) ?? nil
        }
        return nil
    }
}
