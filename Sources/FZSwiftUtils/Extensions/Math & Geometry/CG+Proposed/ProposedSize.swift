
//
//  ProposedSize.swift
//
//
//  Created by Florian Zand on 20.09.22.
//

/*
import Foundation

/**
 A proposal for the size.
 */
public struct ProposedSize: Equatable, Hashable, Sendable {
    /**
     The proposed horizontal size measured in points.
     
     A value of `nil` represents an unspecified width proposal.
     */
    public var width: CGFloat?
    
    /**
     The proposed vertical size measured in points.
     
     A value of `nil` represents an unspecified height proposal.
     */
    public var height: CGFloat?
    
    /// The size, if `width` and `height` values aren't `nil`.
    public var unwrapped: CGSize? {
        if let width = width, let height = height {
            return CGSize(width, height)
        }
        return nil
    }
    
    /// A size proposal that contains zero in both dimensions.
    public static var zero: ProposedSize { .init(width: 0, height: 0) }
    
    /// A size proposal that proposesbBoth dimensions  to `nil`.
    public static var unspecified: ProposedSize { .init(width: nil, height: nil) }
    
    /**
     A size proposal that contains infinity in both dimensions.
     
     Both dimensions contain .infinity in this size proposal.
     */
    public static var infinity: ProposedSize { .init(width: .infinity, height: .infinity) }
    
    /**
     Creates a new proposed size using the specified width and height.
     
     - Parameter width: A proposed width. Use a value of `nil` to indicate that the width is unspecified for this proposal.
     - Parameter height: A proposed height. Use a value of `nil` to indicate that the height is unspecified for this proposal.
     */
    @inlinable public init(width: CGFloat?, height: CGFloat?) {
        self.width = width
        self.height = height
    }
    
    /**
     Creates a new proposed size using the specified width and height.
     
     - Parameter width: A proposed width. Use a value of `nil` to indicate that the width is unspecified for this proposal.
     - Parameter height: A proposed height. Use a value of `nil` to indicate that the height is unspecified for this proposal.
     */
    @inlinable public init(_ width: CGFloat?, _ height: CGFloat?) {
        self.width = width
        self.height = height
    }
    
    /**
     Creates a new proposed size using the specified size.
     
     - Parameter size: A proposed size. Use a value of `nil` to indicate that the `width` and `height` is unspecified for this proposal.
     */
    @inlinable public init(_ size: CGSize?) {
        width = size?.width
        height = size?.height
    }
}

public extension CGSize {
    /**
     Scales the size to fit within the specified proposed size while maintaining the aspect ratio.
     
     - Parameters:
        - size: The proposed size to fit the size within.
     
     - Returns: The scaled size that fits within the proposed size while maintaining the aspect ratio.
     */
    func scaled(toFit size: ProposedSize) -> CGSize {
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
*/
