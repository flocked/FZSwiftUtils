//
//  File.swift
//  
//
//  Created by Florian Zand on 01.08.23.
//

import Foundation
import CoreGraphics

/// A structure that contains a optional x and y value of a point in a two-dimensional coordinate system.
public struct OptionalCGPoint {
    /// The x-coordinate of the point.
    public var x: CGFloat?
    /// The y-coordinate of the point.
    public var y: CGFloat?
    
    /// Creates a optional point with the specified x and y.
    public init(x: CGFloat? = nil, y: CGFloat? = nil) {
        self.x = x
        self.y = y
    }
    
    /// Creates a optional point with the specified x and y.
    public init(_ x: CGFloat?, _ y: CGFloat?) {
        self.x = x
        self.y = y
    }
    
    /// Creates a optional point with the specified point.
    public init(point: CGPoint?) {
        self.x = point?.x
        self.y = point?.y
    }
    
    /// Creates a optional point with the specified point.
    public init(_ point: CGPoint?) {
        self.x = point?.x
        self.y = point?.y
    }
    
    /// The point if `x` and `y` values aren't `nil`.
    public var unwrapped: CGPoint? {
        if let x = x, let y = y {
            return CGPoint(x, y)
        }
        return nil
    }
    
    /// The optional point with location (0,0).
    public static let zero = Self(0, 0)
}

/// A structure that contains optional width and height values.
public struct OptionalCGSize {
    /// A width value.
    public var width: CGFloat?
    /// A height value.
    public var height: CGFloat?
    
    /// Creates a optional size with the specified width and height.
    public init(width: CGFloat? = nil, height: CGFloat? = nil) {
        self.width = width
        self.height = height
    }
    
    /// Creates a optional size with the specified width and height.
    public init(_ width: CGFloat?, _ height: CGFloat?) {
        self.width = width
        self.height = height
    }
    
    /// Creates a optional size with the specified size.
    public init(size: CGSize?) {
        self.width = size?.width
        self.height = size?.height
    }
    
    /// Creates a optional size with the specified size.
    public init(_ size: CGSize?) {
        self.width = size?.width
        self.height = size?.height
    }
    
    /// The size if `width` and `height` values aren't `nil`.
    public var unwrapped: CGSize? {
        if let width = width, let height = height {
            return CGSize(width, height)
        }
        return nil
    }
    
    /// The optional size whose width and height are both zero.
    public static let zero = Self(0, 0)
}

public struct OptionCGRect {
    public var origin: OptionalCGPoint = OptionalCGPoint()
    public var size: OptionalCGSize = OptionalCGSize()
    
    /// Creates a optional rect with the specified origin and size values.
    public init(origin: OptionalCGPoint = OptionalCGPoint(), size: OptionalCGSize = OptionalCGSize()) {
        self.origin = origin
        self.size = size
    }
    
    /// Creates a optional rect with the specified origin and size values.
    public init(_ origin: OptionalCGPoint = OptionalCGPoint(), _ size: OptionalCGSize = OptionalCGSize()) {
        self.origin = origin
        self.size = size
    }
    
    /// Creates a optional rect with the specified origin and size values.
    public init(origin: CGPoint?, size: CGSize?) {
        self.origin = OptionalCGPoint(origin)
        self.size = OptionalCGSize(size)
    }
    
    /// Creates a optional rect with the specified origin and size values.
    public init(_ origin: CGPoint?, _ size: CGSize?) {
        self.origin = OptionalCGPoint(origin)
        self.size = OptionalCGSize(size)
    }
    
    /// The rectangle if both `origin` values and `size values aren't `nil`.
    public var unwrapped: CGRect? {
        if let origin = origin.unwrapped, let size = size.unwrapped {
          return CGRect(origin, size)
        }
        return nil
    }
    
    /// The optional rectangle whose origin and size are both zero.
    public static let zero = Self(.zero, .zero)
}

public extension CGSize {
    /**
     Scales the size to fit within the specified optional size while maintaining the aspect ratio.
     
     - Parameters:
        - size: The target size to fit the size within.
     
     - Returns: The scaled size that fits within the size while maintaining the aspect ratio.
     */
    func scaled(toFit size: OptionalCGSize) -> CGSize {
        switch (size.width, size.height) {
        case (.some(let width), .some(let height)):
            return self.scaled(toFit: CGSize(width, height))
        case (.some(let width), nil):
            return self.scaled(toWidth: width)
        case (nil, .some(let height)):
            return self.scaled(toHeight: height)
        case (nil, nil):
            return self
        }
    }
}

public extension CGRect {
    /**
     Returns a new rect scaled to fit the specified rect, anchored at the specified point.
     
     - Parameters:
        - rect: The target rect for scaling the rect to fit.
        - anchor: The anchor point for scaling. The default value is `CGPoint(x: 0.5, y: 0.5)`.
     
     - Returns: A new rect scaled to fit the specified rect, anchored at the specified point.
     */
    func scaled(toFit rect: OptionCGRect, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
        var newRect = self
        if let x = rect.origin.x {
            newRect.origin.x = x
        }
        if let y = rect.origin.y {
            newRect.origin.y = y
        }
        switch (rect.size.width, rect.size.height) {
        case (.some(let width), .some(let height)):
            newRect = newRect.scaled(toFit: CGSize(width, height), anchor: anchor)
        case (.some(let width), nil):
            newRect = newRect.scaled(toWidth: width, anchor: anchor)
        case (nil, .some(let height)):
            newRect = newRect.scaled(toHeight: height, anchor: anchor)
        case (nil, nil): break
        }
        return newRect
    }
}
