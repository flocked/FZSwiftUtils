//
//  CGRect+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import CoreGraphics
import Foundation

extension CGRect: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(size)
        hasher.combine(origin)
    }
}

public extension CGRect {
    init(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) {
        self.init(x: x, y: y, width: width, height: height)
    }

    init(_ origin: CGPoint, _ size: CGSize) {
        self.init(origin: origin, size: size)
    }

    init(size: CGSize) {
        self.init(x: 0, y: 0, width: size.width, height: size.height)
    }

    init(aroundPoint point: CGPoint, size: CGSize, integralized: Bool = false) {
        let unintegralizedRect = CGRect(x: point.x - size.width / 2.0, y: point.y - size.height / 2.0, width: size.width, height: size.height)
        let result = integralized ? unintegralizedRect.scaledIntegral : unintegralizedRect
        self.init(x: result.origin.x, y: result.origin.y, width: result.size.width, height: result.size.height)
    }

    var scaledIntegral: CGRect {
        CGRect(
            x: origin.x.scaledIntegral,
            y: origin.y.scaledIntegral,
            width: size.width.scaledIntegral,
            height: size.height.scaledIntegral
        )
    }

    var center: CGPoint {
        get { return CGPoint(x: centerX, y: centerY) }
        set { centerX = newValue.x; centerY = newValue.y }
    }

    var bottomLeft: CGPoint {
        get { return CGPoint(x: minX, y: minY) }
        set { origin = newValue }
    }

    var bottomRight: CGPoint { return CGPoint(x: maxX, y: minY) }

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

    var x: CGFloat {
        get { origin.x }
        set {
            var origin = self.origin
            origin.x = newValue
            self.origin = origin
        }
    }

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

    enum ExpandEdge {
        case minXEdge
        case maxXEdge
        case minYEdge
        case maxYEdge
        case centerWidth
        case centerHeight
        case center
    }

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

    func scaled(byFactor factor: CGFloat, centered: Bool = true) -> CGRect {
        var rect = self
        rect.size = rect.size.scaled(byFactor: factor)
        if centered {
            rect.center = center
        }
        return rect
    }

    func scaled(to size: CGSize, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
        let sizeDelta = CGSize(width: size.width - width, height: size.height - height)
        return CGRect(origin: CGPoint(x: minX - sizeDelta.width * anchor.x,
                                      y: minY - sizeDelta.height * anchor.y),
                      size: size)
    }

    func scaled(toFit size: CGSize, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
        let sizeDelta = self.size.scaled(toFit: size)
        return scaled(to: sizeDelta, anchor: anchor)
    }

    func scaled(toFill size: CGSize, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
        let sizeDelta = self.size.scaled(toFill: size)
        return scaled(to: sizeDelta, anchor: anchor)
    }

    func scaled(toWidth width: CGFloat, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
        let sizeDelta = size.scaled(toWidth: width)
        return scaled(to: sizeDelta, anchor: anchor)
    }

    func scaled(toHeight height: CGFloat, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
        let sizeDelta = size.scaled(toHeight: height)
        return scaled(to: sizeDelta, anchor: anchor)
    }

    func scaled(byFactor factor: CGFloat, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
        let sizeDelta = size.scaled(byFactor: factor)
        return scaled(to: sizeDelta, anchor: anchor)
    }

    func rounded(_ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> CGRect {
        return CGRect(x: x.rounded(rule), y: y.rounded(rule), width: width.rounded(rule), height: height.rounded(rule))
    }
}
