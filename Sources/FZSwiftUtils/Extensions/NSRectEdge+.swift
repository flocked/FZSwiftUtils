//
//  NSRectEdge+.swift
//
//
//  Created by Florian Zand on 15.12.23.
//

#if os(macOS)
import Foundation
import AppKit

extension NSRectEdge {
    /// The bottom edge of the rectangle.
    public static let bottom = NSRectEdge.minY
    
    /// The right edge of the rectangle.
    public static let right = NSRectEdge.maxX
    
    /// The top edge of the rectangle.
    public static let top = NSRectEdge.maxY
    
    /// The left edge of the rectangle.
    public static let left = NSRectEdge.minX
    
    /// The leading edge of the rectangle.
    public static var leading: NSRectEdge {
        NSApp.userInterfaceLayoutDirection == .leftToRight ? .left : .right
    }
    
    /// The trailing edge of the rectangle.
    public static var trailing: NSRectEdge {
        NSApp.userInterfaceLayoutDirection == .leftToRight ? .right : .left
    }
}

#endif
