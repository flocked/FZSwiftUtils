//
//  RectEdge.swift
//
//
//  Created by Florian Zand on 03.04.24.
//

#if os(macOS)
import Foundation

public struct RectEdge: OptionSet {
    /// The top edge of the rectangle.
    public static var top = RectEdge(rawValue: 1 << 0)
    /// The left edge of the rectangle.
    public static var left = RectEdge(rawValue: 1 << 1)
    /// The bottom edge of the rectangle.
    public static var bottom = RectEdge(rawValue: 1 << 2)
    /// The right edge of the rectangle.
    public static var right = RectEdge(rawValue: 1 << 3)
    /// All edges of the rectangle.
    public static var all: RectEdge = [.left, .right, .bottom, .top]
    
    /// Creates an edges structure with the specified raw value.
    public init(rawValue: Int) { self.rawValue = rawValue }
    public let rawValue: Int
}

#endif
