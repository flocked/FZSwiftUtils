//
//  CGRect+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import CoreGraphics
import Foundation

public extension CGRect {
    /// Creates a rect with the specified values.
    init(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) {
        self.init(x: x, y: y, width: width, height: height)
    }

    /// Creates a rect with the specified origin and size.
    init(_ origin: CGPoint, _ size: CGSize) {
        self.init(origin: origin, size: size)
    }

    /// Creates a rect with the specified size.
    init(size: CGSize) {
        self.init(x: 0, y: 0, width: size.width, height: size.height)
    }
    
    /// Creates a rect with the specified size.
    init(size: CGFloat) {
        self.init(x: 0, y: 0, width: size, height: size)
    }

    /**
     Initializes a CGRect with the specified point and size.
     
     - Parameters:
        - point: The center point of the rectangle.
        - size: The size of the rectangle.
        - integralized: A Boolean value indicating whether the resulting CGRect should have integral values. The default value is `false`.
     
     - Returns: A new CGRect initialized with the specified parameters.
     */
    init(aroundPoint point: CGPoint, size: CGSize, integralized: Bool = false) {
        let unintegralizedRect = CGRect(x: point.x - size.width / 2.0, y: point.y - size.height / 2.0, width: size.width, height: size.height)
        let result = integralized ? unintegralizedRect.scaledIntegral : unintegralizedRect
        self.init(x: result.origin.x, y: result.origin.y, width: result.size.width, height: result.size.height)
    }

    /**
      Returns the scaled integral rect based on the current rect.
      The origin and size values are scaled based on the current device's screen scale.
      
      - Returns: The scaled integral rect.
      */
    var scaledIntegral: CGRect {
        CGRect(
            x: origin.x.scaledIntegral,
            y: origin.y.scaledIntegral,
            width: size.width.scaledIntegral,
            height: size.height.scaledIntegral
        )
    }

    /**
     The center point of the rect.
     The getter returns a point representing the center point, while the setter sets the origin based on the specified center point.
     */
    var center: CGPoint {
        get { return CGPoint(x: centerX, y: centerY) }
        set { centerX = newValue.x; centerY = newValue.y }
    }

    /**
     The bottom-left point of the rect.
     The getter returns a point representing the bottom-left point, while the setter sets the origin based on the specified bottom-left point.
     */
    var bottomLeft: CGPoint {
        get { return CGPoint(x: minX, y: minY) }
        set { origin = newValue }
    }

    /**
     The bottom-right point of the rect.
     The getter returns a point representing the bottom-right point.
     */
    var bottomRight: CGPoint { return CGPoint(x: maxX, y: minY) }

    /**
     The top-left point of the rect.
     The getter returns a point representing the top-left point, while the setter adjusts the origin and size to maintain the top-left position.
     */
    var topLeft: CGPoint {
        get { return CGPoint(x: minX, y: maxY) }
        set { origin = CGPoint(x: newValue.x, y: origin.y)
            let width = origin.y - newValue.y
            if width < 0 {
                origin = CGPoint(x: origin.x, y: origin.y - width)
            }
            size.width = origin.y + width
        }
    }

    /**
     The top-right point of the rect.
     The getter returns a point representing the top-right point, while the setter adjusts the origin and size to maintain the top-right position.
     */
    var topRight: CGPoint {
        get { return CGPoint(x: maxX, y: maxY) }
        set { origin = CGPoint(x: newValue.x, y: origin.y)
            let width = origin.y - newValue.y
            let height = origin.x - newValue.x
            if width < 0 {
                origin = CGPoint(x: origin.x, y: origin.y - width)
            }
            size.width = origin.y + width

            if height < 0 {
                origin = CGPoint(x: origin.x - height, y: origin.y)
            }
            size.height = origin.x + height
        }
    }

    private var centerX: CGFloat {
        get { return midX }
        set { origin.x = newValue - width * 0.5 }
    }

    private var centerY: CGFloat {
        get { return midY }
        set { origin.y = newValue - height * 0.5 }
    }

    /**
     The x-coordinate of the origin of the rect.
     The getter returns the x-coordinate of the origin, while the setter updates the x-coordinate of the origin.
     */
    var x: CGFloat {
        get { origin.x }
        set {
            var origin = self.origin
            origin.x = newValue
            self.origin = origin
        }
    }

    /**
     The y-coordinate of the origin of the rect.
     The getter returns the y-coordinate of the origin, while the setter updates the y-coordinate of the origin.
     */
    var y: CGFloat {
        get { origin.y }
        set {
            var origin = self.origin
            origin.y = newValue
            self.origin = origin
        }
    }

    /*
     var width: CGFloat {
         get { self.size.width }
         set {
             var size = self.size
             size.width = newValue
             self.size = size }
     }

      var height: CGFloat {
         get { self.size.height }
         set {
             var size = self.size
             size.height = newValue
             self.size = size }
     }
     */

    /// The edge direction used for expanding a rect.
    enum ExpandEdge {
        case minXEdge
        case maxXEdge
        case minYEdge
        case maxYEdge
        case centerWidth
        case centerHeight
        case center
    }

    /**
     Returns a new rect expanded by the specified amount in the given edge direction.
     
     - Parameters:
        - amount: The amount by which to expand the rect.
        - edge: The edge direction in which to expand the rect.
     
     - Returns: A new rect expanded by the specified amount in the given edge direction.
     */
    func expanded(_ amount: CGFloat, edge: ExpandEdge) -> CGRect {
        switch edge {
        case .minXEdge:
            return CGRect(x: minX - amount, y: minY, width: width + amount, height: height)
        case .maxXEdge:
            return CGRect(x: minX, y: minY, width: width + amount, height: height)
        case .minYEdge:
            return CGRect(x: minX, y: minY - amount, width: width, height: height + amount)
        case .maxYEdge:
            return CGRect(x: minX, y: minY, width: width, height: height + amount)
        case .center:
            let widthAmount = amount / 2.0
            let heightAmount = amount / 2.0
            return CGRect(x: minX - widthAmount, y: minY - heightAmount, width: width + widthAmount, height: height + heightAmount)
        case .centerWidth:
            let widthAmount = amount / 2.0
            return CGRect(x: minX - widthAmount, y: minY, width: width + widthAmount, height: height)
        case .centerHeight:
            let heightAmount = amount / 2.0
            return CGRect(x: minX, y: minY - heightAmount, width: width, height: height + heightAmount)
        }
    }

    /**
     Returns a new rect scaled by the specified factor.
     
     - Parameters:
        - factor: The scaling factor to apply to the rect.
        - centered: A Boolean value indicating whether the scaling should be centered around the CGRect's center point. The default value is `true`.
     
     - Returns: A new rect scaled by the specified factor.
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
     Returns a new rect scaled to the specified size, anchored at the specified point.
     
     - Parameters:
        - size: The target size for scaling the rect.
        - anchor: The anchor point for scaling. The default value is `CGPoint(x: 0.5, y: 0.5)`.
     
     - Returns: A new rect scaled to the specified size, anchored at the specified point.
     */
    func scaled(to size: CGSize, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
        let sizeDelta = CGSize(width: size.width - width, height: size.height - height)
        return CGRect(origin: CGPoint(x: minX - sizeDelta.width * anchor.x,
                                      y: minY - sizeDelta.height * anchor.y),
                      size: size)
    }

    /**
     Returns a new rect scaled to fit the specified size, anchored at the specified point.
     
     - Parameters:
        - size: The target size for scaling the rect to fit.
        - anchor: The anchor point for scaling. The default value is `CGPoint(x: 0.5, y: 0.5)`.
     
     - Returns: A new rect scaled to fit the specified size, anchored at the specified point.
     */
    func scaled(toFit size: CGSize, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
        let sizeDelta = self.size.scaled(toFit: size)
        return scaled(to: sizeDelta, anchor: anchor)
    }

    /**
      Returns a new rect scaled to fill the specified size, anchored at the specified point.
      
      - Parameters:
         - size: The target size for scaling the rect to fill.
         - anchor: The anchor point for scaling. The default value is `CGPoint(x: 0.5, y: 0.5)`.
      
      - Returns: A new rect scaled to fill the specified size, anchored at the specified point.
      */
    func scaled(toFill size: CGSize, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
        let sizeDelta = self.size.scaled(toFill: size)
        return scaled(to: sizeDelta, anchor: anchor)
    }

    /**
     Returns a new rect scaled to the specified width, anchored at the specified point.
     
     - Parameters:
        - width: The target width for scaling the rect.
        - anchor: The anchor point for scaling. The default value is `CGPoint(x: 0.5, y: 0.5)`.
     
     - Returns: A new rect scaled to the specified width, anchored at the specified point.
     */
    func scaled(toWidth width: CGFloat, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
        let sizeDelta = size.scaled(toWidth: width)
        return scaled(to: sizeDelta, anchor: anchor)
    }

    /**
     Returns a new rect scaled to the specified height, anchored at the specified point.
     
     - Parameters:
        - height: The target height for scaling the rect.
        - anchor: The anchor point for scaling. The default value is `CGPoint(x: 0.5, y: 0.5)`.
     
     - Returns: A new rect scaled to the specified height, anchored at the specified point.
     */
    func scaled(toHeight height: CGFloat, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
        let sizeDelta = size.scaled(toHeight: height)
        return scaled(to: sizeDelta, anchor: anchor)
    }

    /**
     Returns a new rect scaled by the specified factor, anchored at the specified point.
     
     - Parameters:
        - factor: The scaling factor to apply to the rect.
        - anchor: The anchor point for scaling. The default value is `CGPoint(x: 0.5, y: 0.5)`.
     
     - Returns: A new rect scaled by the specified factor, anchored at the specified point.
     */
    func scaled(byFactor factor: CGFloat, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
        let sizeDelta = size.scaled(byFactor: factor)
        return scaled(to: sizeDelta, anchor: anchor)
    }

    /**
     Returns a new rect with rounded coordinates according to the specified rounding rule.
     
     - Parameters:
        - rule: The rounding rule to apply to the coordinates. The default value is `.toNearestOrAwayFromZero`.
     
     - Returns: A new rect with rounded coordinates according to the specified rounding rule.
     */
    func rounded(_ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> CGRect {
        return CGRect(x: x.rounded(rule), y: y.rounded(rule), width: width.rounded(rule), height: height.rounded(rule))
    }
}

extension CGRect: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(size)
        hasher.combine(origin)
    }
}

extension Collection where Element == CGRect {
    /// The union of all rectangles in the collection.
    public func union() -> CGRect {
        var unionRect = CGRect.zero
        for rect in self {
            unionRect = NSUnionRect(unionRect, rect)
        }
        return unionRect
    }
}
