//
//  File.swift
//  
//
//  Created by Florian Zand on 01.08.23.
//

import Foundation
import CoreGraphics

/**
 A proposal for the rect.
 */
public struct ProposedRect: Equatable, Hashable, Sendable {
    /// The proposed point that specifies the coordinates of the rectangle’s origin.
    public var origin: ProposedPoint
    
    /// The proposed size that specifies the width and height of the rectangle.
    public var size: ProposedSize
    
    /// The rect, if  both `origin` and `size` values aren't `nil`.
    public var unwrapped: CGRect? {
        if let origin = origin.unwrapped, let size = size.unwrapped {
            return CGRect(origin, size)
        }
        return nil
    }
    
    /// A rect proposal that proposes a `zero` origin and `zero` size.
    public static var zero: ProposedRect { .init(.zero, .zero) }
    
    /// A rect proposal where rects origin and size values are `nil`.
    public static var unspecified: ProposedRect { .init(nil, nil) }
    
    /**
     Creates a new proposed rect using the specified origin and size.
     
     - Parameter origin: A proposed origin. Use a value of `nil` to indicate that the origin is unspecified for this proposal.
     - Parameter size: A proposed size. Use a value of `nil` to indicate that the size is unspecified for this proposal.
     */
    @inlinable public init(origin: CGPoint?, size: CGSize?) {
        self.origin = ProposedPoint(origin)
        self.size = ProposedSize(size)
    }
    
    /**
     Creates a new proposed rect using the specified origin and size.
     
     - Parameter origin: A proposed origin. Use a value of `nil` to indicate that the origin is unspecified for this proposal.
     - Parameter size: A proposed size. Use a value of `nil` to indicate that the size is unspecified for this proposal.
     */
    @inlinable public init(_ origin: CGPoint?, _ size: CGSize?) {
        self.origin = ProposedPoint(origin)
        self.size = ProposedSize(size)
    }
    
    /**
     Creates a new proposed rect using the specified rect.
     
     - Parameter rect: A proposed rect. Use a value of `nil` to indicate that the origin and size is unspecified for this proposal.
     */
    @inlinable public init(_ rect: CGRect?) {
        self.origin = ProposedPoint(rect?.origin)
        self.size = ProposedSize(rect?.size)
    }
}

public extension CGRect {
    /**
     Returns a new rect scaled to fit the specified proposed rect, anchored at the specified point.
     
     - Parameters:
        - rect: The proposed rect for scaling the rect to fit.
        - anchor: The anchor point for scaling. The default value is `CGPoint(x: 0.5, y: 0.5)`.
     
     - Returns: A new rect scaled to fit the specified proposed rect, anchored at the specified point.
     */
    func scaled(toFit rect: ProposedRect, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
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
