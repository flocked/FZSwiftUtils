//
//  ProposedPoint.swift
//  
//
//  Created by Florian Zand on 01.08.23.
//

/*
import Foundation


/**
 A proposal for the point.
 */
public struct ProposedPoint: Equatable, Hashable, Sendable {
    
    /**
     The proposed x-coordinate of the point.
     
     A value of `nil` represents an unspecified x-coordinate proposal.
     */
    public var x: CGFloat?
    
    /**
     The proposed y-coordinate of the point.
     
     A value of `nil` represents an unspecified y-coordinate proposal.
     */
    public var y: CGFloat?
    
    /// The point, if `x` and `y` values aren't `nil`.
    public var unwrapped: CGPoint? {
        if let x = x, let y = y {
            return CGPoint(x, y)
        }
        return nil
    }
    
    /// A point proposal that contains zero in both coordinates.
    public static var zero: ProposedPoint { .init(x: 0, y: 0) }
    
    /**
    The proposed point with both coordinates left unspecified.
     
    Both coordinates contain `nil` in this size proposal.
     */
    public static var unspecified: ProposedPoint { .init(x: nil, y: nil) }
    
    /// A size proposal that contains infinity in both dimensions.
    ///
    
    /**
     Creates a new proposed origin using the specified x and y coordinate.
     
     - Parameter x: A proposed x-coordinate. Use a value of `nil` to indicate that the x is unspecified for this proposal.
     - Parameter y: A proposed y-coordinate. Use a value of `nil` to indicate that the y is unspecified for this proposal.
     */
    @inlinable public init(x: CGFloat?, y: CGFloat?) {
        self.x = x
        self.y = y
    }
    
    /**
     Creates a new proposed origin using the specified x and y coordinate.
     
     - Parameter x: A proposed x-coordinate. Use a value of `nil` to indicate that the x is unspecified for this proposal.
     - Parameter y: A proposed y-coordinate. Use a value of `nil` to indicate that the y is unspecified for this proposal.
     */
    @inlinable public init(_ x: CGFloat?, _ y: CGFloat?) {
        self.x = x
        self.y = y
    }
    
    /**
     Creates a new proposed point from the specified point.
     
     - Parameter point: A proposed point. Use a value of `nil` to indicate that the `x` and `y` is unspecified for this proposal.
     */
    @inlinable public init(_ point: CGPoint?) {
        x = point?.x
        y = point?.y
    }
}
*/
