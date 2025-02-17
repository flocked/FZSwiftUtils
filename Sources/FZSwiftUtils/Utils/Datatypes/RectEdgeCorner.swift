//
//  RectEdgeCorner.swift
//
//
//  Created by Florian Zand on 01.12.24.
//

import Foundation

/// Edges and corners of a rectangle.
public struct RectEdgeCorner: OptionSet, CustomStringConvertible, Hashable, Codable {
    /// MinX.
    public static let minX = RectEdgeCorner(rawValue: 1 << 0)
    /// MaxX.
    public static let maxX = RectEdgeCorner(rawValue: 1 << 1)
    /// MinY.
    public static let minY = RectEdgeCorner(rawValue: 1 << 2)
    /// MinXMinY.
    public static let minXMinY = RectEdgeCorner(rawValue: 1 << 3)
    /// MaxXMinY.
    public static let maxXMinY = RectEdgeCorner(rawValue: 1 << 4)
    /// MaxY.
    public static let maxY = RectEdgeCorner(rawValue: 1 << 5)
    /// MinXMaxY.
    public static let minXMaxY = RectEdgeCorner(rawValue: 1 << 6)
    /// MaxXMaxY.
    public static let maxXMaxY = RectEdgeCorner(rawValue: 1 << 7)
    
    /// Left edge.
    public static let left = minX
    /// Right edge.
    public static let right = maxX
    #if os(macOS)
    /// Bottom edge.
    public static let bottom = minY
    /// Bottom-left corner
    public static let bottomLeft = minXMinY
    /// Bottom-right corner.
    public static let bottomRight = maxXMinY
    /// Top edge.
    public static let top = maxY
    /// Top-left corner.
    public static let topLeft = minXMaxY
    /// Top-right corner.
    public static let topRight = maxXMaxY
    #else
    /// Bottom edge.
    public static let bottom = maxY
    /// Bottom-left corner
    public static let bottomLeft = minXMaxY
    /// Bottom-right corner.
    public static let bottomRight = maxXMaxY
    /// Top edge.
    public static let top = minY
    /// Top-left corner.
    public static let topLeft = minXMinY
    /// Top-right corner.
    public static let topRight = maxXMinY
    #endif
    /// All corners.
    public static let corners: RectEdgeCorner = [.topLeft, .topRight, bottomLeft, .bottomRight]
    /// All edges.
    public static let edges: RectEdgeCorner = [.top, .bottom, .left, .right]
    /// All edges and corners.
    public static let all: RectEdgeCorner = [.topLeft, .topRight, bottomLeft, .bottomRight, .top, .bottom, .left, .right]
    /// No edges and corners.
    public static let none: RectEdgeCorner = []

    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    public var description: String {
        if self == .all {
            return "RectEdgeCorner.all"
        } else if self == .edges {
            return "RectEdgeCorner.edges"
        } else if self == .corners {
            return "RectEdgeCorner.corners"
        } else if self == .none {
            return "RectEdgeCorner.none"
        }
        
        var strings: [String] = []
        for element in elements() {
            switch element {
            case .top: strings += "top"
            case .bottom: strings += "bottom"
            case .left: strings += "left"
            case .right: strings += "right"
            case .topLeft: strings += "topLeft"
            case .topRight: strings += "topRight"
            case .bottomLeft: strings += "bottomLeft"
            case .bottomRight: strings += "bottomRight"
            default: break
            }
        }
        return "RectEdgeCorner[" + strings.sorted().joined(separator: ", ") + "]"
    }
}
