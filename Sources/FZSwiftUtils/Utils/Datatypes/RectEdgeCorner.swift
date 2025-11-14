//
//  RectEdgeCorner.swift
//
//
//  Created by Florian Zand on 01.12.24.
//

import Foundation

/// Edges and corners of a rectangle.
public struct RectEdgeCorner: OptionSet, CustomStringConvertible, Hashable, Codable {
    
    // MARK: - Edges

    /// Edge at minimum X.
    public static let minX = Self(rawValue: 1 << 0)
    /// Edge at maximum X.
    public static let maxX = Self(rawValue: 1 << 1)
    /// Edge at minimum Y.
    public static let minY = Self(rawValue: 1 << 2)
    /// Edge at maximum Y.
    public static let maxY = Self(rawValue: 1 << 3)
    
    /// Corner at minimum X and minimum Y.
    public static let minXminY = Self(rawValue: 1 << 4)
    /// Corner at maximum X and minimum Y.
    public static let maxXminY = Self(rawValue: 1 << 5)
    /// Corner at minimum X and maximum Y.
    public static let minXmaxY = Self(rawValue: 1 << 6)
    /// Corner at maximum X and maximum Y.
    public static let maxXmaxY = Self(rawValue: 1 << 7)
    
    /// Left edge.
    public static let left = minX
    /// Right edge.
    public static let right = maxX
    #if os(macOS)
    /// Bottom edge.
    public static let bottom = minY
    /// Bottom-left corner
    public static let bottomLeft = minXminY
    /// Bottom-right corner.
    public static let bottomRight = maxXminY
    /// Top edge.
    public static let top = maxY
    /// Top-left corner.
    public static let topLeft = minXmaxY
    /// Top-right corner.
    public static let topRight = maxXmaxY
    #else
    /// Bottom edge.
    public static let bottom = maxY
    /// Bottom-left corner
    public static let bottomLeft = minXmaxY
    /// Bottom-right corner.
    public static let bottomRight = maxXmaxY
    /// Top edge.
    public static let top = minY
    /// Top-left corner.
    public static let topLeft = minXminY
    /// Top-right corner.
    public static let topRight = maxXminY
    #endif
    /// All corners.
    public static let corners: Self = [.topLeft, .topRight, bottomLeft, .bottomRight]
    /// All edges.
    public static let edges: Self = [.top, .bottom, .left, .right]
    /// All edges and corners.
    public static let all: Self = [.topLeft, .topRight, bottomLeft, .bottomRight, .top, .bottom, .left, .right]
    /// No edges and corners.
    public static let none: Self = []

    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    public var description: String {
        var strings: [String] = []
        if contains(.topLeft) { strings += "topLeft" }
        if contains(.top) { strings += "top" }
        if contains(.topRight) { strings += "topRight" }
        if contains(.left) { strings += "left" }
        if contains(.right) { strings += "right" }
        if contains(.bottomLeft) { strings += "bottomLeft" }
        if contains(.bottom) { strings += "bottom" }
        if contains(.bottomRight) { strings += "bottomRight" }
        return "[" + strings.sorted().joined(separator: ", ") + "]"
    }
}
