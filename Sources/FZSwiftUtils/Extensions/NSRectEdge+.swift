//
//  NSRectEdge+.swift
//
//
//  Created by Florian Zand on 15.12.23.
//

#if os(macOS)
import Foundation

extension NSRectEdge {
    /// The bottom edge of the rectangle.
    public static let bottom = NSRectEdge.minY
    
    /// The right edge of the rectangle.
    public static let right = NSRectEdge.maxX
    
    /// The top edge of the rectangle.
    public static let top = NSRectEdge.maxY
    
    /// The left edge of the rectangle.
    public static let left = NSRectEdge.minX
}

#endif
