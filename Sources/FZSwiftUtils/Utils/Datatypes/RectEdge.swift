//
//  RectEdge.swift
//
//
//  Created by Florian Zand on 03.04.24.
//

#if os(macOS)
import Foundation

/**
 Constants that specify the edges of a rectangle.
 
 You can add these constants together to specify multiple edges at the same time.
 */
public struct RectEdge: OptionSet, CustomStringConvertible {
    /// The top edge of the rectangle.
    public static let top = Self(rawValue: 1 << 0)
    /// The left edge of the rectangle.
    public static let left = Self(rawValue: 1 << 1)
    /// The bottom edge of the rectangle.
    public static let bottom = Self(rawValue: 1 << 2)
    /// The right edge of the rectangle.
    public static let right = Self(rawValue: 1 << 3)
    /// All edges of the rectangle.
    public static let all: Self = [.left, .right, .bottom, .top]
    
    public var description: String {
        var strings: [String] = []
        if contains(.top) { strings.append(".top") }
        if contains(.bottom) { strings.append(".bottom") }
        if contains(.left) { strings.append(".left") }
        if contains(.right) { strings.append(".right") }
        return "[\(strings.joined(separator: ", "))]"
    }
    
    /// Creates an edges structure with the specified raw value.
    public init(rawValue: Int) { self.rawValue = rawValue }
    public let rawValue: Int
}

#endif
