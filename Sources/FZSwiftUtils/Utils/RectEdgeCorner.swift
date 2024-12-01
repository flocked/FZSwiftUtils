//
//  RectEdgeCorner.swift
//
//
//  Created by Florian Zand on 01.12.24.
//

import Foundation

/// Edges and corners of a rectangle.
public struct RectEdgeCorner: OptionSet, CustomStringConvertible, Hashable, Codable {
    
    /// Left edge.
    public static let left = RectEdgeCorner(rawValue: 1 << 0)
    /// Right edge.
    public static let right = RectEdgeCorner(rawValue: 1 << 1)
    /// Bottom edge.
    public static let bottom = RectEdgeCorner(rawValue: 1 << 2)
    /// Bottom-left corner
    public static let bottomLeft = RectEdgeCorner(rawValue: 1 << 3)
    /// Bottom-right corner.
    public static let bottomRight = RectEdgeCorner(rawValue: 1 << 4)
    /// Top edge.
    public static let top = RectEdgeCorner(rawValue: 1 << 5)
    /// Top-left corner.
    public static let topLeft = RectEdgeCorner(rawValue: 1 << 6)
    /// Top-right corner.
    public static let topRight = RectEdgeCorner(rawValue: 1 << 7)
    
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
